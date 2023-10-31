/* easier queries */
-- a) Which country has the most and least invoices?
select 
	billingcountry,
	count(*) 
from Invoice i 
group by billingcountry 
order by count(*) desc;
--ANS: most - USA with 91, least - 15 countries tied with 7


--b) Which country paid the most and least for music (assume converted into the same currency)?
select 
	billingcountry,
	sum(total) 
from Invoice i 
group by billingcountry 
order by sum(total) desc;
--ANS: most - USA with 523.06, least 7 countries tied at 37.62


--c) Which customer (id and name) had the least invoices? 
-- show their invoices
select 
	customerid,
	count(*) 
from Invoice i 
group by customerid 
order by count(*);

select * from customer where customerid=59;
--ANS: customerid: 59, Puja Srivastava with 6 invoices


--d) How many tracks did the customer from c) purchase across all invoices?
select 
	* 
from Invoice i 
where customerid =59;

select 
	count(*) 
from InvoiceLine il 
where invoiceid in(23,45,97,218,229,284);

--ANS: 36


--e) What is the highest price for a track ?
select max(unitprice) from InvoiceLine il ;
select max(unitprice) from Track t ;
--ANS: 1.99 check both invoiceline and track


--f) What is the longest album (id and name) in seconds?
select * from track;
select 
	albumid,
	sum(milliseconds)/1000 as album_length_seconds 
from track
group by albumid
order by sum(milliseconds) desc;
select * from album where albumid =229;
--ANS: albumid =229, Lost, Season 3


--g) What is the largest playlist (id and name) by the number of tracks?
select 
	playlistid,
	count(*) 
from PlaylistTrack pt 
group by playlistid 
order by count(*) desc;

select * from Playlist p where PlaylistId in(1,8);

--ANS: tied first place by playlist_id 1,8 with 3290 tracks, both called Music.


/* harder queries */
--h) What is the largest playlist by bytes?
select 
	pt.PlaylistId,
	p.name,
	sum(t.bytes) as playlist_in_bytes --divide by 10^9 to get to GB
from PlaylistTrack pt 
left join track t 
	on pt.TrackId = t.TrackId 
left join Playlist p 
	on p.PlaylistId = pt.PlaylistId
group by pt.PlaylistId, p.name
order by sum(t.bytes) desc

--ANS: playlists 3,10 called TV Shows with 89.9GB of tracks


--i) What is the most popular genre by tracks purchased?
select 
	count(il.TrackId) as number_tracks,
	t.GenreId,
	g.name as genre
from InvoiceLine il 
left join Track t 
	on t.TrackId = il.TrackId 
left join Genre g 
	on g.GenreId = t.GenreId 
group by t.GenreId, g.name
order by count(il.TrackId) desc;

--ANS: Rock with 835 tracks



--j) Which artist has created work across the most genres? Fact check the result.
select
	artist_genre.ArtistId,
	a.Name,
	count(artist_genre.GenreId) as count_genres
from (
		select 
			t.genreid,
			a.artistid
		from Track t
		left join Album a 
			on t.AlbumId = a.AlbumId 
		group by t.genreid, a.artistid
	)  artist_genre
left join Artist a 
	on a.ArtistId = artist_genre.ArtistId 
group by 	artist_genre.ArtistId,
			a.Name
order by count(artist_genre.GenreId) desc;

--ANS: Iron Maiden, artistid =90
select 
	g.GenreId,
	g.name
from album a 
left join track t 
	on t.AlbumId = a.AlbumId 
left join genre g 
	on g.GenreId = t.GenreId 
where a.ArtistId =90
group by g.GenreId,g.name;


--k) What is the most purchased track? Which city has the most purchased tracks?
--find most purchase track
select 
	il.trackid,
	t.name,
	count(*) as count_tracks
from InvoiceLine il
left join track t
	on t.TrackId = il.TrackId 
group by il.trackid,t.name
order by count(*) desc; --most purchased tracks have 2 sales, 256 of them..

--find the city with the most purchased tracks
select 
--	max_count.trackid,
--	max_count.name,
	i.BillingCity,
	count(*)
from ( 
		select 
			il.trackid,
			t.name,
			count(*) as count_tracks
		from InvoiceLine il
		left join track t
			on t.TrackId = il.TrackId 
		group by il.trackid,t.name
--		order by count(*) desc
) max_count
left join invoiceline il 
	on max_count.trackid = il.trackid
left join Invoice i 
	on i.InvoiceId = il.InvoiceId 
where max_count.count_tracks =2
	and i.BillingCity is not null
group by 	--max_count.trackid,
--			max_count.name,
			i.BillingCity
order by count(*) desc;

--ANS: Paris



--l) Which employee supports the most customers? 
select 
	employee,
	employeeid,
	count(*) 
from (
	select --*
		i.customerid,
		e.EmployeeId,
		e.FirstName||' '||e.LastName as employee
	from InvoiceLine il
	left join invoice i 
		on il.InvoiceId = i.InvoiceId 
	left join customer c
		on c.CustomerId = i.CustomerId  
	left join Employee e 
		on c.supportrepid = e.EmployeeId 
	group by 	i.customerid,
			e.employeeid,
			e.FirstName||' '||e.LastName
)
group by employee,
	employeeid;

--ANS: Employeeid 3, Jane Peacock with 21 distinct customers


--m) An employee gets a bonus if they support the most sales by dollars. Which employee will get the bonus? 
select
	sum(il.UnitPrice *il.Quantity ) as sales,  
	e.EmployeeId,
	e.FirstName||' '||e.LastName as employee
from InvoiceLine il
left join invoice i 
	on il.InvoiceId = i.InvoiceId 
left join customer c
	on c.CustomerId = i.CustomerId  
left join Employee e 
	on c.supportrepid = e.EmployeeId 
group by e.EmployeeId,
	e.FirstName||' '||e.LastName;

--ANS: Jane Peacock with 833.04 in support sales
