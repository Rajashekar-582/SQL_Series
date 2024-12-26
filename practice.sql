  
create database practice;
use practice;

create table product (productid int primary key,
product_name varchar(20)
)

CREATE TABLE sales (
    productid INT,
    date DATE,
    sales_amount INT,
    FOREIGN KEY (productid) REFERENCES product(productid)
);

insert into product values(1,'A'),(2,'B'),(3,'C');

insert into sales values(1,'2023-06-24',1000),(2,'2023-07-05',1000),(3,'2023-08-24',1500);

select * from sales
select * from product
------------------------------------------------------------------------------------------
--1)Find avg sales amount for each month

select p.productid,MONTH(s.date)as each_month,avg(s.sales_amount)as avgsales from product p join sales s on p.productid=s.productid group by MONTH(s.date),p.productid;

--2)find productid,productname with second highest sale.
with cte as(
select  p.productid,p.product_name ,s.sales_amount,
DENSE_RANK() over(order by s.sales_amount desc)as d 
from sales s join product p on 
s.productid=p.productid )
select productId,product_name,sales_amount from cte where d=2;

select * from(select p.productid,p.product_name,s.sales_amount, DENSE_RANK() over(order by s.sales_amount desc)as d
from sales s join product p on s.productid=p.productid) as a where d=2

--3)count of sames saleamount
select sales_amount, count(sales_amount)as total_count from sales  group by sales_amount ;
select sales_amount,count(*) from sales group by sales_amount having count(*)>1;

------------------------------------------------------------------------------------------------

create table dept(deptid int primary key,
designation varchar(25)
)

create table emp(empid int primary key,
emp_name varchar(25),
manager_id int,
deptid int,
foreign key (deptid) references dept(deptid)
)

insert into dept values(1,'CEO'),(2,'CTO'),(3,'HR'),(4,'President'),(5,'Teamlead'),(6,'CheifArchitect');

insert into emp values(1,'rajeev',4,1),(2,'deekshith',4,2),(3,'arun',5,3),(4,'anand',5,4),(5,'vamshi',6,5),(6,'mahesh',4,6),(7,'sanjay',7,3),(8,'ravi',null,3); 

----------------------------------------------------------------------------------------------------------------------------------------------------------------

select * from emp
select * from dept

select e.emp_name from emp e join emp d on e.empid=d.manager_id group by e.emp_name having count(e.emp_name)>1



with cte as (select e.emp_name,count(e.emp_name)as frequent  from emp e join emp f on e.empid=f.manager_id group by e.emp_name)
select top 1 emp_name from cte order by frequent desc 

select e.empid,e.emp_name from emp e  join dept d on e.deptid=d.deptid
where e.manager_id is null;

select empid,emp_name from emp where manager_id is null


--4)find the employee who designation is ceo
create view empdept as
select e.*,d.designation from emp e join dept d on e.deptid=d.deptid;


select * from empdept where designation='CEO'


------------------------------------------------------------------

select e.empid,e.emp_name as employee_name,c.designation,d.emp_name,d.manager_id,r.designation from emp e left join emp d
on d.deptid=e.manager_id
left join dept c
on e.deptid=c.deptid
left join dept r
on d.deptid=r.deptid

----------------------------------------------------------------------
create table emp1(eid int primary key,
ename varchar(10),mid int,dptid int,foreign key(dptid) references  dept1(dptid))

create table dept1(dptid int primary key,dptname varchar(10))

insert into dept1 values(1,'it'),(2,'hr')

insert into emp1 values(1,'a',4,1),(2,'b',3,2),(3,'c',2,1),(4,'d',1,2)

select e.eid,e.ename,d.dptname as emp_dept,m.eid as mgid,m.ename as manager_name,s.dptname as manager_dept  
from emp1 e 
join emp1 m on e.mid=m.eid 
join dept1 d on e.dptid=d.dptid 
join dept1 s on m.dptid=s.dptid


----------------------------------------------
create table salary1(eid int,
salary int,
foreign key (eid) references emp1(eid)
)

insert into salary1 values (1,1000),(2,2000),(3,1000),(4,4500)

select * from salary1
-----------------------------------------------------------

select top 1 e.eid,e.ename,d.dptname,s.salary from emp1 e join salary1 s on e.eid=s.eid   join dept1 as d on e.dptid=d.dptid order by s.salary desc

select top 1 e.eid,e.ename,d.dptname from emp1 e join salary1 s on e.eid=s.eid join dept1 as d on e.dptid=d.dptid order by s.salary desc

alter view emp_salary as
(select e.*,s.salary from emp1 e join salary1 s on e.eid=s.eid)

select * from emp_salary

select salary,count(*) from emp_salary group by salary order by salary desc

--------------------------------------------------------------------------------

create table emp2(eid int,ename varchar(50),salary int)

insert into emp2 values(1,'A',2000),(2,'B',3000),(3,'C',4000),(4,'D',5000),(5,'E',3400),(6,'F',2300),(7,'G',4900)
insert into emp2 values(9,'H',3000)
select * from emp2

alter table emp2 drop column joiningdate 

--Nth highest salary
select ename,salary from(select ename,salary,RANK() over( order by salary desc)as d from emp2)as a where d=5

------------------------------------------------------------------------------------------
create proc suresh
as
begin
select * from emp2
end;

exec suresh


--with one input stored procedure

create proc suresh1
@salary int
as
begin
select * from emp2 where salary=@salary;
end;

exec suresh1 5000

--with two output

alter proc suresh3
@maxSalary int output,
@minSalary int output
as
begin
select @maxSalary=max(salary),@minSalary=min(Salary) from emp2
end;

declare @max int ,@min int
exec suresh3 @maxSalary=@max output,@minSalary=@min output
select @max as maxsalary,@min as minSalary

--------------------------------------------------------------------------

--with one input,one output

create proc suresh4
@eid int,
@salary int output
as
begin
select @salary=salary from emp2 where eid=@eid
end;

declare @sal int
exec suresh4 1,@salary=@sal output
select @sal as salary

-----------------------------------------------------------------------------------
--update value using stored procedure

create proc suresh5
@in int,
@salary int
as
begin
update  emp2
set salary=@salary
where eid=@in 
end;

exec suresh5 @in=5,@salary=3890

select * from emp2
with cte as(
select *,ROW_NUMBER() over(order by eid )as b from emp2
)
select * from cte where b%2=0

select * from emp2 where eid%2=0
use practice
alter table emp2 add joiningdate date

update emp2
set joiningdate=
case eid
when 1 then '2024-06-06'
when 2 then '2024-07-06'
when 3 then '2023-05-09'
when 4 then '2022-07-07'
when 5 then '2022-07-01'
when 6 then '2023-09-11'
when 7 then '2024-06-29'
when 8 then '2023-06-04'
end;

-------------------------------------------------------------------------------------

-----------------Functions--------------------------------------------
create function dbo.experience(@e date)
returns int
as
begin
return datediff(year,@e,getdate())
end
go
select ename,salary,dbo.experience(joiningdate)as experience from emp2;

-------------------------------------------------------------------------------

create function dbo.month(@d date)
returns int
as
begin
declare @res int;
set @res=datediff(month,@d,getdate());
return @res
end
go
select ename,salary,dbo.month(joiningdate)as months from emp2
---------------------------------------------------------------------
create function dbo.updated(@i int)
returns  table
as
return(
select ename,salary from(select ename,salary,RANK() over( order by salary desc)as d from emp2)as a where d=@i);

select * from dbo.updated(4)
select * from emp2
-----------------------------------------------------------------------
create table empaudit
(auditid int primary key identity(1,1) ,
operations varchar(10),
complete_details varchar(1000)
)
alter TRIGGER trg_Op
ON emp2
INSTEAD OF INSERT
AS
BEGIN
    -- Insert into empaudit table
    INSERT INTO empaudit (operations, complete_details)
    SELECT 
        'insert',
        CONCAT(
            'eid: ', CAST(i.eid AS NVARCHAR), ', ',
            'ename: ', i.ename, ', ',
            'salary: ', CAST(i.salary AS NVARCHAR), ', ',
            'joiningdate: ', CAST(i.joiningdate AS NVARCHAR)
        )
    FROM inserted i;
    
    -- Perform the actual insert into emp2
    INSERT INTO emp2 (eid, ename, salary, joiningdate)
    SELECT 
        i.eid,
        i.ename,
        i.salary,
        i.joiningdate
    FROM inserted i;
END;

insert into emp2 values(9,'I',6000,'2024-08-07')
select * from emp2
select * from empaudit

with cte
as
(select *,row_number() over(partition by salary order by salary)as row_num from emp2 )
delete from cte where row_num>1

insert into emp2 values (2,'B',2000)

select * from emp2
SELECT COALESCE(NULL,'PostgreSQL','SQL');
SELECT ROUND(123.4567, 2);
SELECT AVG(salary) FROM Emp2;
CREATE INDEX salary_idx ON Emp2(salary);
select * from sys.indexes 
SELECT 
    name AS index_name, 
    type_desc AS index_type, 
    is_unique 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('Emp2')

select * from emp2 with(index(salary_idx))


CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    manager_id INT,
    salary DECIMAL(10, 2)
);

INSERT INTO employees (employee_id, name, manager_id, salary) VALUES
(3, 'Mila', 9, 60301),
(12, 'Antonella', NULL, 31000),
(13, 'Emery', NULL, 67084),
(1, 'Kalel', 11, 21241),
(9, 'Mikaela', NULL, 50937),
(11, 'Joziah', 6, 28485);

select e.employee_id from employees e join employees d on e.employee_id=d.manager_id where e.salary<300000 and e.manager_id != d.employee_id;

---------------------------------------------------------------------------------------------------------------------

CREATE TABLE ActivityLog (
    machine_id INT,
    process_id INT,
    activity_type VARCHAR(10),
    timestamp DECIMAL(5, 3)
);

INSERT INTO ActivityLog (machine_id, process_id, activity_type, timestamp) VALUES
(0, 0, 'start', 0.712),
(0, 0, 'end', 1.520),
(0, 1, 'start', 3.140),
(0, 1, 'end', 4.120),
(1, 0, 'start', 0.550),
(1, 0, 'end', 1.550),
(1, 1, 'start', 0.430),
(1, 1, 'end', 1.420),
(2, 0, 'start', 4.100),
(2, 0, 'end', 4.512),
(2, 1, 'start', 2.500),
(2, 1, 'end', 5.000);

select * from ActivityLog

select s.machine_id, round(avg(e.timestamp-s.timestamp),3) as processing_time 
from activitylog s 
join activitylog e 
on s.machine_id = e.machine_id
and s.process_id=e.process_id 
and s.activity_type='start' and e.activity_type='end' 
group by s.machine_id;


with b as
(select machine_id,timestamp,process_id from ActivityLog where activity_type='start'),

a as( select machine_id,timestamp,process_id from ActivityLog where activity_type='end')

select a.machine_id,round(avg(a.timestamp-b.timestamp),3)as Processing_time 
from a,b 
where a.machine_id=b.machine_id and a.process_id=b.process_id 
group by a.machine_id

---------------------------------------------------------------------------------------------------------------

select * from emp2

create table emp3(eid int,ename varchar(50),salary int)
insert into emp3 values(1,'a',100),(2,'b',100)

create function dbo.gethighestsalary2(@N int)
returns int
begin
return(
select  salary from(select salary, row_number() over( order by salary desc)as b from emp2)as a where b=@N
)
end
go
select dbo.gethighestsalary2(2) 

-----------------------------------------------------------------------------------------------
select salary, ROW_NUMBER() over(partition by salary order by salary  desc)as b from emp2
-----------------------------------------------------------------------------------------------

create proc vember(@min as int, @max as int)
as
begin
select * from emp2 where salary between @min and @max;
end;

exec vember 1000,3000

create proc vember1(@min as int,@max as int)
as
begin
update emp2 set salary=@max where eid=@min;
end;

exec vember1 1,3000

select * from emp2

create proc vember3
@i int
as
begin
DECLARE @counter INT = 1;

WHILE @counter <= 5
BEGIN
    PRINT @counter;
    SET @counter = @counter + 1;
END
end;

exec vember3 4

------------------------------------------------------

CREATE PROC EVEN
AS
BEGIN
select * from emp2 where eid%2!=0
END;


EXEC EVEN

--------------------------------------------------------------------------

ALTER PROC NthHIGHEST
@n INT
AS
BEGIN
SELECT SALARY FROM (SELECT SALARY,ROW_NUMBER() OVER(ORDER BY SALARY DESC)AS B FROM EMP2)AS A WHERE B=@n;
END;

EXEC NthHIGHEST 9


WITH CTE AS (
    SELECT * FROM (SELECT salary,ROW_NUMBER() OVER(partition by salary ORDER BY SALARY DESC)AS B FROM EMP2)AS A 
)
DELETE FROM CTE
WHERE b > 1;

select * from emp2

select @@ROWCOUNT
--------------------------------------------------------
create view hello as
select * from emp2 full join dept on emp2.eid=dept.deptid

insert into dept values(7,'CEO'),(8,'HR')

select * from hello

select distinct (designation),salary from hello  group by designation,salary order by salary desc

select coalesce(salary,0) as salary,coalesce(designation,'unknown') as designation from
( select  designation,salary,rank()over( partition by designation order by salary desc) as b from hello)as a  where b=1 


select * from emp2


select * ,Rank() over(Partition by salary order by salary desc) as b from emp2


---------------------------------------------------------------------------------------
CREATE TABLE Movies (
    id INT PRIMARY KEY,
    movie VARCHAR(50),
    description VARCHAR(255),
    rating FLOAT
);

INSERT INTO Movies (id, movie, description, rating) VALUES
(1, 'War', 'great 3D', 8.9),
(2, 'Science', 'fiction', 8.5),
(3, 'Irish', 'boring', 6.2),
(4, 'Ice Song', 'Fantasy', 8.6),
(5, 'House Card', 'Interesting', 9.1);


select * from Movies where description!='boring' and id%2!=0 order by rating desc

-------------------------------------------------------------------------------------------------------------
create table triangle
(x int,y int, z int,primary key(x,y,z))

insert into triangle
values(13,15,30),(10,20,15)


with cte as
(
select x,y,z,sum(x+y)as a,sum(x+z) as c,sum(y+z) as b from triangle group by x,y,z
)
select x,y,z from cte where ((a+b)>c)  


----------------------------------------------------------------------------------------
Movies table:
+-------------+--------------+
| movie_id    |  title       |
+-------------+--------------+
| 1           | Avengers     |
| 2           | Frozen 2     |
| 3           | Joker        |
+-------------+--------------+
Users table:
+-------------+--------------+
| user_id     |  name        |
+-------------+--------------+
| 1           | Daniel       |
| 2           | Monica       |
| 3           | Maria        |
| 4           | James        |
+-------------+--------------+
MovieRating table:
+-------------+--------------+--------------+-------------+
| movie_id    | user_id      | rating       | created_at  |
+-------------+--------------+--------------+-------------+
| 1           | 1            | 3            | 2020-01-12  |
| 1           | 2            | 4            | 2020-02-11  |
| 1           | 3            | 2            | 2020-02-12  |
| 1           | 4            | 1            | 2020-01-01  |
| 2           | 1            | 5            | 2020-02-17  | 
| 2           | 2            | 2            | 2020-02-01  | 
| 2           | 3            | 2            | 2020-03-01  |
| 3           | 1            | 3            | 2020-02-22  | 
| 3           | 2            | 4            | 2020-02-25  | 
+-------------+--------------+--------------+-------------+
Output: 
+--------------+
| results      |
+--------------+
| Daniel       |
| Frozen 2     |
+--------------+
-----------------------------------------------------------------------------

create table emp29 (eid int,ename varchar(100),deptid int,salary int)

insert into emp29 values(1,'siri',10,1000),(2,'sairam',20,2000),(3,'raju',30,3000),(3,'raju',30,3000),(1,'siri',10,1000)

select * from emp29

with cte as (select eid,ename,deptid,salary,row_number()over (partition by eid,ename,deptid,salary order by eid)as r from emp29 where deptid in (10,30))
delete   from cte where r>1

select * from emp29

select * from(
select *,dense_rank() over(order by salary ) as r from emp29
) as b where r in (2,3)

----------------------------------------------------------------------
select * from emp

select  salary from (select distinct salary ,dense_rank() over ( order by salary desc)as r from emp)as a where r=6
alter table emp add salary int

update  emp set salary= case
when empid=1 then 1000 
when empid=2 then 2000 
when empid=3 then 3000
when empid=4 then 4000 
when empid=5 then 5000
when empid=6 then 2000
when empid=7 then 1000
when empid=8 then 9000
end;


select e.empid,e.emp_name,e.salary,m.emp_name as manager,m.salary as manager_salary 
from emp e join emp m on e.empid=m.manager_id and e.salary>m.salary

--------------------------------------------------------------------------------------------------

