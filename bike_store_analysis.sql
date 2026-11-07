-- Bike Store Sales Analysis
-- by Sanzida Siddike
--
-- Tool: MySQL 8.0 (Workbench)
-- Data: Bike Store Sample Database from Kaggle
-- https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database
-- 9 csv files imported with Workbench's Table Data Import Wizard
--
-- revenue in this file = quantity * list_price * (1 - discount), from order_items


-- ---------------- Setup ----------------
CREATE DATABASE IF NOT EXISTS bike_store;
USE bike_store;

-- 1. row count of every table (to check the import worked)
SELECT 'brands' AS table_name, COUNT(*) AS total_rows FROM brands
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'stores', COUNT(*) FROM stores
UNION ALL SELECT 'staffs', COUNT(*) FROM staffs
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'stocks', COUNT(*) FROM stocks;


-- quick look at the main tables
SELECT * FROM customers LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;
-- order_status: 1 = Pending, 2 = Processing, 3 = Rejected, 4 = Completed


-- ---------------- Part 1: basic queries ----------------

-- 2. customers from New York
SELECT first_name,last_name,city
FROM customers
WHERE state = 'NY';


-- 3. most expensive products (top 15)
SELECT product_name, list_price
FROM products
order by  list_price DESC
LIMIT 15;


-- 4. customers with no phone number
-- checking real NULL and the text 'NULL' both, csv import can save empty cells as text
Select first_name,last_name,phone
from customers
where phone IS NULL or phone='NULL' or phone=' ';


-- 5. rejected orders, latest first
Select order_id,customer_id,order_date,store_id
from orders
where order_status =3
order by order_date desc;


-- 6. how many 2018 model products
select count(*) as 2018_model_years
from products
where model_year= 2018;


-- 7. electric bikes
select product_name, list_price
from products
where product_name like '%Electric%';


-- 8. orders from 2016
select order_id, order_date, customer_id
from orders
where year(order_date) = 2016
order by order_date desc;


-- 9. customers from CA or TX
-- first tried state = 'CA' or 'TX' but that only counted CA, IN works
select count(*) as ca_tx_customers
from customers
-- where state = 'CA' or state= 'TX'-- 
where state in ('TX','CA');


-- 10. products between $500 and $1000
select product_name,product_id,list_price
from products
where list_price between 500 and 1000
order by list_price asc;


-- 11. which cities the stores are in
select store_name, store_id, city
from stores;


-- 12. customers and their city
select distinct customer_id, city
from customers;


-- ---------------- Part 2: group by / having ----------------

-- 13. customers in each state
select state, count(*) as total_customer
from customers
group by  state 
order by total_customer desc;


-- 14. orders per store
select store_id, count(*) as total_orders
from orders
group by store_id
order by total_orders desc;


-- 15. number of products and avg price per category
select category_id, count(*) as total_products,
									round(avg(list_price),2)  as avg_price
                                    from products
                                    group by category_id;
                                    

-- 16. cities with more than 10 customers
-- used 10 because no city has more than 20
select  city, count(*) as total_customers
from customers
group  by   city
having count(*)>10;


-- 17. orders per year
-- 2018 looked much lower than the other years, so checked the dates below
select year(order_date) as order_year, count(*) as total_orders
from orders
group by year(order_date)
order by order_year desc;


-- 18. first and last order date
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order
FROM orders;


-- 19. 2018 orders month by month
-- 2018 data is not complete, so 2018 is not a fair comparison with 2016/2017
SELECT MONTH(order_date) AS month_no, COUNT(*) AS total_orders
FROM orders
WHERE YEAR(order_date) = 2018
GROUP BY MONTH(order_date)
ORDER BY month_no;


-- ---------------- Part 3: joins and revenue ----------------

-- 20. product with brand name
select p.product_name, b.brand_name
from products p 
join brands b on p.brand_id = b.brand_id;


-- 21. product with category name
select p.product_name, c.category_name
from products p
join categories c on p.category_id = c.category_id;


-- 22. product, brand, category and price together
select p.product_name,b.brand_name, c.category_name, p.list_price
from products p
join brands b on p.brand_id = b.brand_id
join categories c on p.category_id = c.category_id;


