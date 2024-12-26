create database ankit_bansal;
use ankit_bansal;

create table emp_compensation (
emp_id int,
salary_component_type varchar(20),
val int
);

insert into emp_compensation
values 
(1,'salary',10000),
(1,'bonus',5000),
(1,'hike_percent',10), 
(2,'salary',15000),
(2,'bonus',7000),
(2,'hike_percent',8), 
(3,'salary',12000),
(3,'bonus',6000),
(3,'hike_percent',7);
select * from emp_compensation;

	----------row to column(without pivot)-------------------------
select emp_id,sum( case when salary_component_type='salary' then val end) as salary,
sum(case when salary_component_type='bonus' then val end )as bonus,
sum(case when salary_component_type='hike_percent' then val end) as hike_percent
from emp_compensation group by emp_id

-------------------------------------------------------------------------------------------------------

create table products (
id int,
name varchar(10)
);
insert into products VALUES 
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');

create table colors (
color_id int,
color varchar(50)
);
insert into colors values (1,'Blue'),(2,'Green'),(3,'Orange');

create table sizes
(
size_id int,
size varchar(10)
);

insert into sizes values (1,'M'),(2,'L'),(3,'XL');

create table transactions1
(
order_id int,
product_name varchar(20),
color varchar(10),
size varchar(10),
amount int
);
insert into transactions1 values 
(1,'A','Blue','L',300),
(2,'B','Blue','XL',150),
(3,'B','Green','L',250),
(4,'C','Blue','L',250),
(5,'E','Green','L',270),
(6,'D','Orange','L',200),
(7,'D','Green','M',250);


select  product_name,color,size,sum(amount)as totalsum from transactions1 group by product_name,color,size

-------------------------------------------------------------------------
create table mode 
(
id int
);

insert into mode values (1),(2),(2),(3),(3),(3),(3),(4),(5);

select * from mode

with cte as(
select id,count(*)as c from mode group by id
)
select * from cte where c=(select max(c) from cte)


with cte as(
select id,count(*)as c from mode group by id
)select * from(select *,ROW_NUMBER() over (order by c desc)as r from cte)as a where r=1

------------------------------------------------------------------

create table emp_2020
(
emp_id int,
designation varchar(20)
);

create table emp_2021
(
emp_id int,
designation varchar(20)
)

insert into emp_2020 values (1,'Trainee'), (2,'Developer'),(3,'Senior Developer'),(4,'Manager');
insert into emp_2021 values (1,'Developer'), (2,'Developer'),(3,'Manager'),(5,'Trainee');

select isnull(e20.emp_id,e21.emp_id),
case when e20.designation != e21.designation then 'Promoted'
when e21.designation is null then 'Resigned' 
else 'New Joiner' end as status 
from emp_2020 e20 full outer join emp_2021 e21 on e20.emp_id=e21.emp_id 
where isnull(e20.designation,'xxxx') != isnull(e21.designation,'yyyy')


----------------------------------------------------------------------------------------------------------
create table list (id varchar(5));
insert into list values ('a');
insert into list values ('a');
insert into list values ('b');
insert into list values ('c');
insert into list values ('c');
insert into list values ('c');
insert into list values ('d');
insert into list values ('d');
insert into list values ('e');

select * from list


with cte as
(
select id from list group by id having count(*)>1
),
cte1 as(select *,rank() over (order by id )as s from cte)

select li.id,('Dup'+cast(s as varchar(2))) as state from list li left join cte1 on li.id=cte1.id

-----------------------------------------------------------------------------------------------


--1- Update basic syntax
--2- Update with where clause
--3- Update multiple values in a statement 
--4- Update using Join
--5- Update using calculations
--6- Interview question on Update
--7- Some tips and tricks on sql update

------------slowly changing dimensions ( over a period of time the dimensions will change)---------------


------------running sum-----------------------
create table producttable
(
productid varchar(10),
cost int
)

insert into producttable values ('p1',200),('p2',300),('p3',300),('p4',500),('p5',800)

select *,sum(cost) over(order by cost asc,productid)as running from producttable



-----------------------------------------------------------------------------------------------------
------count no of occurence 
create table strings (name varchar(50));
insert into strings values 
('Ankit Bansal'),
('Ram Kumar Verma'),
('Akshay Kumar Ak k'),
('Rahul');

select * from strings

select name,REPLACE(name,' ','')as replaced,len(name)-len(replace(name,' ',''))as length from strings