----Print 1 to 100 prime numbers in sql-------------
declare @start int
declare @end int
declare @current int
declare @output nvarchar(max)
set @start=2
set @end=1000
set @current=@start

while @current<=@end
begin

with prime as (
select  @start as primenbr
union all
select a.primenbr+1 as value
from prime a
where a.primenbr <@end
),
b as(
select primenbr from prime a 
where not exists 
(select 1 from prime b 
where a.primenbr % b.primenbr=0 
and a.primenbr != b.primenbr)
)
)
SELECT @output = COALESCE(@output + '&', '') + CAST(primenbr AS NVARCHAR)
    FROM b
    WHERE primenbr = @current
    OPTION (MAXRECURSION 0);
set @current=@current+1
end

select @output as output

---------------------------------------------------------------------------

declare @start int
declare @end int
declare @current int
declare @output nvarchar(max)
set @start=1
set @end=10
set @current=@start

while @current<=@end
begin

with even as(
select @start as evennbr
union all
select e.evennbr+1 as value from even e where e.evennbr<@end
),
b as( select evennbr from even e where evennbr%2!=0)
SELECT @output = COALESCE(@output + '&', '') + CAST(evennbr AS NVARCHAR)
    FROM b
    WHERE evennbr = @current
    OPTION (MAXRECURSION 0);
set @current=@current+1
end

select @output as output

---------------------------------------------------------------

with prime as (
select  2 as primenbr
union all
select a.primenbr+1 as value
from prime a
where a.primenbr <10
)
select primenbr from prime a


select * from(select  *,dense_rank() over(order by salary desc) as ra
from emp2) a
where  ra in (3,5);


-------------------------------------------------------------------------------------------------

use practice

create table Mynumbers (num int)

insert into Mynumbers values (8),(8),(3),(1),(3),(1)
drop table mynumbers
select * from Mynumbers

with cte as(
select num,count(num)as count from Mynumbers  group by num 
)
select top 1 isnull(cte.num,null)as num   from cte where count=1 order by num desc


---------------------------------------------------------------------------------------------
CREATE TABLE Product1 (
    product_key INT PRIMARY KEY
);

INSERT INTO Product1 (product_key) VALUES
(5),
(6);

CREATE TABLE Customer1 (
    customer_id INT,
    product_key INT,
    FOREIGN KEY (product_key) REFERENCES Product1(product_key)
);

INSERT INTO Customer1 (customer_id, product_key) VALUES
(1, 5),
(2, 6),
(3, 5),
(3, 6),
(1, 6);

WITH cte AS (
    SELECT p.product_key, c.customer_id
    FROM Product1 p
    JOIN Customer1 c ON p.product_key = c.product_key
),
customer_product_count AS (
    SELECT customer_id, COUNT(DISTINCT product_key) AS product_count
    FROM cte
    GROUP BY customer_id
),
total_product_count AS (
    SELECT COUNT(DISTINCT product_key) AS total_count
    FROM Product1
)
SELECT cpc.customer_id
FROM customer_product_count cpc
JOIN total_product_count tpc ON cpc.product_count = tpc.total_count;

---------------------------------------------------------------------------------------------------------
09/09/2024

use practice

create table college
(
studentid int identity(581,1) primary key,
college_name varchar(20) default 'TR',
dep varchar(20),
course varchar(20)
)
create table student1
(
studentid int identity(581,1) primary key,
year_of_joining date
)

insert into college (dep,course)values('1','A0')

insert into student1 values('09-09-2019')

select * from student1
select * from college

SELECT concat(FORMAT(DATEADD(year, 0, s.year_of_joining), 'yy'),c.college_name,c.dep,c.course,s.studentid)as hallticket from student1 s join college c on s.studentid=c.studentid where year(year_of_joining)=2019

---------------------------------------------------------------------------------------------------------------------
create table register
(college_code varchar(5) default 'TR',
course_code varchar(5) default 'A',
studentid int identity(1,1) primary key,
student_name varchar(25),
dept_name varchar(5),
year_of_joining date,
scholar_type varchar(10),
hallticket_no nvarchar(50)
)
create table department
(
dept_name varchar(5),
dept_code varchar(3)
)
create table scholar
(
scholar_type varchar(10),
scholar_code int
)


insert into department values ('cse','05'),('ece','04'),('eee','02'),('ce','01'),('me','03'),('it','12')

insert into scholar values ('day',1),('lateral',5)

insert into register (student_name,dept_name,scholar_type,year_of_joining) values('Rajashekar','cse','day','09-09-2019')
select * from register

------------------------------------------------------------------------------------------------------------------------------------
-----Trigger--------------------

create trigger trg_hall
on register
after insert
as
begin

declare @stdid int;
declare @scholar varchar(10);
declare @dept varchar(5);

select @stdid = studentid,@scholar=scholar_type,@dept=dept_name from inserted;

declare @dept_code varchar(2);
select @dept_code=dept_code from department where dept_name=@dept;

declare @scholar_code int;
select @scholar_code=scholar_code from scholar where scholar_type=@scholar;



with cte as (
        select
            studentid,
            ROW_NUMBER() OVER (PARTITION BY dept_name, year(year_of_joining) ORDER BY studentid) AS row_num
        from register
    )
    UPDATE r
    SET hallticket_no = CONCAT(
        FORMAT(DATEADD(year, 0, r.year_of_joining), 'yy'),
        r.college_code,
        @scholar_code,
        r.course_code,
        @dept_code,
        RIGHT('00' + CAST(c.row_num AS
		VARCHAR(2)), 2)
    )
    from register r
    join CTE c on r.studentid = c.studentid
    where r.studentid = @stdid;

end;

insert into register (student_name,dept_name,scholar_type,year_of_joining)
values('shekar','ece','day','09-09-2019')
insert into register (student_name,dept_name,scholar_type,year_of_joining)
values('Rajashekar','cse','day','09-09-2019')
insert into register (student_name,dept_name,scholar_type,year_of_joining)
values('vinay','cse','day','09-09-2019')
insert into register (student_name,dept_name,scholar_type,year_of_joining)
values('vikas','cse','day','09-09-2019')
insert into register (student_name,dept_name,scholar_type,year_of_joining)
values('arjun','cse','day','09-09-2019')
insert into register (student_name,dept_name,scholar_type,year_of_joining)
values('arjun','ece','day','09-09-2019')
insert into register (student_name,dept_name,scholar_type,year_of_joining)
values('arjun kumar','cse','day','09-09-2020')

select * from register order by hallticket_no ;
-----------------------------------------------------------------------------------------
-----------------stored procedure-----------------------


create table student (
studentid int primary key identity,
studentname nvarchar(20),
deptid int,
yoj int,
foreign key (deptid) references dept (deptid)
 
);
 
create table dept2(
deptid int primary key,
deptname nvarchar(20)
foreign key (deptid) references college (deptid)
 
);
 
create table college (
deptid int primary key,
collegeid nvarchar(20) default 'TR1',
Universityid nvarchar(20) default 'AO'
);
 
INSERT INTO college (deptid)
VALUES
  (1),
  (2),
  (3),
  (4),
  (5);
 
INSERT INTO dept (deptid, deptname)
VALUES
  (1, 'CS'),
  (2, 'ECE'),
  (3, 'EEE'),
  (4, 'IT'),
  (5, 'CME');
 
 
  INSERT INTO student (studentname, deptid, yoj)
VALUES
  ('John Doe', 1, 2018),
  ('Jane Doe', 2, 2019),
  ('Alice Smith', 3, 2017),
  ('Bob Johnson', 4, 2018),
  ('Eve Brown', 5, 2019),
  ('Mike Davis', 1, 2020),
  ('Emma Taylor', 2, 2018),
  ('David Lee', 3, 2019),
  ('Sophia Patel', 4, 2020),
  ('Oliver White', 5, 2017);
 
 
  select * from student
  select * from dept
  select * from college
 
create view v_studentdetails
as
select s.studentid,s.studentname,s.deptid,s.yoj,d.deptname,c.collegeid,c.universityid
from student s join dept d
on s.deptid=d.deptid 
join college c on
d.deptid=c.deptid
 
select * from v_studentdetails
 
 
create procedure generate_student_ids
as
begin
	declare @rollno varchar(3)
	select cast(right(yoj,2) as nvarchar(20)) +
			cast(collegeid as nvarchar(20))  +cast(universityid as nvarchar(20))+cast(deptid as nvarchar(2)) +
			cast(format(ROW_NUMBER() OVER (PARTITION BY deptid,yoj ORDER BY studentid) ,'00')as nvarchar(13)) AS STUDENT_HALLTICKET_NO,*
	from v_studentdetails
end
 
exec generate_student_ids
 

INSERT INTO Student(student_id,student_name,dept_id) VALUES (4,'Man',1);
 
 
create function fun_generate_student_ids()
returns table
as
return(	select cast(right(yoj,2) as nvarchar(20)) +
			cast(collegeid as nvarchar(20))  +cast(universityid as nvarchar(20))+cast(deptid as nvarchar(2)) +
			cast(format(ROW_NUMBER() OVER (PARTITION BY deptid,yoj ORDER BY studentid) ,'00')as nvarchar(13)) AS STUDENT_HALLTICKET_NO,*
	from v_studentdetails);
 
select * from dbo.fun_generate_student_ids()
 
insert into student values ('sandeep',1,2019)
-----------------------------------------------------------
DECLARE @i INT = 100;
BEGIN
    PRINT RIGHT('00' + CAST(@i AS VARCHAR(2)), 2);
END;

-----------------------------------------------------------
WITH NumberSequence AS (
    SELECT 1 AS number
    UNION ALL
    SELECT number + 1
    FROM NumberSequence
    WHERE number < 135
),
AlphaNumericSequence AS (
    SELECT RIGHT('00' + CAST(number AS VARCHAR(2)), 2) AS formatted_number
    FROM NumberSequence
    WHERE number <= 99
    UNION all
    SELECT CHAR(65 + ((number - 100) / 10)) + CAST((number - 100) % 10 AS VARCHAR(1)) AS formatted_number
    FROM NumberSequence
    WHERE number >= 100 AND number <= 120 
)
SELECT formatted_number
FROM AlphaNumericSequence
OPTION (MAXRECURSION 200);



---------------------------------------------------------------------
create trigger trg_hall
on register
after insert
as
begin

declare @stdid int;
declare @scholar varchar(10);
declare @dept varchar(5);

select @stdid = studentid,@scholar=scholar_type,@dept=dept_name from inserted;

declare @dept_code varchar(2);
select @dept_code=dept_code from department where dept_name=@dept;

declare @scholar_code int;
select @scholar_code=scholar_code from scholar where scholar_type=@scholar;

DECLARE @i INT = @stdid;
Declare @result varchar(50);
set @result=(select cast(right(year_of_joining,2) as nvarchar(20)) +
			cast(college_code as nvarchar(20))  +cast(@scholar_code as varchar(10))+course_code +@dept_code,
			cast(format(ROW_NUMBER() OVER (PARTITION BY @dept_code,year_of_joining ORDER BY @i) ,'00')as nvarchar(13)) AS STUDENT_HALLTICKET_NO,*
	from register);


update  register set hallticket_no=@result
where studentid= @stdid;

end;


-----------------------------------------------------------------------

alter TRIGGER trg_hall
ON register
AFTER INSERT
AS
BEGIN
    DECLARE @stdid INT;
    DECLARE @scholar VARCHAR(10);
    DECLARE @dept VARCHAR(5);

    SELECT @stdid = studentid, @scholar = scholar_type, @dept = dept_name 
    FROM inserted;

    DECLARE @dept_code VARCHAR(2);
    SELECT @dept_code = dept_code 
    FROM department 
    WHERE dept_name = @dept;

    DECLARE @scholar_code INT;
    SELECT @scholar_code = scholar_code 
    FROM scholar 
    WHERE scholar_type = @scholar;

    WITH NumberSequence AS (
        SELECT studentid, dept_name, year_of_joining,
               ROW_NUMBER() OVER (PARTITION BY dept_name, YEAR(year_of_joining) ORDER BY studentid) AS number
        FROM register
    ),
    AlphaNumericSequence AS (
        SELECT studentid, dept_name, year_of_joining,
               RIGHT('00' + CAST(number AS VARCHAR(2)), 2) AS formatted_number
        FROM NumberSequence
        WHERE number <= 99
        UNION ALL
        SELECT studentid, dept_name, year_of_joining,
               CHAR(65 + ((number - 100) / 10)) + CAST((number - 100) % 10 AS VARCHAR(1)) AS formatted_number
        FROM NumberSequence
        WHERE number >= 100 AND number <= 120
    )
    UPDATE r
    SET hallticket_no = CONCAT(
        FORMAT(DATEADD(year, 0, r.year_of_joining), 'yy'),
        r.college_code,
        @scholar_code,
        r.course_code,
        @dept_code,
        c.formatted_number
    )
    FROM register r
    JOIN AlphaNumericSequence c ON r.studentid = c.studentid
    WHERE r.studentid = @stdid;
END;
---------------------------------------------------------------------------
select * from department
use practice

create table subjects
(
subjectid int identity(1,1) primary key,
departmentid int,
subject_code nvarchar(5),
subject_name nvarchar(25)
)

insert into subjects values(05,'cs101','Programming'),(05,'cs102','chemistry'),(05,'cs103','BEEE'),(05,'cs201','C language')
,(05,'cs202','DSA'),(05,'cs203','OS'),(04,'ec101','English'),(04,'ec102','OOPs'),(04,'ec103','EG')

---------------------------------------------------------------------------------
create table triangle(id int identity(1,1) primary key, a int,b int,c int)

select * from triangle

SELECT 
    CASE 
	    when x=y and x=z then 'equilateral triangle'
		WHEN x = y or x=z or y=z THEN 'isoceles triangle'
		when (x+y)>z then 'scalar triangle'
        ELSE 'not  triangle'
    END AS triangle_type
FROM triangle;
---------------------------------------------------------------------

create table occupation (id int identity(1,1) primary key,name varchar(10),occupation varchar(10))

INSERT INTO occupation (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashely', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');

with cte as(
select name,occupation,row_number() over(partition by occupation order by name asc)as r from occupation
)
select max(case when occupation='Doctor' then name end )as doctors,max(case when occupation='professor' then name end )as professors,max(case when occupation='singer' then name end)as singers,max(case when occupation='Actor' then name end)as actors from cte group by r 

insert into triangle values(10,10,10),(13,15,17),(1,2,5)
insert into triangle values(10,10,20)

----------------------------------------------------------------------------------------------
create table city
(id int identity(1,1) primary key,
name varchar(10),
country_code varchar(3),
district varchar(10),
population int
)


insert into city values ('madhapur',01,'hyd',100000),('sec',01,'hyd',200000),('jgl',07,'jgl',1000),('ameerpet',01,'hyd',2000)

with cte as (select name,population from city where population>100000)
select count(*) from cte;

with cte as
(select population,name from city where name='hyd')
select sum(population) from cte
----------------------------------------------------------------------------------------------

create table emp
(id int identity(1,1) primary key,
name varchar(10),
salary int)

insert into emp values ('a',1460),('b',2006),('c',3000),('d',2210)



select  salary = CAST(REPLACE(CAST(salary AS VARCHAR), '0', '') AS INT) from emp

select cast(ceiling(avg(cast(salary as float))- avg(CAST(REPLACE(salary, '0', '')as float))) AS INT) from emp
---------------------------------------------------------------------------------------------------------------
-- Create the employees table
CREATE TABLE employees1 (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    months INT,
    salary INT
);

-- Insert values into the employees table
INSERT INTO employees1 (employee_id, name, months, salary) VALUES
(122345, 'Rose', 15, 1968),
(336645, 'Angela', 1, 3443),
(456562, 'Frank', 17, 1608),
(561518, 'Patrick', 11, 1345),
(597725, 'Lisa', 7, 2330),
(741947, 'Kimberly', 16, 4372),
(835665, 'Bonnie', 6, 1771),
(886087, 'Michael', 8, 2017),
(990880, 'Todd', 5, 3396),
(101010, 'Joe', 9, 3573);

WITH cte AS (
    SELECT 
        employee_id,
        (salary * months) AS total_earnings
    FROM employees1
)
SELECT 
    MAX(total_earnings),
    COUNT(*)
FROM cte
WHERE total_earnings = (SELECT MAX(total_earnings) FROM cte);
-------------------------------------------------------------------
create table student
(id int identity(1,1) primary key,
name varchar(10),
marks int
)

insert into student values
('a', 88),('b',68),('c',99),('d',78),('e',63),('f',91)

create table grade
(grade int,
min_mark int,
max_mark int
)

insert into grade values (1,0,9),(2,10,19),(3,20,29),(4,30,39),(5,40,49),(6,50,59),(7,60,69),(8,70,79),(9,80,89),(10,90,100)

select student.name,case when grade.grade>=8 then grade.grade else null end,student.marks from student,grade where student.marks between grade.min_mark and grade.max_mark order by grade.grade desc, name;

---------------------------------------------------------------------

