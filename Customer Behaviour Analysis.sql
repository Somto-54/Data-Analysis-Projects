-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) AS total_spent
FROM sales s 
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id;



-- 2. How many days has each customer visited the restaurant?

SELECT s.customer_id, COUNT(DISTINCT s.order_date) AS days_visited -- we're using distinct because we want to count the unique days a customer has 
-- visited  
FROM sales s
GROUP BY s.customer_id;



-- 3. What was the first item from the menu purchased by each customer?

-- 1st, we find out the first purchase date for each customer and use the result to get the item purchased on that date
SELECT s.customer_id, MIN(s.order_date) AS first_purchase_date
FROM sales s
GROUP BY s.customer_id;
-- now we use cte for the query above so we can select values from the cte
WITH customer_first_purchase AS (
 SELECT s.customer_id, MIN(s.order_date) AS first_purchase_date
 FROM sales s
 GROUP BY s.customer_id
)
SELECT cfp.customer_id, cfp.first_purchase_date, m.product_name
FROM customer_first_purchase cfp
JOIN sales s ON s.customer_id = cfp.customer_id
AND cfp.first_purchase_date = s.order_date
JOIN menu m ON m.product_id = s.product_id;
-- the joins the sales table on the customer_id and order date so it will link the customers' first purchase 
-- with the corresponding sales record. we're making sure the order dates are the same in the cfp and sales table 
-- and we join the menu table to give us the item names  


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, COUNT(*) AS total_purchased
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchased DESC
LIMIT 1; -- desc and limit 1 because we're looking for the highest item that was purchased 
-- to get the total times each item was purchased 
SELECT m.product_name, COUNT(*) AS total_purchased
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchased DESC;
-- top 2
SELECT m.product_name, COUNT(*) AS total_purchased
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchased DESC
LIMIT 2;




-- 5. Which item was the most popular for each customer?

-- getting the items purchased by each customer:
SELECT s.customer_id, m.product_name, COUNT(*) AS purchase_count, 
ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS row_num
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name;
-- the row_number function assigns a unique squential integer to each row and we order by the number of products in descending 
-- order so the row_num 1 for each customer group is the product with the highest purchase count 

-- to get the most popular item 
WITH customer_purchase AS(
 SELECT s.customer_id, m.product_name, COUNT(*) AS purchase_count, 
 DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS row_num
 FROM sales s
 JOIN menu m ON s.product_id = m.product_id
 GROUP BY s.customer_id, m.product_name
 )
SELECT cp.customer_id, cp.product_name, cp.purchase_count
FROM customer_purchase cp
WHERE row_num = 1; 
-- we use the because the row_number() function just assigns a sequential number to each row and it wont answer our question of the most popular 
-- items for each customer in cases where we have items with the same purchase_count and there's a tie it still assigns different numbers
-- for the rows, to handle this issue we use the dense_rank function which considers factors like ties and assigns the same number to rows 
-- with ties 

-- 6. Which item was purchased first by the customer after they became a member?

SELECT s.customer_id, MIN(S.order_date) AS first_purchase_date
FROM sales s
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date >= mb.join_date
GROUP BY customer_id;
-- the above query just gets the first purchase by each customer after they became a member and we do this by using the where clause
-- to filter the order date for only when the customer became a member
-- using the query result we get the first item they purchased
WITH first_membership_order AS (
 SELECT s.customer_id, MIN(S.order_date) AS first_purchase_date
 FROM sales s
 JOIN members mb ON s.customer_id = mb.customer_id
 WHERE s.order_date >= mb.join_date
 GROUP BY customer_id
)
SELECT fmo.customer_id, m.product_name
FROM first_membership_order fmo
JOIN sales s ON s.customer_id = fmo.customer_id -- to make sure that we are getting the same customer id from the two tables
AND fmo.first_purchase_date = s.order_date -- to make sure we are getting the same date
JOIN menu m ON s.product_id = m.product_id;




-- 7. Which item was purchased just before the customer became a member?

SELECT s.customer_id, MAX(S.order_date) AS last_purchase_date -- using the max function because we want the most recent date
FROM sales s
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY customer_id;
-- using the query result to get the last item they purchased before membership
WITH last_n_membership_order AS (
 SELECT s.customer_id, MAX(S.order_date) AS last_purchase_date
 FROM sales s
 JOIN members mb ON s.customer_id = mb.customer_id
 WHERE s.order_date < mb.join_date
 GROUP BY customer_id
 )
SELECT lnmo.customer_id, m.product_name 
FROM last_n_membership_order lnmo
JOIN sales s ON lnmo.customer_id = s.customer_id
AND lnmo.last_purchase_date = s.order_date
JOIN menu m ON s.product_id = m.product_id;



-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(*) AS total_items, SUM(m.price) as total_amount
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
where s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, SUM(
    CASE
       WHEN m.product_name = 'sushi' THEN m.price * 20
       ELSE m.price * 10 END) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_points DESC;



/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?*/

SELECT s.customer_id, SUM(
   CASE
     WHEN s.order_date BETWEEN mb.join_date AND DATE_ADD(mb.join_date, INTERVAL 7 DAY)
     THEN m.price * 20 
     WHEN m.product_name = 'sushi' 
     THEN m.price * 20 
     ELSE m.price * 10 END) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.customer_id IN ('A', 'B') AND s.order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY total_points DESC; 

-- 11. Recreate the table output using the available data

SELECT s.customer_id, s.order_date, m.product_name, m.price, 
CASE
  WHEN s.order_date >= mb.join_date THEN 'Y'
  ELSE 'N'
  END AS membership
FROM sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mb ON s.customer_id = mb.customer_id -- left join because we need all the records in the sales table but only matching 
-- record in the members table and normally it will give us null for records that do not match but because we have specified the 
-- condition in the case statement we get an N instead of a null
ORDER BY s.customer_id, s.order_date;


-- 12. Rank all the things
WITH customers_data AS (
	SELECT s.customer_id, s.order_date, m.product_name, m.price, 
	CASE
		WHEN s.order_date < mb.join_date THEN 'N'
		WHEN s.order_date >= mb.join_date THEN 'Y'
		ELSE 'N'
		END AS membership
	FROM sales s
	LEFT JOIN members mb ON s.customer_id = mb.customer_id 
	JOIN menu m ON s.product_id = m.product_id
)
SELECT *, 
CASE WHEN membership = 'N' THEN NULL
ELSE RANK() OVER(PARTITION BY customer_id, membership ORDER BY order_date)
END AS ranking 
FROM customers_data
ORDER BY customer_id, order_date;