-----------------------------------------------------------------------------------------------------
---------------all aggregations--------------------
CREATE TABLE [dbo].[int_orders1](
 [order_number] [int] NOT NULL,
 [order_date] [date] NOT NULL,
 [cust_id] [int] NOT NULL,
 [salesperson_id] [int] NOT NULL,
 [amount] [float] NOT NULL
) ON [PRIMARY]
GO
INSERT [dbo].[int_orders1] ([order_number], [order_date], [cust_id], [salesperson_id], [amount])
VALUES (30, CAST(N'1995-07-14' AS Date), 9, 1, 460)
INSERT [dbo].[int_orders1] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) 
VALUES (10, CAST(N'1996-08-02' AS Date), 4, 2, 540)
INSERT [dbo].[int_orders1] ([order_number], [order_date], [cust_id], [salesperson_id], [amount])
VALUES (40, CAST(N'1998-01-29' AS Date), 7, 2, 2400)
INSERT [dbo].[int_orders1] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) 
VALUES (50, CAST(N'1998-02-03' AS Date), 6, 7, 600)
INSERT [dbo].[int_orders1] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) 
VALUES (60, CAST(N'1998-03-02' AS Date), 6, 7, 720)
INSERT [dbo].[int_orders1] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) 
VALUES (70, CAST(N'1998-05-06' AS Date), 9, 7, 150)
INSERT [dbo].[int_orders1] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) 
VALUES (20, CAST(N'1999-01-30' AS Date), 4, 8, 1800)

select * from int_orders1

select salesperson_id,sum(amount) from int_orders1 group by salesperson_id

select salesperson_id,sum(amount)over()from int_orders1 

select salesperson_id,sum(amount) over(partition by salesperson_id)as s from int_orders1

select salesperson_id,sum(amount) over(order by order_date) as s from int_orders1

select salesperson_id,sum(amount) over(partition by salesperson_id order by order_date) as s from int_orders1

select salesperson_id,order_date,order_number,amount,
sum(amount)over(order by order_date rows between 2 preceding and current row) from int_orders1

select salesperson_id,order_date,order_number,amount,
sum(amount)over(order by order_date rows between 2 preceding and 1 preceding ) from int_orders1

select salesperson_id,order_date,order_number,amount,
sum(amount)over(order by order_date rows between 1 preceding and 1 following) from int_orders1

select salesperson_id,order_date,order_number,amount,
sum(amount)over(order by order_date rows between unbounded preceding and current row) from int_orders1

select salesperson_id,order_date,order_number,amount,
sum(amount)over(partition by salesperson_id order by order_date rows between 2 preceding and current row) 
from int_orders1

----------------------------------------------------------------------------------------------------------
---------------------rank(),row_number(),dense_rank()---------------------------------------
create table emp1 
(
empid int,
ename nvarchar(25),
deptid int,
salary int
)
insert into emp1 values
(1,'Ankit',100,10000),
(2,'Mohit',100,15000),
(3,'vikas',100,10000),
(4,'Rohit',100,5000),
(5,'Mudit',200,12000),
(6,'Agam',200,12000),
(7,'Sanjay',200,9000),
(8,'Ashish',200,5000);

select *,rank() over(order by salary )as rank,
DENSE_RANK()over(order by salary) as denserank,
row_number()over(order by salary)as rownumber from emp1

-----------------------------------------------------------------------------
----------full outer join & union()----------------------------------------

Create Table Customer1 (Customer_id int, customer_name Varchar(20))
Create Table Customer_order (Customer_id int, orderDate date)

Insert into Customer1 Values (1,'A')
Insert into Customer1 Values (2,'B')
Insert into Customer1 Values (3,'C')
Insert into Customer1 Values (4,'D')
Insert into Customer1 Values (5,'E')

Insert into Customer_order Values (1,'2022-01-05')
Insert into Customer_order Values (2,'2022-01-06')
Insert into Customer_order Values (3,'2022-01-07')
Insert into Customer_order Values (4,'2022-01-08')
Insert into Customer_order Values (6,'2022-01-09')

select c.Customer_id,c.customer_name,co.Customer_id,co.orderDate from Customer1 c 
full outer join Customer_order co 
on c.Customer_id=co.Customer_id

select c.Customer_id,c.customer_name,co.Customer_id,co.orderDate from Customer1 c 
left join Customer_order co 
on c.Customer_id=co.Customer_id
union all
select c.Customer_id,c.customer_name,co.Customer_id,co.orderDate from Customer_order co
left join Customer1 c
on co.Customer_id=c.Customer_id
where c.Customer_id is null