create table s1 (
id int,name varchar(5)
)
insert into s1 values (1,'a'),(2,'b'),(3,'c'),(4,'d')

create table friends
(id int,
friend_id int)

insert into friends values(1,4),(2,3),(3,2),(4,1)

create table packages
(id int,
salary int)

insert into packages values(1,1000),(2,2000),(3,3000),(4,4000)


with ab as
(select s1.id as stid,s1.name,friends.id as fid,p.salary
from s1 join friends 
on s1.id=friends.friend_id
join packages p on s1.id=p.id
where friends.friend_id=s1.id)

select ab.name
from ab join s1 
on s1.id=ab.fid 
join packages p on ab.fid=p.id
where ab.salary<p.salary

---------------------------------------------------------------------------------------------------------

create table e (id int,name varchar(10),department varchar(5),managerid int)

INSERT INTO E (id, name, department, managerId) VALUES
(101, 'John', 'A', NULL),
(102, 'Dan', 'A', 101),
(103, 'James', 'A', 101),
(104, 'Amy', 'A', 101),
(105, 'Anne', 'A', 101),
(106, 'Ron', 'B', 101),
(111, 'John', 'A', NULL),
(112, 'Dan', 'A', 111),
(113, 'James', 'A', 111),
(114, 'Amy', 'A', 111),
(115, 'Anne', 'A', 111),
(116, 'Ron', 'B', 111);

with cte as(select e.name,d.managerid from e e join e d on e.id=d.managerid group by e.name,e.managerid  having count(e.id)>=5
)
select name from cte

select * from e
select e1.id,e1.name,e1.managerid,d.name from e e1 join e d on e1.id=d.managerid 

select count(managerid) from e
------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS Hall;
GO

CREATE PROCEDURE Hall
AS
BEGIN
    DECLARE @stdid INT=1, @deptid INT, @deptname VARCHAR(5);
    DECLARE @collegeid INT=1, @collegecode VARCHAR(5), @courseid INT=1, @coursecode VARCHAR(5), @coursename VARCHAR(10);
    DECLARE @scholar_code INT, @scholartype VARCHAR(5), @year INT, @scholarid INT=1, @yearid INT=1,@hallticket_no varchar(25),@i int;


	 DECLARE dept_cursor CURSOR FOR
    SELECT dept_id FROM dept;

    OPEN dept_cursor;
    FETCH NEXT FROM dept_cursor INTO @deptid;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @stdid = 1;
        WHILE @stdid <= 10
        BEGIN

    SELECT @stdid = studentid, @deptid = deptid, @collegeid = collegeid, @courseid = courseid, @yearid = year_id
    FROM student ;

    SELECT @year = years FROM years WHERE year_id = @yearid;
    SELECT @deptid = dept_id,@deptname=dept_name FROM dept WHERE dept_id=@deptid;
    SELECT @collegecode = college_code FROM college WHERE collegeid = @collegeid;
    SELECT @coursecode = course_code FROM course WHERE courseid=@courseid;
	select @scholar_code=scholar_code  from scholar where scholarid=@scholarid;

    WITH cte AS (
        SELECT
            studentid,
            ROW_NUMBER() OVER (PARTITION BY deptname, collegeid, year_id, courseid,scholar_id ORDER BY studentid) AS row_num
        FROM student
    )
    UPDATE r
    SET hallticket_no = CONCAT(
        RIGHT(@year, 2),
        @collegecode,
        @scholar_code,
        @coursecode,
        RIGHT('00' + CAST(@deptid AS VARCHAR(2)), 2),
        RIGHT('00' + CAST(c.row_num AS VARCHAR(2)), 2)
    )
    FROM student r
    JOIN cte c ON r.studentid = c.studentid
    WHERE r.studentid = @stdid;

	update student set deptname=@deptname where deptid=@deptid;
	
	select @hallticket_no=hallticket_no from student where studentid=@stdid;

	INSERT INTO student (deptid, collegeid, courseid, scholar_id, year_id, hallticket_no)
            VALUES (@deptid, @collegeid, @courseid, @scholarid, @yearid, @hallticket_no);
            SET @stdid = @stdid + 1;
        END
        FETCH NEXT FROM dept_cursor INTO @deptid;
    END

    CLOSE dept_cursor;
    DEALLOCATE dept_cursor;
END;
    
	exec hall
	select * from student


insert into student (deptid,courseid,scholar_id,year_id,collegeid) values(1,1,1,1,1)

exec hall
drop proc hall
select * from student
----------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS InsertRandomMarksForStudents;
GO

-- Create the procedure to insert random marks for each student
CREATE PROCEDURE InsertRandomMarksForStudents
AS
BEGIN
    DECLARE @studentid INT;
    DECLARE @subject_id INT;
    DECLARE @random_marks INT;
    DECLARE @semester INT;

    DECLARE student_cursor CURSOR FOR
    SELECT studentid FROM student;

    DECLARE subject_cursor CURSOR FOR
    SELECT subject_id FROM subject;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @studentid;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        OPEN subject_cursor;
        FETCH NEXT FROM subject_cursor INTO @subject_id;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @random_marks = CAST(RAND() * 100 AS INT);  -- Marks between 0 and 100
            SET @semester = ABS(CHECKSUM(NEWID())) % 4 + 1; -- Assuming there are 4 semesters

            INSERT INTO marks (studentid, subject_id, marks, semester)
            VALUES (@studentid, @subject_id, @random_marks, @semester);
			exec spGetPassFail

            FETCH NEXT FROM subject_cursor INTO @subject_id;
        END;

        CLOSE subject_cursor;
        FETCH NEXT FROM student_cursor INTO @studentid;
    END;

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
    DEALLOCATE subject_cursor;
END;
GO

-- Execute the procedure to insert random marks for each student
EXEC InsertRandomMarksForStudents;

--------------------------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS Hall;
GO

CREATE PROCEDURE Hall
AS
BEGIN
    DECLARE @stdid INT, @deptid INT, @deptname VARCHAR(5);
    DECLARE @collegeid INT, @collegecode VARCHAR(5), @courseid INT, @coursecode VARCHAR(5), @coursename VARCHAR(10);
    DECLARE @scholar_code INT, @scholartype VARCHAR(5), @year INT, @scholarid INT, @yearid INT;

    SELECT @stdid = studentid, @deptname = deptname, @collegeid = collegeid, @coursename = coursename, @yearid = year_id
    FROM student ;

    SELECT @year = years FROM years WHERE year_id = @yearid;
    SELECT @deptid = deptid FROM department WHERE deptname = @deptname;
    SELECT @collegecode = collegecode FROM college WHERE collegeid = @collegeid;
    SELECT @coursecode = course_code, @courseid = courseid FROM course WHERE course_name = @coursename;

	select @scholar_code=s1.scholar_code,@scholarid= s1.scholarid  from student s join scholar s1 on s.scholar_type=s1.scholar_type;

    WITH cte AS (
        SELECT
            studentid,
            ROW_NUMBER() OVER (PARTITION BY deptname, collegeid, year_id, coursename, scholar_type ORDER BY studentid) AS row_num
        FROM student
    )
    UPDATE r
    SET hallticket_no = CONCAT(
        RIGHT(@year, 2),
        @collegecode,
        @scholar_code,
        @coursecode,
        RIGHT('00' + CAST(@deptid AS VARCHAR(2)), 2),
        RIGHT('00' + CAST(c.row_num AS VARCHAR(2)), 2)
    )
    FROM student r
    JOIN cte c ON r.studentid = c.studentid
    WHERE r.studentid = @stdid;

    INSERT INTO fact (deptid, collegeid, courseid, scholarid,year_id,years,studentid)
    VALUES (@deptid, @collegeid, @courseid, @scholarid,@yearid, @year,@stdid);
END;
GO

-- Insert a student and execute the stored procedure
INSERT INTO student (student_name, deptname, collegeid, coursename, scholar_type, year_id, hallticket_no)
VALUES ('Raj', 'ece', 1, 'b.tech', 'lateral', 4, NULL);

EXEC Hall;

INSERT INTO student (student_name, deptname, collegeid, coursename, scholar_type, year_id, hallticket_no)
VALUES ('santhosh', '', 3,'b.tech', 'lateral', 40, NULL);

select * from student
select * from fact

create table marks(
	mark_id int not null primary key identity(1,1),
	studentid int,
	subject_id int,
	marks int,
	semester int,
	passFailStatus nvarchar(10),
    foreign key (studentid) references student(studentid),
	foreign key (subject_id) references subject(subject_id)
);
drop table marks

--------------------------------------------------------------------------
set @mark1 = CAST(RAND() * 100 AS INT);  -- Marks between 0 and 100
			set @mark2=cast(rand()*100 as int);

			if @mark1>=40
				begin
					if @mark2>=40
					begin
						set @pass='PASS';
						set @semid=@semid+1;
					end
					else
					begin
						set @pass='FAIL';
					end
				end
			else
				begin
					set @pass='FAIL';
				end

				if @i <= 99
            begin
                SET @hallticket_no = CONCAT(
                    RIGHT(@year, 2),
                    @collegecode,
                    @scholar_code,
                    @coursecode,
                    RIGHT('00' + CAST(@deptid AS VARCHAR(2)), 2),
                    RIGHT('00' + CAST(@i AS VARCHAR(2)), 2)
                );
            end
            else
            begin
                SET @hallticket_no = CONCAT(
                    RIGHT(@year, 2),
                    @collegecode,
                    @scholar_code,
                    @coursecode,
                    RIGHT('00' + CAST(@deptid AS VARCHAR(2)), 2),
                    CHAR(65 + ((@i - 100) / 10)) + CAST((@i - 100) % 10 AS VARCHAR(1))
                );
            end

				set @subjectid =(select  top 1 subject_id from subject where deptid=@deptid);
				set @subjectid2=(@subjectid)+1;

				---------------------------------------------------------------------------------------

				19-09-2024


create table table1
(x int,
y int)

insert into table1 values (20,20),(20,20),(20,21),(23,22),(22,23),(21,20)


with cte as (
select x,y , row_number() over (order by x) as rn from table1
   )
   select distinct a.x, a.y from cte a join cte b
   on a.x = b.y and a.y = b.x 
   where a.rn != b.rn and a.x <= a.y
   order by a.x
   ---------------------------------------------------------------------------------------
   SELECT DISTINCT CONVERT(DECIMAL(15,4),PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY LAT_N) OVER ())
FROM STATION

--------------------------------------------------------------------------------------------------
declare @start int
declare @end int
declare @current int
declare @output nvarchar(max)
set @start=2
set @end=1000
set @current=@start

while @current<=@end
begin

with prime as (
select  @start as primenbr
union all
select a.primenbr+1 as value
from prime a
where a.primenbr <@end
),
b as(
select primenbr from prime a 
where not exists 
(select 1 from prime b 
where a.primenbr % b.primenbr=0 
and a.primenbr != b.primenbr)
)

SELECT @output = COALESCE(@output + '&', '') + CAST(primenbr AS NVARCHAR)
    FROM b
    WHERE primenbr = @current
    OPTION (MAXRECURSION 0);
set @current=@current+1
end
select @output as output
-----------------------------------------------------------------------------------

with prime as (
select  1 as primenbr
union all
select a.primenbr+1 as value
from prime a
where a.primenbr <10
)select primenbr from prime;

-------------------------------------------------------------------------------------------------

print'---------------------------------------------'
print('           Patterns-with-sql               ')
print'---------------------------------------------'
declare @i1 int=1;
while @i1<=5
begin
print(rtrim(replicate('* ',@i1)))
set @i1=@i1+1;
end
print'---------------------------------------------'
declare @i2 int=5;
while @i2>=1
begin
print(rtrim(replicate('* ',@i2)))
set @i2=@i2-1;
end
print'---------------------------------------------'
declare @i3 int=5,@j1 int=5;
while @i3>0
begin
DECLARE @formattedString NVARCHAR(MAX);
    SET @formattedString = REPLICATE(' ', @j1 - @i3) + REPLICATE(' *', @i3);
    
    PRINT RIGHT(@formattedString, LEN(@formattedString) - 1);
set @i3=@i3-1;
end
print'---------------------------------------------'
declare @i4 int=5,@j2 int=5;
while @i4>0
begin
DECLARE @formattedString1 NVARCHAR(MAX);
    SET @formattedString1 = REPLICATE('  ', @j2 - @i4) + REPLICATE(' *', @i4);
    
    PRINT RIGHT(@formattedString1, LEN(@formattedString1) - 1);
set @i4=@i4-1;
end
print'---------------------------------------------'
declare @i5 int=1,@j3 int=5;
while @i5<=5
begin
DECLARE @formattedString2 NVARCHAR(MAX);
    SET @formattedString2 = REPLICATE(' ', @j3 - @i5) + REPLICATE(' *', @i5);
    
    PRINT RIGHT(@formattedString2, LEN(@formattedString2) - 1);
set @i5=@i5+1;
end
print'---------------------------------------------'
declare @i6 int=1,@j4 int=5;
while @i6<=5
begin
DECLARE @formattedString3 NVARCHAR(MAX);
    SET @formattedString3 = REPLICATE('  ', @j4) + REPLICATE(' *', @i6);
	    PRINT RIGHT(@formattedString3, LEN(@formattedString3) - 3);

	set @i6=@i6+1;
	set @j4=@j4-1;
	end

print'---------------------------------------------'

----------------------------------------------------------------------------------------
CREATE TABLE Prime_Numbers (number INT);

DECLARE @nr INT;
DECLARE @divider INT;
DECLARE @prime BIT;

SELECT @nr = 1;


WHILE @nr <= 1000
    BEGIN
    SELECT @divider = @nr - 1;
    SELECT @prime = 1;
    -- Prime Number test
    WHILE @divider > 1
        BEGIN
        IF @nr % @divider = 0
            SELECT @prime = 0;
        SELECT @divider = @divider - 1         
        END
    IF @prime = 1 AND @nr <> 1
        INSERT INTO Prime_Numbers (number) VALUES (@nr);
    
    SELECT @nr = @nr + 1
    END

SELECT STRING_AGG(number,'&') FROM Prime_Numbers;

-----------------------------------------------------------------

create table queries (query_name varchar(5),result nvarchar(50),position int,rating int)

insert into queries values('dog','golden retriever',1,5),('dog','german shepherd',2,5),('dog','mule',200,1),('cat','shirazi',5,2),('cat','siamese',3,3),('cat','sphynx',7,4)

select * from queries

