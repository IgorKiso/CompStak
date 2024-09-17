CREATE SCHEMA IF NOT EXISTS dim;
CREATE SCHEMA IF NOT EXISTS fact;

DROP TABLE IF EXISTS fact.transactions;
DROP TABLE IF EXISTS dim.products;
DROP TABLE IF EXISTS dim.customers;
DROP TABLE IF EXISTS dim.stores;
DROP TABLE IF EXISTS dim.regions;

CREATE TYPE product_status AS ENUM ('in stock', 'out of stock');
CREATE TYPE product_category AS ENUM 
    (
        'Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Footwear',
        'Activewear', 'Swimwear', 'Loungewear', 'Accessories', 
        'Hats & Caps', 'Scarves & Gloves', 'Socks & Hosiery', 
        'Underwear', 'Bags & Purses', 'Sunglasses', 'Belts', 'Other'
        );
CREATE TYPE sex_type AS ENUM 
    (
        'Male', 'Female', 'Unisex', 'Kids'
        );
CREATE TYPE payment_status_type AS ENUM 
    (
        'completed', 'pending', 'canceled'
        );
CREATE TYPE delivery_status_type AS ENUM 
    (
        'delivered', 'pending', 'returned'
        );
CREATE TYPE customer_category AS ENUM 
    (
        'Individual', 'Business', 'Frequent Buyer', 
        'Occasional Buyer', 'Rare Buyer', 
        'High Value', 'Medium Value', 'Low Value', 
        'Urban', 'Suburban', 'Rural','Other'
        );

CREATE TYPE store_types AS ENUM (
    'Physical',
    'Online'
);

CREATE TABLE dim.products (
    product_sku VARCHAR(16) PRIMARY KEY,
    created_date TIMESTAMP DEFAULT NOW(),
    closed_date TIMESTAMP DEFAULT NULL,
    changed_date TIMESTAMP DEFAULT NULL,
    updated_date TIMESTAMP DEFAULT NULL,
    name VARCHAR(25) NOT NULL,
    cost DECIMAL(8, 2) CHECK (cost > 0),
    price DECIMAL(8, 2) CHECK (price > 0),
    status product_status NOT NULL,
    inventory_quantity INT CHECK (inventory_quantity >= 0),
    category product_category NOT NULL,
    brand VARCHAR(25) NOT NULL,
    size VARCHAR(10) NOT NULL,
    color VARCHAR(20) NOT NULL,
    sex sex_type NOT NULL
);

CREATE TABLE dim.customers (
    customer_id SERIAL PRIMARY KEY,
    created_time TIMESTAMP DEFAULT NOW(),
    changed_time TIMESTAMP DEFAULT NULL,
    updated_time TIMESTAMP DEFAULT NOW(),
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25)NOT NULL,
    gender VARCHAR(20),
    company VARCHAR(30),
    email VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    category customer_category DEFAULT 'Other',
    address VARCHAR(50),
    city VARCHAR(30),
    zip VARCHAR(10),
    province VARCHAR(30),
    state VARCHAR(30),
    country VARCHAR(30),
    continent VARCHAR(15),
    email_marketing_status BOOLEAN DEFAULT FALSE,
    phone_marketing_status BOOLEAN DEFAULT FALSE,
    shipping_address VARCHAR(50),
    shipping_city VARCHAR(30),
    shipping_zip VARCHAR(10),
    shipping_province VARCHAR(30),
    shipping_state VARCHAR(30),
    shipping_country VARCHAR(30),
    shipping_continent VARCHAR(15)
);

CREATE TABLE dim.regions (
    region_id SERIAL PRIMARY KEY,
    region varchar(20) NOT NULL,
    created_date TIMESTAMP DEFAULT NOW(),
    updated_date TIMESTAMP DEFAULT NOW()
);

CREATE TABLE dim.stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(50) NOT NULL,
    store_type store_types NOT NULL,
    address VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(20) NOT NULL,
    postal_code VARCHAR(10),
    country VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(50) NOT NULL,
    opening_date TIMESTAMP DEFAULT NOW(),
    closing_date TIMESTAMP DEFAULT NULL,
    created_date TIMESTAMP DEFAULT NOW(),
    updated_date TIMESTAMP DEFAULT NOW(),
    region_id INT REFERENCES dim.regions(region_id)
);

