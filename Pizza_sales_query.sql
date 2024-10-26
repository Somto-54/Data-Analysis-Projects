SELECT * from pizza_data;

-- counting the rows 
SELECT count(distinct pizza_id) as distinct_count
from pizza_data;

-- changing the datatype of date and time columns
SELECT str_to_date(order_date, '%d-%m-%Y') as new_date 
from pizza_data;
SELECT time(str_to_date(order_time, '%H:%i:%s')) as new_time 
from pizza_data;

-- creating a columns for the new date
ALTER table pizza_data
ADD COLUMN new_order_date date;
-- adding values to the column
UPDATE pizza_data
SET new_order_date = STR_TO_DATE(order_date, '%d-%m-%Y');
-- dropping the old order date column and renaming the new one
ALTER table pizza_data
DROP order_date,
CHANGE COLUMN new_order_date order_date DATE;

-- changing the time column 
ALTER table pizza_data
MODIFY COLUMN order_time time;
UPDATE pizza_data
SET order_time = time(str_to_date(order_time, '%H:%i:%s'));

-- total revenue 
SELECT sum(total_price) as Total_Revenue from pizza_data;

-- average order value
SELECT sum(total_price) / count(distinct order_id) as Average_order_value
from pizza_data;

-- total pizza sold 
SELECT sum(quantity) as Total_pizza_sold from pizza_data;

-- total orders placed
SELECT count(distinct order_id) as Total_orders_placed
from pizza_data;

-- average pizza per order
SELECT round(sum(quantity) / count(distinct order_id),2) as Avg_pizza_per_order
from pizza_data;

-- daily trend for total orders
SELECT dayname(order_date) as Day_of_week, count(distinct order_id) as Total_orders
from pizza_data
group by dayname(order_date)
order by count(distinct order_id);

-- monthly trend for total orders
SELECT monthname(order_date) as Month, count(distinct order_id) as Total_orders
from pizza_data
group by monthname(order_date)
order by count(distinct order_id);

-- percentage of sales by pizza category 
SELECT pizza_category, 
round(sum(total_price),2) as Total_sales,
round((sum(total_price) * 100.0) / (select sum(total_price) from pizza_data),2) as Percentage_of_Sales
from pizza_data
group by pizza_category
order by Percentage_of_Sales;

-- to filter by month 
SELECT pizza_category, 
round(sum(total_price),2) as Total_sales,
round((sum(total_price) * 100.0) / 
(select sum(total_price) from pizza_data where month(order_date) = 1),2) as Percentage_of_Sales
from pizza_data
where month(order_date) = 1 -- filtering for january 
group by pizza_category
order by Percentage_of_Sales;

-- percentage of sales by pizza size
SELECT pizza_size, 
round(sum(total_price),2) as Total_sales,
round((sum(total_price) * 100.0) / (select sum(total_price) from pizza_data),2) as Percentage_of_Sales
from pizza_data
group by pizza_size
order by Percentage_of_Sales;

-- top 5 best sellers by revenue, total quantity, and total orders
SELECT pizza_name, sum(total_price) as Total_revenue
from pizza_data
group by pizza_name
order by Total_revenue desc limit 5;

SELECT pizza_name, sum(quantity) as Total_Qty
from pizza_data
group by pizza_name
order by Total_Qty desc limit 5;

SELECT pizza_name, count(distinct order_id) as Total_orders
from pizza_data
group by pizza_name
order by Total_orders desc limit 5;

-- bottom 5 sellers
SELECT pizza_name, sum(total_price) as Total_revenue
from pizza_data
group by pizza_name
order by Total_revenue asc limit 5;

SELECT pizza_name, sum(quantity) as Total_Qty
from pizza_data
group by pizza_name
order by Total_Qty asc limit 5;

SELECT pizza_name, count(distinct order_id) as Total_orders
from pizza_data
group by pizza_name
order by Total_orders asc limit 5;