with cte as(
select query_name,round(sum(convert(decimal(10,2),rating)/position)/count(*),2)as quality 
from queries group by query_name
),
b as(
SELECT query_name,ROUND((CAST(SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(*)) * 100, 2) AS per
FROM queries group by query_name)
select c.query_name,c.quality,b.per as poor_query_percentage from cte c join b on c.query_name=b.query_name;

-------------------------------------------------------------------------------------------------------------------
create table teacher(teacherid int,subjectid int,departmentid int)

insert into teacher values(1,2,3),(1,2,4),(1,3,3),(2,1,1),(2,2,1),(2,3,1),(2,4,1)


select teacherid,count(distinct(subjectid))as cnt from teacher  group by teacherid 

------------------------------------------------------------------------------------------------------------------
create table person (id int,email nvarchar(25))

insert into person values (1,'abc@gmail.com'),(2,'def@gmail.com'),(3,'abc@gmail.com')

delete id from(select  id,email,count(*) over (partition by email order by id )as r from person)as a where r>1

------------------------------------------------------------------------------------------------------------------

CREATE TABLE Signups (
    user_id INT,
    time_stamp DATETIME
);

INSERT INTO Signups (user_id, time_stamp) VALUES
(3, '2020-03-21 10:16:13'),
(7, '2020-01-04 13:57:59'),
(2, '2020-07-29 23:09:44'),
(6, '2020-12-09 10:39:37');

CREATE TABLE Confirmations (
    user_id INT,
    time_stamp DATETIME,
    action VARCHAR(50)
);

INSERT INTO Confirmations (user_id, time_stamp, action) VALUES
(3, '2021-01-06 03:30:46', 'timeout'),
(3, '2021-07-14 14:00:00', 'timeout'),
(7, '2021-06-12 11:57:29', 'confirmed'),
(7, '2021-06-13 12:58:28', 'confirmed'),
(7, '2021-06-14 13:59:27', 'confirmed'),
(2, '2021-01-22 00:00:00', 'confirmed'),
(2, '2021-02-28 23:59:59', 'timeout');


with cte as(
select s.*,c.time_stamp as tm,c.action from Signups s left join Confirmations c on s.user_id=c.user_id
)
select USER_ID,case when count(action)>=2 then 1 when count(action) is null then 0 else 0 end from cte where case when action='confirmed' then action else 0 end group by user_id 

------------------------------------------------------------------------------------------------------------------------

SELECT p.product_id,COALESCE(ROUND(CAST(SUM(p.price * Us.units) AS FLOAT)/SUM(Us.units),2),0) AS average_price
FROM Prices p
LEFT join UnitsSold Us
ON p.product_id = Us.product_id
    AND Us.purchase_date  BETWEEN p.start_date AND p.end_date  
GROUP BY p.product_id

-----------------------------------------------------------------------------------------------------------

create table logs
(id int identity(1,1),
num int)

insert into logs values (1),(1),(1),(2),(1),(2),(2)

select * from logs

select num from (SELECT  id, num ,row_number() OVER (partition by num,id ORDER BY id) AS prev_num FROM logs)as a where prev_num>=3

with base as(
select 
   id, 
   num, 
   lag(num,1)over(order by id) as lag1, 
   lag(num,2) over(order by id)as lag2
from 
    logs )

select distinct 
    num as ConsecutiveNums  
from 
    base 
where 
    num = lag1 and
    num = lag2
--------------------------------------------------------------------------------

-- Create the Activity table
CREATE TABLE Activity (
    user_id INT,
    session_id INT,
    activity_date DATE,
    activity_type VARCHAR(50)
);

-- Insert the given values into the Activity table
INSERT INTO Activity (user_id, session_id, activity_date, activity_type)
VALUES 
(1, 1, '2019-07-20', 'open_session'),
(1, 1, '2019-07-20', 'scroll_down'),
(1, 1, '2019-07-20', 'end_session'),
(2, 4, '2019-07-20', 'open_session'),
(2, 4, '2019-07-21', 'send_message'),
(2, 4, '2019-07-21', 'end_session'),
(3, 2, '2019-07-21', 'open_session'),
(3, 2, '2019-07-21', 'send_message'),
(3, 2, '2019-07-21', 'end_session'),
(4, 3, '2019-06-25', 'open_session'),
(4, 3, '2019-06-25', 'end_session');





select Activity_date as day,count(distinct user_id) as active_users from activity
where activity_date<='2019-07-27' and DATEDIFF(day,activity_date,'2019-07-27')<30 group by activity_date

-----------------------------------------------------

create table users
(id int,
name varchar(10)
)

insert into users values (1,'aLice'),(2,'bOB')

select concat(upper(substring(name,1,1)),lower(substring(name,2,len(name))))as name from users

-----------------------------------------------------------------------------------------------

-- Create the Activities table
CREATE TABLE Activities (
    sell_date DATE,
    product VARCHAR(50)
);

-- Insert the given values into the Activities table
INSERT INTO Activities (sell_date, product)
VALUES 
('2020-05-30', 'Headphone'),
('2020-06-01', 'Pencil'),
('2020-06-02', 'Mask'),
('2020-05-30', 'Basketball'),
('2020-06-01', 'Bible'),
('2020-06-02', 'Mask'),
('2020-05-30', 'T-Shirt');


--------------------------------------------------------------------------------
SELECT 
    *
FROM
    USERS
WHERE
    RIGHT(MAIL,13) = '@leetcode.com' AND 
    LEFT(MAIL,1) LIKE '[a-zA-Z]%' AND
    LEFT(MAIL, LEN(MAIL) - 13) NOT LIKE '%[^a-zA-Z0-9_.-]%';


	------------------------------------------------------------------------------------------
	-- Create Movies table
CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    title NVARCHAR(100)
);

-- Create Users table
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name NVARCHAR(100)
);

-- Create MovieRating table
CREATE TABLE MovieRating (
    movie_id INT,
    user_id INT,
    rating INT,
    created_at DATE,
    PRIMARY KEY (movie_id, user_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Insert data into Movies table
INSERT INTO Movies (movie_id, title) VALUES
(1, 'Avengers'),
(2, 'Frozen 2'),
(3, 'Joker');

-- Insert data into Users table
INSERT INTO Users (user_id, name) VALUES
(1, 'Daniel'),
(2, 'Monica'),
(3, 'Maria'),
(4, 'James');

-- Insert data into MovieRating table
INSERT INTO MovieRating (movie_id, user_id, rating, created_at) VALUES
(1, 1, 3, '2020-01-12'),
(1, 2, 4, '2020-02-11'),
(1, 3, 2, '2020-02-12'),
(1, 4, 1, '2020-01-01'),
(2, 1, 5, '2020-02-17'),
(2, 2, 2, '2020-02-01'),
(2, 3, 2, '2020-03-01'),
(3, 1, 3, '2020-02-22'),
(3, 2, 4, '2020-02-25');

select * from users

select m.title,m1.*,u.name from movies m join MovieRating m1 on m.movie_id=m1.movie_id 
join users u on u.user_id=m1.user_id 
where (m1.created_at <'2020-03-1' and m1.created_at >='2020-02-1') and m1.rating>3 


select top 1 name as results
    from (
        select u.user_id, u.name, m.title, mr.rating
        from MovieRating mr
        join Users u on mr.user_id = u.user_id
        join Movies m on mr.movie_id = m.movie_id
        ) new1
    group by new1.user_id, new1.name
    order by count(new1.user_id) desc, new1.name
	union all
	select top 1 title as results
    from (
        select m.title, avg(mr.rating*1.0) as rating
        from MovieRating mr 
        join Movies m on mr.movie_id = m.movie_id 
        where mr.created_at between '2020-02-01' and '2020-02-29'
        group by mr.movie_id, m.title
        ) new2
    order by new2.rating desc, new2.title

	--------------------------------------------------------------------------------

	-- Create Customer table
CREATE TABLE Customer (
    customer_id INT,
    name NVARCHAR(100),
    visited_on DATE,
    amount INT,
    PRIMARY KEY (customer_id, visited_on)
);

-- Insert data into Customer table
INSERT INTO Customer (customer_id, name, visited_on, amount) VALUES
(1, 'Jhon', '2019-01-01', 100),
(2, 'Daniel', '2019-01-02', 110),
(3, 'Jade', '2019-01-03', 120),
(4, 'Khaled', '2019-01-04', 130),
(5, 'Winston', '2019-01-05', 110),
(6, 'Elvis', '2019-01-06', 140),
(7, 'Anna', '2019-01-07', 150),
(8, 'Maria', '2019-01-08', 80),
(9, 'Jaze', '2019-01-09', 110),
(1, 'Jhon', '2019-01-10', 130),
(3, 'Jade', '2019-01-10', 150);


SELECT * FROM CUSTOMER


select * from customer order by visited_on 


with cte as
(select visited_on,sum(amount)as amount from Customer group by visited_on)
select visited_on,sum(amount) over(order by visited_on rows between 6 preceding and current row )as amount,
round(avg(amount)over (order by visited_on rows between 6 preceding and current row),2) as average_amount
 from cte 
 order by visited_on
 OFFSET 6 rows

 ---------------------------------------------------------------------------------------------------

SELECT 
    FORMAT(trans_date, 'yyyy-MM') AS month,
    country,
    COUNT(id) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM 
    transactions
GROUP BY 
    FORMAT(trans_date, 'yyyy-MM'), country;


-------------------------------------------------------------------------------------------------------------

-- Create SalesPerson table
CREATE TABLE SalesPerson (
    sales_id INT PRIMARY KEY,
    name NVARCHAR(100),
    salary INT,
    commission_rate INT,
    hire_date DATE
);

-- Create Company table
CREATE TABLE Company (
    com_id INT PRIMARY KEY,
    name NVARCHAR(100),
    city NVARCHAR(100)
);

drop table Orders
-- Create Orders table
CREATE TABLE Orders1 (
    order_id INT PRIMARY KEY,
    order_date DATE,
    com_id INT,
    sales_id INT,
    amount INT,
    FOREIGN KEY (com_id) REFERENCES Company(com_id),
    FOREIGN KEY (sales_id) REFERENCES SalesPerson(sales_id)
);

-- Insert data into SalesPerson table
INSERT INTO SalesPerson (sales_id, name, salary, commission_rate, hire_date) VALUES
(1, 'John', 100000, 6, '2006-04-01'),
(2, 'Amy', 12000, 5, '2010-05-01'),
(3, 'Mark', 65000, 12, '2008-12-25'),
(4, 'Pam', 25000, 25, '2005-01-01'),
(5, 'Alex', 5000, 10, '2007-02-03');

-- Insert data into Company table
INSERT INTO Company (com_id, name, city) VALUES
(1, 'RED', 'Boston'),
(2, 'ORANGE', 'New York'),
(3, 'YELLOW', 'Boston'),
(4, 'GREEN', 'Austin');

-- Insert data into Orders table
INSERT INTO Orders1 (order_id, order_date, com_id, sales_id, amount) VALUES
(1, '2014-01-01', 3, 4, 10000),
(2, '2014-02-01', 4, 5, 5000),
(3, '2014-03-01', 1, 1, 50000),
(4, '2014-04-01', 1, 4, 25000);

with cte as(
select s.*,o.order_id,o.amount,o.com_id,o.order_date from SalesPerson s  join Orders1 o on s.sales_id=o.sales_id
)


SELECT name
FROM SalesPerson
EXCEPT
SELECT s.name
FROM Orders1 o
JOIN Company c ON o.com_id = c.com_id
JOIN SalesPerson s ON o.sales_id = s.sales_id
WHERE c.name = 'RED'

select name
from SalesPerson
where sales_id NOT IN (select sales_id
                from Orders1
                where com_id IN (select com_id
                            from Company
                            where name='RED'))


---------------------------------------------------------------------
-- Create the table
CREATE TABLE ActorDirector (
    actor_id INT,
    director_id INT,
    timestamp INT,
    PRIMARY KEY (actor_id, director_id, timestamp)
);

-- Insert data into the table
INSERT INTO ActorDirector (actor_id, director_id, timestamp) VALUES
(1, 1, 0),
(1, 1, 1),
(1, 1, 2),
(1, 2, 3),
(1, 2, 4),
(2, 1, 5),
(2, 1, 6);

select actor_id, director_id
from ActorDirector
group by actor_id, director_id
having count(timestamp) >= 3

select contest_id, 
round(count(user_id) * 100.0 / (select count(user_id) from Users), 2) as percentage
from Register
group by contest_id
order by percentage desc, contest_id;
----------------------------------------------------------------------------
Employee table:
+----+-------+--------+--------------+
| id | name  | salary | departmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Jim   | 90000  | 1            |
| 3  | Henry | 80000  | 2            |
| 4  | Sam   | 60000  | 2            |
| 5  | Max   | 90000  | 1            |
+----+-------+--------+--------------+
Department table:
+----+-------+
| id | name  |
+----+-------+
| 1  | IT    |
| 2  | Sales |
+----+-------+


-- Create Employee table
CREATE TABLE Employee11 (
    id INT PRIMARY KEY,
    name NVARCHAR(100),
    salary INT,
    departmentId INT,
    FOREIGN KEY (departmentId) REFERENCES Department(id)
);

-- Create Department table
CREATE TABLE Department (
    id INT PRIMARY KEY,
    name NVARCHAR(100)
);

-- Insert data into Department table
INSERT INTO Department (id, name) VALUES
(1, 'IT'),
(2, 'Sales');

-- Insert data into Employee table
INSERT INTO Employee11 (id, name, salary, departmentId) VALUES
(1, 'Joe', 70000, 1),
(2, 'Jim', 90000, 1),
(3, 'Henry', 80000, 2),
(4, 'Sam', 60000, 2),
(5, 'Max', 90000, 1);


with cte as(
select e.*,d.name as dpt from employee11 e left join department d on e.departmentid=d.id
)
select * from(select  dpt,name,salary,rank() over (partition by dpt order by salary desc) r from cte group by dpt,name,salary )as a where r=1

---------------------------------------------------------------------------------------------------------------------------------------

Employee table:
+----+-------+--------+--------------+
| id | name  | salary | departmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 85000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
| 5  | Janet | 69000  | 1            |
| 6  | Randy | 85000  | 1            |
| 7  | Will  | 70000  | 1            |
+----+-------+--------+--------------+

INSERT INTO Employee11 (id, name, salary, departmentId) VALUES
(1, 'Joe', 85000, 1),
(2, 'henry', 80000, 2),
(3, 'Sam', 60000, 2),
(4, 'max', 90000, 1),
(5, 'janet', 69000, 1),
(6,'Randy',85000,1),
(7,'will',70000,1);
Department table:
+----+-------+
| id | name  |
+----+-------+
| 1  | IT    |
| 2  | Sales |
+----+-------+

SELECT * FROM employee11
ORDER BY salary
OFFSET 1 ROWS;

with cte as(
select e.*,d.name as dpt from employee11 e left join department d on e.departmentid=d.id
)
select * from(select  dpt,name,salary,dense_rank() over (partition by dpt order by salary desc) r from cte group by dpt,name,salary )as a where r<4
----------------------------------------------------------------------------------------------------------------------------------------------------

SELECT id, CASE
        WHEN id % 2 = 0 THEN LAG(student) OVER(ORDER BY id)
        ELSE COALESCE(LEAD(student) OVER(ORDER BY id), student)
    END AS student
FROM Seat
-----------------------------------------------------------------------------------------------------------------------
with cte AS(
    select pid,
        tiv_2015,
        tiv_2016 ,
        count(pid)OVER(partition by tiv_2015 )AS tv_cnt,
        count(pid)OVER(partition by lat,lon)AS l_cnt 
from insurance
)
select round(sum(tiv_2016),2)AS tiv_2016  from cte where tv_cnt >1 and l_cnt <2
------------------------------------------------------------------------------------------------------------------

-- Create Accounts table
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    income INT
);

-- Insert data into Accounts table
INSERT INTO Accounts (account_id, income) VALUES
(3, 108939),
(2, 12747),
(8, 87709),
(6, 91796);

"Low Salary": All the salaries strictly less than $20000.
"Average Salary": All the salaries in the inclusive range [$20000, $50000].
"High Salary": All the salaries strictly greater than $50000.

SELECT 'High Salary' as category, COUNT( CASE WHEN income > 50000 THEN income ELSE null END) as accounts_count FROM Accounts
UNION
SELECT 'Low Salary' as category, COUNT( CASE WHEN income < 20000 THEN income ELSE null END) as accounts_count FROM Accounts
UNION
SELECT 'Average Salary' as category, COUNT( CASE WHEN income >= 20000 and income <= 50000 THEN income ELSE null END) as accounts_count FROM Accounts ORDER BY accounts_count DESC

---------------------------------------------------------------------------------------

-- Create Activity table
CREATE TABLE Activity (
    player_id INT,
    device_id INT,
    event_date DATE,
    games_played INT,
    PRIMARY KEY (player_id, device_id, event_date)
);

-- Insert data into Activity table
INSERT INTO Activity (player_id, device_id, event_date, games_played) VALUES
(1, 2, '2016-03-01', 5),
(1, 2, '2016-03-02', 6),
(2, 3, '2017-06-25', 1),
(3, 1, '2016-03-02', 0),
(3, 4, '2018-07-03', 5);

select * from activity


  WITH FirstLogin AS (
    SELECT 
        player_id, 
        MIN(event_date) AS first_login 
    FROM 
        Activity 
    GROUP BY 
        player_id
)
SELECT 
    ROUND(CAST(COUNT(DISTINCT A.player_id) AS FLOAT) / 
          (SELECT COUNT(DISTINCT player_id) FROM Activity), 2) AS fraction
FROM 
    Activity A
JOIN 
    FirstLogin F ON A.player_id = F.player_id 
WHERE 
    A.event_date = DATEADD(DAY, 1, F.first_login);

	-----------------------------------------------------------------------------------------------------

	create table hacker 
	(
	hacker_id int,
	name varchar(10)
	)

	INSERT INTO Hacker (hacker_id, name) VALUES
(5077, 'Rose'),
(21283, 'Angela'),
(62743, 'Frank'),
(88255, 'Patrick'),
(96196, 'Lisa');

create table challenges
(
challenges_id int ,
hacker_id int
)

INSERT INTO Challenges (Challenges_Id, Hacker_Id) VALUES
(61654, 5077),
(58302, 21283),
(40587, 88255),
(29477, 5077),
(1220, 21283),
(69514, 21283),
(46561, 62743),
(58077, 62743),
(18483, 88255),
(76766,21283),
(52382, 5077),
(74467, 21283),
(33625, 96196),
(26053, 88255),
(42665,62743),
(12859,62743),
(70094, 21283),
(34599, 88255),
(54680, 88255),
(61881, 5077);





WITH ChallengeCounts AS 
( SELECT h.hacker_id, h.name, COUNT(c.challenges_id) AS total_challenges 
FROM Hacker h LEFT JOIN Challenges c ON h.hacker_id = c.hacker_id 
GROUP BY h.hacker_id, h.name 
), 
MaxChallenges AS ( 
SELECT MAX(total_challenges) AS max_challenges FROM ChallengeCounts
), 
DuplicateCounts AS ( 
SELECT total_challenges FROM ChallengeCounts GROUP BY total_challenges HAVING COUNT(*) > 1 
)

SELECT cc.hacker_id, cc.name, cc.total_challenges FROM ChallengeCounts cc 
WHERE cc.total_challenges = 
(SELECT max_challenges FROM MaxChallenges) OR cc.total_challenges 
NOT IN (SELECT total_challenges FROM DuplicateCounts)
ORDER BY cc.total_challenges DESC, cc.hacker_id;

------------------------------------------------------------------------------------------------

create table contact(empid varchar(10), contact_details varchar(250))

INSERT INTO contact VALUES 
('E001', 'John works at ABC corp. Contact: 9876543210'),
('E002', 'Anna email is anna.smith@gmail.com, Her phone is 9123456789'),
('E003', 'No contact information available.'),
('E004', 'Reach me at 9234567890 or via mail alice.johnson@xyz.co.uk');

 select * from contact

 SELECT 
    empid,
    contact_details,
  
    CASE 
        WHEN contact_details LIKE '%@%' 
        THEN SUBSTRING(contact_details, PATINDEX('[' ']@%', contact_details),10)
        ELSE 'null'
    END AS email_address
FROM contact;


select empid,(case when contact_details like '%[7-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' then substring(contact_details,patindex('%[7-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%',contact_details),10) else null end) as mobile,
(case when contact_details  LIKE ' %@% ' then substring(contact_details,patindex(' %@% ',contact_details),20) else null end) as email from contact


SELECT 
    empid,
    contact_details,
    CASE 
        WHEN PATINDEX('%[A-Za-z0-9._%+-]@[A-Za-z0-9.-]%.[A-Za-z]{2,}%', contact_details) > 0 
        THEN SUBSTRING(
            contact_details, 
            PATINDEX('%[A-Za-z0-9._%+-]@[A-Za-z0-9.-]%.[A-Za-z]{2,}%', contact_details), 
            LEN(contact_details) - PATINDEX('%[A-Za-z0-9._%+-]@[A-Za-z0-9.-]%.[A-Za-z]{2,}%', contact_details) + 1
        )
        ELSE 'None'
    END AS email_address
FROM contact;


select * from contact
select * from contact cross apply string_split(contact_details,' ')

	WITH cte AS (
    SELECT 
        empid,
        Max(CASE WHEN value LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' THEN value ELSE NULL END) AS mobile,
        max(CASE WHEN value LIKE '%@%' THEN value ELSE NULL END) AS email
    FROM 
        contact
    CROSS APPLY 
        STRING_SPLIT(REPLACE(contact_details, ',', ' '), ' ')
    GROUP BY 
        empid
)
SELECT 
    empid, 
    mobile, 
    email
FROM 
    cte;

	-------------------------------------------------------------------------------------------------------------

CREATE TABLE EventLog (
    empid INT,
    event_type NVARCHAR(50),
    event_time DATETIME
);

INSERT INTO EventLog (empid, event_type, event_time) VALUES
(1, 'event_start', '2023-09-01 08:00:00'),
(1, 'event_process', '2023-09-01 08:05:00'),
(1, 'event_complete', '2023-09-01 08:15:00'),
(2, 'event_start', '2023-09-01 10:00:00'),
(2, 'event_process', '2023-09-01 10:05:00'),
(2, 'event_complete', '2023-09-01 10:30:00');

select * from eventlog




with cte as(
select empid,max(case when event_type='event_start' then event_time end)as start,
max(case when event_type='event_complete' then event_time end)as end1
from eventlog
group by empid)
select empid,datediff(minute,start,end1)as duration_minuates from cte


---------------------------------------------------------------------------------------------------

CREATE TABLE Transactions (
    empid INT,
    amounts NVARCHAR(MAX)
);


INSERT INTO Transactions (empid, amounts) VALUES
(1, '[{"amount": 45}, {"amount": 60}]'),
(2, '[{"amount": 30}, {"amount": 20}]'),
(3, '[{"amount": 120}, {"amount": 80}]');


use practice
select * from transactions

SELECT 
    empid,
    SUM(CAST(JSON_VALUE(value, '$.amount') AS INT)) AS total_amount
FROM 
    Transactions
CROSS APPLY 
    OPENJSON(amounts)
GROUP BY 
    empid;

----------------------------------------------------------------------------------------
CREATE TABLE EmployeeAmounts (
    empid INT,
    amount INT
);
INSERT INTO EmployeeAmounts (empid, amount) VALUES
(1, 10),
(1, 20),
(1, 30),
(1, 40),
(2, 20),
(2, 40),
(2, 60),
(2, 80);

select empid,amount,sum(amount) over(partition by empid order by amount)as running_total from employeeamounts

--------------------------------------------------------------------------------------------------------------------



create table hackers(hackerid int,name nvarchar(25))
insert into hackers values (15758,'Rose'),(20703,'Angela'),(36396,'Frank'),(38289,'Patrick'),(44065,'Lisa'),(53473,'kimberly'),(62529,'bonnie'),(79722,'Michael')

create table submission (submissiondate date,submissionid int,hackerid int ,score int)
INSERT INTO submission (submissiondate, submissionid, hackerid, score) VALUES 
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 50344, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);

with cte1 as(
select 
dense_rank() over(order by a.submissiondate asc)a1,
dense_rank() over(partition by a.hackerid order by a.submissiondate asc)a2,
a.submissiondate,a.hackerid,
count(distinct a.submissionid)n from submission a 
group by a.submissiondate,a.hackerid
),
cte2 AS(
select a.submissiondate,a.hackerid,
dense_rank()over(partition by a.submissiondate order by a.n desc,a.hackerid asc)r,
sum(case when a.a1=a.a2 then 1 else 0 end)over(partition by a.submissiondate)no_hacker from cte1 as a
)
select a.submissiondate,a.no_hacker,a.hackerid,b.name from cte2 a join hackers b on a.hackerid=b.hackerid and a.r=1
order by a.submissiondate asc;

-----------------------------------------------------------------------------------------------------

-- Create the Stocks table
CREATE TABLE Stocks (
    stock_name NVARCHAR(50),
    operation NVARCHAR(10),
    operation_day INT,
    price DECIMAL(10, 2)
);

-- Insert data into the Stocks table
INSERT INTO Stocks (stock_name, operation, operation_day, price) VALUES
('Leetcode', 'Buy', 1, 1000),
('Corona Masks', 'Buy', 2, 10),
('Leetcode', 'Sell', 5, 9000),
('Handbags', 'Buy', 17, 30000),
('Corona Masks', 'Sell', 3, 1010),
('Corona Masks', 'Buy', 4, 1000),
('Corona Masks', 'Sell', 5, 500),
('Corona Masks', 'Buy', 6, 1000),
('Handbags', 'Sell', 29, 7000),
('Corona Masks', 'Sell', 10, 10000);

select stock_name,
sum(case when operation='Buy' then -price when operation='Sell' then price end)as captial_gain_loss
from stocks
group by stock_name

----------------------------------------------------------------------------------------------------


create table inputdata
(id int,
phone_number bigint
)

insert into inputdata
values(1,9876543210),(1,9515783732),(2,9945675647),(3,8767435678),(3,8874592178)

select id,'[ '+string_agg(phone_number,' , ')+' ]' as phone_number from inputdata 
group by id
----------------------------------------------------
DECLARE @start INT
DECLARE @end INT
DECLARE @c INT
SET @start = 1
SET @end = 10

WHILE @start <= @end
BEGIN
    SET @c = 0
    DECLARE @i INT
    SET @i = 1

    WHILE @i <= @start
    BEGIN
        IF @start % @i = 0
        BEGIN
            SET @c = @c + 1
        END
        SET @i = @i + 1
    END

    IF @c = 2
    BEGIN
        PRINT @start
    END

    SET @start = @start + 1
END
---------------------------------------------------
DECLARE @start INT
DECLARE @end INT
DECLARE @c INT
DECLARE @result NVARCHAR(MAX)
SET @start = 1
SET @end = 10
SET @result = ''

WHILE @start <= @end
BEGIN
    SET @c = 0
    DECLARE @i INT
    SET @i = 1

    WHILE @i <= @start
    BEGIN
        IF @start % @i = 0
        BEGIN
            SET @c = @c + 1
        END
        SET @i = @i + 1
    END

    IF @c = 2
    BEGIN
        SET @result = @result + CAST(@start AS NVARCHAR) + '&'
    END

    SET @start = @start + 1
END
---------------------------------------------------------------------------------

declare @start int
declare @end int
set @start =1
set @end=

-- Remove the last '&' character
IF LEN(@result) > 0
BEGIN
    SET @result = LEFT(@result, LEN(@result) - 1)
END

PRINT @result
-----------------------------------------------------------------------------------------------
CREATE TABLE relationships (
    relationship_id INT PRIMARY KEY IDENTITY(101,1),
    person_a INT,
    person_b INT,
    relationship_type NVARCHAR(50)
);

INSERT INTO relationships (person_a, person_b, relationship_type)
VALUES
    (1, 2, 'Friend'),
    (2, 3, 'Colleague'),
    (3, 4, 'Family'),
    (4, 1, 'Neighbor'),    -- This creates a cycle (1 -> 2 -> 3 -> 4 -> 1)
    (5, 6, 'Friend'),
    (6, 7, 'Colleague'),
    (7, 5, 'Family'),      -- This creates another cycle (5 -> 6 -> 7 -> 5)
    (8, 9, 'Friend'),
    (9, 10, 'Colleague'),
    (10, 8, 'Family');-- This creates another cycle (8 -> 9 -> 10 -> 8)
 
 select * from relationships


with sessions as (
select person_a, person_b,
sum(case when person_a != prev_person_b then 1 else 0 end) over(order by relationship_id) as session 
from (
	select relationship_id, person_a, person_b,
	lag(person_b,1,person_b) over(order by relationship_id) as prev_person_b
	from relationships
) req

),

count as (

select *,

count(*) over(partition by session) as count,

row_number() over(partition by session order by session) as num

from sessions

)

select person_a, person_b,session, num, count

from count

where num = 1 and count>2
 
 ----------------------------------------------------------------------------
 declare @i int 
 set @i=5
 while @i>=1
 begin
 print(rtrim(replicate('* ',@i)))
 set @i=@i-1
 end
 -------------------------------------------------------------------------------------
 create table salar(eid int,salary int)
 insert into salar values (1,1000),(2,2000),(3,3000),(4,4000),(5,5000),(6,3000),(7,5000)


 select distinct salary from(select salary ,dense_rank() over (order by salary desc)as n from salar)as a where n=2
 -------------------------------------------------------------------------------------------

 create table scores (id int, score decimal(10,2))

 insert into scores values (1,3.50),(2,3.65),(3,4.00),(4,3.85),(5,4.00),(6,3.65)
 select * from scores
 drop table scores

 select * from (select score,dense_rank() over(order by score desc) from scores)as a
 
 ---------------------------------------------------------------------------------------------
 select * from logs

 select num from(select id,num,lag(num,1)over(order by num)as a,lag(num,3)over (order by num)as b from logs)as z where a=num and b=num


 create table log (id int,num int)
 insert into log values(1,1),(2,2),(3,1),(4,1)
 select * from log
 

  select num from(select id,num,lag(num,1)over(order by id)as a,lag(num,2)over (order by id)as b from log)as z where a=num and b=num
-------------------------------------------------------------------------------------------------------
create table employee (id int,name varchar(10),salary int,managerid int)
select * from employee
insert into employee values(1,'joe',70000,3),(2,'henry',80000,4),(3,'sam',60000,null),(4,'max',90000,null)


select e1.name as employee from employee e1 join employee e2 on e1.managerid=e2.id where e1.salary>e2.salary

------------------------------------------------------------------------------------------------------------

create table box (model_id int ,model_name varchar(25),color varchar(25),brand varchar(10))
insert into box values(1,'leaf','black','nisaan'),(2,'leaf','black','nisaan'),
(3,'Model S','black','tesla'),
(4,'Model L','white','tesla'),(5,'ioniq 5','black','hyundai'),
(6,'ioniq 5','black','hyundai'),(7,'ioniq 6','white','hyundai')

select * from box

select * from (select model_name,rank()over(order by model_id) from box)as b

select d
select model_name from box group by model_name having count(model_name)=1

select model_id,model_name,color,brand from(select *,rank()over(partition by model_name order by model_id asc)as n from box) as a where n=1 order by model_id

---------------------------------------------------------------------------------
create table flight (cust_id int,flight_id varchar(7),origin varchar(20),destination varchar(20))

insert into flight values(1,'SG1234','delhi','hyderabad'),(2,'SG3476','kochi','mangalore'),(3,'69876','hyderabad','kochi'),
(4,'68749','mumbai','varanasi'),(5,'SG5723','varanasi','delhi')

select * from flight

select * from(select * ,lag(destination)over(order by cust_id)as a from flight)as b where origin =a
-----------------------------------------------------------------------------------------------------

-----------------------Interview Series-----------------------------

--1)Find Nth Highest Salary from the table
select * from (select *,row_number() over(order by salary desc) as a from salar) as b where a=1

