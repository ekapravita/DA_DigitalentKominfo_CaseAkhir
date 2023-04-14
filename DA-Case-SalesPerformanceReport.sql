	--Overall Performance by Year

with tableref as
(select order_id, extract(year from order_date) as years, sales
from dqlab_sales_store
where order_status = 'Order Finished')

select years, sum(sales) as sales, count(order_id) as number_of_order
from tableref
group by 1
order by 1

-------------------------------------------------------------------------------------------------------------------------------------------

	--Overall Performance by Product Sub Category

with tableref as
(select order_id, product_sub_category, sales, extract(year from order_date) as years
from dqlab_sales_store
where order_status = 'Order Finished'
)

select years, product_sub_category, sum(sales) as sales
from tableref
where years = 2011 or years =2012 --where years in (2011, 2012)
group by 1,2
order by 1,3 desc

-------------------------------------------------------------------------------------------------------------------------------------------

	--Promotion Effectiveness and Efficiency by Years

--Formula untuk burn rate : (total discount / total sales) * 100
--Pada bagian ini kita akan melakukan analisa terhadap efektifitas dan efisiensi dari promosi yang sudah dilakukan selama ini

--Efektifitas dan efisiensi dari promosi yang dilakukan akan dianalisa berdasarkan Burn Rate yaitu dengan membandigkan total value promosi 
--yang dikeluarkan terhadap total sales yang diperoleh

--DQLab berharap bahwa burn rate tetap berada diangka maskimum 4.5%


with tableref as
(select order_id, extract(year from order_date) as years, sales, discount_value
from dqlab_sales_store
where order_status = 'Order Finished'
),

tableref_2 as
(select years, sum(sales) as sales,
sum(discount_value) as promotion_value
from tableref
group by 1
order by 1
)

select years, sales, promotion_value,
round((promotion_value/sales)*100,2)
as burn_rate_percentage
from tableref_2

-------------------------------------------------------------------------------------------------------------------------------------------

	--Promotion Effectiveness and Efficiency by Product Sub Category

with tableref as
(select extract(year from order_date) as years,
product_sub_category, product_category,
sales, discount_value
from dqlab_sales_store
where order_status = 'Order Finished'),

tableref_2 as
(select years, product_sub_category, product_category, sum(sales) as sales, sum(discount_value) as promotion_value
from tableref
where years = 2012
group by 1,2,3
)

select years, product_sub_category, product_category, sales, promotion_value,
round(promotion_value/sales*100,2)
as burn_rate_percentage
from tableref_2
order by sales desc

-------------------------------------------------------------------------------------------------------------------------------------------

	--Customers Transactions per Year

with tableref as
(select extract(year from order_date) as years,
customer
from dqlab_sales_store
where order_status = 'Order Finished')

select years, count(distinct customer)
as number_of_customer
from tableref
group by 1
order by 1

-------------------------------------------------------------------------------------------------------------------------------------------