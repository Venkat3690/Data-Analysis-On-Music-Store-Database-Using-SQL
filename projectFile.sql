create database if not exists music_store;
show databases;

use music_store;

-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);

-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY auto_increment,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
	levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY auto_increment,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
    on update cascade on delete cascade
);

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY auto_increment,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
    on update cascade on delete cascade
);

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY auto_increment,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id)
    on update cascade on delete cascade,
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id)
    on update cascade on delete cascade,
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
    on update cascade on delete cascade
);

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY auto_increment,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
    on update cascade on delete cascade
);

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY auto_increment,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id)
    on update cascade on delete cascade,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
    on update cascade on delete cascade
);

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY auto_increment,
	name VARCHAR(255)
);

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT auto_increment,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id)
    on update cascade on delete cascade,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
    on update cascade on delete cascade
);

show tables;

select * from genre;
select * from mediatype;
select * from Employee;
insert into Employee(employee_id,last_name,first_name,title,levels,birthdate,hire_date,address,city,state,country,postal_code,phone,fax,email) 
values(9,'Madan','Mohan','Senior General Manager','L7','1961-01-26','2016-01-14','1008 Vrinda Ave MT','Edmonton','AB','Canada','T5K 2N1','+1 (780) 428-9482','+1 (780) 428-3457','madan.mohan@chinookcorp.com'); 
select * from Customer;
select * from Artist;
select * from Album;

/*Ensure secure_file_priv is properly configured
Before importing, run this command to check where MySQL allows file imports from:
*/
SHOW VARIABLES LIKE 'secure_file_priv';

-- Use the following SQL command to import track.csv:
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE  track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);

select * from track;
select * from invoice;
select * from invoiceline;
select * from playlist;
select * from playlisttrack;

-- 1. Who is the senior most employee based on job title? 
select * from Employee;
select * 
from Employee 
where reports_to is null;
/*Explanation:-
This query works by selecting the employee who does not report to anyone, indicated by a NULL value in the reports_to column. 
This person is at the top of the company hierarchy.
*/

-- 2. Which countries have the most Invoices?
select * from invoice;
select billing_country,count(*) as countOfEachCountryInvoices
from invoice
group by billing_country
order by countOfEachCountryInvoices desc;
/*Explanation:-
This query counts the number of invoices for each country, 
then sorts the results in descending order to show the countries with the highest number of invoices at the top.*/

-- 3. What are the top 3 values of total invoice?
select * from invoice;

select total 
from invoice 
order by total desc
limit 3;
/*Explanation:-
This query selects the total column from the invoice table, sorts the values in descending order, 
and then returns only the top 3 highest values.*/

/* 4. Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals
*/
select * from invoice;
select billing_city,sum(total) as SumOfTotalInvoiceOfEachCity
from invoice 
group by billing_city
order by SumOfTotalInvoiceOfEachCity desc
limit 1;
/*Explanation:-
This query calculates the total sales for each city, sorts them in descending order, 
and then returns the city with the highest total.
*/

/*5. Who is the best customer? - The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select * from Customer;
select * from Invoice;

select i.customer_id,concat(c.first_name," ",c.last_name) as CustomerName,sum(i.total) as totalInvoiceByACustomer
from Invoice i
inner join Customer c
on c.customer_id=i.customer_id
group by i.customer_id
order by totalInvoiceByACustomer desc
limit 1;
/*Explanation: This query joins the Customer and Invoice tables, 
calculates the total spending for each customer by summing up their invoice totals, 
and then orders the results in descending order to find the customer with the highest total spending. 
The LIMIT 1 clause ensures that only the top customer is returned.*/

/*6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with 'A'.
*/
select * from customer;
select * from invoice;
select * from invoiceline;
select * from track;
select * from genre;

select c.customer_id,c.email,c.first_name,c.last_name,t.genre_id,g.name
from customer c
join invoice i
on c.customer_id=i.customer_id
join invoiceline il
on il.invoice_id=i.invoice_id
join track t
on t.track_id=il.track_id
join genre g
on g.genre_id=t.genre_id
where t.genre_id is not null and t.genre_id=1
group by c.customer_id
order by c.email
;
/*Explanation: This SQL query joins the Customer, Invoice, InvoiceLine, Track, 
and Genre tables to link customers to the genres of music they have purchased. 
The WHERE clause filters these results to include only 'Rock' music, and ORDER BY sorts the final list by email.*/