--------------------------------------------------------------------------------------------------------
--2)Query to get organization hierarchy

create table man(id int,emp_name varchar(20),managerid int)

insert into man values (1,'john',5),(2,'Mark',8),(3,'steve',8),(4,'Tom',3),(5,'lara',8),(6,'sivon',2),(7,'david',4),
(8,'Ben',null),(9,'stacy',2),(10,'sam',5)


declare @id int;
set @id=5;

with cte as(
select * from man where id=@id
 union all
 select m.id,m.emp_name,m.managerid  from man m join cte c on m.id=c.managerid
 )

 select c1.emp_name,isnull(c2.emp_name,'No Boss') as manager_name
 from cte c1 left join cte c2 on c1.managerid=c2.id

 -----------------------------------------------------------------------------------------------------
 --3)how does recursive cte work
 /*  it consists two members
        1.Anchor
		2.Recursive member
	  here the anchor part will execute first 
	  then the recursive member will execute other set these will give as input for the next iteration .
	  these will repeat until the recursive member becomes null.
*/
-------------------------------------------------------------------------------------------------------
--4)delete duplicate rows in query
create table emp21(id int,first_name varchar(25),last_name varchar(25),salary int)

insert into emp21 values (1,'Mark','Hosting',6000),(1,'Mark','Hosting',6000),(1,'Mark','Hosting',6000),
(2,'Mary','Lambeth',3000),(2,'Mary','Lambeth',3000),(3,'Ben','Hokiens',7000),(3,'Ben','Hokiens',7000),
(3,'Ben','Hokiens',7000)

with cte as(
select *,row_number() over(partition by id order by id) as a from emp21
)

delete from cte where a>1

select * from emp21
---------------------------------------------------------------------------------------
--5)Employees hired in last n month

create table emp22(id int primary key identity,first_name varchar(25),last_name varchar(25),salary int,hireddate datetime)

insert into emp22 values ('Mark','Hastings',6000,'5/10/2024'),('Steve','smith',4500,'4/10/2024'),
('John','cena',7000,'3/10/2024'),('Aksha','kumari',4500,'2/9/2024'),('Raj','kumar',5000,'2/22/2024'),
('soumya','nagula',9000,'5/25/2023'),('Ramesh','gupta',2000,'2/14/2010');

select *,datediff(month,hireddate,getdate()) from emp22 
where datediff(month,hireddate,getdate()) between 1 and 5
order by hireddate desc

----------------------------------------------------------------------------------------
--6)transform rows into columns

create table country(country varchar(25),city varchar(25))

insert into country values ('USA','New York'),('USA','Dallas'),('USA','Florida'),('India','Hyderabad'),
('India','Kolkata'),('India','Delhi'),('UK','London'),('UK','Manchester'),('UK','Birmngham')

select country,city1,city2,city3 from(
select country,city,'city'+cast(row_number() over
(partition by country order by country)as varchar(25))as a from country
) temp 
pivot
(
max(city)
for a in (city1,city2,city3)
)piv

-----------------------------------------------------------------------------------------------------------
--7)sql query to find rows that contain only numerical values

create table values1 (id int,value nvarchar(25))

insert into values1 values (1,'ABC'),(2,'123'),(3,'EFG'),(4,'901'),(5,'XYZ'),(6,'140')

select * from values1 where isnumeric(value)=1

-----------------------------------------------------------------------------------------------------------
--8)sql query to find department with highest no of employees

create table dept3 (id int primary key identity,dept_name varchar(25))

insert into dept3 values('software testing'),('HR'),('Software Engineering'),('Devops')

create table emp23(
id int primary key identity,
emp_name varchar(15),deptid int ,
foreign key(deptid) references  dept3(id) )

insert into emp23 values ('abc',1),('efg',1),('def',2),('pqr',3),('xyz',4)


select top 1 d.dept_name from emp23 e join dept3 d on e.deptid=d.id
group by d.dept_name order by count(*) desc

-------------------------------------------------------------------------------------------------
select * from emp21

select first_name,instr(first_name,binary 'a') from emp21

SELECT first_name, CHARINDEX('M', first_name) AS position FROM emp21;

-----------------------------------------------------------------------------------------------------
create table book
(
productid int,
name varchar(5),
unitprice int,
primary key(productid)
)

insert into book values (1,'Books',20),(2,'Pen',14),(3,'tape',11),(4,'clips',10)