CREATE TABLE fact.transactions (
    order_id INT NOT NULL,
    order_line INT NOT NULL,
    order_time TIMESTAMP DEFAULT NOW(),
    updated_time TIMESTAMP DEFAULT NOW(),
    closed_time TIMESTAMP DEFAULT NULL,
    quantity INT CHECK(quantity > 0),
    shipping_amount DECIMAL(10, 2) CHECK(shipping_amount>=0) DEFAULT 0,
    tax_amount DECIMAL(10, 2) CHECK(tax_amount >=0) DEFAULT 0,
    discount_amount DECIMAL(10, 2) CHECK(discount_amount >=0) DEFAULT 0,
    refund_amount DECIMAL(10, 2) CHECK(refund_amount <= 0) DEFAULT 0,
    total_amount DECIMAL(10, 2) CHECK(total_amount >=0),
    payment_status payment_status_type NOT NULL, 
    delivery_status delivery_status_type NOT NULL,
    refund BOOLEAN DEFAULT FALSE,
    discount_applied BOOLEAN DEFAULT FALSE,
    cookies_domain VARCHAR(255),
    cookies_search_keyword VARCHAR(255),
    cookies_user_agent VARCHAR(255),
    cookies_system VARCHAR(255),
    product_sku VARCHAR(16) REFERENCES dim.products(product_sku),
    customer_id INT REFERENCES dim.customers(customer_id),
    store_id INT REFERENCES dim.stores(store_id),
    PRIMARY KEY (order_id,order_line)
);

CREATE INDEX idx_transactions_product_sku ON fact.transactions(product_sku);
CREATE INDEX idx_transactions_customer_id ON fact.transactions(customer_id);
CREATE INDEX idx_transactions_store_id ON fact.transactions(store_id);
CREATE INDEX idx_transactions_order_time ON fact.transactions(order_time);

CREATE TABLE sales_cube(
    store_name VARCHAR(50),
    product_name VARCHAR(50),
    region VARCHAR(50),
    year INT,
    month INT,
    quantity_sold INT,
    total_sales DECIMAL(10, 2),
    total_orders INT,
    discount_applied DECIMAL(10, 2)
    );

INSERT INTO sales_cube (
    store_name, product_name, region, year, month, 
    quantity_sold, total_sales, total_orders, discount_applied
)
SELECT
    s.store_name,
    p.name,
    r.region,
    EXTRACT(YEAR FROM t.order_time),
    EXTRACT(MONTH FROM t.order_time),
    SUM(t.quantity),
    SUM(t.total_amount),
    COUNT(DISTINCT t.order_id),
    SUM(t.discount_amount)
FROM fact.transactions t
JOIN dim.stores s ON t.store_id = s.store_id
JOIN dim.products p ON t.product_sku = p.product_sku
JOIN dim.regions r ON s.region_id = r.region_id
GROUP BY 
    s.store_name, p.name, r.region,  
    EXTRACT(YEAR FROM t.order_time), EXTRACT(MONTH FROM t.order_time);

CREATE TABLE customers_cube(
    store_name VARCHAR(50),
    product_name VARCHAR(50),
    customer_id INT,
    year INT,
    month INT,
    total_customers INT,
    total_spent DECIMAL(10, 2),
    quantity_bought INT
    );

INSERT INTO customers_cube (
    store_name, product_name, customer_id, year, month, 
    total_customers, total_spent, quantity_bought
)
SELECT
    s.store_name,
    p.name,
    c.customer_id,
    EXTRACT(YEAR FROM t.order_time),
    EXTRACT(MONTH FROM t.order_time),
    COUNT(c.customer_id),
    SUM(t.total_amount),
    SUM(t.quantity)
FROM fact.transactions t
JOIN dim.stores s ON t.store_id = s.store_id
JOIN dim.products p ON t.product_sku = p.product_sku
JOIN dim.customers c ON t.customer_id = c.customer_id
GROUP BY 
    s.store_name, p.name, c.customer_id, 
    EXTRACT(YEAR FROM t.order_time), EXTRACT(MONTH FROM t.order_time);

CREATE TABLE inventory_cube (
    store_name VARCHAR(50),
    product_name VARCHAR(50),
    region VARCHAR(50),
    year INT,
    month INT,
    inventory_volume INT
);

INSERT INTO inventory_cube (
    store_name, product_name, region, year, month, inventory_volume
)
SELECT
    s.store_name,
    p.name,
    r.region,
    EXTRACT(YEAR FROM t.order_time),
    EXTRACT(MONTH FROM t.order_time),
    SUM(p.inventory_quantity)
FROM fact.transactions t
JOIN dim.stores s ON t.store_id = s.store_id
JOIN dim.products p ON t.product_sku = p.product_sku
JOIN dim.regions r ON s.region_id = r.region_id
GROUP BY 
    s.store_name, p.name, r.region, 
    EXTRACT(YEAR FROM t.order_time), EXTRACT(MONTH FROM t.order_time);






