create database sales_database;

use sales_database;

create table sales(
sales_id int not null,
product_id int not null,
product_name varchar(20),
customer_id int not null,
customer_name varchar(20),
sale_date date,
quality float,
price_per_unit float,
total_amount float,
manufactering_date date,
primary key(sales_id,product_id,customer_id)
);
 
EXEC sp_help 'sales';
 
INSERT INTO sales (sales_id, product_id, product_name, customer_id, customer_name, sale_date, quality, price_per_unit, total_amount, manufactering_date)
VALUES
(1, 101, 'Product A', 201, 'Customer X', '2024-07-09', 5, 10.50, 52.50, '2024-06-01'),
(2, 102, 'Product B', 202, 'Customer Y', '2024-07-09', 3, 8.25, 24.75, '2024-06-15'),
(3, 103, 'Product C', 203, 'Customer Z', '2024-07-08', 10, 15.75, 157.50, '2024-05-20'),
(4, 104, 'Product D', 204, 'Customer W', '2024-07-08', 8, 12.00, 96.00, '2024-06-10'),
(5, 105, 'Product E', 205, 'Customer V', '2024-07-07', 12, 7.50, 90.00, '2024-05-25'),
(6, 106, 'Product F', 206, 'Customer U', '2024-07-07', 6, 18.50, 111.00, '2024-06-05'),
(7, 107, 'Product G', 207, 'Customer T', '2024-07-06', 4, 20.25, 81.00, '2024-06-12'),
(8, 108, 'Product H', 208, 'Customer S', '2024-07-06', 15, 5.75, 86.25, '2024-06-20'),
(9, 109, 'Product I', 209, 'Customer R', '2024-07-05', 7, 9.99, 69.93, '2024-06-08'),
(10, 110, 'Product J', 210, 'Customer Q', '2024-07-05', 9, 14.20, 127.80, '2024-05-30'),
(11, 111, 'Product A', 200, 'Customer x', '2023-07-05', 9, 14.20, 127.80, '2023-05-30'),
(12, 112, 'Product B', 190, 'Customer y', '2023-07-05', 9, 14.20, 127.80, '2022-05-30'),
(13, 113, 'Product C', 210, 'Customer z', '2023-07-05', 9, 14.20, 127.80, '2023-05-30'),
(14, 111, 'Product A', 201, 'John Doe', null, 5, 10.5, 52, '2023-06-01'),
(15, 112, 'Product B', 202, 'Jane Smith', null, 3, 8.25, 24, '2022-06-15');
 
 
select * from sales;

--1)Retrieve the product name with highest price  
select top 1 product_name,max(price_per_unit)as highest_price  from sales  group by product_name order by highest_price desc;
select product_name from sales where price_per_unit= (select max(price_per_unit) from sales);

--2)Retrieve the rows where the quantity is greater than 2
select * from sales where quality>2;
 
--3)Total quantities sold for each product
select product_name,sum(quality)as total_qualities from sales group by product_name;
 
--4)Retrieve how many products got manufactured every year 
select year(manufactering_date)as Manu_year,count(product_id) as product from sales group by year( manufactering_date);
 
--5)Retrieve no. Of products sold every year 
select year(sale_date)as Each_year,count(product_name) as product_sold from sales group by year(sale_date);
 
--6)How many products are unsold every year 
select year(manufactering_date)as Each_year,count(*) as unsold from sales where sale_date is null group by year(manufactering_date);
 
--7)Average spends for each customer  
select customer_name,avg(total_amount)as Average from sales group by customer_name;
 
--8)Total amount sold for each , total sales of each product  
select product_name,sum(quality)as total_sales from sales group by product_name;
 
--9)What are the sales for every month for each year month wise
select year(sale_date)as year,month(sale_date) as month,count(sale_date) as sales
from sales
where sale_date is NOT NULL
group by year(sale_date),month(sale_date);
 
--10)What is the highest sold product - amount  
select top 1product_name,sum(total_amount)as total_amount from sales group by product_name;
 
--11)What is the highest sold product – quantity  
select top 1 product_name,sum(quality) as total_quantity from sales group by product_name;
 
--12)Oldest sold product  
select top 1  product_name,sale_date from sales where sale_date is not null order by year(sale_date) ;
 
--13) Least sold product  
select top 1 product_name,sum(quality) as total  from sales where sale_date is not null
 group by product_name order by total;
 
--14)Which product is in the stock for longest amount of time  
SELECT top 1 DATEDIFF(day, manufactering_date, sale_date) AS DateDiff ,product_id
from sales
where sale_date is not null
order by datediff desc;