create table saled
(id int,
quantitysold int,
foreign key(id) references book(productid)
)
insert into saled values(1,10),(3,23),(4,21),(2,12),(1,13),(3,12),(4,13),(1,11),(2,12),(1,14)


alter view vw_totalsalesbyproduct as
select b.name,sum(b.unitprice*s.quantitysold)as sale,count(*)as transactions
from book b join saled s on b.productid=s.id
group by b.name

select * from vw_totalsalesbyproduct order by sale desc

--------------------------------------------------------------------------------------------------------
create table sales1 (saleagent varchar(10),salecountry varchar(10),saleamount int)

insert into sales1 values ('Tom','uk',200),('John','us',180),('John','uk',260),('Davind','India',450),('Tom','India',350),
('David','us',200),('Tom','us',130),('John','India',150),('David','us',320),('John','India',120),('David','uk',220),
('Tom','us',320),('David','uk',120)

select salecountry,saleagent,sum(saleamount)as total from sales1
group by salecountry,saleagent order by salecountry,saleagent desc

select * from sales1
--query using pivot operator
select saleagent,India,us,uk from sales1 
pivot( sum(saleamount) for salecountry in ([India],[us],[uk]))as pivottable

--------------------------------------------------------------------------------------------------------------------

create table tblproduct
(pid int,pname varchar(15),unitprice int,qtyavailable int)

insert into tblproduct values(1,'laptops',2340,90),(2,'Desktops',3467,50)

create table tblproductsales
(productsaleid int,pid int,quantitysold int)

alter proc sp_productsale
@pid int,
@quantity int
as
begin

	declare @stock int
	select @stock=qtyavailable from tblproduct where pid=@pid

	if @stock<@quantity
	begin
		raiserror('Not enough stock available',16,1)
	end
	else
	begin 
		begin try
		begin tran
			update tblproduct set qtyavailable=(qtyavailable-@quantity) where pid=@pid

			declare @maxsalesid int

			select @maxsalesid=case when max(productsaleid) is null then 0 else max(productsaleid) end from tblproductsales

			set @maxsalesid=@maxsalesid+1

			insert into tblproductsales values(@maxsalesid,@pid,@quantity)
		commit tran
		end try
		begin catch
		rollback tran
		select error_number() as errornumber,error_message() as errormessage,error_procedure()as errorprocedure,
		error_state() as errorstate,error_severity() as errorseverity,error_line() as errorline
		end catch
	end
end

exec sp_productsale 2,10

select * from tblproduct
select * from tblproductsales

begin transaction
update tblproduct set qtyavailable=500 where pid=1


set transaction isolation level read uncommitted
select * from tblproduct ;

--------------------------------------------------------------------------------

with cte as (
select saleagent,
case when salecountry = 'India' then saleamount end as India,
  case when salecountry = 'us' then saleamount end as us,
case when salecountry = 'uk' then saleamount end as uk
from sales1
)
select saleagent, sum(India) as India, sum(us) as us, sum(uk) as uk
from cte
group by saleagent

select saleagent,India,us,uk from sales1 
pivot( sum(saleamount) for salecountry in ([India],[us],[uk]))as pivottable

---------------------------------------------------------------------------------

CREATE TABLE city_distance
(
    distance INT,
    source VARCHAR(512),
    destination VARCHAR(512)
);
 
--delete from city_distance;
INSERT INTO city_distance(distance, source, destination) VALUES ('100', 'New Delhi', 'Panipat');
INSERT INTO city_distance(distance, source, destination) VALUES ('200', 'Ambala', 'New Delhi');
INSERT INTO city_distance(distance, source, destination) VALUES ('150', 'Bangalore', 'Mysore');
INSERT INTO city_distance(distance, source, destination) VALUES ('150', 'Mysore', 'Bangalore');
INSERT INTO city_distance(distance, source, destination) VALUES ('250', 'Mumbai', 'Pune');
INSERT INTO city_distance(distance, source, destination) VALUES ('250', 'Pune', 'Mumbai');
INSERT INTO city_distance(distance, source, destination) VALUES ('2500', 'Chennai', 'Bhopal');
INSERT INTO city_distance(distance, source, destination) VALUES ('2500', 'Bhopal', 'Chennai');
INSERT INTO city_distance(distance, source, destination) VALUES ('60', 'Tirupati', 'Tirumala');
INSERT INTO city_distance(distance, source, destination) VALUES ('80', 'Tirumala', 'Tirupati');
select * from city_distance;


with cte as(
select * ,row_number() over(order by (select (null)))as rn from city_distance
)

select c1.distance,c1.source,c1.destination
from cte c1 
left join cte c2 on c1.source=c2.destination and c2.source=c1.destination
where c2.distance is null or c1.distance <> c2.distance or c1.rn<c2.rn

-------------------------------------------------------------------------------------------------------
CREATE TABLE [students](
 [studentid] [int] NULL,
 [studentname] [nvarchar](255) NULL,
 [subject] [nvarchar](255) NULL,
 [marks] [int] NULL,
 [testid] [int] NULL,
 [testdate] [date] NULL
)
data:
insert into students values (2,'Max Ruin','Subject1',63,1,'2022-01-02');
insert into students values (3,'Arnold','Subject1',95,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject1',61,1,'2022-01-02');
insert into students values (5,'John Mike','Subject1',91,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject2',71,1,'2022-01-02');
insert into students values (3,'Arnold','Subject2',32,1,'2022-01-02');
insert into students values (5,'John Mike','Subject2',61,2,'2022-11-02');
insert into students values (1,'John Deo','Subject2',60,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject2',84,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject3',29,3,'2022-01-03');
insert into students values (5,'John Mike','Subject3',98,2,'2022-11-02');

--write a sql query to get the list of students who scored above the avgerage marks in each subject
with cte as(
select subject,avg(marks)as avg from students group by subject
)
select s.*,c.* from students s join cte c on s.subject=c.subject where s.marks>c.avg

--write a sql query to get the percentage of the students who score more than 90 in any subject among the total students

select round((count(distinct case when marks>90 then studentid else null end)*1.0/count(distinct studentid))*100,2) as perc
from students 

--write a sql query to get second highest marks and second lowest marks from the student 
/* subject   second_highest_marks second_lowest_marks
   subject1  91                      63
   subject2  71                      60
   subject3  29                      98
   */
   
select subject,
sum(case when r_desc=2 then marks else null end) as Second_highest_marks,
sum(case when r_asc=2 then marks else null end) as Second_lowest_marks from(
select subject,marks,
row_number() over(partition by subject order by marks asc)as r_asc,
row_number() over(partition by subject order by marks desc)as r_desc from students ) a
group by subject

--for each student from  the test identify if their marks increased or decreased from the previous test
select * from students


select *,case when marks>prev then 'Incremented' end as stats,
case when marks<prev then 'Decremented' end as stats
 from(
select *,lag(marks,1) over(partition by studentid order by testdate,subject)as prev
from students)a

-----------------------------------------------------------------------------------------------


create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);
INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');

select * from icc_world_cup;

select team_name,count(1) as no_of_matches_played,sum(win_flag) as no_of_matches_won,
count(1)-sum(win_flag) as no_of_losses from (
select team_1 as team_name,case when team_1=winner then 1 else 0 end as win_flag
from icc_world_cup
union all
select team_2 as team_name,case when team_2=winner then 1 else 0 end as win_flag
from icc_world_cup
)a group by team_name
order by no_of_matches_won desc

--------------------------------------------------------------------------------------------


script: 
CREATE TABLE seats (
    id INT,
    student VARCHAR(10)
);

INSERT INTO seats VALUES 
(1, 'Amit'),
(2, 'Deepa'),
(3, 'Rohit'),
(4, 'Anjali'),
(5, 'Neha'),
(6, 'Sanjay'),
(7, 'Priya')


/* write a solution to swap the seat id of every two consecutive students.
if the number of students is odd the id of last student is not swapped */

select *from seats

select *,
case when id= (select max(id) from seats) and id%2=1 then id
when id%2=0 then id-1
else id+1
end as new_id from seats

----------------------------------------------------------------------------------
create table book1
(
bookid int,
bookname varchar(25),
genre varchar(20)
)

create table borrowers
(
borrowerid int,
borrowername varchar(10),
bookid int
)

INSERT INTO Book1 (BookID, BookName, Genre) VALUES
(1, 'The Great Gatsby', 'Fiction'),
(2, 'To Kill a Mockingbird', 'Fiction'),
(3, '1984', 'Fiction'),
(4, 'The Catcher in the Rye', 'Fiction'),
(5, 'Pride and Prejudice', 'Romance'),
(6, 'Romeo and Juliet', 'Romance'),
(7, 'The Notebook', 'Romance'),
(8, 'The Hunger Games', 'Science Fiction'),
(9, 'Dune', 'Science Fiction'),
(10, 'Foundation', 'Science Fiction');

insert into borrowers values
(1, 'Alice',1),
(2, 'Bob',2),
(3, 'Charlie',3),
(4, 'David',4),
(5, 'Eve',5),
(6, 'Frank',6),
(7, 'Grace',7),
(1, 'Alice',5),
(2, 'Bob',6),
(3,'Charlie',7),
(4,'David',8),
(6,'Frank',10),
(8,'Harry',2),
(9,'Ivy',3);



+--------------+-----------------------------------------+
| BorrowerName | BorrowedBooks                           |
+--------------+-----------------------------------------+
| Alice        | Pride and Prejudice,The Great Gatsby    |
| Bob          | Romeo and Juliet,To Kill a Mockingbird  |
| Charlie      | 1984,The Notebook                       |
| David        | The Catcher in the Rye,The Hunger Games |
| Eve          | Pride and Prejudice                     |
| Frank        | Foundation,Romeo and Juliet             |
| Grace        | The Notebook                            |
| Harry        | To Kill a Mockingbird                   |
| Ivy          | 1984                                    |
+--------------+-----------------------------------------+
select b1.borrowername,String_agg(b.bookname,',')as bookname 
from borrowers b1 inner join book1 b on b1.bookid=b.bookid 
group by b1.borrowername order by b1.borrowername
----------------------------------------------------------------------------------------


script:
CREATE TABLE events (
ID int,
event varchar(255),
YEAR INt,
GOLD varchar(255),
SILVER varchar(255),
BRONZE varchar(255)
);

delete from events;

INSERT INTO events VALUES (1,'100m',2016, 'Amthhew Mcgarray','donald','barbara');
INSERT INTO events VALUES (2,'200m',2016, 'Nichole','Alvaro Eaton','janet Smith');
INSERT INTO events VALUES (3,'500m',2016, 'Charles','Nichole','Susana');
INSERT INTO events VALUES (4,'100m',2016, 'Ronald','maria','paula');
INSERT INTO events VALUES (5,'200m',2016, 'Alfred','carol','Steven');
INSERT INTO events VALUES (6,'500m',2016, 'Nichole','Alfred','Brandon');
INSERT INTO events VALUES (7,'100m',2016, 'Charles','Dennis','Susana');
INSERT INTO events VALUES (8,'200m',2016, 'Thomas','Dawn','catherine');
INSERT INTO events VALUES (9,'500m',2016, 'Thomas','Dennis','paula');
INSERT INTO events VALUES (10,'100m',2016, 'Charles','Dennis','Susana');
INSERT INTO events VALUES (11,'200m',2016, 'jessica','Donald','Stefeney');
INSERT INTO events VALUES (12,'500m',2016,'Thomas','Steven','Catherine');

select * from events

select gold as player_name,count(1) as no_of_gold_won from events 
where gold not in 
(select silver from events union all select bronze from events)
group by gold

with cte as(
select gold as player_name,'gold' as medal from events union all
select silver,'silver' as medal from events union all
select bronze,'bronze' as medal from events 
)
select player_name,count(1) as no_of_gold_won from cte group by player_name having 
count(distinct medal)=1 and max(medal)='gold'
------------------------------------------------------------------------------------
create table tickets
(
ticket_id varchar(10),
create_date date,
resolved_date date
);
delete from tickets;
insert into tickets values
(1,'2022-08-01','2022-08-03')
,(2,'2022-08-01','2022-08-12')
,(3,'2022-08-01','2022-08-16');
create table holidays
(
holiday_date date
,reason varchar(100)
);
delete from holidays;
insert into holidays values
('2022-08-11','Rakhi'),('2022-08-15','Independence day');

--write a sql query to find current businessdays after weekends and public holidays
select *,
datediff(day,create_date,resolved_date) as days,
datediff(day,create_date,resolved_date)-2*datediff(week,create_date,resolved_date)as business_days
from tickets


select *,
datediff(day,create_date,resolved_date) as days,
datediff(day,create_date,resolved_date)-2*datediff(week,create_date,resolved_date)-holidays as businessdays from
(
select ticket_id,create_date,resolved_date,count(holiday_date)as holidays
from tickets left join holidays
on holiday_date between create_date and resolved_date
group by ticket_id,create_date,resolved_date
)a
------------------------------------------------------------------------------
with cte as (
    select 
        ticket_id,
        create_date,
        resolved_date,
        holiday_date
    from 
        tickets 
    left join 
        holidays 
    on 
        holiday_date between create_date and resolved_date 
        and datename(weekday, holiday_date) not in ('Saturday', 'Sunday')
)
select 
    ticket_id,
    create_date,
    resolved_date,
    datediff(day, create_date, resolved_date) 
    - 2 * (datediff(week, create_date, resolved_date)) 
    - count(distinct holiday_date) as business_days
from 
    cte
group by 
    ticket_id, create_date, resolved_date;

-------------------------------------------------------------------

create table hospital ( emp_id int
, action varchar(10)
, time datetime);

insert into hospital values ('1', 'in', '2019-12-22 09:00:00');
insert into hospital values ('1', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:00:00');
insert into hospital values ('2', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:30:00');
insert into hospital values ('3', 'out', '2019-12-22 09:00:00');
insert into hospital values ('3', 'in', '2019-12-22 09:15:00');
insert into hospital values ('3', 'out', '2019-12-22 09:30:00');
insert into hospital values ('3', 'in', '2019-12-22 09:45:00');
insert into hospital values ('4', 'in', '2019-12-22 09:45:00');
insert into hospital values ('5', 'out', '2019-12-22 09:40:00');

select * from hospital

--write a sql query to find total no of employee present inside the hospital
with cte as(
select emp_id,max(case when action='in' then time end) as intime,max(case when action='out' then time end)as outime
from hospital
group by emp_id
)
select emp_id from cte where intime>outime or outime is null

-----------------------------------------------------------------------------------------------

Create table Employe
(
 ID int primary key identity,
 FirstName nvarchar(50),
 LastName nvarchar(50),
 Gender nvarchar(50),
 Salary int
)
GO

Insert into Employe values ('Ben', 'Hoskins', 'Male', 70000)
Insert into Employe values ('Mark', 'Hastings', 'Male', 60000)
Insert into Employe values ('Steve', 'Pound', 'Male', 45000)
Insert into Employe values ('Ben', 'Hoskins', 'Male', 70000)
Insert into Employe values ('Philip', 'Hastings', 'Male', 45000)
Insert into Employe values ('Mary', 'Lambeth', 'Female', 30000)
Insert into Employe values ('Valarie', 'Vikings', 'Female', 35000)
Insert into Employe values ('John', 'Stanmore', 'Male', 80000)

select * from employe order by salary desc

select max(salary) from employe

select max(salary) from employe where salary < (select max(salary)from employe)

select * from(select *,row_number() over(order by salary desc) as r from employe)a where r=5

-----------------------------------------------------------------------------------------------
CREATE TABLE Flights (cust_id INT, flight_id VARCHAR(10), origin VARCHAR(50), destination VARCHAR(50));

-- Insert data into the table
INSERT INTO Flights (cust_id, flight_id, origin, destination)
VALUES (1, 'SG1234', 'Delhi', 'Hyderabad'),
(1, 'SG3476', 'Kochi', 'Mangalore'),
(1, '69876', 'Hyderabad', 'Kochi'), 
(2, '68749', 'Mumbai', 'Varanasi'),
(2, 'SG5723', 'Varanasi', 'Delhi');

select * from(select *, lag(destination)over(order by cust_id)as r from flights)a where r=origin

with  origins as(
select f.cust_id,f.origin from Flights f  left join Flights f1 on f.cust_id=f1.cust_id and f.origin=f1.destination
where f1.origin is null
),
destinations as(
select f.cust_id,f.destination from Flights f  left join Flights f1 on f.cust_id=f1.cust_id and f.destination=f1.origin
where f1.destination is null
)
select * from origins o  inner join  destinations d on o.cust_id=d.cust_id

-----------------------------------------------------------------------------------------------

CREATE TABLE Flight1 (cust_id INT, flight_id VARCHAR(10), origin VARCHAR(50), destination VARCHAR(50));

INSERT INTO Flight1 (cust_id, flight_id, origin, destination)
VALUES (1, 'SG1234', 'Delhi', 'Hyderabad'),
(1, '69876', 'Hyderabad', 'Kochi'), 
(1, 'SG3476', 'Kochi', 'Mangalore'),
(2, '68749', 'Mumbai', 'Varanasi'),
(2, 'SG5723', 'Varanasi', 'Delhi');

with cte as(
select *,lag(origin)over(partition by cust_id order by (select (null)))as s,
lead(origin)over(partition by cust_id order by (select (null)))as d
from flight1
)
select cust_id,max(case when s is null then origin end) as origins,
max(case when d is null then destination end) as destination 
from cte 
group by cust_id

-----------------------------------------------------------------------------------------------

CREATE TABLE sls_tbl (pid INT, sls_dt DATE, sls_amt INT )

-- Insert data into the table
INSERT INTO sls_tbl (pid, sls_dt, sls_amt)
VALUES (201, '2024-07-11', 140), 
(201, '2024-07-18', 160), 
(201, '2024-07-25', 150), 
(201, '2024-08-01', 180), 
(201, '2024-08-15', 170), 
(201, '2024-08-29', 130)

with cte as (
select
case when (datediff(day,sls_dt,lead(sls_dt) over(order by sls_dt))<>7 )
then dateadd(day,7,sls_dt)
else null 
end as missing_date
from sls_tbl

)
select * from cte where missing_date is not null

-----------------------------------------------------------------------------------------------
--------------cursor-----------------
declare @productid int
declare @name nvarchar(30)

declare productcursor cursor for
select id,name from tblproduct where id<1000

open productcursor

fetch next from productcursor into @productid,@name

while (@@FETCH_STATUS=0)
begin
	fetch next from productcursor into @productid,@name
end
close productcursor
deallocate productcursor

-----------------------------------------------------------------------------

CREATE TABLE user1 (
    USER_ID INT PRIMARY KEY,
    USER_NAME VARCHAR(20) NOT NULL,
    USER_STATUS VARCHAR(20) NOT NULL
);

CREATE TABLE logins (
    USER_ID INT,
    LOGIN_TIMESTAMP DATETIME NOT NULL,
    SESSION_ID INT PRIMARY KEY,
    SESSION_SCORE INT,
    FOREIGN KEY (USER_ID) REFERENCES USER1(USER_ID)
);
drop table logins


-- Users Table
INSERT INTO USER1 VALUES (1, 'Alice', 'Active');
INSERT INTO USER1 VALUES (2, 'Bob', 'Inactive');
INSERT INTO USER1 VALUES (3, 'Charlie', 'Active');
INSERT INTO USER1  VALUES (4, 'David', 'Active');
INSERT INTO USER1  VALUES (5, 'Eve', 'Inactive');
INSERT INTO USER1  VALUES (6, 'Frank', 'Active');
INSERT INTO USER1  VALUES (7, 'Grace', 'Inactive');
INSERT INTO USER1  VALUES (8, 'Heidi', 'Active');
INSERT INTO USER1 VALUES (9, 'Ivan', 'Inactive');
INSERT INTO USER1 VALUES (10, 'Judy', 'Active');

-- Logins Table 

INSERT INTO LOGINS  VALUES (1, '2023-07-15 09:30:00', 1001, 85);
INSERT INTO LOGINS VALUES (2, '2023-07-22 10:00:00', 1002, 90);
INSERT INTO LOGINS VALUES (3, '2023-08-10 11:15:00', 1003, 75);
INSERT INTO LOGINS VALUES (4, '2023-08-20 14:00:00', 1004, 88);
INSERT INTO LOGINS  VALUES (5, '2023-09-05 16:45:00', 1005, 82);

INSERT INTO LOGINS  VALUES (6, '2023-10-12 08:30:00', 1006, 77);
INSERT INTO LOGINS  VALUES (7, '2023-11-18 09:00:00', 1007, 81);
INSERT INTO LOGINS VALUES (8, '2023-12-01 10:30:00', 1008, 84);
INSERT INTO LOGINS  VALUES (9, '2023-12-15 13:15:00', 1009, 79);


-- 2024 Q1
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1011, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2024-01-25 09:30:00', 1012, 89);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-02-05 11:00:00', 1013, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2024-03-01 14:30:00', 1014, 91);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-03-15 16:00:00', 1015, 83);

INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2024-04-12 08:00:00', 1016, 80);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (7, '2024-05-18 09:15:00', 1017, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (8, '2024-05-28 10:45:00', 1018, 87);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (9, '2024-06-15 13:30:00', 1019, 76);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-25 15:00:00', 1010, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-26 15:45:00', 1020, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-27 15:00:00', 1021, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-28 15:45:00', 1022, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1101, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-01-25 09:30:00', 1102, 89);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-01-15 11:00:00', 1103, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2023-11-10 07:45:00', 1201, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2023-11-25 09:30:00', 1202, 84);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2023-11-15 11:00:00', 1203, 80);






