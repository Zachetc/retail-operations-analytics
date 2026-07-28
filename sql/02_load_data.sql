-- Run from psql at the repository root after creating the schema.
SET search_path TO retail;

\copy customers FROM 'data/raw/customers.csv' CSV HEADER;
\copy suppliers FROM 'data/raw/suppliers.csv' CSV HEADER;
\copy stores FROM 'data/raw/stores.csv' CSV HEADER;
\copy employees FROM 'data/raw/employees.csv' CSV HEADER;
\copy products FROM 'data/raw/products.csv' CSV HEADER;
\copy promotions FROM 'data/raw/promotions.csv' CSV HEADER NULL '';
\copy orders FROM 'data/raw/orders.csv' CSV HEADER NULL '';
\copy order_items FROM 'data/raw/order_items.csv' CSV HEADER;
\copy shipments FROM 'data/raw/shipments.csv' CSV HEADER;
\copy returns FROM 'data/raw/returns.csv' CSV HEADER;
\copy inventory FROM 'data/raw/inventory.csv' CSV HEADER;
