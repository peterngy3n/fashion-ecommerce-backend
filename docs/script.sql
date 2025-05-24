USE ecommerce
-- ================================================================================================
-- b. Create oder
-- Step 1: Define role and permission

INSERT INTO roles (name, description, created_at) VALUES
('admin', 'Administrator with full system access', '2025-05-24 13:52:44'),
('moderator', 'Moderator with limited administrative permissions', '2025-05-24 13:52:44'),
('customer', 'Regular customer role with basic shopping permissions', '2025-05-24 13:52:44')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO permissions (name, description, resource, action) VALUES
('order.create', 'Create new orders', 'order', 'create'),
('order.read', 'View orders', 'order', 'read'),
('order.update', 'Update orders', 'order', 'update'),
('order.delete', 'Delete orders', 'order', 'delete'),
('product.read', 'View products', 'product', 'read'),
('product.create', 'Create products', 'product', 'create'),
('cart.manage', 'Manage shopping cart', 'cart', 'manage'),
('user.read', 'View user profile', 'user', 'read'),
('user.update', 'Update user profile', 'user', 'update')
ON DUPLICATE KEY UPDATE description = VALUES(description);


INSERT INTO role_permissions (role_id, permission_id) VALUES
('customer', 'order.create'),
('customer', 'order.read'),
('customer', 'product.read'),
('customer', 'cart.manage'),
('customer', 'user.read'),
('customer', 'user.update');

-- Step2: Create new user account with customer role

SET @user_id = UUID();
INSERT INTO users (id, email, password_hash, first_name, 
phone, status, email_verified_at, created_at, updated_at)
VALUES (@user_id, 'thinhnp123@gmail.com', '$2a$10$UsnfiEdEGX0QJXPng7X1gueaihfKlD81j3b9/XaVYE8wKf9f0MHRC',
'assessment', '0328355333', 'ACTIVE', '2025-05-24 13:52:44', '2025-05-24 13:52:44', '2025-05-24 13:52:44')

INSERT INTO users (id, email, password_hash, first_name, 
phone, status, email_verified_at, created_at, updated_at)
VALUES (UUID(), 'admin123@gmail.com', '$2a$10$UsnfiEdEGX0QJXPng7X1gueaihfKlD81j3b9/XaVYE8wKf9f0MHRC',
'admin', '0328355333', 'ACTIVE', '2025-05-24 13:52:44', '2025-05-24 13:52:44', '2025-05-24 13:52:44')


INSERT INTO user_roles (user_id, role_id)
VALUES (@user_id, 'customer')
SHOW CREATE TABLE user_roles ;

-- Step 3: Create Product

--  Insert Category

SET @category_id = UUID()
SET @product_id = UUID();
SET @variant_id = UUID();
SET @store_id = UUID();
SET @order_id = UUID();
SET @current_time = NOW() 
INSERT INTO categories (id, name, slug, description, sort_order, is_active, created_at, updated_at)
VALUES (@category_id, 'Women\'s Shoes', 'womens-shoes', 'Women\'s footwear collection', 1, 1, @current_time, @current_time)


-- Insert product
INSERT INTO products (id, sku_code, price, name, slug, description, base_price, category_id, created_by, discount_percentage, is_active, created_at, updated_at)
VALUES (@product_id, 'KAPPA-WS-001', 980000, 'KAPPA Women\'s Sneakers', 'kappa-womens-sneakers', 'Comfortable and stylish women\'s sneakers from KAPPA brand', 980000, @category_id, @user_id, 0, 1, @current_time, @current_time)


-- Insert Product Variant
INSERT INTO product_variants (id, product_id, sku_code, price, quantity, created_at)
VALUES (@variant_id, @product_id, 'KAPPA-WS-001-YELLOW-36', 980000, 5, @current_time);

-- Insert Store
INSERT INTO stores (id, name, code, address, city, district, phone, is_active, created_at)
VALUES (@store_id, 'Main Store', 'MAIN_STORE', '123 Main Street', 'Ho Chi Minh City', 'District 1', '0123456789', 1, @current_time)

