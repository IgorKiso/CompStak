# BI Engineer Technical Assessment

## Task 1: Data Modeling

**Tools I Used:**

- PostgreSQL
- pgAdmin 4
- Visual Studio Code
- ERD For Database Tool (within pgAdmin 4)

**Workflow Description:**

First, I created the compstak_task1 database using pgAdmin 4. 
Before creating the ER diagram, I set up the necessary predefined ENUM data types. 
I then designed the ER diagram, defining the required dimension and fact tables along with their attributes, aiming to accurately represent the real-world scenario. 
After that, I used Visual Studio Code to create the tables with DDL commands.

**Instructions for Running the Code:**

Create the compstak_task1 database.
Run the code from the Task1.sql file.

**Additional Explanations:**

To save you from manually creating types, I included code to create ENUM predefined data types. 
Some attributes in the model have constraints based on the assumption that a customer must register using an email, first name, and last name. 
Additionally, a customer might register without making a purchase, which is why some attributes have default null values. 
Attributes related to cookies could be associated with either the customer or transaction tables.
I used for the latter approach.

**Schema Overview:**

I designed this schema using a star schema structure, which is ideal for reporting and analytics in a data warehouse setting. 
The star schema consists of a central fact table surrounded by several dimension tables.
The fact table records transactional data. Each row represents a unique line item in a sales order, allowing tracking of purchases, refunds, promotional usage and more. 
The fact table stores important measures (e.g., quantity, total_amount, discount_amount), essential for analytical queries.
It references dimension tables through foreign keys, making it easy to analyze data from various perspectives. 
The product table stores product-related data, enabling detailed product-level analysis such as tracking sales performance, analyzing inventory levels, and identifying trends in different product categories. 
The customer table allows analysis of customer purchasing behavior, segmentation by type, and tracking marketing preferences like email or phone opt-ins. 
The promotions table helps analyze the effectiveness of promotions by tracking usage and their impact on total sales.
The star schema is straightforward and user-friendly for querying. 
This structure allows for efficient data aggregation and slicing across various dimensions. 
The star schema is highly efficient for OLAP queries, essential for reporting and business intelligence, and speeds up aggregations, summaries, and drill-down queries for high-performance analytics.


# Task 2: Advanced SQL Query and Optimization

**Tools I Used:**

- PostgreSQL
- pgAdmin 4
- Visual Studio Code

**Workflow Description:**

I used EXPLAIN ANALYZE to identify performance bottlenecks and full table scans in the query. 
To improve performance, I created indexes on the relevant columns and implemented a materialized view. 
The task did not specify data modeling, which could have further optimized performance through denormalization. 
Therefore, I focused on indexing and materialized views.
Additionally, I created and populated the database with test data to evaluate performance. 
I used a PL/pgSQL block to compare the performance of the original query, the query after creating indexes, and the query after implementing the materialized view and its index.

**Instructions for Running the Code:**

Create the compstak_task2 database.
Run the code from the Task2_performance_test.sql file up to the first comment to create the necessary tables, populate them with values, and get the performance of the query without optimization.
Run the code between the first and second comments to apply indexing and see the performance after indexing.
Run the remaining code to create the materialized view and index on it to achieve the final performance.

**Additional Explanations:**

*Identifying Performance Issues:*

- Lack of Indexes:
- Join Operation: Joining large tables without indexes is inefficient and involves scanning entire tables.
- Aggregation and Grouping: Aggregation functions (SUM, COUNT, AVG) and grouping operations (GROUP BY) are time-consuming on large datasets without proper indexing.

*Optimized Query:*

- Creating Indexes:
    Indexes on fact.Orders(product_id) and dim.Products(product_id) enhance join performance.
    Creating an index on dim.Products(category) accelerates the grouping operation.
- Using a Materialized View: 
    This stores the query results physically, allowing for rapid retrieval of precomputed results and avoiding repetitive calculations.