-----------------------------------------------------------------------------------------
---------------left outer join master()----------------------------------
create table emp2(
emp_id int,
emp_name varchar(20),
dep_id int,
salary int,
manager_id int,
emp_age int);
delete from emp;
insert into emp2
values
(1, 'Ankit', 100,10000, 4, 39);
insert into emp2
values (2, 'Mohit', 100, 15000, 5, 48);
insert into emp2
values (3, 'Vikas', 100, 10000,4,37);
insert into emp2
values (4, 'Rohit', 100, 5000, 2, 16);
insert into emp2
values (5, 'Mudit', 200, 12000, 6,55);
insert into emp2
values (6, 'Agam', 200, 12000,2, 14);
insert into emp2
values (7, 'Sanjay', 200, 9000, 2,13);
insert into emp2
values (8, 'Ashish', 200,5000,2,12);
insert into emp2
values (9, 'Mukesh',300,6000,6,51);
insert into emp2
values (10, 'Rakesh',500,7000,6,50);

create table dept2(
dep_id int,
dep_name varchar(20));

INSERT INTO dept2 VALUES (100,'Analytics'),(200,'IT'),(300,'HR'),(400,'Text Analytics');

select * from emp2 e left join dept2 d on e.dep_id=d.dep_id

select * from emp2 e left join dept2 d on e.dep_id=d.dep_id where d.dep_name='Analytics'

select * from emp2 e left join (select * from dept2 where dep_name='Analytics')de on e.dep_id=de.dep_id

--------------------------------------------------------------------------------------------------------
---------------------business case of weeknd and public hoildays----------------------------------------
use ankit_bansal
create table tickets
(
ticket_id varchar(10),
create_date date,
resolved_date date
);
insert into tickets values
(1,'2022-08-01','2022-08-03')
,(2,'2022-08-01','2022-08-12')
,(3,'2022-08-01','2022-08-16');
create table holidays
(
holiday_date date
,reason varchar(100)
);
insert into holidays values
('2022-08-11','Rakhi'),('2022-08-15','Independence day');

select *,datediff(day,create_date,resolved_date)as diffdate from tickets

select *,
datediff(day,create_date,resolved_date)as diffdate,
datepart(week,create_date),
datepart(week,resolved_date)
from tickets

select ticket_id,create_date,resolved_date,count(holiday_date)as no_of_holidays
--datediff(day,create_date,resolved_date)as actualdays,
--datediff(day,create_date,resolved_date)-2*datediff(week,create_date,resolved_date)as business_days,
--datediff(week,create_date,resolved_date)as diffweek
from tickets left join holidays on holiday_date between create_date and resolved_date
group by ticket_id,create_date,resolved_date

select * from holidays

--------------------------------------------------------------------------------------------------------
----------------convert comma separate values into rows------------------------------------------------

create table airbnb_searches 
(
user_id int,
date_searched date,
filter_room_types varchar(200)
);

insert into airbnb_searches values
(1,'2022-01-01','entire home,private room')
,(2,'2022-01-02','entire home,shared room')
,(3,'2022-01-02','private room,shared room')
,(4,'2022-01-03','private room')
;

select * from airbnb_searches

select value from string_split('entrie home,private room',',');

select value as roomtypes,count(1)as no_of_searches 
from airbnb_searches cross apply string_split(filter_room_types,',')
group by value

--------------------------------------------------------------------------------------------
--------------------Aggregations and window function() together------------------------
with sales_value as(
	select category,product_name,sum(sales)as total_sales from orders 
	group by category,product_name
)
    select * from
	(
	select *,
	rank() over(
				partition  by category order by total_sales desc 
				)as rn
			from sales_value
	 ) as a 
	where rn<=5

---------------------------------------------------------------------------------------------
----------------------pattern matching using wildcards---------------------------------------

select order_id,order_date,customer_name from
orders
where customer_name like 'Raja%';

select order_id,order_date,customer_name from
orders
where customer_name like '%shekar';

select order_id,order_date,customer_name from
orders
where customer_name like '%she%';

---% 0 or more characters

select order_id,order_date,customer_name from
orders
where customer_name like '_a%';

select order_id,order_date,customer_name from
orders
where customer_name like '__e%';

---'_' is a single character

select order_id,order_date,customer_name from
orders
where customer_name like 'A[ns]%';

---[]anything within the brackets can come

select order_id,order_date,customer_name from
orders
where customer_name like 'A[^ns]%';

--'^' not like 



-----identify and delete duplicates 

select id,count(1) from emp group by id having count(1)>1

