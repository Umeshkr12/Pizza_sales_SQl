create database pizzaJH;
use pizzaJH;

show tables;
select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- 1.Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) total_orders
FROM
    orders;

-- 2.Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id;

-- 3.Identify the highest-priced pizza.

SELECT 
   pt.name ,p.price highest_price
FROM pizzas p
join pizza_types pt
on pt.pizza_type_id = p. pizza_type_id
order by  highest_price desc
limit 1;
    

-- 4.Identify the most common pizza size ordered.

select p.size ,count(*) as c from order_details od
join pizzas p
on p.pizza_id = od.pizza_id 
group by p.size
order by c desc limit 1;


-- 5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) total_orders
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_orders DESC
LIMIT 5;  

-- ------------------intermediate-----------------

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category,sum(od.quantity) total_qty from pizzas p
join pizza_types pt
on pt. pizza_type_id = p.pizza_type_id
join order_details od 
on od.pizza_id = p.pizza_id
group by pt.category;


-- 7.Determine the distribution of orders by hour of the day.

select  hour(time)as order_time ,count(order_id) as order_count from orders
group by hour(time)
order by order_count desc;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types
group by category;


-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(sum_qty) from (select o.date,sum(od.quantity) sum_qty from orders o
join order_details od
on o.order_id = od.order_id 
group by o.date) as data;


-- 10.Determine the top 3 most ordered pizza types based on revenue.



select pt.name,sum(od.quantity*p.price) revenue from pizzas p
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id
group by pt.name
order by revenue desc
limit 3;


-- -------------ADVANCE-----------------

-- 11.Calculate the percentage contribution of each pizza type to total revenue.

select pt.category,round((round(sum(od.quantity*p.price),0)/(SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id)*100),0) as pct from pizzas p
join pizza_types  pt
 on p.pizza_type_id = pt.pizza_type_id
 join order_details od 
 on od.pizza_id =p.pizza_id 
 group by pt.category ;
 
-- 12.Analyze the cumulative revenue generated over time.
-- select *, sum(quantity) over(order by order_id) from order_details;

select date ,sum(revenue) over(order by date) as cumulative
 from
(select o.date,round(sum(od.quantity*p.price),0) as revenue from pizzas p
join order_details od
on od.pizza_id = p.pizza_id 
join orders o 
on o.order_id = od.order_id
group by o.date)as sales;


-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue,category from
(select sb.name,sb.revenue ,sb.category,rank() over(partition by sb.category order by revenue desc) as rn from 
(select pt.category,pt.name,round(sum(od.quantity*p.price),0)as revenue from  pizzas p
join pizza_types pt
 on pt.pizza_type_id = p.pizza_type_id
 join order_details od
 on od.pizza_id = p.pizza_id
 group by pt.category,pt.name)sb)sd2
 where rn<=3;
 