-- Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_number_of_orders
FROM orders


-- Calculate the total revenue generated from pizza sales.

SELECT SUM(o.quantity*p.price) AS total_revenue_generated
FROM order_details o
LEFT JOIN pizzas p
ON o.pizza_id=p.pizza_id



-- Identify the highest-priced pizza.

SELECT pt.name, p.price
FROM pizza_types pt
JOIN pizzas p
ON pt.pizza_type_id= p.pizza_type
ORDER BY p.price DESC 
LIMIT 1



-- Identify the most common pizza size ordered.

SELECT p.size, SUM(o.quantity) AS num_of_pizzas_ordered
FROM order_details o
LEFT JOIN pizzas p
ON o.pizza_id=p.pizza_id
GROUP BY p.size
ORDER BY num_of_pizzas_ordered DESC
LIMIT 1


-- List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(o.quantity)
from order_details o
left join pizzas p
ON o.pizza_id=p.pizza_id
LEFT JOIN pizza_types pt
ON p.pizza_type=pt.pizza_type_id
GROUP BY pt.pizza_type_id
ORDER BY SUM(o.quantity) DESC
LIMIT 5



-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category, SUM(o.quantity)
FROM order_details o
LEFT JOIN pizzas p
ON o.pizza_id=p.pizza_id
LEFT JOIN pizza_types pt
ON p.pizza_type=pt.pizza_type_id
GROUP BY pt.category



-- Determine the distribution of orders by hour of the day.

SELECT EXTRACT(HOUR FROM o.time) AS HOURS, SUM(od.quantity) AS quantity
FROM order_details od
JOIN orders o
ON od.order_id=o.order_id
GROUP BY HOURS
ORDER BY HOURS



-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, COUNT(name)
FROM pizza_types
GROUP BY category



-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT AVG(quantityy)::INT AS avg_order_per_day 
FROM (SELECT o.date, SUM(od.quantity) AS quantityy
FROM order_details od
LEFT JOIN orders o
ON od.order_id=o.order_id
GROUP BY o.date)



-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name, SUM(p.price*od.quantity) AS revenue
FROM order_details od
LEFT JOIN pizzas p 
ON od.pizza_id=p.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id=p.pizza_type
GROUP BY pt.pizza_type_id
ORDER BY revenue DESC
LIMIT 3



-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.name, SUM(p.price*od.quantity) AS revenue, ROUND(100*SUM(p.price*od.quantity)/(SELECT SUM(p2.price*od2.quantity) FROM order_details od2
LEFT JOIN pizzas p2 
ON od2.pizza_id=p2.pizza_id
JOIN pizza_types pt2
ON pt2.pizza_type_id=p2.pizza_type),2) AS percentage
FROM order_details od
LEFT JOIN pizzas p 
ON od.pizza_id=p.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id=p.pizza_type
GROUP BY pt.pizza_type_id
ORDER BY percentage DESC


-- Analyze the cumulative revenue generated over time.

SELECT date, daily_revenue, SUM(daily_revenue) OVER (ORDER BY date) AS cumulative_revenue
FROM(
SELECT o.date, ROUND(SUM(od.quantity*p.price),2) AS daily_revenue
FROM order_details od
JOIN orders o
ON od.order_id=o.order_id
JOIN pizzas p
ON p.pizza_id=od.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id=p.pizza_type
GROUP BY o.date)



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category, name, revenue
FROM
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue) AS rn
FROM(
SELECT pt.category, pt.name, SUM(p.price*od.quantity) AS revenue
FROM order_details od
LEFT JOIN pizzas p 
ON od.pizza_id=p.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id=p.pizza_type
GROUP BY pt.pizza_type_id
ORDER BY revenue DESC) AS a) AS b 
WHERE rn<=3
ORDER BY category ASC, revenue DESC
