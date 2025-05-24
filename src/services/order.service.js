const { NotFoundException, BadRequest } = require('../errors/exception');
const prisma = require('../config/prisma.config');
const { sendConfirmationEmail } = require('./mailer.service');

exports.createOrder = async (data) => {
  const { user_id, email, items, shipping_address, billing_address } = data;

  return await prisma.$transaction(async (tx) => {
    let subtotal = 0;

    for (const item of items) {
      const inventory = await tx.productInventory.findFirst({
        where: { product_variant_id: item.variant_id },
        select: { quantity: true, reserved_quantity: true, version: true, store_id: true },
      });

      if (!inventory) throw new NotFoundException('Không tìm thấy tồn kho');
      const available = inventory.quantity - inventory.reserved_quantity;

      if (available < item.quantity) throw new Error(`Không đủ tồn kho cho biến thể`);

      // optimistic locking update
      const update = await tx.productInventory.updateMany({
        where: {
          product_variant_id: item.variant_id,
          store_id: inventory.store_id,
          version: inventory.version,
        },
        data: {
          reserved_quantity: { increment: item.quantity },
          version: { increment: 1 },
        },
      });

      if (update.count === 0) throw new Error('Xung đột tồn kho, vui lòng thử lại');

      await tx.inventoryReservation.create({
        data: {
          product_variant_id: item.variant_id,
          store_id: inventory.store_id,
          quantity: item.quantity,
          reservation_type: 'ORDER',
          reference_id: `ORD-${Date.now()}`,
          expires_at: new Date(Date.now() + 15 * 60 * 1000), // giữ trong 15 phút
        },
      });

      subtotal += item.unit_price * item.quantity;
    }

    const order = await tx.order.create({
      data: {
        order_number: 'ORD-' + Date.now(),
        user_id,
        subtotal,
        shipping_fee: 30000,
        total_amount: subtotal + 30000,
        shipping_address,
        billing_address,
        payment_method: 'MOCK',
        payment_status: 'PENDING',
        order_status: 'PROCESSING',
        version: 1,
        order_items: {
          create: items.map((item) => ({
            product_variant_id: item.variant_id,
            product_name: item.product_name,
            product_sku: item.product_sku,
            quantity: item.quantity,
            unit_price: item.unit_price,
            total_price: item.unit_price * item.quantity,
          })),
        },
      },
    });

    await sendConfirmationEmail(email, order.id);

    return { orderId: order.id, status: 'CREATED' };
  });
};

exports.simulatePayment = async (orderId) => {
  return await prisma.$transaction(async (tx) => {
    const order = await tx.order.findUnique({
      where: { id: orderId },
      include: { order_items: true },
    });

    if (!order) throw new Error('Không tìm thấy đơn hàng');
    if (order.payment_status !== 'PENDING') throw new Error('Đơn hàng đã thanh toán');

    for (const item of order.order_items) {
      const inventory = await tx.productInventory.findFirst({
        where: { product_variant_id: item.product_variant_id },
        select: { quantity: true, reserved_quantity: true, version: true, store_id: true },
      });

      if (!inventory) throw new Error('Không tìm thấy tồn kho');

      const update = await tx.productInventory.updateMany({
        where: {
          product_variant_id: item.product_variant_id,
          store_id: inventory.store_id,
          version: inventory.version,
        },
        data: {
          quantity: { decrement: item.quantity },
          reserved_quantity: { decrement: item.quantity },
          version: { increment: 1 },
        },
      });

      if (update.count === 0) throw new Error('Race condition trong tồn kho');

      await tx.inventoryReservation.deleteMany({
        where: {
          product_variant_id: item.variant_id,
          reference_id: orderId,
          expires_at: {
            gt: new Date()
          }
        }
      });
    }

    await tx.order.update({
      where: { id: orderId },
      data: {
        payment_status: 'PAID',
        order_status: 'CONFIRMED',
        payment_reference: 'MOCK_' + Date.now(),
      },
    });

    return order;
  });
};

exports.confirmOrder = async (orderId) => {
    console.log('Confirming order:', orderId);
    const orders = await prisma.order.findUnique({ where: { id: orderId } });
    if (!orders) throw new NotFoundException('Không tìm thấy đơn hàng');
    if (orders.order_status !== 'PROCESSING') throw new Error('Đơn đã xác nhận hoặc đã xử lý');
  
    await prisma.order.update({
      where: { id: orderId },
      data: {
        order_status: 'PENDING',
      },
    });
  
    return { orderId, status: 'CONFIRMED_AWAITING_PAYMENT' };
  };
