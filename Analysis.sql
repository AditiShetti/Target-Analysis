#1a. Data type of all columns in the "customers" table. 
select * from target-analysis-477811.Target.customers;

#1b. Get the time range between which the orders were placed.
select min(order_purchase_timestamp)as start_time, max(order_purchase_timestamp) as end_time
from target-analysis-477811.Target.orders;


#1c. Display details of the Cities & States of customers who ordered during the given period.
select c.customer_city, c.customer_state
from target-analysis-477811.Target.orders as o
join target-analysis-477811.Target.customers as c on o.customer_id= c.customer_id
where extract(YEAR from order_purchase_timestamp)= 2017 and 
extract (month from order_purchase_timestamp) in (1,3,5,7,9,11);


# 2a). Is there a growing trend in the no. of orders placed over the past years?
select count(order_id) as order_count,extract(month from order_purchase_timestamp) as month_order,
from target-analysis-477811.Target.orders
group by extract(month from order_purchase_timestamp)
order by month_order ;
#2b . Monthly Seasonality as per previous qn? In the month of Aug and May, highest orders were placed.

#2c.During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
#■ 0-6 hrs : Dawn
#■ 7-12 hrs : Mornings
#■ 13-18 hrs : Afternoon
#■ 19-23 hrs : Night

select 
      case when extract(hour from order_purchase_timestamp) between 0 and 6 then "Dawn"
           when extract(hour from order_purchase_timestamp) between 7 and 12 then "Mornings"
           when extract(hour from order_purchase_timestamp) between 13 and 18 then "Afternoon"
           else "Night" 
      end as time_slot  , count(order_id) as order_count
from target-analysis-477811.Target.orders
group by time_slot 
order by order_count desc;


# 3a. Get the month on month no. of orders placed in each state.
select count(order_id) as order_count,
extract(month from order_purchase_timestamp) as order_month,
extract(year from order_purchase_timestamp) as order_year
from target-analysis-477811.Target.orders
group by extract(month from order_purchase_timestamp),extract(year from order_purchase_timestamp)
order by order_year, order_month;

#3b. How are the customers distributed across all the states?
select customer_city,customer_state,
count(distinct customer_id) as cust_count
from target-analysis-477811.Target.customers
group by customer_city, customer_state
order by cust_count desc;


#4a. Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only). 
#Use payments table 

With cte1 as
(
SELECT sum(p.payment_value) as cost,
      EXTRACT(YEAR from order_purchase_timestamp) as year
FROM target-analysis-477811.Target.orders as o 
JOIN target-analysis-477811.Target.payments as p 
on o.order_id = p.order_id 
WHERE EXTRACT(YEAR from order_purchase_timestamp) in (2017, 2018)
and EXTRACT(MONTH from order_purchase_timestamp) between 1 and 8
GROUP BY EXTRACT(YEAR from order_purchase_timestamp)
),
cte2 as 
(SELECT year, cost,
       lag(cost) over(order by year asc) as prev_year
FROM cte1
)
SELECT *, round(((cost-prev_year)/prev_year)*100,2) as growth
FROM cte2 ;



#4b. Calculate the Total & Average value of order price for each state.
SELECT customer_state, 
      sum(oi.price) as total_price ,
      avg(oi.price) as avg_price
FROM target-analysis-477811.Target.order_items as oi
JOIN target-analysis-477811.Target.orders as o on oi.order_id= o.order_id
JOIN target-analysis-477811.Target.customers as c on c.customer_id= o.customer_id
GROUP BY customer_state;

#4c. Calculate the Total & Average value of order freight for each state. 
SELECT customer_state, 
      sum(oi.freight_value) as total_freight ,
      avg(oi.freight_value) as avg_freight
FROM target-analysis-477811.Target.order_items as oi
JOIN target-analysis-477811.Target.orders as o on oi.order_id= o.order_id
JOIN target-analysis-477811.Target.customers as c on c.customer_id= o.customer_id
GROUP BY customer_state;


#5a. 1. Find the no. of days taken to deliver each order from the order’s purchase date as delivery time. 
#Also, calculate the difference (in days) between the estimated & actual 
#delivery date of an order.Do this in a single query. 
#■time_to_deliver = order_delivered_customer_date - order_purchase_timestamp 
#■ diff_estimated_delivery = order_delivered_customer_date - order_estimated_delivery_date
SELECT order_id,
      date_diff(order_delivered_customer_date,order_purchase_timestamp,DAY) as days_to_deliver,
      date_diff(order_delivered_customer_date,order_estimated_delivery_date,DAY) as delivery_days_diff
FROM target-analysis-477811.Target.orders;


#5b. Find out the top 5 states with the highest & lowest average freight value. 
-- Top 5 states with highest avg freight value
SELECT customer_state,
       round(AVG(oi.freight_value)) as avg_freight_value,
FROM target-analysis-477811.Target.orders as o
JOIN target-analysis-477811.Target.order_items as oi ON o.order_id=oi.order_id
JOIN target-analysis-477811.Target.customers as c ON c.customer_id= o.customer_id
GROUP BY customer_state
ORDER BY avg_freight_value desc
LIMIT 5;

