# BI Engineer Technical Assessment

## Task 1: Data Modeling

**Tools I Used:**

- PostgreSQL
- pgAdmin 4
- Visual Studio Code
- ERD For Database Tool (within pgAdmin 4)

**Workflow Description:**

First, I created the `compstak_task1` database using pgAdmin 4. Before creating the ER diagram, I set up the necessary predefined ENUM data types. I then designed the ER diagram, defining the required dimension and fact tables along with their attributes, aiming to accurately represent the real-world scenario. After that, I used Visual Studio Code to create the tables with DDL commands.

**Instructions for Running the Code:**

1. Create the `compstak_task1` database.
2. Run the code from the `Test1.sql` file.

**Additional Explanations:**

To avoid manually creating types, I included code to create ENUM predefined data types. Some attributes in the model have constraints based on the assumption that a customer must register using an email, first name, and last name. Additionally, a customer might register without making a purchase, which is why some attributes have default null values. Attributes related to cookies could be associated with either the customer or transaction tables; I opted for the latter approach.

**Schema Overview:**

I designed this schema using a star schema structure, which is ideal for reporting and analytics in a data warehouse setting. The star schema consists of a central fact table surrounded by several dimension tables, creating a clear and efficient model for querying data.

The fact table records transactional data. Each row represents a unique line item in a sales order, allowing tracking of purchases, refunds, and promotional usage. The fact table stores important measures (e.g., quantity, total_amount, discount_amount), essential for analytical queries such as summing total sales, calculating average order values, or determining the most popular products. It references dimension tables through foreign keys, making it easy to analyze data from various perspectives. 

The product table stores product-related data, enabling detailed product-level analysis such as tracking sales performance, analyzing inventory levels, and identifying trends in different product categories. The customer table allows analysis of customer purchasing behavior, segmentation by type, and tracking marketing preferences like email or phone opt-ins. The promotions table helps analyze the effectiveness of promotions by tracking usage and their impact on total sales.

The star schema is straightforward and user-friendly for querying. Each dimension links directly to the fact table, simplifying queries with JOIN operations. The fact table contains numerical data for analysis, while dimension tables hold descriptive attributes. This structure allows for efficient data aggregation and slicing across various dimensions. The star schema is highly efficient for OLAP queries, essential for reporting and business intelligence, and speeds up aggregations, summaries, and drill-down queries for high-performance analytics.


