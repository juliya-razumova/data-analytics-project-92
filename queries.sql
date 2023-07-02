customers_count.cvs
  
select count(distinct customer_id) from sales;




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
  
select 
to_char (sale_date, 'YYYY-MM') as date,
count(distinct customer_id) as total_customers,
sum(price*quantity) as income
from sales
left join customers
using (customer_id)
left join products
using (product_id)
group by to_char (sale_date, 'YYYY-MM')
order by to_char (sale_date, 'YYYY-MM');




special_offer.csv
  
select distinct on (concat (c.first_name, ' ', c.last_name))
concat (c.first_name, ' ', c.last_name) as customer,
sale_date,
concat (e.first_name, ' ', e.last_name) as sales
from sales s 
left join employees e 
on employee_id = sales_person_id
left join customers c 
using (customer_id)
left join products 
using (product_id)
where price = 0
order by concat (c.first_name, ' ', c.last_name), sale_date, customer_id;