-- Top 5 states with lowest avg freight value
SELECT customer_state,
       round(AVG(oi.freight_value)) as avg_freight_value,
FROM target-analysis-477811.Target.orders as o
JOIN target-analysis-477811.Target.order_items as oi ON o.order_id=oi.order_id
JOIN target-analysis-477811.Target.customers as c ON c.customer_id= o.customer_id
GROUP BY customer_state
ORDER BY avg_freight_value
LIMIT 5;

#5c. Find out the top 5 states with the highest & lowest average delivery time. 
SELECT customer_state, 
       avg(date_diff(order_delivered_customer_date,order_purchase_timestamp, DAY)) as avg_delivery_time
FROM target-analysis-477811.Target.orders AS o
JOIN target-analysis-477811.Target.customers as c 
ON o.customer_id = c.customer_id
GROUP BY customer_state
ORDER BY avg_delivery_time DESC LIMIT 5 ;


#5d. Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery. 
#You can use the difference between the averages of actual & estimated delivery date to figure out how fast the delivery was for each state. 

# AVG OF DATEDIFF  ???
SELECT customer_state, 
      order_estimated_delivery_date as estimated_date,
      order_delivered_customer_date as actual_date,
      date_diff(order_delivered_customer_date,order_estimated_delivery_date,DAY) as delivery_diff
FROM target-analysis-477811.Target.orders AS o
JOIN target-analysis-477811.Target.customers as c 
ON o.customer_id = c.customer_id
WHERE date_diff(order_delivered_customer_date,order_estimated_delivery_date,DAY) is not null
ORDER BY delivery_diff asc
LIMIT 5;

#6.a. Find the month on month no. of orders placed using different payment types. 
SELECT
      payment_type,
      EXTRACT(YEAR from order_purchase_timestamp) as year,
      EXTRACT(MONTH from order_purchase_timestamp) as month,
      count(distinct(p.order_id)) as no_of_orders
FROM target-analysis-477811.Target.payments as p
JOIN target-analysis-477811.Target.orders as o on p.order_id= o.order_id
group by payment_type,year,month
ORDER BY payment_type,year, month;


#6b. Find the no. of orders placed on the basis of the payment installments that have been paid. 
SELECT count(distinct(order_id)) as no_of_orders, payment_installments
FROM target-analysis-477811.Target.payments
group by payment_installments;


---------------------------------- EDA and Basic overview of Dataset------------------------------


#Date range of dataset
select min(order_purchase_timestamp), max(order_purchase_timestamp)
FROM target-analysis-477811.Target.orders;

# Count of customers, count of customer state, city
SELECT count(distinct(customer_state)) as c_states,
count(distinct(customer_city)) as c_city, 
FROM target-analysis-477811.Target.customers;

#Seller state, city
SELECT count(distinct(seller_state)) as s_state,
count(distinct(seller_city)) as s_city
FROM target-analysis-477811.Target.sellers;

# No. of sellers - 3095
SELECT count(distinct(seller_id))
FROM target-analysis-477811.Target.sellers;

# count of Product in each category (32k products in 73 prod categories with bedtable bath being the highest)
SELECT count(product_id), `product category`
FROM target-analysis-477811.Target.products
group by `product category` ORDER BY count(product_id) DESC;

#DIFF CATEGORIES: 
SELECT  distinct`product category`
FROM target-analysis-477811.Target.products;

# COUNT OF DISTINCT PRODUCTS
SELECT count(distinct(product_id)) as prod_cat
FROM target-analysis-477811.Target.products;

#Avg price and freight value
select avg(freight_value), avg(price)
from target-analysis-477811.Target.order_items;

#types of paym methods
SELECT distinct(payment_type)
FROM target-analysis-477811.Target.payments;

#TOP 10 SELLING PRODUCTS 
 SELECT oi.product_id, `product category`, count(oi.product_id) as count_p
 FROM target-analysis-477811.Target.products as p
 JOIN target-analysis-477811.Target.order_items as oi on p.product_id= oi.product_id
 group by oi.product_id, `product category`
 order by count_p desc
 limit 10;


# no of diff zip codes
select count(distinct(geolocation_zip_code_prefix))
from target-analysis-477811.Target.geolocation;


# PAYMENT
SELECT
  order_id,
  SUM(payment_value) AS total_payment_value,
  COUNT(*) AS payment_row_count,
  MAX(payment_installments) AS installments
FROM `target-analysis-477811.Target.payments`
GROUP BY order_id;


select count(distinct(order_id))
from target-analysis-477811.Target.orders;


# Total Price per prod category.
SELECT `product category` as prod_cat,sum(round(price))
FROM target-analysis-477811.Target.order_items as oi
JOIN target-analysis-477811.Target.products as p
ON p.product_id= oi.product_id
GROUP BY prod_cat;

# Types of payment methods and their revenue
select payment_type,sum(payment_value) as revenue_paym_types
from target-analysis-477811.Target.payments
group by payment_type 
order by revenue_paym_types desc;

# Total revenue
select sum(payment_value) as total_revenue
from target-analysis-477811.Target.payments;