-- 23. revenue of each order line, checking the formula first
select order_id,	item_id,	product_id,	quantity,	list_price,	discount,
quantity * list_price* (1-discount) as revenue
from order_items
limit 10;


-- 24. total revenue
select 
round(sum(quantity*list_price*(1-discount)),2) as total_revenue
from order_items;


-- 25. revenue by brand
select b.brand_name,
round(sum(oi.quantity*oi.list_price*(1-oi.discount)),2) as revenue
from order_items oi
join products p on oi.product_id= p.product_id
join brands b on p.brand_id = b.brand_id
group by b.brand_name
order by revenue desc;


-- 26. revenue by category
select c.category_name,
round(sum(oi.quantity*oi.list_price*(1-oi.discount)),2) as revenue
from order_items oi
join products p on oi.product_id = p.product_id
join categories c on p.category_id = c.category_id
group by c.category_name
order by revenue desc;


-- 27. products that were never sold (left join + is null)
select p.product_id,p.product_name, p.list_price, oi.order_id
from products p
left join order_items oi on p.product_id = oi.product_id
where oi.order_id is null;


-- 28. count of never sold products
SELECT COUNT(*) AS never_sold
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;


-- 29. top 10 customers by spending
select c.customer_id, c.first_name,c.last_name,
round(sum(oi.quantity*oi.list_price*(1-oi.discount)),2) as total_spent
from order_items oi
join orders o on oi.order_id = o.order_id
join customers c on o.customer_id = c.customer_id
group by c.customer_id, c.first_name,c.last_name
order by total_spent desc
limit 10;


-- 30. staff and their manager (self join)
-- manager_id is the staff_id of the manager, built it step by step
select s.manager_id, s.first_name
from staffs s;

select s.first_name, s.manager_id
from staffs s
left join staffs f on s.manager_id= f.staff_id;

select f.first_name as manager_name, s.first_name as staff_name , s.manager_id
from staffs s
left join staffs f on s.manager_id= f.staff_id;


-- ---------------- Part 4: case when and dates ----------------

-- 31. orders by status name
select case
when order_status ='1' then 'pending'
when order_status ='2' then 'processing'
when order_status ='3' then 'rejected'
when order_status ='4' then 'completed'
end as status_name,

count(*) as total_orders
from orders
group by status_name
order by total_orders desc;


-- 32. price group of each product (budget < 500, mid_range < 1000, high)
select product_name, list_price,
case 
when list_price <500 then 'budget'
when list_price <1000 then 'mid_range'
else 'high'
end as price_segment
from products;


-- 33. how many products in each price group
select case 
when list_price <500 then 'budget'
when list_price <1000 then 'mid_range'
else 'high'
end as price_segment,
count(*) as total_price_segment,
ROUND(AVG(list_price), 2) as avg_price_segment
from products
group by price_segment
order by total_price_segment desc;


-- 34. monthly revenue
select date_format(o.order_date, '%Y-%m') as order_month,
round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as revenue
from order_items oi
join orders o on oi.order_id = o.order_id
group by order_month
order by order_month;


-- trying DATEDIFF
SELECT DATEDIFF('2017-01-05', '2017-01-01');


-- 35. days taken to ship each order
select order_id, order_date, shipped_date,
   datediff( shipped_date, order_date) as days_to_ship
from orders;


-- 36. average shipping days per store
-- orders not shipped yet have no shipped_date, so they are left out
SELECT store_id,
       ROUND(AVG(DATEDIFF(shipped_date, order_date)), 1) AS avg_days_to_ship
FROM orders
WHERE shipped_date is not null
GROUP BY store_id
order by  store_id;


-- 37. late orders per store (shipped after required_date)
select store_id,
count(*) as shipped_order,
sum(case when shipped_date > required_date then 1 else 0 end) as late_orders,
round (100* sum(case when shipped_date > required_date then 1 else 0 end)/count(*),2) as late_percentage
FROM orders
WHERE shipped_date IS NOT NULL
GROUP BY store_id;


