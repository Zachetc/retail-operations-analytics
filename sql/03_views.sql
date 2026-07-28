SET search_path TO retail;

CREATE OR REPLACE VIEW vw_sales_detail AS
SELECT
    oi.order_item_id,
    o.order_id,
    o.order_date,
    o.channel,
    o.order_status,
    c.customer_id,
    c.segment,
    s.store_id,
    s.store_name,
    s.state,
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.supplier_id,
    oi.quantity,
    oi.unit_price,
    oi.discount_rate,
    p.unit_cost,
    oi.quantity * oi.unit_price AS net_sales,
    oi.quantity * p.unit_cost AS total_cost,
    (oi.quantity * oi.unit_price) - (oi.quantity * p.unit_cost) AS gross_profit,
    CASE WHEN oi.quantity * oi.unit_price = 0 THEN 0
         ELSE ((oi.quantity * oi.unit_price) - (oi.quantity * p.unit_cost))
              / (oi.quantity * oi.unit_price)
    END AS margin_pct
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN stores s ON s.store_id = o.store_id
JOIN products p ON p.product_id = oi.product_id;

CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    sh.shipment_id,
    sh.order_id,
    sh.carrier,
    sh.ship_date,
    sh.promised_date,
    sh.delivery_date,
    sh.delivery_date - sh.promised_date AS days_late,
    CASE WHEN sh.delivery_date <= sh.promised_date THEN 1 ELSE 0 END AS on_time_flag
FROM shipments sh;

CREATE OR REPLACE VIEW vw_inventory_risk AS
SELECT
    i.store_id,
    s.store_name,
    i.product_id,
    p.product_name,
    p.category,
    i.quantity_on_hand,
    i.reorder_point,
    i.target_stock,
    CASE
        WHEN i.quantity_on_hand = 0 THEN 'Stockout'
        WHEN i.quantity_on_hand <= i.reorder_point THEN 'Reorder'
        WHEN i.quantity_on_hand > i.target_stock * 1.5 THEN 'Overstock'
        ELSE 'Healthy'
    END AS inventory_status
FROM inventory i
JOIN stores s ON s.store_id = i.store_id
JOIN products p ON p.product_id = i.product_id;