#Count of unique customers
select count(customer_unique_id) as unique_customers
from target-analysis-477811.Target.customers;

# REVIEW 
SELECT review_score,count(review_score) as rating
FROM target-analysis-477811.Target.order_reviews
GROUP BY review_score
ORDER BY count(review_score) DESC;

#GEOLOCATION
select distinct(geolocation_city)
from target-analysis-477811.Target.geolocation;

# Count of products in each category
SELECT `product category`,count(product_id) as prod_count 
FROM `target-analysis-477811.Target.products` 
group by `product category` order by prod_count desc;


# Orders and their payment details
select customer_id,orders.order_id , order_estimated_delivery_date,payment_type,payment_value
from target-analysis-477811.Target.orders
right join target-analysis-477811.Target.payments
on orders.order_id = payments.order_id;


# Products without images
select * from target-analysis-477811.Target.products
where product_photos_qty is null;


# Customers locatn with lat long.
select customer_id,customer_city,geolocation_lat,geolocation_lng
from target-analysis-477811.Target.geolocation
join target-analysis-477811.Target.customers
on customers.customer_zip_code_prefix = geolocation.geolocation_zip_code_prefix limit 20;


# Repeat customers
select count(customer_id) as all_cust, count(customer_unique_id) as unique_cust,
count(customer_id)-count(customer_unique_id) as repeat_cust
from target-analysis-477811.Target.customers;


# Cusomers and orders table relation:  many to one?
select count(*),count(o.customer_id) as cust_in_orders, count(c.customer_unique_id) as all_cust_count
from target-analysis-477811.Target.customers as c 
join target-analysis-477811.Target.orders as o
on c.customer_id= o.customer_id;




---------- CHECKING CARDINALITY OF THE TABLES PAIRWISE-----------------

-- IF COUNT(DISTINCT FK) < COUNT(*) THEN MANY TO MANY else ONE TO ONE

-- Order_reviews and Orders . Many to One
SELECT COUNT(DISTINCT(order_id)) as FK , COUNT(*) as all_rows,
       CASE WHEN COUNT(DISTINCT(order_id)) <  COUNT(*) then "MANY TO ONE" else "ONE TO ONE" 
       END AS cardinality
FROM target-analysis-477811.Target.order_reviews;


-- orders and customer. ONE TO ONE
SELECT COUNT(DISTINCT(order_id)) as FK , COUNT(*) as all_rows,
       CASE WHEN COUNT(DISTINCT(order_id)) <  COUNT(*) then "MANY TO ONE" else "ONE TO ONE" 
       END AS cardinality
FROM target-analysis-477811.Target.orders;


-- orders and payments. MANY TO ONE.
SELECT COUNT(DISTINCT(order_id)) as FK , COUNT(*) as all_rows,
       CASE WHEN COUNT(DISTINCT(order_id)) <  COUNT(*) then "MANY TO ONE" else "ONE TO ONE" 
       END AS cardinality
FROM target-analysis-477811.Target.payments;

-- ORDER ITEMS AND ORDER. Many to one
SELECT COUNT(DISTINCT(order_id)) as FK , COUNT(*) as all_rows,
       CASE WHEN COUNT(DISTINCT(order_id)) <  COUNT(*) then "MANY TO ONE" else "ONE TO ONE" 
       END AS cardinality
FROM target-analysis-477811.Target.order_items;


-- Product and ORDER ITEMS. Many to one
SELECT COUNT(DISTINCT(product_id)) as FK , COUNT(*) as all_rows,
       CASE WHEN COUNT(DISTINCT(product_id)) <  COUNT(*) then "MANY TO ONE" else "ONE TO ONE" 
       END AS cardinality
FROM target-analysis-477811.Target.order_items;


-- SELLER and ORDER ITEMS. many to one
SELECT COUNT(DISTINCT(seller_id)) as FK , COUNT(*) as all_rows,
       CASE WHEN COUNT(DISTINCT(seller_id)) <  COUNT(*) then "MANY TO ONE" else "ONE TO ONE" 
       END AS cardinality
FROM target-analysis-477811.Target.order_items;

-- geolocation and customers
SELECT COUNT(DISTINCT(customer_zip_code_prefix)) as FK , COUNT(*) as all_rows,
       CASE WHEN COUNT(DISTINCT(customer_zip_code_prefix)) <  COUNT(*) then "MANY TO ONE" else "ONE TO ONE" 
       END AS cardinality
FROM target-analysis-477811.Target.customers;

-- geolocation and sellers
SELECT COUNT(DISTINCT(seller_zip_code_prefix)) as FK , COUNT(*) as all_rows,
       CASE WHEN COUNT(DISTINCT(seller_zip_code_prefix)) <  COUNT(*) then "MANY TO ONE" else "ONE TO ONE" 
       END AS cardinality
FROM target-analysis-477811.Target.sellers;


# Month on month no. of orders placed over the past years?
select count(order_id) as order_count,
       extract(month from order_purchase_timestamp) as month_order,
       extract(year from order_purchase_timestamp) as year
from target-analysis-477811.Target.orders
group by extract(year from order_purchase_timestamp),extract(month from order_purchase_timestamp)
order by month_order,year ;

