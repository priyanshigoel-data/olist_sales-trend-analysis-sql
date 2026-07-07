-- ===================================================
-- Task 6: Sales Trend Analysis Using SQL
-- Dataset: Olist Brazilian E-commerce Dataset
-- Database: PostgreSQL
-- Author: Priyanshi Goel
-- ===================================================

Drop table if exists olist_customers_dataset ;
CREATE TABLE olist_customers_dataset(
customer_id	varchar(120) Primary key,
customer_unique_id	varchar(120),
customer_zip_code_prefix int,
customer_city	varchar(80),
customer_state varchar(20)
);

Drop table if exists olist_geolocation_dataset ;
CREATE TABLE olist_geolocation_dataset(
geolocation_zip_code_prefix	int,
geolocation_lat	float,
geolocation_lng	float,
geolocation_city	varchar(80),
geolocation_state varchar(80)
);

Drop table if exists olist_order_items_dataset ;
CREATE TABLE olist_order_items_dataset(
order_id	varchar(80),
order_item_id	 int,
product_id	varchar(80),
seller_id	varchar(80),
shipping_limit_date	timestamp,
price	float,
freight_value float,
PRIMARY KEY (order_id, order_item_id)
);

Drop table if exists olist_order_payments_dataset ;
CREATE TABLE olist_order_payments_dataset(
order_id	varchar(80),
payment_sequential	int,
payment_type	varchar(80),
payment_installments	int,
payment_value float,
PRIMARY KEY (order_id, payment_sequential)
);

Drop table if exists olist_order_reviews_dataset ;
CREATE TABLE olist_order_reviews_dataset(
review_id	varchar(100),
order_id	varchar(100),
review_score	int,
review_comment_title	Text,
review_comment_message	Text,
review_creation_date	timestamp,
review_answer_timestamp timestamp
);

Drop table if exists olist_orders_dataset ;
CREATE TABLE olist_orders_dataset(
order_id varchar(100) primary key,
customer_id	varchar(100),
order_status	varchar(100),
order_purchase_timestamp	timestamp,
order_approved_at	timestamp,
order_delivered_carrier_date	timestamp,
order_delivered_customer_date	timestamp,
order_estimated_delivery_date timestamp
);

Drop table if exists olist_products_dataset  ;
CREATE TABLE olist_products_dataset(
product_id	varchar(100) primary key,
product_category_name	varchar(200),
product_name_lenght	int,
product_description_lenght	int,
product_photos_qty	int,
product_weight_g	float,
product_length_cm	float,
product_height_cm	float,
product_width_cm float
);

Drop table if exists olist_sellers_dataset  ;
CREATE TABLE olist_sellers_dataset(
seller_id	varchar(100) primary key,
seller_zip_code_prefix	int,
seller_city	varchar(100),
seller_state varchar(80)
);

Drop table if exists product_category_name_translati ;
CREATE TABLE product_category_name_translati(
product_category_name	varchar(200),
product_category_name_english varchar(200)
);

ALTER TABLE olist_customers_dataset
RENAME TO customers;

ALTER TABLE olist_orders_dataset
RENAME TO orders;

ALTER TABLE olist_order_items_dataset
RENAME TO order_items;

ALTER TABLE olist_products_dataset
RENAME TO products;

ALTER TABLE olist_order_reviews_dataset
RENAME TO reviews;

ALTER TABLE olist_order_payments_dataset
RENAME TO payments;

ALTER TABLE olist_sellers_dataset
RENAME TO sellers;

Alter Table olist_geolocation_dataset
RENAME TO locations;

--Q1 How many orders does each customer place?
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) as total_orders
FROM orders as o
JOIN customers as c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
ORDER BY 2 DESC;

--Which customers are repeat buyers, and how many are there?

SELECT
    COUNT(*) AS repeat_customers
FROM (
   SELECT
    c.customer_unique_id,
    COUNT(o.order_id) as total_orders
	FROM orders as o
	JOIN customers as c
    ON o.customer_id = c.customer_id
	GROUP BY c.customer_unique_id
	Having count(o.order_id)>1
)rc;
 
--Repeat Customers
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) as total_orders
FROM orders as o
JOIN customers as c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
Having count(o.order_id)>1
ORDER BY 2 DESC;

--Monthly revenue and order volume
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    SUM(oi.price) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS order_volume
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY
    EXTRACT(YEAR FROM o.order_purchase_timestamp),
    EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY
    year,
    month;

--Find the top 5 months by revenue

SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    SUM(oi.price) AS total_revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY
    EXTRACT(YEAR FROM o.order_purchase_timestamp),
    EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY total_revenue DESC
LIMIT 5;


--Analyze only 2018 sales

SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    SUM(oi.price) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS order_volume
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY month;


--Average order value by month

SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    ROUND(AVG(oi.price), 2) AS average_order_value
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY
    EXTRACT(YEAR FROM o.order_purchase_timestamp),
    EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY year, month;