delete from emp where id in (select id,count(1) from emp group by id having count(1)>1)


--------------------------------------------------------------------------------------------
-------------first value() and last value () in window function-----------------------------

create table employee(
    emp_id int,
    emp_name varchar(20),
    dept_id int,
    salary int,
    manager_id int,
    emp_age int
);

insert into employee values(1,'Ankit',100,10000,4,39);
insert into employee values(2,'Mohit',100,15000,5,48);
insert into employee values(3,'Vikas',100,10000,4,37);
insert into employee values(4,'Rohit',100,5000,2,16);
insert into employee values(5,'Mudit',200,12000,6,55);
insert into employee values(6,'Agam',200,12000,2,14);
insert into employee values(7,'Sanjay',200,9000,2,13);
insert into employee values(8,'Ashish',200,5000,2,12);
insert into employee values(9,'Mukesh',300,6000,6,51);
insert into employee values(10,'Rakesh',500,7000,6,50);

select * from employee

select *,FIRST_VALUE(emp_name) over(order by emp_age desc)as lowest_salary,
LAST_VALUE(emp_name) over (order by emp_age)as oldest_employee  from employee


select *,
LAST_VALUE(emp_name) over(order by emp_age rows between current row and unbounded following) as oldest_emp
from
employee

------------------------------------------------------------------------------

------------------calender problem-------------------------------------
create proc spGetAllDays
@startDate date,
@endDate date
as
begin
		with cte as (
			select @startDate as date
			union all
			select DATEADD(day,1, date) as date from cte
			where date < @endDate
		)
		select * 
		into #dates
		from cte
		option (MAXRECURSION 0);
 
		select year(date) as year, count(*) as no_of_days
		from #dates
		group by year(date)
 
		drop table #dates
end;
 
exec spGetAllDays @startDate = '2024-11-04', @endDate =  '2024-12-06';
-----------------------------------------------------------------------------------
---------------creating a calendar-------------------------------------------------

select cast('2000-01-01' as date)as cal_date,datepart(year,'2000-01-01')as cal_year

-----Recursive cte--
with cte as
(
select 1 as id 
union all
select id+1 as id 
from cte where id<30
)
select * from cte
option (maxrecursion 300)-- this for maximum recursion limit
---------------------

-- calender problem from start date to end date---------------
alter proc spDates
@start date,
@end date
as
begin

with cte as
(
select @start as date
union all
select dateadd(day,1,date) as date from cte where date<@end
)
select * into #drop from cte option (maxrecursion 0)

select year(date)as years,count(*)as days from #drop group by year(date) order by years desc

drop table #drop
end

exec spDates '2019-01-01','2024-12-04'
------------------------------------------------------------------------------------------------


------building calender from 2000-01-01 to 2050-12-31-------------------------------------------

with cte as
(
select cast('2000-01-01' as date)as cal_date,datepart(year,'2000-01-01')as cal_year
,datepart(dayofyear, '2000-01-01') as cal_year_day
,datepart(quarter, '2000-01-01') as cal_quarter
,datepart(month, '2000-01-01') as cal_month
,datename(month, '2000-01-01') as cal_month_name
,datepart(day, '2000-01-01') as cal_month_day
,datepart(week, '2000-01-01') as cal_week
,datepart(weekday, '2000-01-01') as cal_week_day
,datename(weekday, '2000-01-01') as cal_day_name
union all
select dateadd(day,1,cal_date) as cal_date, datepart(year,dateadd(day,1,cal_date))as cal_year
,datepart(dayofyear, dateadd(day,1,cal_date)) as cal_year_day
,datepart(quarter, dateadd(day,1,cal_date)) as cal_quarter
,datepart(month, dateadd(day,1,cal_date)) as cal_month
,datename(month, dateadd(day,1,cal_date)) as cal_month_name
,datepart(day, dateadd(day,1,cal_date)) as cal_month_day
,datepart(week, dateadd(day,1,cal_date)) as cal_week
,datepart(weekday, dateadd(day,1,cal_date)) as cal_week_day
,datename(weekday, dateadd(day,1,cal_date)) as cal_day_name
from cte
where cal_date<cast('2050-12-31' as date)
)
select ROW_NUMBER() over(order by cal_date asc)as id, * into cal_date_dim from cte
option (maxrecursion 32676)

select * from cal_date_dim

-----------------------------------------------------------------------------------
----------------Dynamic way to create insert statements---------------------------

create table emp
(
id int,
ename varchar(25),
salary int,
dob date
)
insert into emp values 
(1,'abc',1000,'2000-01-01'),
(2,'def',2000,'2001-02-02'),
(3,'ghi',3000,'2002-03-03');

