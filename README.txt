BI Engineer Technical Assessment

Task 1: Data Modeling

Tools I Used:
- Visual Studio Code
- pgAdmin 4

Workflow Description:
First, I created the `comstan_task1` database using pgAdmin 4. Before setting up the ER diagram, I defined the necessary predefined enumeration types. Then, using the ERD For Database tool in pgAdmin4, I created the ER diagram, outlining the required dimension and fact tables with their attributes. I made sure to accurately represent the real-world scenario as closely as possible. Afterward, I switched to Visual Studio Code to implement the tables using DDL commands.

Instructions for running the code:
Create the compstak_task1 database.  
Run the code from the Test1.sql file.

Additional explanations:  
To save you from manually creating the data types, I have included the code for creating predefined ENUM data types. Some attributes within the model have constraints. I assumed that a customer must register using an email, first name, and last name. Also, it's possible for a customer to register without making any purchases, so some attributes have default null values. Furthermore, the attributes related to cookies could be tied to either the customer or the transaction table. I decided to go with the latter approach.

Schema Overview
I designed this schema using a star schema structure, which is ideal for reporting and analytics in a data warehouse setting. The star schema consists of a central fact table surrounded by several dimension tables, creating a clear and efficient model for querying data.

Fact Table: fact.transactions
Purpose: This table records transactional data such as sales across different stores. Each row represents a unique line item in a sales order, which allows me to track purchases, refunds, and promotional usage.
Why I chose this: The fact table stores important measures (e.g., quantity, total_amount, discount_amount), which are essential for analytical queries like summing up total sales, calculating average order values, or determining the most popular products. It also references dimension tables through foreign keys, making it easy to analyze data from various perspectives.
Dimension Tables:
dim.products:

Purpose: Stores product-related data such as name, category, cost, and inventory quantity.
Why I included this: This dimension enables detailed product-level analysis, such as tracking sales performance, analyzing inventory levels, and identifying trends in different product categories.
dim.customers:

Purpose: Holds customer information, including first name, last name, email, and location.
Why I included this: This table allows me to analyze customer purchasing behavior, segment customers by type (e.g., Frequent Buyer, High Value), and track marketing preferences like email or phone opt-ins.
dim.promotions:

Purpose: Captures promotional data such as discount percentages, promotion codes, and usage limits.
Why I included this: This helps me analyze how effective promotions are by tracking usage and the impact they have on total sales.
Why I Chose a Star Schema
Ease of Querying:

The star schema is straightforward and user-friendly for querying. Each dimension links directly to the fact table, which simplifies queries with JOIN operations between the fact and dimension tables.
Support for Aggregation:

The fact table contains the numerical data needed for analysis (like quantity sold and total sales), while dimension tables hold descriptive attributes (such as product categories and customer details). This structure allows for efficient data aggregation and slicing across various dimensions (e.g., sales by store, product, or customer).
Optimized for OLAP (Online Analytical Processing):

The star schema is highly efficient for OLAP queries, which are essential for reporting and business intelligence. This design speeds up aggregations, summaries, and drill-down queries, making it ideal for high-performance analytics.