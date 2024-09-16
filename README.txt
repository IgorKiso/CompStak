BI Engineer Technical Assessment

Task 1: Data Modeling

Tools I Used:
- Visual Studio Code
- pgAdmin 4

Workflow Description:

First, I created the `comstan_task1` database using pgAdmin 4. Before setting up the ER diagram, I defined the necessary predefined enumeration types. 
Then, using the ERD For Database tool in pgAdmin4, I created the ER diagram, outlining the required dimension and fact tables with their attributes. 
I made sure to accurately represent the real-world scenario as closely as possible. Afterward, I switched to Visual Studio Code to implement the tables using DDL commands.

Instructions for running the code:
  - Create the compstak_task1 database.  
  - Run the code from the Test1.sql file.

Additional explanations:

To save you from manually creating the data types, I have included the code for creating predefined ENUM data types. 
Some attributes within the model have constraints. I assumed that a customer must register using an email, first name, and last name. 
Also, it's possible for a customer to register without making any purchases, so some attributes have default null values. 
Furthermore, the attributes related to cookies could be tied to either the customer or the transaction table. I decided to go with the latter approach.

Schema Overview:

The star schema is straightforward and user-friendly for querying. Each dimension links directly to the fact table, which simplifies queries with JOIN operations between the fact and dimension tables. The fact table contains the numerical data needed for analysis (like quantity sold and total sales), while dimension tables hold descriptive attributes. This structure allows for efficient data aggregation and slicing across various dimensions.
The star schema is highly efficient for OLAP queries, which are essential for reporting and business intelligence. This design speeds up aggregations, summaries, and drill-down queries, making it ideal for high-performance analytics.
