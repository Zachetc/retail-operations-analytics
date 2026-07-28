SET search_path TO retail;

CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_store_id ON orders(store_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_supplier_id ON products(supplier_id);
CREATE INDEX idx_returns_product_id ON returns(product_id);
CREATE INDEX idx_shipments_delivery_dates ON shipments(promised_date, delivery_date);

ANALYZE;