-- Query to create Order
-- ================================================================================================ 
-- Insert Order
INSERT INTO orders (id, order_number, user_id, subtotal, shipping_fee, discount_amount, total_amount, shipping_address, billing_address, payment_method, payment_status, notes, order_status, created_at, updated_at, version)
VALUES (
    @order_id,
    CONCAT('ORD', DATE_FORMAT(@current_time, '%Y%m%d%H%i%s'), UPPER(SUBSTRING(MD5(RAND()), 1, 6))),
    @user_id,
    980000,
    30000,
    0,
    1010000,
    JSON_OBJECT('name', 'assessment', 'phone', '328355333', 'province', 'Bắc Kạn', 'district', 'Ba Bể', 'commune', 'Phúc Lộc', 'address', '73 tân hoà 2', 'housing_type', 'nhà riêng'),
    JSON_OBJECT('name', 'assessment', 'phone', '328355333', 'province', 'Bắc Kạn', 'district', 'Ba Bể', 'commune', 'Phúc Lộc', 'address', '73 tân hoà 2', 'housing_type', 'nhà riêng'),
    'COD',
    'PENDING',
    'Order created on 2025-05-24 13:51:01 UTC by peterngy3n',
    'PENDING',
    @current_time,
    @current_time,
    1
);

-- Insert Order Item
INSERT INTO order_items (id, order_id, product_variant_id, product_name, product_sku, quantity, unit_price, discount_amount, total_price)
VALUES (UUID(), @order_id, @variant_id, 'KAPPA Women\'s Sneakers', 'KAPPA-WS-001-YELLOW-36', 1, 980000, 0, 980000);

-- ================================================================================================



-- ================================================================================================
-- c. 
-- Sử dụng DATE_FORMAT thay vì MONTHNAME để tránh GROUP BY error
SELECT 
    YEAR(created_at) as year,
    MONTH(created_at) as month,
    DATE_FORMAT(created_at, '%M') as month_name,
    COUNT(*) as total_orders,
    ROUND(AVG(total_amount), 2) as average_order_value,
    ROUND(MIN(total_amount), 2) as min_order_value,
    ROUND(MAX(total_amount), 2) as max_order_value,
    ROUND(SUM(total_amount), 2) as total_revenue
FROM orders 
WHERE YEAR(created_at) = 2025
    AND order_status NOT IN ('CANCELLED', 'RETURNED')
GROUP BY YEAR(created_at), MONTH(created_at), DATE_FORMAT(created_at, '%M')
ORDER BY YEAR(created_at), MONTH(created_at);

-- ================================================================================================
-- d. Churn rate
-- Set time periods based on current date: 2025-05-24 14:57:44
SET @current_date = '2025-05-24 14:57:44';
SET @last_6_months_start = DATE_SUB(@current_date, INTERVAL 6 MONTH);
SET @last_12_months_start = DATE_SUB(@current_date, INTERVAL 12 MONTH);

-- Main churn rate calculation query
SELECT 
    'Customer Churn Analysis' as analysis_type,
    @current_date as analysis_date,
    @last_12_months_start as period_12_months_ago,
    @last_6_months_start as period_6_months_ago,
    total_customers_6_12_months_ago,
    churned_customers,
    (total_customers_6_12_months_ago - churned_customers) as retained_customers,
    ROUND((churned_customers / total_customers_6_12_months_ago * 100), 2) as churn_rate_percentage,
    ROUND(((total_customers_6_12_months_ago - churned_customers) / total_customers_6_12_months_ago * 100), 2) as retention_rate_percentage
FROM (
    -- Count customers who purchased 6-12 months ago
    SELECT 
        COUNT(DISTINCT customers_6_12_months.user_id) as total_customers_6_12_months_ago,
        COUNT(DISTINCT customers_6_12_months.user_id) - COUNT(DISTINCT recent_customers.user_id) as churned_customers
    FROM (
        -- Customers who made purchases 6-12 months ago
        SELECT DISTINCT o.user_id
        FROM orders o
        WHERE o.created_at >= @last_12_months_start
            AND o.created_at < @last_6_months_start
            AND o.order_status NOT IN ('CANCELLED', 'RETURNED')
    ) customers_6_12_months
    LEFT JOIN (
        -- Customers who made purchases in last 6 months
        SELECT DISTINCT o.user_id
        FROM orders o
        WHERE o.created_at >= @last_6_months_start
            AND o.created_at <= @current_date
            AND o.order_status NOT IN ('CANCELLED', 'RETURNED')
    ) recent_customers ON customers_6_12_months.user_id = recent_customers.user_id
) churn_calculation;




