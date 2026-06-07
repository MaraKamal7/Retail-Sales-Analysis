CREATE DATABASE retail_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE retail_db;
CREATE TABLE calendar (
    full_date DATE PRIMARY KEY,
    
    year_num INT,
    
    quarter_num INT,
    
    month_num INT,
    month_name VARCHAR(20),
    
    day_num INT,
    day_name VARCHAR(20)
);
INSERT INTO calendar
SELECT
    DATE_ADD('2017-01-01', INTERVAL n DAY) AS full_date,

    YEAR(DATE_ADD('2017-01-01', INTERVAL n DAY)),

    QUARTER(DATE_ADD('2017-01-01', INTERVAL n DAY)),

    MONTH(DATE_ADD('2017-01-01', INTERVAL n DAY)),

    MONTHNAME(DATE_ADD('2017-01-01', INTERVAL n DAY)),

    DAY(DATE_ADD('2017-01-01', INTERVAL n DAY)),

    DAYNAME(DATE_ADD('2017-01-01', INTERVAL n DAY))

FROM (
    SELECT a.N + b.N * 10 + c.N * 100 AS n
    FROM
    (SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,

    (SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b,

    (SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) c
) numbers

WHERE DATE_ADD('2017-01-01', INTERVAL n DAY) <= '2018-12-31';

SELECT * FROM calendar LIMIT 10;
TRUNCATE TABLE calendar;
SELECT * FROM calendar LIMIT 10;

INSERT INTO calendar
SELECT
    DATE_ADD('1997-01-01', INTERVAL n DAY) AS full_date,

    YEAR(DATE_ADD('1997-01-01', INTERVAL n DAY)),

    QUARTER(DATE_ADD('1997-01-01', INTERVAL n DAY)),

    MONTH(DATE_ADD('1997-01-01', INTERVAL n DAY)),

    MONTHNAME(DATE_ADD('1997-01-01', INTERVAL n DAY)),

    DAY(DATE_ADD('1997-01-01', INTERVAL n DAY)),

    DAYNAME(DATE_ADD('1997-01-01', INTERVAL n DAY))

FROM (
    SELECT a.N + b.N * 10 + c.N * 100 AS n
    FROM
    (SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,

    (SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b,

    (SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) c
) numbers

WHERE DATE_ADD('1997-01-01', INTERVAL n DAY) <= '1998-12-31';

SELECT * FROM calendar LIMIT 10;

USE retail_db;
CREATE TABLE dim_customers AS
SELECT *
FROM customers;
CREATE TABLE dim_products AS
SELECT *
FROM products;
CREATE TABLE dim_calendar AS
SELECT *
FROM calendar;
CREATE TABLE dim_region AS
SELECT *
FROM region;
CREATE TABLE fact_returns AS
SELECT *
FROM returns;
CREATE TABLE fact_sales AS
SELECT *
FROM sales_2017;
INSERT INTO fact_sales
SELECT *
FROM sales_2018;
ALTER TABLE dim_customers
ADD PRIMARY KEY (ï»¿customer_id);
ALTER TABLE dim_products
ADD PRIMARY KEY (ï»¿product_id);
ALTER TABLE dim_calendar
ADD PRIMARY KEY (full_date);
ALTER TABLE dim_region
ADD PRIMARY KEY (ï»¿region_id);
ALTER TABLE fact_sales
ADD COLUMN sales_id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE fact_returns
ADD COLUMN return_id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE dim_customers
RENAME COLUMN `ï»¿customer_id` TO customer_id;
ALTER TABLE dim_products
RENAME COLUMN `ï»¿product_id` TO customer_id;
ALTER TABLE dim_region
RENAME COLUMN `ï»¿region_id` TO region_id;
ALTER TABLE dim_products
RENAME COLUMN `customer_id` TO product_id;
ALTER TABLE fact_sales
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES dim_customers(customer_id);
ALTER TABLE fact_sales
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id)
REFERENCES dim_products(product_id);
ALTER TABLE fact_sales
RENAME COLUMN `ï»¿transaction_date` TO transaction_date;
ALTER TABLE fact_sales
ADD CONSTRAINT fk_sales_date
FOREIGN KEY (transaction_date)
REFERENCES dim_calendar(full_date);

DESCRIBE fact_sales;
ALTER TABLE fact_sales
ADD COLUMN new_transaction_date DATE;
SET SQL_SAFE_UPDATES = 0;
UPDATE fact_sales
SET new_transaction_date =
CASE
    WHEN transaction_date LIKE '%/%'
    THEN STR_TO_DATE(transaction_date, '%m/%d/%Y')

    WHEN transaction_date LIKE '%-%'
    THEN STR_TO_DATE(transaction_date, '%d-%m-%y')
END;
SELECT transaction_date, new_transaction_date
FROM fact_sales
LIMIT 20;
ALTER TABLE fact_sales
DROP COLUMN transaction_date;
ALTER TABLE fact_sales
RENAME COLUMN new_transaction_date TO transaction_date;
ALTER TABLE fact_sales
ADD CONSTRAINT fk_sales_date
FOREIGN KEY (transaction_date)
REFERENCES dim_calendar(full_date);

ALTER TABLE fact_returns
ADD CONSTRAINT fk_return_product
FOREIGN KEY (product_id)
REFERENCES dim_products(product_id);

ALTER TABLE fact_returns
ADD CONSTRAINT fk_return_date
FOREIGN KEY (return_date)
REFERENCES dim_calendar(full_date);

ALTER TABLE fact_returns
RENAME COLUMN `ï»¿return_date` TO return_date;
ALTER TABLE fact_returns
ADD COLUMN new_return_date DATE;
UPDATE fact_returns
SET new_return_date =
CASE
    WHEN return_date LIKE '%/%'
    THEN STR_TO_DATE(return_date, '%m/%d/%Y')

    WHEN return_date LIKE '%-%'
    THEN STR_TO_DATE(return_date, '%d-%m-%y')
END;
ALTER TABLE fact_returns
DROP COLUMN return_date;
ALTER TABLE fact_returns
RENAME COLUMN new_return_date TO return_date;
ALTER TABLE fact_returns
ADD CONSTRAINT fk_return_date
FOREIGN KEY (return_date)
REFERENCES dim_calendar(full_date);

-- Cleaning
DELETE c1 FROM dim_customers c1 JOIN dim_customers c2 ON c1.customer_id = c2.customer_id AND c1.customer_acct_num > c2.customer_acct_num;

DELETE p1 FROM dim_products p1 JOIN dim_products p2 ON p1.product_id = p2.product_id AND p1.product_name > p2.product_name;

SELECT DISTINCT recyclable
FROM dim_products;
UPDATE dim_products
SET recyclable = 'N/A'
WHERE TRIM(recyclable) = '';
UPDATE dim_products
SET low_fat = 'N/A'
WHERE TRIM(low_fat) = '';

-- Phase 3: SQL Analysis & Business Queries
-- What are the top-selling products?
SELECT
    p.product_name,
    SUM(s.quantity) AS total_quantity_sold,
    SUM(s.quantity * p.product_retail_price) AS total_sales
FROM fact_sales s
JOIN dim_products p
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 10;

-- Which products generate the highest revenue?
SELECT
    p.product_name,
    SUM(s.quantity * p.product_retail_price) AS revenue
FROM fact_sales s
JOIN dim_products p
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- Which regions have the highest sales?
SELECT
    r.sales_region,
    SUM(s.quantity * p.product_retail_price) AS total_revenue
FROM fact_sales s
JOIN dim_products p
ON s.product_id = p.product_id
JOIN dim_region r
ON s.store_id = r.region_id
GROUP BY r.sales_region
ORDER BY total_revenue DESC;

-- What are the monthly sales trends?
SELECT
    c.month_name,
    c.year_num,
    SUM(s.quantity * p.product_retail_price) AS total_sales
FROM fact_sales s
JOIN dim_products p
ON s.product_id = p.product_id
JOIN dim_calendar c
ON s.transaction_date = c.full_date
GROUP BY c.year_num, c.month_name, c.month_num
ORDER BY c.year_num, c.month_num;




-- Which products have the highest return quantity?
SELECT
    p.product_name,
    SUM(r.quantity) AS total_returns
FROM fact_returns r
JOIN dim_products p
ON r.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_returns DESC
LIMIT 10;

-- Which months have the highest returns?
SELECT
    c.month_name,
    c.year_num,
    SUM(r.quantity) AS total_returns
FROM fact_returns r
JOIN dim_calendar c
ON r.return_date = c.full_date
GROUP BY c.year_num, c.month_name, c.month_num
ORDER BY total_returns DESC;

-- Which products are underperforming?
SELECT
    p.product_name,
    SUM(s.quantity * p.product_retail_price) AS revenue
FROM fact_sales s
JOIN dim_products p
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue ASC
LIMIT 10;

-- Which regions are underperforming?
SELECT
    r.sales_region,
    SUM(s.quantity * p.product_retail_price) AS total_sales
FROM fact_sales s
JOIN dim_products p
ON s.product_id = p.product_id
JOIN dim_region r
ON s.store_id = r.region_id
GROUP BY r.sales_region
ORDER BY total_sales ASC;

-- What is the sales contribution by product brand?
SELECT
    p.product_brand,
    SUM(s.quantity * p.product_retail_price) AS brand_sales
FROM fact_sales s
JOIN dim_products p
ON s.product_id = p.product_id
GROUP BY p.product_brand
ORDER BY brand_sales DESC;



-- What is the total sales by year?
SELECT
    c.year_num,
    SUM(s.quantity * p.product_retail_price) AS yearly_sales
FROM fact_sales s
JOIN dim_products p
ON s.product_id = p.product_id
JOIN dim_calendar c
ON s.transaction_date = c.full_date
GROUP BY c.year_num
ORDER BY c.year_num;

