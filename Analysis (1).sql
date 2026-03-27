-- =====================================================================
-- ======================   SECTION 1: BASIC INFO   =====================
-- =====================================================================

-- 1a. Data type of all columns in the customers table
SELECT * FROM target-analysis-477811.Target.customers;

-- 1b. Time range of order placements
SELECT MIN(order_purchase_timestamp) AS start_time,
       MAX(order_purchase_timestamp) AS end_time
FROM target-analysis-477811.Target.orders;

-- 1c. Cities & States of customers who ordered in selected months of 2017
SELECT c.customer_city, c.customer_state
FROM target-analysis-477811.Target.orders AS o
JOIN target-analysis-477811.Target.customers AS c
  ON o.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2017
  AND EXTRACT(MONTH FROM order_purchase_timestamp) IN (1,3,5,7,9,11);

-- =====================================================================
-- ======================   SECTION 2: ORDERING TRENDS   ===============
-- =====================================================================

-- 2a. Growing trend in number of orders over the years
SELECT
       EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
       EXTRACT(MONTH FROM order_purchase_timestamp) AS month_order,
       COUNT(order_id) AS order_count
FROM target-analysis-477811.Target.orders
GROUP BY EXTRACT(YEAR FROM order_purchase_timestamp),EXTRACT(MONTH FROM order_purchase_timestamp)
ORDER BY month_order;

-- 2c. Preferred time of day for placing orders
SELECT CASE
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Mornings'
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
         ELSE 'Night'
       END AS time_slot,
       COUNT(order_id) AS order_count
FROM target-analysis-477811.Target.orders
GROUP BY time_slot
ORDER BY order_count DESC;

-- NEW: 2d. Monthly & YoY Sales Trend (Orders + GMV)
-- (No SQL provided earlier — placeholder for your future query)
-- TRACK monthly orders, GMV, and YoY growth.



-- =====================================================================
-- ======================   SECTION 3: GEOGRAPHIC   =====================
-- =====================================================================

-- 3a. Month-on-month number of orders for each year
SELECT COUNT(order_id) AS order_count,
       EXTRACT(MONTH FROM order_purchase_timestamp) AS order_month,
       EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year
FROM target-analysis-477811.Target.orders
GROUP BY order_month, order_year
ORDER BY order_year, order_month;

-- 3b. Customer distribution across states
SELECT customer_city, customer_state,
       COUNT(DISTINCT customer_id) AS cust_count
FROM target-analysis-477811.Target.customers
GROUP BY customer_city, customer_state
ORDER BY cust_count DESC; 

-- NEW: 3c. Geographic Performance (Orders, Revenue, Delivery Speed)
-- (Add later: orders + GMV + avg delivery time by state/city)

select * from target-analysis-477811.Target.geolocation;
-- NEW: 3d. Delivery Speed by Region
-- (Add later: avg delivery time grouped by state/city)



-- =====================================================================
-- ======================   SECTION 4: COSTS & REVENUE   ===============
-- =====================================================================

-- 4a. % Increase in cost of orders from 2017 to 2018 (Jan–Aug)
WITH cte1 AS (
  SELECT SUM(p.payment_value) AS cost,
         EXTRACT(YEAR FROM order_purchase_timestamp) AS year
  FROM target-analysis-477811.Target.orders AS o
  JOIN target-analysis-477811.Target.payments AS p
    ON o.order_id = p.order_id
  WHERE EXTRACT(YEAR FROM order_purchase_timestamp) IN (2017, 2018)
    AND EXTRACT(MONTH FROM order_purchase_timestamp) BETWEEN 1 AND 8
  GROUP BY year
),
cte2 AS (
  SELECT year, cost,
         LAG(cost) OVER (ORDER BY year) AS prev_year
  FROM cte1
)
SELECT *, ROUND(((cost - prev_year) / prev_year) * 100, 2) AS growth
FROM cte2;

-- 4b. Total & Avg order price per state
SELECT customer_state,
       SUM(oi.price) AS total_price,
       AVG(oi.price) AS avg_price
FROM target-analysis-477811.Target.order_items AS oi
JOIN target-analysis-477811.Target.orders AS o ON oi.order_id = o.order_id
JOIN target-analysis-477811.Target.customers AS c ON c.customer_id = o.customer_id
GROUP BY customer_state;

-- 4c. Total & Avg freight per state
SELECT customer_state,
       SUM(oi.freight_value) AS total_freight,
       AVG(oi.freight_value) AS avg_freight
FROM target-analysis-477811.Target.order_items AS oi
JOIN target-analysis-477811.Target.orders AS o ON oi.order_id = o.order_id
JOIN target-analysis-477811.Target.customers AS c ON c.customer_id = o.customer_id
GROUP BY customer_state;

-- NEW: 4d. Top Product Categories (Revenue + Volume)
-- Uses your earlier top products query.

