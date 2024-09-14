CREATE DATABASE compstak_task2;

CREATE SCHEMA IF NOT EXISTS dim;
CREATE SCHEMA IF NOT EXISTS fact;

DROP TABLE IF EXISTS fact.Orders;
DROP TABLE IF EXISTS dim.Products;
DROP TABLE IF EXISTS dim.Customers;

CREATE TABLE dim.Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(20) NOT NULL,
    category VARCHAR(15) NOT NULL
);

CREATE TABLE dim.Customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(25) NOT NULL,
    country VARCHAR(35) NOT NULL
);

CREATE TABLE fact.Orders (
    order_id SERIAL PRIMARY KEY,
    order_date TIMESTAMP NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES dim.Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES dim.Products(product_id) ON DELETE CASCADE
);

INSERT INTO dim.Products (product_name, category)
SELECT
    'Product_' || i AS product_name,
    'Category_' || (i % 5 + 1) AS category
FROM generate_series(1, 1500) AS i;


INSERT INTO dim.Customers (customer_name, country)
SELECT
    'Customer_' || i AS customer_name,
    CASE
        WHEN i % 5 = 0 THEN 'Serbia'
        WHEN i % 5 = 1 THEN 'USA'
        WHEN i % 5 = 2 THEN 'UK'
        WHEN i % 5 = 3 THEN 'Japan'
        ELSE 'Spain'
    END AS country
FROM generate_series(1, 25000) AS i;


INSERT INTO fact.Orders (order_date, customer_id, product_id, quantity, total_amount)
SELECT
    NOW() - (i * interval '1 minute') AS order_date,
    (i % 25000) + 1 AS customer_id,
    (i % 1500) + 1 AS product_id,
    (i % 10 + 1) AS quantity,
    (i % 1000 + 100) * (i % 10 + 1) AS total_amount
FROM generate_series(1, 1500000) AS i;


SELECT 
    p.category,
    SUM(o.total_amount) AS total_sales,
    COUNT(o.order_id) AS total_orders,
    AVG(o.total_amount)::DECIMAL(10,2) AS avg_order_value
FROM 
    fact.Orders o
JOIN dim.Products p ON o.product_id = p.product_id
GROUP BY p.category;

DO $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    exec_time DOUBLE PRECISION;
BEGIN
    start_time := clock_timestamp();
    
    PERFORM 
        p.category,
        SUM(o.total_amount) AS total_sales,
        COUNT(o.order_id) AS total_orders,
        AVG(o.total_amount)::DECIMAL(10,2) AS avg_order_value
    FROM fact.Orders o
    JOIN dim.Products p ON o.product_id = p.product_id
    GROUP BY p.category;

    end_time := clock_timestamp();

    exec_time := EXTRACT(EPOCH FROM (end_time - start_time));
    
    RAISE NOTICE 'Execution time: % seconds', exec_time;
END $$;

/*

Execution time: 0.319228 seconds
Query returned successfully in 374 msec.
*/



CREATE INDEX idx_orders_product ON fact.Orders(product_id);
CREATE INDEX idx_products_product ON dim.Products(product_id);
CREATE INDEX idx_products_category ON dim.Products(category);
CREATE INDEX idx_orders_total_amount ON fact.Orders(total_amount);


DO $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    exec_time DOUBLE PRECISION;
BEGIN
    start_time := clock_timestamp();
    
    PERFORM 
        p.category,
        SUM(o.total_amount) AS total_sales,
        COUNT(o.order_id) AS total_orders,
        AVG(o.total_amount)::DECIMAL(10,2) AS avg_order_value
    FROM fact.Orders o
    JOIN dim.Products p ON o.product_id = p.product_id
    GROUP BY p.category;

    end_time := clock_timestamp();

    exec_time := EXTRACT(EPOCH FROM (end_time - start_time));
    
    RAISE NOTICE 'Execution time: % seconds', exec_time;
END $$;

/*
Execution time: 0.278903 seconds
Query returned successfully in 317 msec.
*/

CREATE MATERIALIZED VIEW orders_summary AS
SELECT 
    p.category,
    SUM(o.total_amount) AS total_sales,
    COUNT(o.order_id) AS total_orders,
    AVG(o.total_amount)::DECIMAL(10,2) AS avg_order_value
FROM fact.Orders o
JOIN dim.Products p ON o.product_id = p.product_id
GROUP BY p.category;

CREATE INDEX idx_orders_summary_category
ON orders_summary (category);

REFRESH MATERIALIZED VIEW orders_summary;

SELECT *
FROM
    orders_summary;

DO $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    exec_time DOUBLE PRECISION;
BEGIN
	start_time := clock_timestamp();
	PERFORM 
	*
	FROM 
		orders_summary;
    
	end_time := clock_timestamp();
    exec_time := EXTRACT(EPOCH FROM (end_time - start_time));

    RAISE NOTICE 'Execution time: % seconds', exec_time;
END $$;

/*
Execution time: 0.002872 seconds
Query returned successfully in 123 msec.
*/



