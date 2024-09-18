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
The task did not specify data modeling, which could have further optimized performance through denormalization, partitionig... 
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
**I created two solutions: one using the cube extension and another simulating an OLAP cube using physical tables with dimensions and measures.**

**Instructions for Running the Code:**

Create the compstak_task3 database.
Run the code from the Task3.sql file.
Run the code from the Task3_1.sql file.
Run the code from the Task3_3.sql file.

**Additional Explanations:**

To save you from manually creating types, I included code to create ENUM predefined data types. 
While PostgreSQL doesn’t offer a native OLAP engine, you can simulate OLAP functionality through: 
SQL features like CUBE, ROLLUP, and GROUPING SETS for multidimensional queries, materialized views for precomputed aggregations or extensions for multidimensional data (e.g.cube extension).
In Task3. sql I opted for an OLAP cube. 
In Task3_1, I used physical tables to simulate OLAP cubes.
In Task3_2, I used materialized views, which are the best option for a DWH in Snowflake.

    
Additionally, I did not create all the necessary indexes or the logic to check if an order is completed due to time constraints from family obligations. All of these are easily implementable.
For the solution in Task3_2, indexes and manual refresh of materialized views are not necessary if Snowflake is used as the platform. Snowflake uses automatic clustering. If you want to automate the refresh, you can use task objects like the following:

CREATE OR REPLACE TASK refresh_sales_cube_task
  WAREHOUSE = compstak_warehouse 
  SCHEDULE = 'USING CRON 0 0 * * * UTC'
  COMMENT = 'Daily refresh of sales_cube'
AS
  REFRESH MATERIALIZED VIEW dim.sales_cube;

Although Snowflake automatically optimizes performance for materialized views, cluster keys can be used for further optimization, such as:

ALTER TABLE fact.transactions 
  CLUSTER BY (order_time);

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
Additionally, the model can easily be integrated into any reporting tool.