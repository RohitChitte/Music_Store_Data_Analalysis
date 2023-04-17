-- Basic Level Questions

--who is seniour most employee
/*
select * from Employee as T1
order by T1.hire_date 
limit 1
*/

--Which country have the most invoices ?
/*
select T1.billing_country,count(T1.invoice_id) from Invoice as T1
group by T1.billing_country
order by count desc
limit 1
*/

-- select top  3 values of total invoices ?
/*
select total from invoice order by total desc limit 3
*/

-- find billing city with higest sum of invoice totals
/*

select billing_city,sum(total) as s from invoice 
group by billing_city
order by s desc limit 1
*/

-- Which customer spend most money 
/*
select customer.first_name,customer.last_name,invoice.customer_id,invoice.total from 
(
select customer_id,sum(total) as total
from invoice group by customer_id
order by total desc limit 1
) as invoice inner join customer on customer.customer_id=invoice.customer_id
*/

-- 2nd approach
/*
select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as total from customer inner join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id order by total desc limit 1
*/

--- Moderate Level Questions
-- Query details of rock music listenere, sort alphabetically by email 

/*
select distinct customer.email,customer.first_name,customer.last_name,genre.name 
from 
customer inner join invoice 
on customer.customer_id=invoice.customer_id  
inner join invoice_line 
on invoice.invoice_id=invoice_line.invoice_id
inner join track 
on invoice_line.track_id=track.track_id
inner join genre 
on genre.genre_id=track.genre_id
where genre.name='Rock'
order by customer.email
*/

-- 2nd approach more optimised
/*
select distinct customer.email,customer.first_name,customer.last_name,genre.name 
from 
customer inner join invoice 
on customer.customer_id=invoice.customer_id  
inner join invoice_line 
on invoice.invoice_id=invoice_line.invoice_id
where track_id in (
	Select track_id from track 
   join genre on genre.genre_id=track.genre_id
   where genre.name like 'Rock'
)
order by customer.email
*/


-- names of artist who have writtern most number of rock songs
-- artist album- track - genre  (artist names, track counts)
/*
select artist.name,count(genre.genre_id) as count
from 
artist inner join album 
on artist.artist_id=album.artist_id 
inner join track 
on album.album_id=track.album_id
inner join genre
on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.name
order by count desc
limit 10
*/

-- Return the name & milliseconds of songs, which have lenght greater than avg length of songs
-- order the list in descending order
/*
select name, milliseconds from 
track
where milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc
*/

with total as (
select *,quantity*unit_price as total
from invoice_line 
)
select customer.first_name,customer.last_name,artist.name,sum(total.total)
from customer join invoice on customer.customer_id=invoice.customer_id
join total on total.invoice_id=invoice.invoice_id
join track on track.track_id=total.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by 1,2,3
order by 4 desc


with best_genre_in_country as(
select 
customer.country,genre.name,count(genre.genre_id) ,
row_number() over(partition by customer.country order by count(genre.genre_id) desc )
from 
customer join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
group by 1,2
order by 1,3 desc
)
select * from best_genre_in_country where row_number<=1


with best_customer_in_country as(
select 
customer.country as country,customer.first_name,customer.last_name,sum(invoice.total),
row_number() over(partition by country order by sum(invoice.total) desc)
from customer join invoice on customer.customer_id=invoice.customer_id
group by 1,2,3
order by 1,4 desc
	)
	
select country,first_name,last_name,sum from best_customer_in_country where row_number<=1