-- NEW: 4e. AOV Drivers (Category, Region, Time-of-Day)
-- Will combine category, location & time-of-day for AOV insights.



-- =====================================================================
-- ========================   SECTION 5: DELIVERY   =====================
-- =====================================================================

-- 5a. Days to deliver + diff between actual & estimated delivery
SELECT order_id,
       DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS days_to_deliver,
       DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS delivery_days_diff
FROM target-analysis-477811.Target.orders;

-- 5b. Top 5 states with highest avg freight
SELECT customer_state,
       ROUND(AVG(oi.freight_value)) AS avg_freight_value
FROM target-analysis-477811.Target.orders AS o
JOIN target-analysis-477811.Target.order_items AS oi ON o.order_id = oi.order_id
JOIN target-analysis-477811.Target.customers AS c ON c.customer_id = o.customer_id
GROUP BY customer_state
ORDER BY avg_freight_value DESC
LIMIT 5;

-- 5b. Lowest avg freight
SELECT customer_state,
       ROUND(AVG(oi.freight_value)) AS avg_freight_value
FROM target-analysis-477811.Target.orders AS o
JOIN target-analysis-477811.Target.order_items AS oi ON o.order_id = oi.order_id
JOIN target-analysis-477811.Target.customers AS c ON c.customer_id = o.customer_id
GROUP BY customer_state
ORDER BY avg_freight_value
LIMIT 5;

-- 5c. Top 5 states by highest avg delivery time
SELECT customer_state,
       AVG(DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY)) AS avg_delivery_time
FROM target-analysis-477811.Target.orders AS o
JOIN target-analysis-477811.Target.customers AS c ON o.customer_id = c.customer_id
GROUP BY customer_state
ORDER BY avg_delivery_time DESC
LIMIT 5;

-- 5d. Fastest delivery vs estimated date
SELECT customer_state,
       order_estimated_delivery_date,
       order_delivered_customer_date,
       DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS delivery_diff
FROM target-analysis-477811.Target.orders AS o
JOIN target-analysis-477811.Target.customers AS c ON o.customer_id = c.customer_id
WHERE DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) IS NOT NULL
ORDER BY delivery_diff ASC
LIMIT 5;

-- NEW: 5e. Late Delivery % + Root Cause (distance, freight, category, seller)
-- Placeholder for your detailed late-delivery model.

-- NEW: 5f. Delivery Time Breakdown (Warehouse vs Shipping Transit)
-- Requires additional timestamp fields if available.



-- =====================================================================
-- =====================   SECTION 6: PAYMENT BEHAVIOUR   ==============
-- =====================================================================

-- 6a. Month-on-month orders by payment type
SELECT payment_type,
       EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
       EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
       COUNT(DISTINCT p.order_id) AS no_of_orders
FROM target-analysis-477811.Target.payments AS p
JOIN target-analysis-477811.Target.orders AS o ON p.order_id = o.order_id
GROUP BY payment_type, year, month
ORDER BY payment_type, year, month;

-- 6b. Orders by installments
SELECT COUNT(DISTINCT order_id) AS no_of_orders,
       payment_installments
FROM target-analysis-477811.Target.payments
GROUP BY payment_installments;

-- NEW: 6c. Installment Usage % (extension)
-- Add installment share of GMV + orders.



-- =====================================================================
-- =======================   SECTION 7: BASIC EDA   =====================
-- =====================================================================

SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)
FROM target-analysis-477811.Target.orders;

SELECT COUNT(DISTINCT customer_state) AS c_states,
       COUNT(DISTINCT customer_city) AS c_city
FROM target-analysis-477811.Target.customers;

SELECT COUNT(DISTINCT seller_state) AS s_state,
       COUNT(DISTINCT seller_city) AS s_city
FROM target-analysis-477811.Target.sellers;

SELECT COUNT(DISTINCT seller_id)
FROM target-analysis-477811.Target.sellers;

SELECT COUNT(product_id), `product category`
FROM target-analysis-477811.Target.products
GROUP BY `product category`
ORDER BY COUNT(product_id) DESC;

SELECT DISTINCT `product category`
FROM target-analysis-477811.Target.products;

SELECT COUNT(DISTINCT product_id) AS prod_cat
FROM target-analysis-477811.Target.products;

SELECT AVG(freight_value), AVG(price)
FROM target-analysis-477811.Target.order_items;

SELECT DISTINCT payment_type
FROM target-analysis-477811.Target.payments;

SELECT oi.product_id,
       `product category`,
       COUNT(oi.product_id) AS count_p
FROM target-analysis-477811.Target.products AS p
JOIN target-analysis-477811.Target.order_items AS oi ON p.product_id = oi.product_id
GROUP BY oi.product_id, `product category`
ORDER BY count_p DESC
LIMIT 10;

SELECT COUNT(DISTINCT geolocation_zip_code_prefix)
FROM target-analysis-477811.Target.geolocation;