select * from user1
select * from logins

------------------------------------------------------------------------------------------------
create table studentsource
(id int primary key,
name nvarchar(10)
)
insert into studentsource values (1,'Mike'),(2,'Ravi')

create table studenttarget
(id int primary key,
name nvarchar(10)
)

insert into studenttarget values (1,'Mike M'),(3,'Bhalu')

merge studenttarget AS t using studentsource as s on
t.id=s.id
	when  matched then 
update set t.name=s.name
	when not matched by target then 
insert (id,name) values (s.id,s.name)
	when not matched by source then
delete;

select * from studentsource
select * from studenttarget

select * from sysobjects where xtype='FN'

---------------------------------------------------------------------------
select * from employees

create table emp20
(
id int,
name varchar(25),
salary int,
country varchar(10),
Gender varchar(7)
)

insert into emp20 values (1,'Mark',5000,'usa','male'),
(2,'willam',2000,'uk','male'),
(3,'srujana',2000,'india','female'),
(4,'deepika',500,'japan','female'),
(5,'Marked',5000,'usa','male'),
(6,'willam son',2000,'uk','male'),
(7,'srujan',2000,'india','male'),
(8,'deepika',500,'india','female')

select country,gender,sum(salary)Totalsalary from emp20 
group by 
grouping sets
(
(country,gender),--sum of salary by country & gender
(country), -- sum of salary by country
(gender), --sum of salary by gender
() -- grand total
)
order by grouping(country),grouping(gender),gender;
---------------------------------------------------------------------------
----difference between cube and rollup ---------------------
select country,sum(salary) from emp20 group by rollup (country)

--or

select country,sum(salary) from emp20 group by cube(country)

------------------------------------------------------------------------------
-----grouping function----------------------------

select country,sum(salary) from emp20 grouping(salary) as cty group by rollup(country)
--------------------------------------------------------------------------------------


create table phones_table(userid int,iphone_model varchar(5))

insert into phones_table values (1,'i-11'),(1,'i-15'),(2,'i-15')
insert into phones_table values (3,'i-12'),(3,'i-15')

select * from phones_table 

select userid from phones_table group by userid having count(userid)=1

select *, case when iphone_model='i-15' then 1 else 0 end as count_iphone,
count(iphone_model) over(partition by userid) as r from phones_table 

select userid from phones_table  group by userid
having  count(iphone_model)=count(case when iphone_model='i-15' then 1 else 0 end)


--iphone who buy i-12 and i-15-----------------------------------------------------------------------
select userid from phones_table  group by userid having sum(case when iphone_model='i-11'  then 1 else 0 end)=0


------iphone who buy only i-15-------------
select userid from phones_table group by userid having sum(case when iphone_model='i-15' then 0 else 1 end)=0

---------iphone who not buy i-12
select userid from phones_table group by userid having sum(case when iphone_model='i-12' then 1 else 0 end)=0


------------------------------------------------------------------------------------------------------------------

create table Rowstocolumn
(empid int,
salary_component_type varchar(10),
val int
)

insert into Rowstocolumn values (1,'salary',10000),(1,'bonus',400),
(1,'hike per',10),
(2,'salary',15000),(2,'bonus',200),
(2,'hike per',20),(3,'salary',20000),
(3,'bonus',500),(3,'hike per',10)

select * from Rowstocolumn


select empid,max(case when salary_component_type='salary' then val end )as salary,
max(case when salary_component_type='bonus' then val end) as bonus ,
max(case when salary_component_type='hike per' then val end )as hire_percentage into columntorow 
from Rowstocolumn group by empid

select * from columntorow

 
----------------------------------------------------------------------------------------------------------
-------10 interview questions---------------
create table emp17(
emp_id int,
emp_name varchar(20),
department_id int,
salary int,
manager_id int,
emp_age int);

insert into emp17
values
(1, 'Ankit', 100,10000, 4, 39),
(2, 'Mohit', 100, 15000, 5, 48), 
(3, 'Vikas', 100, 10000,4,37),
(4, 'Rohit', 100, 5000, 2, 16),
(5, 'Mudit', 200, 12000, 6,55),
(6, 'Agam', 200, 12000,2, 14),
(7, 'Sanjay', 200, 9000, 2,13),
(8, 'Ashish', 200,5000,2,12),
(9, 'Mukesh',300,6000,6,51),
(10, 'Rakesh',300,7000,6,50);
 insert into emp17 values (9,'Mukesh',700,8000,6,51)

 create table dept17(
 
 dept_id int,
 dept_name varchar(10)
 );
 

insert into dept17 values(100,'Analytics');
insert into dept17 values(300,'IT');

--how to find duplicates in the given table
select emp_id from emp17 group by emp_id having  count(1)>1

---how to delete duplicates
with cte as(
select *,row_number() over(partition by emp_id order by emp_id)as r from emp17
)
delete from cte where r=2

select * from emp17

--difference between union and unionall
/* union it returns no duplicates it provide unique values
union all it returns all rows from the both table
*/


--difference between rank(),dense_rank(),row_number()

--employees who are not present in the department table
select e.emp_id,e.emp_name from emp17 e left join dept17 d
on e.department_id=d.dept_id where d.dept_id is null

--second highest salary from each department
select emp_id,emp_name,department_id,salary from (
select *,row_number() over(partition by department_id order by salary desc ) as r from emp17
) a where r=2

---find all the transactions done by Mukesh


select * from emp17 where emp_name='Mukesh'

--self join manager salary> employee salary

select e.emp_name,e.salary,d.emp_name,d.salary from emp17 e join emp17 d 
on e.manager_id=d.emp_id 
where d.salary>e.salary

---join left/inner 

select * from emp17 e left join emp17 d on e.emp_id=d.manager_id
union all
select * from emp17 e inner join emp17 d on e.emp_id=d.manager_id

---update query to swape gender

create table order17(
 customer_name char(10),
 order_date date,
 order_amount int,
 customer_gender char(6)
 );
 
 insert into order17 values('Shilpa','2020-01-01',10000,'Male');
 insert into order17 values('Rahul','2020-01-02',12000,'Female');
 insert into order17 values('Shilpa','2020-01-02',12000,'Male');
 insert into order17 values('Rohit','2020-01-03',15000,'Female');
 insert into order17 values('Shilpa','2020-01-03',14000,'Male');


 update  order17 set customer_gender= case when customer_gender='Male' then 'Female' else 'Male' end 

 select * from order17

 -----------------------------------------------------------------------------------------------------------

 create table emp_manager(emp_id int,emp_name varchar(50),salary int,manager_id int);
insert into emp_manager values(	1	,'Ankit',	10000	,4	);
insert into emp_manager values(	2	,'Mohit',	15000	,5	);
insert into emp_manager values(	3	,'Vikas',	10000	,4	);
insert into emp_manager values(	4	,'Rohit',	5000	,2	);
insert into emp_manager values(	5	,'Mudit',	12000	,6	);
insert into emp_manager values(	6	,'Agam',	12000	,2	);
insert into emp_manager values(	7	,'Sanjay',	9000	,2	);
insert into emp_manager values(	8	,'Ashish',	5000	,2	);

select * from emp_manager
select w.emp_name,w.salary,m.emp_name,m.salary from emp_manager w  join emp_manager m 
on w.emp_id=m.manager_id 
where w.salary>m.salary

--------------------------------------------------------------------------------------

with cte as
(
select 1 as empid,1000 as salary ,101 as deptid
union all 
select 2 as empid,2000 as salary, 102 as deptid
union all
select 3 as empid,3000 as salary ,103 as deptid
),
dept as
(
select 101 as deptid ,'d1' as deptname
union all
select 102 as deptid,'d2' as deptname
union all
select 103 as deptid,'d3' as deptname
)
select * from cte join dept on cte.deptid=dept.deptid

----------------------------------------------------------------------------
create proc spPrintEvenumbers
@target int
as
begin
declare @start int
set @start =1
while (@start<@target)
begin
if (@start%2=0)
begin
print(@start)
end
set @start=@start+1;
end
end


declare @target int
set @target=10
exec spPrintEvenumbers @target
print('Done')

-----------------------------------------------------------------------------------
Create Table Emp14
(
 Id int primary key,
 Name nvarchar(50),
 Gender nvarchar(10),
 Salary int
)

Insert Into Emp14 Values (1, 'Mark', 'Male', 5000)
Insert Into Emp14 Values (2, 'John', 'Male', 4500)
Insert Into Emp14 Values (3, 'Pam', 'Female', 5500)
Insert Into Emp14 Values (4, 'Sara', 'Female', 4000)
Insert Into Emp14 Values (5, 'Todd', 'Male', 3500)
Insert Into Emp14 Values (6, 'Mary', 'Female', 5000)
Insert Into Emp14 Values (7, 'Ben', 'Male', 6500)
Insert Into Emp14 Values (8, 'Jodi', 'Female', 7000)
Insert Into Emp14 Values (9, 'Tom', 'Male', 5500)
Insert Into Emp14 Values (10, 'Ron', 'Male', 5000)

select * from emp14

use practice

/*Write a query to retrieve total count of employees by Gender. 
Also in the result we want Average, Minimum and Maximum salary by Gender.*/
select name,gender,salary,count(gender) over (partition by gender)as countgender,
avg(salary) over (partition by gender)as avgsalary,
max(salary) over (partition by gender) as maxsalary,
min(salary) over (partition by gender) as minsalary
from Emp14



select name,gender,salary,genders.gendertotal,genders.avgsalary,genders.maxsalary,genders.minsalary from emp14
inner join
(
select salary,gender,count(*)as gendertotal,avg(salary)as avgsalary,
min(salary)as minsalary,max(salary)as maxsalary
from emp14 group by gender
)as genders
on emp14.Gender=genders.Gender

---difference b/w rownumber,rank,denserank-----------
select name,salary,gender,
ROW_NUMBER() over (order by salary desc) as RowNumber,
Rank() over (order by salary desc)as RankNumber,
DENSE_RANK() over(order by salary desc) as DenseRank
from Emp14

-------------------total the running sum----------------
select name,salary,gender,
sum(salary)over(partition by gender order by id asc)as runningSum
from emp14



------NTILE function : is used to divide the rows--------------------

select name,salary,gender,
ntile(2) over(partition by gender order by id ) as rows from emp14

----------lead() and lag()---------------
select name,salary,gender,lag(salary,2) over(order by salary) as laging,
lead(salary,2) over (order by salary) as leading from emp14


------------first_value()---------------------------

select name,salary,gender,FIRST_VALUE(name) over (partition by gender order by salary) as firstvalue
from emp14

--------------last_value()---------------------------

select name,salary,gender,LAST_VALUE(salary) over (partition by gender order by salary) as lastvalue
from emp14


---------the default for rows o range clause---------------------
--range between unbounded preceding and current row

select name,salary,gender,
avg(salary)over (order by salary rows between unbounded preceding and unbounded following) as avgsalary,
count(salary)over (order by salary rows between unbounded preceding and unbounded following) as avgsalary,
sum(salary)over (order by salary rows between unbounded preceding and unbounded following) as avgsalary
from emp14

--------------------------------------------------------------------------------------------------------------

create table table_1(id int)

insert into table_1 values(1),(1),(1),(2),(3),(3),(3)

create table table_2 (id int)
insert into table_2 values (1),(1),(2),(2),(4),(null)

select * from table_1 t1 
join table_2 t2 on t1.id=t2.id

select * from table_1 t1 inner join table_2 t2 on t1.id=t2.id

select * from table_1 t1 full outer join table_2 t2 on t1.id=t2.id

select * from table_1 t1 left join table_2 t2 on t1.id=t2.id

select * from table_1 t1 right join table_2 t2 on t1.id=t2.id

select * from table_1 t1 cross join table_2 t2

-------------------------------------------------------------------------------------
---------all the aggregration ,zero to hero , sum(),avg(),min(),max()
CREATE TABLE [dbo].[int_orders](
 [order_number] [int] NOT NULL,
 [order_date] [date] NOT NULL,
 [cust_id] [int] NOT NULL,
 [salesperson_id] [int] NOT NULL,
 [amount] [float] NOT NULL
) ON [PRIMARY]
GO
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (30, CAST(N'1995-07-14' AS Date), 9, 1, 460)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (10, CAST(N'1996-08-02' AS Date), 4, 2, 540)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (40, CAST(N'1998-01-29' AS Date), 7, 2, 2400)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (50, CAST(N'1998-02-03' AS Date), 6, 7, 600)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (60, CAST(N'1998-03-02' AS Date), 6, 7, 720)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (70, CAST(N'1998-05-06' AS Date), 9, 7, 150)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (20, CAST(N'1999-01-30' AS Date), 4, 8, 1800)