-- 38. orders by day of the week
SELECT DAYNAME(order_date) AS day_name,
       COUNT(*) AS total_orders
FROM orders
GROUP BY day_name
ORDER BY total_orders DESC;


-- ---------------- Part 5: CTE and window functions ----------------

-- 39. customers who spent more than $10,000
with customer_spent as (
select o.customer_id,
round(sum(oi.quantity*oi.list_price*(1-oi.discount)),2) as total_spent
from order_items oi
join orders o on oi.order_id = o.order_id
join customers c on o.customer_id = c.customer_id
group by o.customer_id
)

select* from customer_spent
where total_spent>10000;


-- 40. ranking customers by spending
with customer_spent as (
select o.customer_id,
round(sum(oi.quantity*oi.list_price*(1-oi.discount)),2) as total_spent
from order_items oi
join orders o on oi.order_id = o.order_id
join customers c on o.customer_id = c.customer_id
group by o.customer_id
)

select customer_id , total_spent, 
dense_rank() over (order by total_spent desc) as spent_rank
from customer_spent;

-- 41. row_number vs rank vs dense_rank, to see the difference with same prices
SELECT product_name, list_price,
       ROW_NUMBER() OVER (ORDER BY list_price DESC) AS row_num,
       RANK()       OVER (ORDER BY list_price DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY list_price DESC) AS dense_rnk
FROM products
LIMIT 20;


-- 42. top 3 products in each category
-- units sold per product first
SELECT c.category_name, p.product_name,
       SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name, p.product_name;

-- then rank inside each category
select c.category_name, p.product_name,
sum(oi.quantity) as unit_sold,
 row_number() over ( partition by c.category_name order by sum(oi.quantity) desc) as rn
from order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name, p.product_name;


-- keep only top 3
with ranked as
( select c.category_name, p.product_name,
sum(oi.quantity) as units_sold,
 row_number() over ( partition by c.category_name order by sum(oi.quantity) desc) as rn
from order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name, p.product_name
)

SELECT category_name, product_name, units_sold
FROM ranked
WHERE rn <= 3;


-- 43. month over month growth
-- monthly revenue in a CTE first
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
           SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY order_month
)
SELECT * FROM monthly;

-- compare with previous month using LAG
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
           SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY order_month
)
select  order_month,
round(revenue,2) as revenue,
round(lag (revenue) over (order by order_month),2) as prev_month_revenue,
ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY order_month))
      / LAG(revenue) OVER (ORDER BY order_month), 1) AS growth_pct
from monthly; 


-- 44. running total of revenue
WITH monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
           SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY order_month
)
SELECT order_month,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY order_month), 2) AS running_total
FROM monthly;


-- 45. one-time vs repeat customers
WITH cust AS (
    SELECT o.customer_id,
           COUNT(DISTINCT o.order_id) AS order_count,
           SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT CASE WHEN order_count = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
       COUNT(*) AS customers,
       ROUND(SUM(total_spent), 2) AS revenue,
       ROUND(100 * SUM(total_spent) / (SELECT SUM(total_spent) FROM cust), 1) AS revenue_pct
FROM cust
GROUP BY customer_type;


-- 46. best staff member in each store
WITH staff_revenue AS (
    SELECT st.store_name,
           CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
           SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue,
           RANK() OVER (PARTITION BY st.store_name
                        ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC) AS rnk
    FROM order_items oi
    JOIN orders o  ON oi.order_id = o.order_id
    JOIN staffs s  ON o.staff_id = s.staff_id
    JOIN stores st ON o.store_id = st.store_id
    GROUP BY st.store_name, staff_name
)
SELECT store_name, staff_name, ROUND(revenue, 2) AS revenue
FROM staff_revenue
WHERE rnk = 1;


-- 47. orders above the average order value
WITH order_values AS (
    SELECT order_id,
           SUM(quantity * list_price * (1 - discount)) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT order_id, ROUND(order_value, 2) AS order_value
FROM order_values
WHERE order_value > (SELECT AVG(order_value) FROM order_values)
ORDER BY order_value DESC;