INSERT INTO ecommerce.categories (id, name, slug, description, image_url, sort_order, is_active, created_at, updated_at)
VALUES 
  (UUID(), 'Balo', 'balo', 'Các loại balo', NULL, 1, true, NOW(), NOW()),
  (UUID(), 'Áo thun nam', 'ao-thun-nam', 'Áo thun thời trang dành cho nam', NULL, 2, true, NOW(), NOW());


-- Giày
INSERT INTO ecommerce.attributes (id, name, category_id)
VALUES 
  ('attr-size-shoe', 'Kích cỡ', '8031e875-38ac-11f0-b63c-0242ac110002'),
  ('attr-color-shoe', 'Màu sắc', '8031e875-38ac-11f0-b63c-0242ac110002');

-- Áo
INSERT INTO ecommerce.attributes (id, name, category_id)
VALUES 
  ('attr-size-shirt', 'Kích cỡ', '8054a891-38cb-11f0-b63c-0242ac110002'),
  ('attr-color-shirt', 'Màu sắc', '8054a891-38cb-11f0-b63c-0242ac110002'),
  ('attr-sleeve-type', 'Kiểu tay áo', '8054a891-38cb-11f0-b63c-0242ac110002');

-- Balo
INSERT INTO ecommerce.attributes (id, name, category_id)
VALUES 
  ('attr-capacity', 'Dung tích', '8054877b-38cb-11f0-b63c-0242ac110002'),
  ('attr-material', 'Chất liệu', '8054877b-38cb-11f0-b63c-0242ac110002');

-- Kích cỡ giày
INSERT INTO ecommerce.attribute_values (id, attribute_id, value)
VALUES 
  ('val-size-40', 'attr-size-shoe', '40'),
  ('val-size-41', 'attr-size-shoe', '41'),
  ('val-size-42', 'attr-size-shoe', '42');

-- Màu giày
INSERT INTO ecommerce.attribute_values (id, attribute_id, value)
VALUES 
  ('val-black', 'attr-color-shoe', 'Đen'),
  ('val-white', 'attr-color-shoe', 'Trắng');

-- Kích cỡ áo
INSERT INTO ecommerce.attribute_values (id, attribute_id, value)
VALUES 
  ('val-size-m', 'attr-size-shirt', 'M'),
  ('val-size-l', 'attr-size-shirt', 'L');

-- Màu áo
INSERT INTO ecommerce.attribute_values (id, attribute_id, value)
VALUES 
  ('val-blue', 'attr-color-shirt', 'Xanh'),
  ('val-red', 'attr-color-shirt', 'Đỏ');

-- Kiểu tay áo
INSERT INTO ecommerce.attribute_values (id, attribute_id, value)
VALUES 
  ('val-short', 'attr-sleeve-type', 'Tay ngắn'),
  ('val-long', 'attr-sleeve-type', 'Tay dài');

-- Dung tích balo
INSERT INTO ecommerce.attribute_values (id, attribute_id, value)
VALUES 
  ('val-20l', 'attr-capacity', '20L'),
  ('val-30l', 'attr-capacity', '30L');

-- Chất liệu balo
INSERT INTO ecommerce.attribute_values (id, attribute_id, value)
VALUES 
  ('val-poly', 'attr-material', 'Polyester'),
  ('val-cotton', 'attr-material', 'Cotton');

-- Sản phẩm Giày
INSERT INTO ecommerce.products (id, sku_code, name, slug, price, base_price, category_id, created_by, created_at, updated_at)
VALUES 
  (UUID(), 'SHOE001', 'Giày Nike Air', 'giay-nike-air', 1800000, 2200000, '8031e875-38ac-11f0-b63c-0242ac110002', '2432e652-38cd-11f0-b63c-0242ac110002', NOW(), NOW());

-- Sản phẩm Áo
INSERT INTO ecommerce.products (id, sku_code, name, slug, price, base_price, category_id, created_by, created_at, updated_at)
VALUES 
  (UUID(), 'SHIRT001', 'Áo Thun Cổ Tròn', 'ao-thun-co-tron', 250000, 300000, '8054a891-38cb-11f0-b63c-0242ac110002', '2432e652-38cd-11f0-b63c-0242ac110002', NOW(), NOW());

-- Sản phẩm Balo
INSERT INTO ecommerce.products (id, sku_code, name, slug, price, base_price, category_id, created_by, created_at, updated_at)
VALUES 
  (UUID(), 'BAG001', 'Balo Du Lịch 20L', 'balo-du-lich-20l', 350000, 400000, '8054877b-38cb-11f0-b63c-0242ac110002', '2432e652-38cd-11f0-b63c-0242ac110002', NOW(), NOW());


