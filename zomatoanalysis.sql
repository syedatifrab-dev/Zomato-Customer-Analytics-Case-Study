
--1. What is the total revenue?
select * from zomato_customer;

select sum(order_amount) as total_revenue
from zomato_orders
where order_status='Delivered';

--2) What is the monthly revenue trend?



select date_trunc(month, order_timestamp) as order_month,
sum(order_amount) as total_revenue
from zomato_orders
where order_status='Delivered'
group by order_month
order by order_month asc;

--3) Which city contributes the highest revenue?

select *
from zomato_customer;

select c.city,
sum(o.order_amount) as total_revenue
from zomato_orders o join zomato_customer c 
on o.customer_id= c.customer_id
where o.order_status='Delivered'
group by c.city
order by total_revenue desc;


--4)Which payment mode generates the most revenue?

select payment_mode,
sum(order_amount) as total_revenue
from zomato_orders
where order_status='Delivered'
group by 1
order by total_revenue desc;

--5) What is the Average Order Value (AOV)?

select round(avg(order_amount),2) as avg_order_value
from zomato_orders
where order_status= 'Delivered';


--6) Who are the top 20 customers by revenue?

with cte as (
select customer_id,  sum(order_amount) as total_revenue
from zomato_orders
where order_status='Delivered'
group by customer_id) 

select customer_id, total_revenue from (
select customer_id, total_revenue, 
row_number() over (order by total_revenue desc) as rnk
from cte)  b
where rnk <=20;


--7) What percentage of revenue comes from top customers?


with cte as (
select customer_id,  sum(order_amount) as total_revenue
from zomato_orders
where order_status='Delivered'
group by customer_id),

cte2 as(
select customer_id, total_revenue from (
select customer_id, total_revenue, 
row_number() over (order by total_revenue desc) as rnk
from cte)  b
where rnk <=20)

select round(sum(total_revenue) * 100/ (select sum(order_amount) from zomato_orders 
where order_status = 'Delivered'),2) as order_percentage
from cte2;



--8)Which acquisition channel brings the highest-value customers?

select ACQUISITION_CHANNEL, count(distinct customer_id)  as total_customer
from zomato_customer
group by 1
order by total_customer desc;


with cte as (
select customer_id,  sum(order_amount) as total_revenue
from zomato_orders
where order_status='Delivered'
group by customer_id),

cte2 as(
select customer_id, total_revenue from (
select customer_id, total_revenue, 
row_number() over (order by total_revenue desc) as rnk
from cte)  b
where rnk <=20)

select zc.ACQUISITION_CHANNEL, COUNT(*) AS customer_count
from zomato_customer zc join cte2 ct
on zc.customer_id= ct.customer_id
group by zc.acquisition_channel
order by customer_count desc;

--9)How many repeat customers do we have?

 select customer_id, count(*) as customer_count
 from zomato_orders
 group by customer_id
 having count(*) >1;



select customer_id, count(*) as customer_count
 from zomato_customer
 group by customer_id
 having count(*) >1;


--10) Which restaurants generate the highest revenue?



select o.restaurant_id, r.restaurant_name,
sum(o.order_amount) as total_revenue
from zomato_orders o join restaurants r
on o.restaurant_id=r.restaurant_id
where o.order_status='Delivered'
group by o.restaurant_id, r.restaurant_name
order by total_revenue desc;


--11) Which restaurants receive the most orders?

select o.restaurant_id, r.restaurant_name,
count(order_id) as total_orders
from zomato_orders o join restaurants r
on o.restaurant_id=r.restaurant_id
where o.order_status='Delivered'
group by o.restaurant_id, r.restaurant_name
order by total_orders desc;

--12) Which cuisines are most popular?

select r.cuisine,
count(order_id) as total_orders
from zomato_orders o join restaurants r
on o.restaurant_id=r.restaurant_id
where o.order_status='Delivered'
group by r.cuisine
order by total_orders desc;

