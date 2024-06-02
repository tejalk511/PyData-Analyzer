create table df_orders
(
[order_id] int primary key
,[order_date] date
, [ship_mode] varchar(20)
, [segment] varchar(20)
, [country] varchar(20)
, [city] varchar(20)
, [state] varchar(20)
, [postal_code] varchar(20)
, [region] varchar(20)
, [category] varchar(20)
, [sub_category] varchar(20)
, [product_id] varchar(20)
, [quantity] int 
, [discount] decimal(7,2)
, [sale_price] decimal(7,2)
, [profit] decimal(7,2) 
)

select * from df_orders


--Top 10 highest revenue generating products 
select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc


--Top 5 highest selling products in each region
with cte as (
select region, product_id, sum(sale_price) as sales 
from df_orders
group by region, product_id)
select * from (select*,
row_number() over (partition by region order by sales desc) as rn
from cte) a
where rn<6


--Find month over month growth comparision for 2022 and 2023 sales
--Eg: Jan 22 vs Jan 23
with cte_comp as (
select year(order_date) as order_year, 
month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as Year_2022,
sum(case when order_year=2023 then sales else 0 end) as Year_2023
from cte_comp
group by order_month
order by order_month



--For each category which month had highest sales
with cte_cat as (
select format(order_date, 'yyyyMM') as order_year_month,
category, sum(sale_price) as sales
from df_orders
group by category, format(order_date, 'yyyyMM')
--der by month(order_date)
)
select category, order_year_month, sales 
from (
select *, 
rank() over (partition by category order by sales desc) as rnk
from cte_cat) a
where rnk = 1


--Which sub category has highest growth by profit in 2023 compared to 2022

with cte_sub as (
select sub_category,
year(order_date) as order_year, 
sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
),
cte_sub2 as (
select sub_category,
sum(case when order_year=2022 then sales else 0 end) as Year_2022,
sum(case when order_year=2023 then sales else 0 end) as Year_2023
from cte_sub
group by sub_category)

select top 1 * ,
(Year_2023-Year_2022)*100/Year_2022 as percentage
from cte_sub2
order by (Year_2023-Year_2022)*100/Year_2022 desc 