*Explanation of Optimization Strategy:*

- Indexes: Improve query performance by quickly locating and accessing necessary rows, reducing full table scans and speeding up joins and grouping.
- Materialized View: Speeds up query performance by storing precomputed results, thus avoiding the overhead of recalculating aggregations and joins each time.

These optimizations reduced query execution time from **0.319 seconds** to **0.0001 seconds**, showcasing a significant performance improvement.

## Task 3: Complex Data Modeling for a Multi-Store Retail Chain

**Tools I Used:**

- PostgreSQL
- pgAdmin 4
- Visual Studio Code
- ERD For Database Tool (within pgAdmin 4)
- cube extension

**Workflow Description:**

First, I created the compstak_task3 database using pgAdmin 4. 
Before creating the ER diagram, I set up the necessary predefined ENUM data types. 
I then designed the ER diagram, defining the required dimension and fact tables along with their attributes, aiming to accurately represent the real-world scenario. 
After that, I used Visual Studio Code to create the tables, views, cube, indexes.

**Instructions for Running the Code:**

Create the compstak_task3 database.
Run the code from the Task3.sql file.

**Additional Explanations:**

To save you from manually creating types, I included code to create ENUM predefined data types. 
I opted for an OLAP cube. There were other solutions as well, such as creating a materialized view like:

    CREATE MATERIALIZED VIEW sales_summary_mv AS
    SELECT
        s.store_name AS store,
        p.name AS product_name,
        r.region AS region,
        EXTRACT(YEAR FROM t.order_time) AS year,
        EXTRACT(MONTH FROM t.order_time) AS month,
        SUM(t.quantity) AS quantity_sold,
        SUM(t.total_amount) AS total_sales,
        COUNT(DISTINCT t.order_id) AS total_orders,
        SUM(t.discount_amount) AS discount_applied
    FROM fact.transactions t
    JOIN dim.stores s ON t.store_id = s.store_id
    JOIN dim.products p ON t.product_sku = p.product_sku
    JOIN dim.regions r ON s.region_id = r.region_id
    GROUP BY 
        store, 
        product_name, 
        region, 
        year, 
        month;

Additionally, I did not create all the necessary indexes or the logic to check if an order is completed due to time constraints from family obligations. All of these are easily implementable.

**Design Overview:**

I have designed and implemented a data warehouse schema for a multi-store clothing retail chain using PostgreSQL. This involved creating a dimension tables for stores, products, customers, and regions, and a fact table for transactions.

*Schema Design and Implementation:*

I defined necessary enumerated types to categorize products, payment statuses, delivery statuses, and customer categories.
I created dimension tables (dim.products, dim.customers, dim.stores, dim.regions) to capture detailed attributes related to products, customers, store locations, and regional information.
I implemented a fact table (fact.transactions) to store transactional data, including quantities sold, total amounts, discounts, and other relevant metrics.

*Cube Aggregation:*

Using PostgreSQL’s cube extension, I created a sales_cube_data table to store aggregated sales data. This cube aggregates key metrics such as quantity sold, total sales, total orders, discount applied, total customers, total spent, quantity bought, and inventory volume.
I wrote a function (text_to_numeric_array) to convert textual dimensions into numeric arrays suitable for the cube structure.
I populated the cube with aggregated data by joining the fact table with the dimension tables and grouping by various attributes such as store name, product name, region, customer ID, year, and month.

*Results of Aggregation:*

By aggregating the data into the cube, I obtained a comprehensive summary of sales performance across different dimensions. This included insights into sales trends at the store level, regional performance, customer purchasing behavior, and inventory levels.
The cube allows for efficient querying and analysis of sales data, providing valuable insights into product performance, customer engagement, and store operations.
This implementation facilitates detailed and flexible analysis, supporting the company's need to track individual sales, analyze sales trends, monitor customer behavior, and manage inventory across multiple stores.