select 
concat('insert into emp values(',id,',',char(39),ename,char(39),',',salary,char(39),dob,char(39),');')as query
from emp;

------------------------------------------------------------------------------------------------------------------

--problem statement : find top 25 and bottom 25 percent customers by sales

/* the Ntile Analytical function is used to divide a result set into specified number of groups or bucket based on
a specific row each. Each row in the result set is assigned a group number that represents its position
within in the order set of data. */







---------------------------------------------------------------------------------------------------------------------
---------------------Rolling calculations sum(),Avg(),max(),min()----------------------------------------------------

select *,
sum(salary)over(order by emp_age asc rows between 1 preceding and 1 following)as rolling_sum,
avg(salary) over(order by emp_age asc rows between 1 preceding and 1 following) as rolling_avg,
max(salary)over(order by emp_age asc rows between 1 preceding and 1 following) as rolling_max,
min(salary)over(order by emp_age asc rows between 1 preceding and 1 following) as rolling_min
from employee


---------------------------------------------------------------------------------------------------------------------
--------------full outer join in depth and alternatives-------------------------------------------------------------
create table product_master 
(
product_id int,
product_name varchar(100)
);

insert into product_master values(100,'iphone5'),(200,'hp laptop'),(300,'dell laptop');

create table orders_usa
(
order_id int,
product_id int,
sales int
);
create table orders_europe
(
order_id int,
product_id int,
sales int
);

create table orders_india
(
order_id int,
product_id int,
sales int
);
--delete from orders_india
insert into orders_usa values (1,100,500);
insert into orders_usa values (7,100,500);
insert into orders_europe values (2,200,600);
insert into orders_india values (3,100,500);
insert into orders_india values (4,200,600);
insert into orders_india values (8,100,500);

select coalesce(u.product_id,e.product_id,i.product_id)as product_id,
u.sales as usa_sales,e.sales as europe_sales,i.sales as india_sales  from 
orders_usa u full outer join orders_europe e 
on u.product_id=e.product_id
full outer join orders_india i on coalesce(u.product_id,e.product_id)=i.product_id

with cte as
(
select product_id,sales as usa_sales,null as europe_sales,null as india_sales from orders_usa
union all
select product_id,null as usa_sales,sales as europe_sales,null as india_sales from orders_europe
union all
select product_id,null as usa_sales,null as europe_sales,sales as india_sales from orders_india
)
select product_id,
sum(usa_sales)as usa_sales,
sum(europe_sales)as europe_sales,
sum(india_sales)as india_sales from cte
group by product_id

----------------------------------------------------------------------------------------------------
------------sql order of the execution---------------------------------------------

select * from employee

from ->any join-> where ->group by->having-> select -> order by -> top 5

-----------------------------------------------------------------------------------
---10 methods
create table students  (
student_id int,
skill varchar(20)
);
delete from students;
insert into students values
(1,'sql'),(1,'python'),(1,'tableau'),(2,'sql'),(3,'sql'),(3,'python'),(4,'tableau'),(5,'python'),(5,'tableau');

select * from students

--to find student who work only sql and python
--the student should have 2 skills
--2 skills sql and python

--solution 1
with cte as
(
select student_id,count(*)as total_skills,
count(case when skill in ('python','sql') then skill else null end)as skill_count 
from students 
group by student_id
)
select * from cte where total_skills=2 and skill_count=2

--solution 2

select student_id,count(*)as total_skills,
count(case when skill in ('python','sql') then skill else null end)as skill_count 
from students 
group by student_id having count(*)=2 and count(case when skill in ('python','sql') then skill else null end)=2

--solution 3

select student_id,count(*) as total_skills,
count(case when skill in ('python','sql') then skill else null end) as skill_count,
count(case when skill not in ('python','sql') then skill else null end ) as not_skilled
from students
group by student_id having count(*)=2 and count(case when skill not in ('python','sql') then skill else null end)=0

--solution 4

select student_id,
count(*)as total_skills
from students
where student_id not in ( select student_id from students where skill not in ('python','sql'))
group by student_id having count(*)=2

--solution 5

select student_id from students group by student_id having count(*)=2
except
select student_id from students where skill not in ('python','sql')

--solution 6 (not exists)

select student_id,count(*) as total_skills from 
students s1
where not exists
(select 1 from students s2 where s2.skill not in ('sql','python')
and s1.student_id=s2.student_id)
group by student_id
having count(*)=2
