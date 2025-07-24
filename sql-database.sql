use famous_paintings;

select * from canvas_size
order by label desc;

select 
max(height) as max_height,
max(width) as max_width,
max(label) as max_dimensions,
min(height) as min_height,
min(width) as min_width,
min(label) as min_dimensions,
round(avg(height), 2) as avg_height,
round(avg(width), 2) as avg_width,
avg(label) as avg_dimensions
from canvas_size;



select sale_price, regular_price 
from product_size;

select 
max(sale_price) as max_sale_price,
max(regular_price) as max_regular_price,
min(sale_price) as min_sale_price,
min(regular_price) as min_regular_price,
round(avg(sale_price), 2) as avg_sale_price,
round(avg(regular_price), 2) as avg_regular_price
from product_size;

select * from subject;

-- count number of painting subjects, order by min, max

select
	subject,
	count(*) as subject_quantity
from subject
group by subject
order by subject_quantity asc
limit 1;

select
	subject,
	count(*) as subject_quantity
from subject
group by subject
order by subject_quantity desc
limit 1;

-- count number of painting styles, order by min, max

select 
	style, 
	count(*) as style_count
from work
group by style
order by style_count asc;

select 
	style, 
	count(*) as style_count
from work
group by style
order by style_count desc; 



