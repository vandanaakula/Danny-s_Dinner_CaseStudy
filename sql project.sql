CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);
INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
select * from members
select * from menu
select * from sales
-- What is the total amount each customer spent at the restaurant?
select customer_id, sum(price)
from sales join menu 
on sales.product_id = menu.product_id 
group by customer_id

-- How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date)
from sales group by customer_id

-- What was the first item from the menu purchased by each customer?
'''select s.customer_id, m.product_name from 
sales s join menu m 
on s.product_id=m.product_id 
where (s.customer_id, s.order_date) in 
(select customer_id,min(order_date) from sales 
group by customer_id)'''

select s.customer_id, m.product_name from 
sales s join menu m 
on s.product_id=m.product_id 
where s.order_date = (select min(order_date) 
from sales where customer_id = s.customer_id)

--What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name, count(s.product_id) as purchase_count
from sales s join menu m 
on s.product_id = m.product_id group by m.product_name
order by purchase_count desc limit 1

--Which item was the most popular for each customer?
with ItemCounts as(
select s.customer_id, m.product_name,count(s.product_id) as purchase_count
from sales s join menu m on s.product_id = m.product_id
group by s.customer_id, m.product_name)
select customer_id, product_name, purchase_count from ItemCounts
where (customer_id, purchase_count) in 
(select customer_id, max(purchase_count) from ItemCounts
group by customer_id) order by customer_id;

--Which item was purchased first by the customer after they became a member?
select s.customer_id, m.product_name from sales s join menu m
on s.product_id = m.product_id join members mem 
on s.customer_id = mem.customer_id 
where s.order_date = 
(select min(order_date) from sales 
where customer_id = s.customer_id and order_date  > join_date)

--Which item was purchased just before the customer became a member?
select s.customer_id, m.product_name from sales s join menu m
on s.product_id = m.product_id join members mem 
on s.customer_id = mem.customer_id 
where s.order_date =(select max(order_date)from sales
where customer_id = s.customer_id and order_date < join_date)

--What is the total items and amount spent for each member before they became a member?
select s.customer_id , count(s.product_id) as total_items,
sum(m.price) as amount_spent from sales s join menu m
on s.product_id = m.product_id join members mem
on s.customer_id = mem.customer_id
where order_date < join_date group by s.customer_id

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id,
sum(
	case
		when m.product_name = 'sushi' then (m.price*10*2)
		else (m.price*10)
	end
)as total_point
from sales s join menu m on s.product_id = m.product_id
group by s.customer_id

--In the first week after a customer joins the program 
--(including their join date) they earn 2x points 
--on all items, not just sushi -
--how many points do customer A and B have at the end of January?

with Points as(
	select
		s.customer_id,s.order_date, m.product_name, m.price,
		case
			when s.order_date <= mem.join_date + INTERVAL '7 days' then 2*10*m.price
			when m.product_name =  'sushi' then (2*10*m.price)
			else (10*m.price)
		end as points
	from sales s join menu m on s.product_id = m.product_id
	join members mem on s.customer_id = mem.customer_id
	where order_date between mem.join_date and '2021-01-31'
)
select customer_id, sum(points) as total_points
from Points where customer_id in ('A', 'B')
group by customer_id














