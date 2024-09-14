-- refer to Task2.sql

/*
1. Non-optimized query

Execution time: 0.319228 seconds
Query returned successfully in 374 msec.
*/

CREATE INDEX idx_orders_product ON fact.Orders(product_id);
CREATE INDEX idx_products_product ON dim.Products(product_id);
CREATE INDEX idx_products_category ON dim.Products(category);
CREATE INDEX idx_orders_total_amount ON fact.Orders(total_amount);

/*
2. Performance after creating indexes

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

/*
3. Performance after creating a materialized view

NOTICE:  Execution time: 0.002872 seconds
Query returned successfully in 123 msec.
*/



