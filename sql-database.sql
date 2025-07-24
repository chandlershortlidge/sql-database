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


-- 1. Find avg sale price per style

select
	w.style,
    count(distinct w.work_id) as style_count,
    round(avg(ps.sale_price), 2) as avg_sale_price
from work as w
join product_size as ps on w.work_id = ps.work_id
where style is not null
group by w.style
having style_count >= 100
order by avg_sale_price desc
limit 10; 

-- top 10: Classicism, American Landscape, Orientalism, Art Nouvea, Neo-Classicism, Rococo, Surrealism, American Art, Romanticism, Naturalism

-- 2. find median sale price per style to account for outliers
with ranked_sales as (
	select
		w.style,
		ps.sale_price,
		ROW_NUMBER() OVER (PARTITION BY w.style ORDER BY ps.sale_price) AS rn,
		COUNT(*) OVER (PARTITION BY w.style) AS total_count
	from work as w
	join product_size as ps on w.work_id = ps.work_id
	where w.style is NOT NULL
)
select
style,
sale_price as median_sale_price
from ranked_sales
where rn = floor(total_count) / 2
order by median_sale_price desc
limit 10;

-- top 10 median:  Classicism, Japanese Art, Neo-Classicism, Art Nouveau, Naturalism, Romanticism, Symbolism, Cubism, Nabi, Pointillism




