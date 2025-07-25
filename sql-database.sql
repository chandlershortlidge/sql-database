use famous_paintings;

-- 1. exploring the data
select * from canvas_size
order by label desc;

-- min, max, avg dimensions
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


-- min, max, avg price
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

-- top 50 artits by sale price
select 
a.artist_id,
a.full_name,
a.nationality,
ps.sale_price
from artist as a 
join work as w on a.artist_id = w.artist_id
join product_size as ps on w.work_id = ps.work_id
order by sale_price desc
limit 50;

-- view smallest and largest painting subject

select
	subject,
	count(*) as subject_quantity
from subject
group by subject
order by subject_quantity asc
limit 1; -- Tigers with 31 paintings

select
	subject,
	count(*) as subject_quantity
from subject
group by subject
order by subject_quantity desc
limit 1; -- Portraits with 1070 paintings

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



select 
		style, 
		count(distinct work_id) as style_count
	from work
    where style is NOT NULL
	group by style;
    
-- --------------------------------    
-- Hypothesis 1: The Value of Style
-- --------------------------------

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

-- top 10 avg: Classicism, American Landscape, Orientalism, Art Nouvea, Neo-Classicism, Rococo, Surrealism, American Art, Romanticism, Naturalism

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

-- ---------------------------------
-- Hypothesis 2: The Value of Rarity
-- ---------------------------------

-- The rarer the art style, the higher the price.

with style_counts as(
	select 
		style, 
		count(distinct work_id) as style_count
	from work
    where style is NOT NULL
	group by style
), 
median_prices as (
select
		ps.sale_price as meidan_sale_price,
        w.style,
        ps.sale_price,
		ROW_NUMBER() OVER (PARTITION BY w.style ORDER BY ps.sale_price) AS rn,
		COUNT(*) OVER (PARTITION BY w.style) AS total_count
	from work as w
	join product_size as ps on w.work_id = ps.work_id
)
select
sc.style,
sc.style_count,
mp.sale_price as median_sale_price
from style_counts as sc
join median_prices as mp on sc.style = mp.style
WHERE rn = FLOOR(total_count/2) 
order by
sc.style_count asc;

-- strong trend between rarity and price

-- -------------------------------------
-- Hypothesis 3: The Nationality Premium
-- -------------------------------------

-- Is there a "premium" for artists of a certain nationality? 
-- For example, do works by French or American artists command higher prices on average 
-- than works by artists from other countries, even within the same style?


select  
	nationality,
	style, 
	sale_price AS median_sale_price
from  
(
select
        w.style,
        a.nationality,
        ps.sale_price,
		ROW_NUMBER() OVER (PARTITION BY w.style, a.nationality ORDER BY ps.sale_price) AS rn,
		COUNT(*) OVER (PARTITION BY w.style, a.nationality) AS total_count
from work as w
	join product_size as ps on w.work_id = ps.work_id
    join artist as a on w.artist_id = a.artist_id 
where w.style = "Impressionism"
) as nationality_by_sale_price
WHERE rn = FLOOR(total_count/2);




