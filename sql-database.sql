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
order by style_count asc; -- smallest Japanese Art 

select 
	style, 
	count(*) as style_count
from work
group by style
order by style_count desc; -- largest Impressionism

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

-- create a CET with window function to filter by median price per style by nationality

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

-- then use stored procedure to view 5 most popular styles to see if meaningful differences exist

call sale_price_by_nationality_style("Impressionism");
call sale_price_by_nationality_style("Post-Impressionism"); 
call sale_price_by_nationality_style("Realism");
call sale_price_by_nationality_style("Baroque");
call sale_price_by_nationality_style("Expressionism");


-- Top 5 styles, sorted by median sale price and nationality

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
 join (
	select style
    from work
    where style is not null
    group by style
    order by count(*) desc
    limit 5
      ) as top_5_styles on w.style = top_5_styles.style
) as nationality_by_sale_price
WHERE rn = FLOOR(total_count/2)
order by 
median_sale_price desc;


-- Last 10 styles, sorted by median sale price and nationality
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
 join (
	select style
    from work
    where style is not null
    group by style
    order by count(*) asc
    limit 10
      ) as top_5_styles on w.style = top_5_styles.style
) as nationality_by_sale_price
WHERE rn = FLOOR(total_count/2)
order by 
median_sale_price desc;


select 
a.full_name,
w.name,
ps.sale_price
from artist as a
join work as w on a.artist_id = w.artist_id
join product_size as ps on w.work_id = ps.work_id
order by sale_price desc;






-- -----------------------------------
-- Hypothesis 5: Scarcity and Lifespan
-- -----------------------------------
-- Is the sale price of an artist's work is correlated with their lifespan? 
-- A shorter working life may lead to a smaller body of work, creating scarcity and driving up prices.

-- 1. find artist lifespan using CTE

with artist_lifespan as (
	select
		full_name,
		(death - birth) as lifespan
	from artist
    where (death - birth) > 10 -- remove artist mistakenly labled as living only 5 years
)
select
	full_name,
	lifespan
from artist_lifespan
order by lifespan;


with artist_lifespan as (
	select
		(death - birth) as lifespan
	from artist
)
select
	round(avg(lifespan)) as avg_lifespan
from artist_lifespan
where lifespan > 10
order by avg_lifespan; -- avg lifespan of all artists is 66 years old

-- 2. put lifespans into buckets 
with artist_lifespan as (
	select
		full_name,
		(death - birth) as lifespan
	from artist
    where (death - birth) > 10 -- remove artist mistakenly labled as living only 5 years
)
select
	min(lifespan) as minium_age,
    max(lifespan) as maximum_age
from artist_lifespan
order by lifespan;



