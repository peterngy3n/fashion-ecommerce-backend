const nodemailer = require('nodemailer');

async function sendConfirmationEmail(email, orderId) {
  const confirmLink = `http://localhost:3000/api/v1/orders/confirm/${orderId}/`;

    const transporter = nodemailer.createTransport({
        host: "smtp.gmail.com",
        port: 587,
        secure: false,
        auth: {
            user: 'nguyenphucthinh123pro@gmail.com',
            pass: 'ncvxppwdeeirtfmr'
        }
    });

    await transporter.sendMail({
        from: '"Shop Name" <your_email@gmail.com>',
        to: email,
        subject: 'Xác nhận đơn hàng',
        html: `<p>Vui lòng xác nhận đơn hàng của bạn bằng cách bấm vào liên kết sau:</p><a href="${confirmLink}">Xác nhận đơn hàng</a>`,
    });
}

module.exports = {
    sendConfirmationEmail,
};