select * from int_orders

select salesperson_id,order_number,order_date,amount from int_orders

-----simple sum()
select sum(amount) from int_orders

select salesperson_id,sum(amount) from int_orders group by salesperson_id

select salesperson_id,order_number,order_date,amount,sum(amount) over() from int_orders

----------------------------------------------------------------------------------------

create table salesagent(salesagent varchar(20),ind int,us int, uk int)

insert into salesagent values ('Dravid',920,520,360),('John',970,540,800)

select salesagent,country,salesamount from salesagent

unpivot
(
salesamount
for country in(ind,uk,us)
)as unpivotexample

-----------------------------------------------------------------------------------------
--write a query to provide the date for nth occurence of the sunday in future for given date
--datepart
--sunday-1
--monday-2
--friday-6
--saturday-7

declare @today_date date;
declare @n int;
set @today_date='2022-01-09';--saturday
set @n=3;

select dateadd(week,@n-1, dateadd(day,8-datepart(weekday,@today_date),@today_date))

-------------------------------------------------------------------------------------
/* The Pareto Principle states that for many outcomes, roughly 80% of consequences  come from 20%
of causes. eg:
1- 80% of the productivity come from 20% of the employees,
2- 80% of your sales come from 20%  of your clients
3- 80% of decisions in a meeting are made in  20% of the time
4- 80% of your sales come from 20%  of your products or services.
*/
DECLARE @start DATE;
SET @start = '2024-01-01';
DECLARE @end DATE;
SET @end = '2024-12-31';

WHILE @start <= @end
BEGIN
    DECLARE @weekEnd DATE;
    SET @weekEnd = DATEADD(DAY, 6, @start);

    IF MONTH(@start) <> MONTH(@weekEnd)
    BEGIN
        SET @weekEnd = EOMONTH(@start);
    END

    PRINT CONCAT(CONVERT(VARCHAR, @start, 23), ' to ', CONVERT(VARCHAR, @weekEnd, 23));

    SET @start = DATEADD(DAY, 1, @weekEnd);
END

Create table friend (pid int, fid int)
insert into friend (pid , fid ) values ('1','2');
insert into friend (pid , fid ) values ('1','3');
insert into friend (pid , fid ) values ('2','1');
insert into friend (pid , fid ) values ('2','3');
insert into friend (pid , fid ) values ('3','5');
insert into friend (pid , fid ) values ('4','2');
insert into friend (pid , fid ) values ('4','3');
insert into friend (pid , fid ) values ('4','5');
create table person (PersonID int,	Name varchar(50),	Score int)
insert into person(PersonID,Name ,Score) values('1','Alice','88')
insert into person(PersonID,Name ,Score) values('2','Bob','11')
insert into person(PersonID,Name ,Score) values('3','Devis','27')
insert into person(PersonID,Name ,Score) values('4','Tara','45')
insert into person(PersonID,Name ,Score) values('5','John','63')
select * from person
select * from friend

/*write a query to find personid,name,number of friends,sum of marks of 
persons who have friends with total score greather than 100.*/
select * from friend f1 inner join person p1 on f1.fid=p1.PersonID

with cte as(
select f1.pid,sum(score)as sum_of_score,count(1) as no_of_friends from  friend f1 inner join person p2 
on f1.fid=p2.PersonID group by f1.pid having sum(score)>100
)
select c.*,p1.name from person p1 inner join cte c on p1.PersonID=c.pid

----------------------------------------------------------------------------------------------------

create table tasks (
date_value date,
state varchar(10)
);

insert into tasks  values ('2019-01-01','success'),('2019-01-02','success'),('2019-01-03','success'),('2019-01-04','fail')
,('2019-01-05','fail'),('2019-01-06','success')

select * from tasks
with all_dates as(
select *,row_number()over(partition by state order by date_value)as rn,
dateadd(day,-1*ROW_NUMBER()over(partition by state order by date_value),date_value)as group_date
from tasks
)
select min(date_value)as start_date,max(date_value)as end_date,state from all_dates group by group_date,state
order by start_date

-------------------------------------------------------------------------------------------------------------------------

create table amazon_users
(
user_id integer,
name varchar(20),
join_date date
);
insert into amazon_users
values (1, 'Jon', CAST('2-14-20' AS date)), 
(2, 'Jane', CAST('2-14-20' AS date)), 
(3, 'Jill', CAST('2-15-20' AS date)), 
(4, 'Josh', CAST('2-15-20' AS date)), 
(5, 'Jean', CAST('2-16-20' AS date)), 
(6, 'Justin', CAST('2-17-20' AS date)),
(7, 'Jeremy', CAST('2-18-20' AS date));

create table amazon_events
(
user_id integer,
type varchar(10),
access_date date
);

insert into amazon_events values
(1, 'Pay', CAST('3-1-20' AS date)), 
(2, 'Music', CAST('3-2-20' AS date)), 
(2, 'P', CAST('3-12-20' AS date)),
(3, 'Music', CAST('3-15-20' AS date)), 
(4, 'Music', CAST('3-15-20' AS date)), 
(1, 'P', CAST('3-16-20' AS date)), 
(3, 'P', CAST('3-22-20' AS date));

select * from amazon_events
select * from amazon_users

select u.*,e.access_date,e.type,DATEDIFF(day,u.join_date,e.access_date) from amazon_users u 
inner join amazon_events e 
on u.user_id=e.user_id and e.type='P'
where u.user_id in (select user_id from amazon_events where type='Music')

---------------------------------------------------------------------------------------------------

DECLARE @start DATE;
SET @start = '2024-01-01';
DECLARE @end DATE;
SET @end = '2024-12-31';

WHILE @start <= @end
BEGIN
	if month(CONVERT(VARCHAR, @start, 23))=month(CONVERT(VARCHAR, DATEADD(DAY, 6, @start), 23))
	begin
	set 
	end
	PRINT CONCAT(CONVERT(VARCHAR, @start, 23), ' to ', CONVERT(VARCHAR, DATEADD(DAY, 6, @start), 23));

	SET @start = DATEADD(DAY, 7, @start);
	
	
END





2024-01-01 to 2024-01-07
2024-01-08 to 2024-01-14
2024-01-15 to 2024-01-21
2024-01-22 to 2024-01-28
2024-01-29 to 2024-01-31
2024-02-01 to 2024-02-04
2024-02-05 to 2024-02-12
2024-02-13 to 2024-02-20
2024-02-27 to 2024-02-29
2024-03-01 to 2024-03-07
2024-03-08 to 2024-03-15






declare @start date;
set @start ='2023-01-01';
declare @end date;
set @end='2023-12-31';

while (@start<=@end)
begin
declare @weeknd date;
set @weeknd=dateadd(day,6,@start);

if month(@start)!=month(@weeknd)
begin
set @weeknd=eomonth(@start);
end

print(concat(@start,' to ',@weeknd));

set @start=dateadd(day,1,@weeknd);
end



alter proc spDateRange
@start date,
@end date
as
begin
	

	while @start<=@end
	begin
		declare @res date;
		declare @n int,@start1 date;
		set @res=dateadd(day,6,@start);

		if month(@start) != month(@res)
		begin
			set @res=eomonth(@start);
			Print(concat(@start,' to ',@res));
		set @start1=dateadd(day,1,@res);
		set @n=datediff(day,@start,@res);
		print(@n)
		set @res=dateadd(day,7-@n,@start1);
		Print(concat(@start1,' to ',@res));
		end

		--Print(concat(@start,' to ',@res));
		set @start=dateadd(day,1,@res);
	end
end

exec spDateRange '2024-01-01','2024-12-31'


create function dbo.daterange(@start date,@end date)
returns @output table
(
 daterange varchar(50)
 )
 as
 create proc sprange
 @start date,
 @end date
 as
 begin
	while @start<=@end
	begin
	declare @res date;
	set @res=dateadd(day,6,@start);

	if month(@start)=month(@res)
	begin
	print(concat(@start,' to ',@res));
	set @start=dateadd(day,1,@res);
	end
	else
	begin
		set start

		set @res=eomonth(@start)


end

exec spRange '2024-01-01','2024-12-31'

select * from emp with nolock


----------without fun()/stored proc------------------------------------
DECLARE @start DATE;
SET @start = '2024-01-01';
DECLARE @end DATE;
SET @end = '2024-12-31';

WHILE (@start <= @end)
BEGIN
	declare @weeknd date;
	SET @weeknd = DATEADD(DAY, 6, @start);

	IF MONTH(@start) != MONTH(@weeknd)
	BEGIN
		DECLARE @endmonth DATE = EOMONTH(@start);
		PRINT CONCAT( @start, ' to ', @endmonth);
		SET @start = DATEADD(DAY, 1, @endmonth);
		PRINT CONCAT(@start, ' to ', @weeknd);
	END
	ELSE
	BEGIN
		PRINT CONCAT(@start, ' to ',  @weeknd);
	END

	SET @start = DATEADD(DAY, 1, @weeknd);
END

----------------------------------------------
select * from emp1 join emp2 on emp1.eid=emp2.eid

-----------------------------------------------

EXEC PrintSplitDateRanges;
go;

CREATE PROCEDURE PrintSplitDateRanges 
AS
BEGIN
    DECLARE @StartDate DATE = '2024-01-01';
    DECLARE @EndDate DATE = '2024-12-31';
    DECLARE @CurrentStartDate DATE = @StartDate;
    DECLARE @CurrentEndDate DATE;

    WHILE @CurrentStartDate <= @EndDate
    BEGIN
        -- Calculate the end date for the current range
        SET @CurrentEndDate = DATEADD(DAY, 6, @CurrentStartDate);

        -- Ensure the end date does not exceed the overall end date

        IF @CurrentEndDate > @EndDate

            SET @CurrentEndDate = @EndDate;
 
        -- Check if the start and end dates are in different months

        IF MONTH(@CurrentStartDate) <> MONTH(@CurrentEndDate) OR YEAR(@CurrentStartDate) <> YEAR(@CurrentEndDate)
        BEGIN
            -- Split the range into two parts
            DECLARE @EndOfMonth DATE = EOMONTH(@CurrentStartDate);
            PRINT FORMAT(@CurrentStartDate, 'dd/MM/yyyy') + '_' + FORMAT(@EndOfMonth, 'dd/MM/yyyy');
            PRINT FORMAT(DATEADD(DAY, 1, @EndOfMonth), 'dd/MM/yyyy') + '_' + FORMAT(@CurrentEndDate, 'dd/MM/yyyy');

        END

        ELSE

        BEGIN

            -- Print the date range as is

            PRINT FORMAT(@CurrentStartDate, 'dd/MM/yyyy') + '_' + FORMAT(@CurrentEndDate, 'dd/MM/yyyy');

        END
 
        -- Move to the next start date (7 days later)
        SET @CurrentStartDate = DATEADD(DAY, 7, @CurrentStartDate);
    END
END;
 

 -------------------------------------------------------------------------------
 -----with stored proc()----------
alter PROC spDate
    @start DATE,
    @end DATE
AS
BEGIN
    DECLARE @weeknd DATE;

    WHILE @start <= @end
    BEGIN
        SET @weeknd = DATEADD(DAY, 6, @start);

        IF MONTH(@start) != MONTH(@weeknd)
        BEGIN
            DECLARE @endmonth DATE = EOMONTH(@start);
            PRINT CONCAT( @start, ' to ', @endmonth);
            SET @start = DATEADD(DAY, 1, @endmonth);
            PRINT CONCAT(@start, ' to ', @weeknd);
        END
        ELSE
        BEGIN
            PRINT CONCAT(@start, ' to ',  @weeknd);
        END

        SET @start = DATEADD(DAY, 1, @weeknd);
    END
END

exec spDate '2024-01-01','2024-12-31'

--------------------------------------------------------------

create  table code3601
(
id int,
student varchar(20)
)

insert into code3601 values (1,'Abbot'),(2,'Daris'),(3,'Emerson'),(4,'Green'),(5,'Jeames');
insert into code3601 values (6,'Raja')

select * from code3601

set statistics time on;
with cte as (
select id, student,
lag(student) over(order by id) as prevStd,
lead(student) over(order by id) as nextStd
from code3601
)
select id,
case when (select count(*) from cte) %2 <>0 and id = (select max(id) from cte) then student
when id %2 <>0 then nextStd
when id%2 = 0 then  prevStd
end as name
from cte

select case  
                    when (select max(id) from code3601)= id then id 
                    when id%2<>0 then id+1
                    when id%2=0 then id-1 end as id ,student 
from code3601 order by id


select * from code3601
 
set statistics time off;

-----------------------------------------------------------------------
create table nullcount
(
col1 varchar(5),
col2 varchar(5),
col3 varchar(5),
)

insert into nullcount values ('a',null,'e'),('b','d',null),(null,null,'f')
alter table nullcount add col4 varchar(3)
select distinct
sum(case when col1 is null then 1 else 0 end) over()  as col1null,

sum(case when col2 is null then 1 else 0 end) over()  as col2null,

sum(case when col3 is null then 1 else 0 end) over()  as col3null,
sum(case when col4 is null then 1 else 0 end) over()  as col4null
from nullcount
select * from nullcount;
where col1 is null or  col2 is null or col3 is null

update nullcount
set col4 = 'g'
where col4 is null

------------------------------------------------------------------------------------------
---------------interview series---------------------------------
--1
create table table1
(
count int,
str varchar(5)
)

insert into table1 values (4,'R'),(2,'S'),(3,'Ra')

select *,REPLICATE([str],[count])as rep from table1

----------------------------------------------------
--2
create table tablea(
empid int,
ename varchar(5),
salary int
)

insert into tablea values (1,'AA',1000),(2,'BB',300)


create table tableb(
empid int,
ename varchar(5),
salary int
)

insert into tableb values (2,'BB',400),(3,'CC',100)

	select * from tablea
	
	select * from tableb

	select *
	from tablea a
	full outer join tableb b on a.empid = b.empid


with cte as
(
	select * from tablea
	union
	select * from tableb
)
select empid,ename,salary from 
	(select *,row_number() over (partition by ename order by empid) as r  from cte)a 
where r=1


with cte as
(
	select * from tablea
	union
	select * from tableb
),b as
(
select *,row_number() over(partition by ename order by empid)as r from cte
)

select empid,ename,salary from b where r=1



------------------------------------------------------------------------------------
--3
create table tablestudent1
(
sname varchar(1),
sid varchar(1),
marks int
)

insert into tablestudent1 values 
('A','X',75),('A','Y',75),('A','Z',80),('B','X',90),('B','Y',91),('B','Z',75)


select * from tablestudent1

select distinct sname,sum(marks)over(partition by sname ) as totalmarks from tablestudent1
with cte as (
select sname, marks,
ROW_NUMBER() over(partition by sname order by marks desc) as rn
from tablestudent1
)
select sname, sum(marks) as total_marks
from cte
where rn<3
group by sname


select * from tablestudent1 

-------------------------------------------------------------------
--4

create table events_tbl
(
pid int,
year int
)

insert into events_tbl values (1,2019),(1,2020),(1,2021),(2,2022),(2,2021),(3,2019),(3,2021),(3,2022)

select * from events_tbl

with cte as(
select *,
ROW_NUMBER() over(partition by pid order by year)as grp,
year-ROW_NUMBER() over(partition by pid order by year)as dfy
from events_tbl
)
select pid from cte 
group by pid,dfy
having count(*)=3;

----------------------------------------------------------------------------
--5
create table tablea1(
id int)

insert into tablea1 values(1),(1),(2),(null),(null)

create table tableb1(
id int)

insert into tableb1 values(1),(3),(null)

select count(*)as 'join' from tablea1 join tableb1 on tablea1.id=tableb1.id
union
select count(*)as 'innerjoin' from tablea1 inner join tableb1 on tablea1.id=tableb1.id
union
select count(*)as 'full outer join' from tablea1 full outer join tableb1 on tablea1.id=tableb1.id
union
select count(*)as 'left join' from tablea1 left join tableb1 on tablea1.id=tableb1.id
union
select count(*)as 'right join' from tablea1 right join tableb1 on tablea1.id=tableb1.id
union
select count(*)as 'cross join' from tablea1 cross join tableb1 

--------------------------------------------------------------------------------------------------
--6
create table tablea3
(
id int
)
--------------------------------------------------------------------------------------------------
use practice

select * from student

create view vw_student as
(
select studentid,studentname,yoj from student
)

select * from vw_student

update vw_student set yoj=2024 where studentid=4

select * from student
select * from vw_student


delete from vw_student where studentid=14

select * from student
select * from vw_student