SELECT order_id,
       SUM(payment_value) AS total_payment_value,
       COUNT(*) AS payment_row_count,
       MAX(payment_installments) AS installments
FROM target-analysis-477811.Target.payments
GROUP BY order_id;

SELECT COUNT(DISTINCT order_id)
FROM target-analysis-477811.Target.orders;

SELECT `product category` AS prod_cat,
       SUM(ROUND(price))
FROM target-analysis-477811.Target.order_items AS oi
JOIN target-analysis-477811.Target.products AS p ON p.product_id = oi.product_id
GROUP BY prod_cat;

SELECT payment_type, SUM(payment_value) AS revenue_paym_types
FROM target-analysis-477811.Target.payments
GROUP BY payment_type
ORDER BY revenue_paym_types DESC;

SELECT SUM(payment_value) AS total_revenue
FROM target-analysis-477811.Target.payments;

SELECT COUNT(customer_unique_id) AS unique_customers
FROM target-analysis-477811.Target.customers;

SELECT review_score, COUNT(review_score) AS rating
FROM target-analysis-477811.Target.order_reviews
GROUP BY review_score
ORDER BY COUNT(review_score) DESC;

-- NEW: 7a. Repeat Customer Rate
-- NEW: 7b. Customer LTV
-- NEW: 7c. Cohort Retention Analysis



-- =====================================================================
-- =======================   SECTION 8: CARDINALITY   ===================
-- =====================================================================

SELECT COUNT(DISTINCT(order_id)) AS FK, COUNT(*) AS all_rows,
       CASE WHEN COUNT(DISTINCT(order_id)) < COUNT(*) THEN 'MANY TO ONE' ELSE 'ONE TO ONE' END AS cardinality
FROM target-analysis-477811.Target.order_reviews;

SELECT COUNT(DISTINCT(order_id)) AS FK, COUNT(*) AS all_rows,
       CASE WHEN COUNT(DISTINCT(order_id)) < COUNT(*) THEN 'MANY TO ONE' ELSE 'ONE TO ONE' END AS cardinality
FROM target-analysis-477811.Target.orders;

SELECT COUNT(DISTINCT(order_id)) AS FK, COUNT(*) AS all_rows,
       CASE WHEN COUNT(DISTINCT(order_id)) < COUNT(*) THEN 'MANY TO ONE' ELSE 'ONE TO ONE' END AS cardinality
FROM target-analysis-477811.Target.payments;

SELECT COUNT(DISTINCT(order_id)) AS FK, COUNT(*) AS all_rows,
       CASE WHEN COUNT(DISTINCT(order_id)) < COUNT(*) THEN 'MANY TO ONE' ELSE 'ONE TO ONE' END AS cardinality
FROM target-analysis-477811.Target.order_items;

SELECT COUNT(DISTINCT(product_id)) AS FK, COUNT(*) AS all_rows,
       CASE WHEN COUNT(DISTINCT(product_id)) < COUNT(*) THEN 'MANY TO ONE' ELSE 'ONE TO ONE' END AS cardinality
FROM target-analysis-477811.Target.order_items;

SELECT COUNT(DISTINCT(seller_id)) AS FK, COUNT(*) AS all_rows,
       CASE WHEN COUNT(DISTINCT(seller_id)) < COUNT(*) THEN 'MANY TO ONE' ELSE 'ONE TO ONE' END AS cardinality
FROM target-analysis-477811.Target.order_items;

SELECT COUNT(DISTINCT(customer_zip_code_prefix)) AS FK, COUNT(*) AS all_rows,
       CASE WHEN COUNT(DISTINCT(customer_zip_code_prefix)) < COUNT(*) THEN 'MANY TO ONE' ELSE 'ONE TO ONE' END AS cardinality
FROM target-analysis-477811.Target.customers;

SELECT COUNT(DISTINCT(seller_zip_code_prefix)) AS FK, COUNT(*) AS all_rows,
       CASE WHEN COUNT(DISTINCT(seller_zip_code_prefix)) < COUNT(*) THEN 'MANY TO ONE' ELSE 'ONE TO ONE' END AS cardinality
FROM target-analysis-477811.Target.sellers;



-- =====================================================================
-- =======================   SECTION 9: EXTRA ANALYSIS   ===============
-- =====================================================================

-- Does having more product photos correlate with revenue?
SELECT p.product_id AS prod_id,
       SUM(oi.price) AS price,
       COUNT(product_photos_qty) AS photo_count
FROM target-analysis-477811.Target.order_items AS oi
JOIN target-analysis-477811.Target.products AS p
  ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY COUNT(product_photos_qty);

-- NEW: 9a. Category Cannibalization
-- NEW: 9b. Seller Distance vs Delivery Time/Freight
-- NEW: 9c. Price vs Freight Correlation
-- NEW: 9d. Additional geographic performance queries

-- =====================================================================
-- =======================   END OF FINAL SCRIPT   =====================
-- =====================================================================

