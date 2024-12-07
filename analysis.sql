SET search_path to airbnb;

SELECT * FROM calendars;

select * from listings;

select * from reviews;

-- Property Diversity

-- 1. Total number of listings and unique property types
select count(*) from listings;
select count(distinct property_type) from listings;

--2. Top 5 most common property types
select property_type, count(*) as property_count
from listings
group by property_type
order by count(*) desc
limit 5;

-- Guest Ratings


-- 1. Average reviews across all listings
select round(sum(number_of_reviews*review_scores_rating)/sum(number_of_reviews),2) 
as weighted_avg_review_score
from listings;

-- 2. Top 20 listings by number of reviews

select round(avg(review_scores_rating),2) from listings;

select id, name, number_of_reviews, review_scores_rating
from listings 
where review_scores_rating is not null
order by number_of_reviews desc
limit 20;

-- 3. Number of listings with an average review score < 4
select count(*) from
(select round(sum(number_of_reviews*review_scores_rating)/sum(number_of_reviews),2)
from listings 
group by id, name
having round(sum(number_of_reviews*review_scores_rating)/sum(number_of_reviews),2) < 4);

-- Host Engagement

select * from listings;

--1. Number of hosts with > 3 listings
select host_id, host_name, count(id) as listing_count
from listings 
group by host_id, host_name
having count(id) > 3;

select distinct host_id, host_name, host_listings_count
from listings
where host_listings_count > 3;

--2. Average review scores of host

select host_id, host_name, round(sum(number_of_reviews*review_scores_rating)/sum(number_of_reviews),2) 
as weighted_avg_review_score
from listings 
group by host_id, host_name;

--3. Hosts with >= 2 listings and review scores below 4

select host_id, host_name, count(id) as listing_count,
round(sum(number_of_reviews*review_scores_rating)/sum(number_of_reviews),2) 
as weighted_avg_review_score
from listings 
group by host_id, host_name
having count(id) >= 2 and 
round(sum(number_of_reviews*review_scores_rating)/sum(number_of_reviews),2) < 4;

-- Booking Trends

-- 1.Occupancy rate for each listing in Jan 2024

select * from calendars;

select listing_id, round(sum(booked)*1.0/count(available)*100,2) as occupancy_rate
from
(select listing_id, date, available, 
case 
	when available  = false then 1
	else 0
end as booked
from calendars
where extract(year from date) = 2024
and extract(month from date) = 1)
group by listing_id;

-- 2. Top 5 listings with highest occupancy rates

select listing_id, round(sum(booked)*1.0/count(available)*100,2) as occupancy_rate
from
(select listing_id, date, available, 
case 
	when available  = false then 1
	else 0
end as booked
from calendars
where extract(year from date) = 2024
and extract(month from date) = 1)
group by listing_id
order by round(sum(booked)*1.0/count(available)*100,2) desc, listing_id
limit 5;

--3. Listings without booking in Jan 2024

select listing_id
from
(select listing_id, date, available, 
case 
	when available  = false then 1
	else 0
end as booked
from calendars
where extract(year from date) = 2024
and extract(month from date) = 1)
group by listing_id
having sum(booked) = 0;

-- Pricing patterns across property types

SELECT * FROM calendars;
select * from listings;
select * from reviews;

-- with l_avg_price as (
-- select listing_id,round(avg(cast(price as numeric)),2) as avg_price
-- from calendars
-- group by listing_id
-- )
-- select property_type, round(avg(avg_price),2) as avg_property_type_price
-- from listings l join l_avg_price av
-- on l.id = av.listing_id
-- group by property_type;

-- 1. Average price per night for each property type
select l.property_type, round(avg(cast(c.price as numeric)),2) as avg_price
from listings l join calendars c
on l.id = c.listing_id
group by l.property_type;

-- 2. Top 5 listings with highest average price per night and their property type

select l.id,l.property_type, round(avg(cast(c.price as numeric)),2) as avg_price
from listings l join calendars c
on l.id = c.listing_id
group by l.id, l.property_type
order by round(avg(cast(c.price as numeric)),2) DESC
limit 5;

-- 3. Property types with average price below $150 per night

select l.property_type, round(avg(cast(c.price as numeric)),2) as avg_price
from listings l join calendars c
on l.id = c.listing_id
group by l.property_type
having round(avg(cast(c.price as numeric)),2) < 150;


-- Guest review insights
select * from reviews;

-- 1. Top 10 reviewers by total number of reviews submitted
select reviewer_id, reviewer_name, count(id) as review_count
from reviews
group by reviewer_id, reviewer_name
order by count(id) desc
limit 10;

--2. Average number of reviews per listing

with review_count_cte as 
(select listing_id, count(id) as review_count
from reviews 
group by listing_id)

select round(avg(review_count),2) as avg_number_reviews_per_listing
from review_count_cte;

-- 3. Listings with no reviews in 2023

select id, name from listings
where id not in 
(select distinct listing_id from 
reviews 
where extract(year from date) = 2023);

select * from calendars;



----------------------------------------------------------------------------



-- 1. Reviews ranked by submisison date
select listing_id, date as review_date, reviewer_name, 
rank()over(order by date) as rank_of_review, id, comments
from reviews
where extract(year from date) = 2015
and extract (month from date) < 7;

-- 2. Most active hosts
select count(*) from reviews;

select host_id, host_name, sum(number_of_reviews) as review_count,
rank()over(order by sum(number_of_reviews) desc) as rank
from listings
group by host_id, host_name;

--3. Total revenue for each listing

select listing_id, sum(price :: decimal) as total_revenue,
rank()over(order by sum(price :: decimal) desc) as rank
from calendars
where available  = True
group by listing_id;

-- 4. Total summer revenue for each property type
select * from calendars;

select l.property_type, sum(c.price::decimal) as total_summer_revenue,
PERCENT_RANK()OVER(ORDER BY sum(c.price::decimal)) AS percentile_rank
from 
listings l left join calendars c
on l.id = c.listing_id
where c.available = True
and extract(month from c.date) in (6,7,8)
group by l.property_type
order by PERCENT_RANK()OVER(ORDER BY sum(c.price::decimal)) desc;

-- 5. YoY growth

with revenue_per_year as (
    select
        c.listing_id,
        extract(year from c.date) as year,
        sum(cast(c.price as numeric)) as total_revenue
    from
        calendars c
    where
        c.available = true
        and c.price is not null
    group by
        c.listing_id, extract(year from c.date)
),
revenue_with_growth as (
    select
        r.listing_id,
        r.year,
        r.total_revenue,
        lag(r.total_revenue) over (partition by r.listing_id order by r.year) as previous_year_revenue,
        case
            when lag(r.total_revenue) over (partition by r.listing_id order by r.year) is not null then
                ((r.total_revenue - lag(r.total_revenue) over (partition by r.listing_id order by r.year))
                / lag(r.total_revenue) over (partition by r.listing_id order by r.year)) * 100
            else
                null
        end as yoy_growth
    from
        revenue_per_year r
)
select
    listing_id,
    year,
    total_revenue,
    yoy_growth,
    rank() over (order by yoy_growth desc) as growth_rank
from
    revenue_with_growth
where yoy_growth is not null
order by
    growth_rank;


