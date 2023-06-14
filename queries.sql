select count(*) as customers_count from customers;


with tab_income as(
select 
sales_id,
sales_person_id,
quantity,
price
from sales
left join products
on sales.product_id = products.product_id
)
select
concat(employees.first_name, ' ', employees.last_name) as name,
count(tab_income.sales_person_id) as operations,
round(sum(tab_income.quantity*tab_income.price)) as income
from employees
left join tab_income
on employees.employee_id = tab_income.sales_person_id
group by name
order by income desc nulls last
limit 10;


with tab_income as(
select 
sales_id,
sales_person_id,
quantity,
price,
quantity*price as sale_income
from sales
left join products
on sales.product_id = products.product_id
)
select
concat(employees.first_name, ' ', employees.last_name) as name,
coalesce(round(avg(tab_income.sale_income)), 0) as average_income
from employees
left join tab_income
on employees.employee_id = tab_income.sales_person_id
group by name
having coalesce(round(avg(tab_income.sale_income)), 0) < (select avg(sale_income) from tab_income)
order by average_income nulls first;


with tab_income as(
select 
sales_id,
sales_person_id,
round(price*quantity) as income,
concat(employees.first_name, ' ', employees.last_name) as name,
extract('isodow' from sale_date) as num_day,
to_char(sale_date, 'day') as weekday
from sales
left join products
on sales.product_id = products.product_id
left join employees
on employees.employee_id = sales.sales_person_id
order by num_day
)
select 
name,
weekday,
sum(income) as income
from tab_income
group by name, num_day, weekday
order by substring(name from 1 for 1), num_day, name;


select '16-25' as age_category, count(*) as count from customers where age between 16 and 25
union
select '26-40' as age_category, count(*) as count from customers where age between 26 and 40
union
select '40+' as age_category, count(*) as count from customers where age > 40
order by age_category;


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
