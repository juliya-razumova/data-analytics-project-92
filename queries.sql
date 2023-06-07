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