-- Biến thể Giày
INSERT INTO ecommerce.product_variants (id, product_id, sku_code, price, quantity, created_at)
VALUES 
  ('var-shoe-1', '49064408-38cd-11f0-b63c-0242ac110002', 'SHOE001-BLACK-40', 1800000, 10, NOW()),
  ('var-shoe-2', '49064408-38cd-11f0-b63c-0242ac110002', 'SHOE001-WHITE-41', 1800000, 8, NOW());

-- Biến thể Áo
INSERT INTO ecommerce.product_variants (id, product_id, sku_code, price, quantity, created_at)
VALUES 
  ('var-shirt-1', '4a6c0b6e-38cd-11f0-b63c-0242ac110002', 'SHIRT001-BLUE-M', 250000, 20, NOW()),
  ('var-shirt-2', '4a6c0b6e-38cd-11f0-b63c-0242ac110002', 'SHIRT001-RED-LONG-L', 260000, 12, NOW());

-- Biến thể Balo
INSERT INTO ecommerce.product_variants (id, product_id, sku_code, price, quantity, created_at)
VALUES 
  ('var-bag-1', '4d021cfd-38cd-11f0-b63c-0242ac110002', 'BAG001-20L-POLY', 350000, 15, NOW()),
  ('var-bag-2', '4d021cfd-38cd-11f0-b63c-0242ac110002', 'BAG001-30L-COTTON', 370000, 10, NOW());


INSERT INTO ecommerce.variant_attribute_value (product_variant_id, attribute_value_id)
VALUES 
  ('var-shoe-1', 'val-black'),
  ('var-shoe-1', 'val-size-40'),
  ('var-shoe-2', 'val-white'),
  ('var-shoe-2', 'val-size-41');

-- Áo
INSERT INTO ecommerce.variant_attribute_value (product_variant_id, attribute_value_id)
VALUES 
  ('var-shirt-1', 'val-blue'),
  ('var-shirt-1', 'val-size-m'),
  ('var-shirt-1', 'val-short'),
  ('var-shirt-2', 'val-red'),
  ('var-shirt-2', 'val-size-l'),
  ('var-shirt-2', 'val-long');

-- Balo
INSERT INTO ecommerce.variant_attribute_value (product_variant_id, attribute_value_id)
VALUES 
  ('var-bag-1', 'val-20l'),
  ('var-bag-1', 'val-poly'),
  ('var-bag-2', 'val-30l'),
  ('var-bag-2', 'val-cotton');

INSERT INTO stores (
  id,
  name,
  code,
  address,
  city,
  district,
  phone,
  is_active,
  created_at
)
VALUES
  (
    UUID(), -- id
    'Cửa hàng Hà Nội',
    'HN001',
    '123 Phố Huế, Hai Bà Trưng',
    'Hà Nội',
    'Hai Bà Trưng',
    '0123456789',
    true,
    NOW()
  );

INSERT INTO product_inventory (
  id,
  product_variant_id,
  store_id,
  quantity,
  reserved_quantity,
  cost_price,
  last_updated,
  version
)
VALUES
  (UUID(), 'var-shirt-1', 'f8c79144-38ac-11f0-b63c-0242ac110002', 2, 0, 200000, NOW(), 1),
  (UUID(), 'var-shirt-2', 'f8c79144-38ac-11f0-b63c-0242ac110002', 2, 0, 200000, NOW(), 1),
  (UUID(), 'var-bag-1', 'f8c79144-38ac-11f0-b63c-0242ac110002', 2, 0, 300000, NOW(), 1),
  (UUID(), 'var-bag-2', 'f8c79144-38ac-11f0-b63c-0242ac110002', 2, 0, 300000, NOW(), 1);

-- Insert Inventory
INSERT INTO product_inventory (id, product_variant_id, store_id, quantity, reserved_quantity, cost_price, last_updated, version)
VALUES (UUID(), @variant_id, @store_id, 5, 1, 780000, @current_time, 1);

-- Insert Inventory Reservation
INSERT INTO inventory_reservations (id, product_variant_id, store_id, quantity, reservation_type, reference_id, expires_at, created_at)
VALUES (UUID(), @variant_id, @store_id, 1, 'order', @order_id, DATE_ADD(@current_time, INTERVAL 24 HOUR), @current_time);





