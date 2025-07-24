use famous_paintings;

-- 1. exploring the data
select * from canvas_size
order by label desc;

-- dimensions
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


-- price
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

-- Hypothesis 1: The Value of Style
-- Artworks from certain styles (e.g., Impressionism, Cubism) consistently fetch higher average sale prices than works from other movements 
-- (e.g., Rococo, Classicism).

select
	w.style,
    count(distinct w.work_id) as style_count,
	round(avg(ps.sale_price), 2) as avg_sale_price,
	round(avg(ps.regular_price), 2) as avg_regular_price
from work as w
join product_size as ps on w.work_id = ps.work_id
where style is NOT NULL
group by w.style
having style_count >= 100
order by avg_sale_price desc
limit 10;

-- outcome: Classicism, American