--13) Do highly-rated restaurants generate more revenue?

select r.restaurant_name, r.avg_rating,
sum(o.order_amount) as total_revenue
from zomato_orders o join restaurants r
on o.restaurant_id=r.restaurant_id
where o.order_status='Delivered'
group by all
order by total_revenue desc;


--14) 5. Last 5 Restaurant

select r.restaurant_name, 
sum(o.order_amount) as total_revenue
from zomato_orders o join restaurants r
on o.restaurant_id=r.restaurant_id
where o.order_status='Delivered'
group by 1
order by total_revenue asc
limit 5;


-- 15) What is the cancellation rate?

select 
round(count_if(order_status= 'Cancelled')* 100/ count(*),2) as cancel_percentage
from zomato_orders;


select 
round(count(case when order_status= 'Cancelled' then order_id end)/count(order_id),2) as cancellation_rate
from zomato_orders;


-- 16) What is the refund rate?

select 
round(count(case when order_status= 'Refunded' then order_id end)/count(order_id),2) as refunded_rate
from zomato_orders;

-- 17) How much revenue is lost due to cancellations?

select 
sum(order_amount) as lost_revenue
from zomato_orders
where order_status= 'Cancelled';

--18) Which restaurants have the highest cancellation rate?

select restaurant_id,
round(count_if(order_status= 'Cancelled')* 100/ count(*),2) as cancel_percentage
from zomato_orders
group by restaurant_id
order by cancel_percentage desc;

--19) How many customers have churned?


with last_transactions as(
select max(order_timestamp) as last_txn_date
from zomato_orders)
,
cust_last as(
select customer_id, max(order_timestamp) as max_last
from zomato_orders
group by customer_id)

select count(*) as churn_customer from cust_last a
cross join last_transactions l 
where datediff(day, a.max_last, l.last_txn_date)>90;

--20) What is the churn rate?

with last_transactions as(
select max(order_timestamp) as last_txn_date
from zomato_orders)
,
cust_last as(
select customer_id, max(order_timestamp) as max_last
from zomato_orders
group by customer_id),

churn as(
select *, case when datediff(day, a.max_last, l.last_txn_date)>90 then 1 else 0 end  as churn_tag
from cust_last a  cross join last_transactions l)

select round(sum(churn_tag) * 100.0/(select count(*) from cust_last),2) as churn_rate
from churn;


--21) Which city has the highest churn?

with last_transactions as(
select max(order_timestamp) as last_txn_date
from zomato_orders)
,
cust_last as(
select o.customer_id, c.city , max(order_timestamp) as max_last
from zomato_orders o join zomato_customer c 
on o.customer_id=c.customer_id
group by o.customer_id, c.city)

select city, count(*) as churn_customer from cust_last a
cross join last_transactions l 
where datediff(day, a.max_last, l.last_txn_date)>90
group by city
order by  churn_customer desc;

--22) How much revenue is lost due to churn?
with last_transactions as(
select max(order_timestamp) as last_txn_date
from zomato_orders)
,
cust_last as(
select customer_id, max(order_timestamp) as max_last
from zomato_orders
group by customer_id),

churn as(
select customer_id  from cust_last a
cross join last_transactions l 
where datediff(day, a.max_last, l.last_txn_date)>90)

select sum(order_amount) as lost_rev
from zomato_orders
where customer_id in (select customer_id from churn);


--23) Who are the high-value churned customers?

with last_transactions as(
select max(order_timestamp) as last_txn_date
from zomato_orders)
,
cust_last as(
select customer_id, max(order_timestamp) as max_last
from zomato_orders
group by customer_id),

churn as(
select customer_id  from cust_last a
cross join last_transactions l 
where datediff(day, a.max_last, l.last_txn_date)>90)

select customer_id, sum(order_amount) as lost_rev
from zomato_orders
where customer_id in (select customer_id from churn)
group  by customer_id
order by lost_rev desc
limit 10;






