/* 7. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands */
select * from track;
select * from album;
select * from artist;

 select a.artist_id,a.name,count(*) as trackCount
 from track t
 join album ab
 on t.album_id=ab.album_id
 join artist a 
 on a.artist_id=ab.artist_id
 join genre g
 on t.genre_id=g.genre_id
 where g.genre_id=1
 group by ab.artist_id
 order by trackCount desc
 limit 10;
 /*Explanation: This query joins the tables from Track, Album, Artist down to Genre to associate artists with the genre of their tracks. 
 It then filters for 'Rock' music, groups the results by artist_id to count their rock tracks, 
 and finally orders them by the count to find the top 10.*/
 
/*8. Return all the track names that have a song length longer than the average song length.
 - Return the Name and Milliseconds for each track. 
 Order by the song length, with the longest songs listed first*/
 select * from track;
 
 select name,milliseconds,(select avg(milliseconds) from track) as avgSongDuration 
 from track
 having milliseconds> avgSongDuration
 order by milliseconds desc;
 /*Explanation: This query first calculates the AVERAGE song duration from Track table using  subquery and 
 then uses the HAVING clause to filter for tracks with a duration longer than that average from the results produced by subquery.*/
 
 /*9. Find how much amount is spent by each customer on artists?
 Write a query to return customer name, artist name and total spent */
 select * from customer;
 select * from artist;
 select * from invoiceline;
 
select concat(c.first_name," ",c.last_name) as CustomerName,ar.name as artistName,
sum(il.unit_price * il.quantity) as totalSpentByCustomerOnEachArtist
from customer c
join invoice i 
on c.customer_id = i.customer_id
join invoiceline il 
on i.invoice_id = il.invoice_id
join track t 
on il.track_id = t.track_id
join album al 
on t.album_id = al.album_id
join artist ar 
on al.artist_id = ar.artist_id
group by c.customer_id,ar.artist_id order by customerName,totalSpentByCustomerOnEachArtist;
/*Explanation: This query joins Customer, Invoice, invoiceline,  and track data with album and artist information.
 It then groups the results by customer_id and artist_id to calculate the total amount spent on each artist by every customer.*/
 
 /*10. We want to find out the most popular music Genre for each country.
 We determine the most popular genre as the genre with the highest amount of purchases.
 Write a query that returns each country along with the top Genre. 
 For countries where the maximum number of purchases is shared, return all Genres
*/
select * from customer;
select * from invoice;
select * from invoiceline;
select * from track;
select * from genre;

with countryGenrePurchases as(
select c.country,g.name,sum(il.quantity) as totalPurchases
from customer c
join invoice i on c.customer_id = i.customer_id
join invoiceline il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on g.genre_id=t.genre_id
group by g.genre_id,c.country
),
rankedGenres as (
  select country,name,totalPurchases, rank() over (partition by Country order by totalPurchases desc) as ranking
  from countryGenrePurchases
)
select country,name,totalPurchases
from rankedGenres
where ranking = 1
order by country,totalPurchases desc;
/*Explanation: The above query first calculates the total purchases for each genre in every country using a Common Table Expression (CTE). 
It then uses the RANK() window function to find the top-selling genre(s) for each country, correctly handling any ties.
*/

 /*11. Write a query that determines the customer that has spent the most on music for each country. 
 Write a query that returns the country along with the top customer and how much they spent. 
 For countries where the top amount spent is shared, provide all customers who spent this amount
 */
select * from customer;
select * from invoice;
 
with CustomerSpending as (
select c.country,concat(c.first_name," ",c.last_name) AS customer_name,SUM(i.total) AS total_spent
from customer as c
join invoice as i
on c.customer_id = i.customer_id
group by c.country,customer_name
),
rankedCustomers as (
select country,customer_name,total_spent,
rank() over (partition by country order by total_spent desc) as ranking
from customerSpending
)
select country, customer_name, total_spent
from rankedCustomers
where ranking = 1 order by country,total_spent desc;
/*Explanation: A similar approach using a window function can be used to solve this problem.
 We'll use a Common Table Expression (CTE) to calculate the total spending for each customer, 
 then rank those customers within their respective countries. 
Finally, we'll select the customers who have the highest rank (rank 1) in their country.
*/