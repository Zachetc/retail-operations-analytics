SET search_path TO retail;

-- Duplicate primary identifiers
SELECT order_id, COUNT(*) FROM orders GROUP BY order_id HAVING COUNT(*) > 1;
SELECT product_id, COUNT(*) FROM products GROUP BY product_id HAVING COUNT(*) > 1;

-- Orphan checks
SELECT oi.* FROM order_items oi LEFT JOIN orders o ON o.order_id = oi.order_id WHERE o.order_id IS NULL;
SELECT oi.* FROM order_items oi LEFT JOIN products p ON p.product_id = oi.product_id WHERE p.product_id IS NULL;

-- Reasonableness checks
SELECT * FROM products WHERE unit_cost > list_price;
SELECT * FROM order_items WHERE quantity <= 0 OR unit_price < 0;
SELECT * FROM inventory WHERE quantity_on_hand < 0 OR reorder_point < 0;
SELECT * FROM shipments WHERE delivery_date < ship_date;

-- Reconciliation
SELECT
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(DISTINCT order_id) FROM order_items) AS orders_with_items,
    (SELECT COUNT(*) FROM shipments) AS shipments,
    (SELECT COUNT(*) FROM returns) AS returns;
