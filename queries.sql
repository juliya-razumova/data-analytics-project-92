customers_count.cvs
  
select count(*) as customers_count from customers;




top_10_total_income.csv
  
select 
concat (first_name, ' ', last_name) as name,
count(sales_id) as operations,
round(sum(price*quantity), 0) as income
from sales
left join employees
on employee_id = sales_person_id
left join products
using (product_id)
group by concat (first_name, ' ', last_name)
order by income desc
limit 10;




lowest_average_income.csv
  
with tab as (
select 
concat (first_name, ' ', last_name) as name,
avg(price*quantity) as avg_income
from sales
left join employees
on employee_id = sales_person_id
left join products
using (product_id)
group by concat (first_name, ' ', last_name)
)
select 
name,
round(avg_income) as average_income
from tab
where avg_income < (select avg(avg_income) from tab)
order by avg_income;




day_of_the_week_income.csv
  
with tab as (
select 
concat(first_name, ' ', last_name) as name,
to_char(sale_date, 'day') as weekday,
extract (isodow from sale_date) as day_num,
price*quantity as income
from sales
left join employees
on employee_id = sales_person_id
left join products
using (product_id)
)
select 
name,
weekday,
round(sum(income), 0) as income
from tab
group by name, weekday, day_num
order by day_num, name;




age_groups.cvs
  
with tab as (
select distinct 
s.customer_id,
age
from sales s 
left join customers c 
using (customer_id)
)
select
case 
	when age between 16 and 25 then '16-25'
	when age between 26 and 40 then '26-40'
	when age > 40 then '40+'
	else 'младше 16'
end
as age_category,
count(customer_id)
from tab
group by age_category
order by age_category;




customers_by_month.csv
  
with tab as (
select
to_char(sale_date, 'YYYY-MM') as date,
customer_id as customer,
sum(price*quantity) as income
from sales s
left join products p 
using(product_id)
group by customer_id, to_char(sale_date, 'YYYY-MM')
order by to_char(sale_date, 'YYYY-MM'), customer_id
)
select distinct 
date,
count(customer) over(partition by date) as total_customers,
sum(income) over(partition by date) as income
from tab
order by date;




special_offer.csv
  
with tab as (
select distinct
concat(c.first_name, ' ', c.last_name) as customer,
customer_id,
price,
first_value(sale_date) over(partition by customer_id order by sale_date) as sale_date,
first_value(concat(e.first_name, ' ', e.last_name)) over(partition by customer_id order by sale_date) as seller
from sales s
left join products p 
using(product_id)
left join employees e
on s.sales_person_id = e.employee_id
left join customers c
using(customer_id)
where price = 0
)
select
customer,
sale_date,
seller
from tab
order by customer_id, sale_date;
