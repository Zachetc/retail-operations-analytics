-- PostgreSQL schema
DROP SCHEMA IF EXISTS retail CASCADE;
CREATE SCHEMA retail;
SET search_path TO retail;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    segment TEXT NOT NULL CHECK (segment IN ('Consumer','Small Business','Corporate')),
    city TEXT NOT NULL,
    state CHAR(2) NOT NULL,
    signup_date DATE NOT NULL,
    acquisition_channel TEXT
);

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    supplier_type TEXT,
    state CHAR(2),
    avg_lead_time_days INT CHECK (avg_lead_time_days > 0),
    on_time_rate NUMERIC(5,3) CHECK (on_time_rate BETWEEN 0 AND 1)
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state CHAR(2) NOT NULL,
    store_format TEXT,
    square_feet INT CHECK (square_feet > 0),
    open_date DATE
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name TEXT NOT NULL,
    store_id INT NOT NULL REFERENCES stores(store_id),
    role TEXT NOT NULL,
    hire_date DATE,
    employment_type TEXT
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    subcategory TEXT NOT NULL,
    supplier_id INT NOT NULL REFERENCES suppliers(supplier_id),
    unit_cost NUMERIC(12,2) NOT NULL CHECK (unit_cost >= 0),
    list_price NUMERIC(12,2) NOT NULL CHECK (list_price >= 0),
    product_status TEXT NOT NULL
);

CREATE TABLE promotions (
    promotion_id INT PRIMARY KEY,
    promotion_name TEXT NOT NULL,
    promotion_type TEXT,
    discount_rate NUMERIC(5,2) CHECK (discount_rate BETWEEN 0 AND 1),
    start_date DATE,
    end_date DATE CHECK (end_date >= start_date)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    store_id INT NOT NULL REFERENCES stores(store_id),
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    order_date DATE NOT NULL,
    channel TEXT NOT NULL,
    promotion_id INT REFERENCES promotions(promotion_id),
    order_status TEXT NOT NULL
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    discount_rate NUMERIC(5,2) CHECK (discount_rate BETWEEN 0 AND 1)
);

CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT UNIQUE NOT NULL REFERENCES orders(order_id),
    ship_date DATE NOT NULL,
    promised_date DATE NOT NULL,
    delivery_date DATE,
    carrier TEXT,
    shipping_cost NUMERIC(12,2) CHECK (shipping_cost >= 0)
);

CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity_returned INT NOT NULL CHECK (quantity_returned > 0),
    return_date DATE NOT NULL,
    return_reason TEXT,
    return_status TEXT
);

CREATE TABLE inventory (
    store_id INT NOT NULL REFERENCES stores(store_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity_on_hand INT NOT NULL CHECK (quantity_on_hand >= 0),
    reorder_point INT NOT NULL CHECK (reorder_point >= 0),
    target_stock INT NOT NULL CHECK (target_stock >= 0),
    snapshot_date DATE NOT NULL,
    PRIMARY KEY (store_id, product_id, snapshot_date)
);
