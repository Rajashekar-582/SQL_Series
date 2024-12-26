use Teams;

create proc sphello
as
begin
select * from dev_team;
end;

exec sphello;



select * from operations_team;

create proc hi
as 
begin
select emp_id,f_name,l_name,salary,city,
rank() over(partition by city order by salary desc)as ranked
from (select emp_id,f_name,l_name,salary,city from operations_team)as team ;
end;

exec hi;


create proc sphi
@rank int
as
begin 
with a as(
select emp_id,f_name,l_name,salary,city,
row_number() over(partition by city order by salary desc)as ranked

from (select emp_id,f_name,l_name,salary,city from operations_team)as team)
select * from a where ranked=@rank;
end;

exec sphi 1;

create table emp(empid int,empname varchar(10),sal int);
insert into emp values(1,'Raja',5000),(2,'Shekar',60000),(3,'varun',2300);
select * , (rank() over(order by sal ))
from emp;


alter proc spbye
@salary int,
@cit varchar(10)
as
begin 
with a as(
select emp_id,f_name,l_name,salary,city,
row_number() over(partition by city order by salary desc)as ranked
from (select emp_id,f_name,l_name,salary,city from operations_team)as team)
select * from a where salary>@salary and city=@cit;
end;

exec spbye 1000,'chennai';

 create proc hl0



-----------------------------------------------------------------------
use teams;

select* from operations_team;

-- Define the stored procedure to calculate average salary
alter PROCEDURE vysh
    @AverageSalary INT OUTPUT
AS
BEGIN
    SELECT @AverageSalary = AVG(salary)
    FROM operations_team;
	
END;

-- Declare a variable to capture the output
DECLARE @avgsalary INT;

-- Execute the stored procedure to populate the output parameter
EXEC vysh @AverageSalary = @avgsalary OUTPUT;

-- Display the output
SELECT @avgsalary AS Average_salary;

---string function
select CONCAT (f_name,' ',l_name) as full_name,* from operations_team;

select UPPER( f_name+' '+l_name) as Full_name from operations_team;

select PATINDEX('%a%',f_name)as position_of_a from operations_team;

--get me the second occurence

select replace(f_name,'Muthyam','shekar') from operations_team;


select f_name,space(2) as hi,l_name  from operations_team;

select f_name,stuff(f_name,1,0,'Mr.')as new from operations_team;

select f_name,REPLICATE('Mr.Precious ',3)as stars from operations_team;

select f_name,left(f_name,2) as hi from operations_team where emp_id=101;
select * from operations_team
select f_name,right(f_name,3) as hi from operations_team;



--date time function

select now() as current_datetime;

select GETDATE() as current_datetime;

select year(getdate()) as current_year;

select month(getdate()) as current_month;

select day(getdate()) as current_day;

select DATEADD(month,5,getdate()) as current_now;

select DATEDIFF(year,1-1-2020,year_of_joining) from operations_team;

select year_of_joining,DATEPART(year,year_of_joining) from operations_team;

----------------------------------------------------
select * from operations_team

select abs(year_of_joining-year_of_graduation) from operations_team;

select (year_of_joining-year_of_graduation) from operations_team;


---------------------------------------------------------------
create function dbo.exp1(@yoj int)
returns int
as
begin
	return (@yoj-year(getdate()));
end;
go

select emp_id,f_name,l_name,dbo.exp1(year_of_joining) from operations_team;

-------------------------------------------------------------------------------

--create a function which receives two inputs and calculate total pending tasks for each employee in the operation team

create function dbo.vyshu(@totaltask int,@ontimetask int)
returns int
as
begin
	return (@totaltask-@ontimetask);
end;
go
select emp_id,f_name,l_name,dbo.vyshu(total_tasks,on_time_tasks) as pending_tasks from operations_team;
--------------------------------------------------------------------------------------------------------------
--avg(salary) for each employee based on the city -- input city
create function dbo.avgsal(@city varchar(10))
returns int
as
begin
declare @avg_salary int;
select @avg_salary=avg(salary) from operations_team where city=@city;
return @avg_salary;

end;
go
select emp_id,f_name,l_name,city,salary,dbo.avgsal(city) as average_salary from operations_team;


--year wise salary increment for each employee--yoj current

alter function dbo.salary_inc(@salary int,@yoj int)
returns decimal(10,2)
as
begin
declare @total int;
set @total=(@salary/(year(GETDATE())-@yoj));
return (@total*100/@salary);
end;

select emp_id,f_name,l_name, year_of_joining,salary,dbo.salary_inc(salary,year_of_joining)as Yearwise_salary_increment from operations_team;

-----------------------------------------------------------------------------------------------------------------
--inlined table valued functions

create function dbo.ex(@year int)
returns table
as
return 
(
select emp_id,f_name,l_name,(year(getdate())-year_of_joining) as exper
from operations_team
where (year(getdate())-year_of_joining) >@year
);
go 
select * from dbo.ex(2);
select *
--------------------------------------------------------------------------------------------
--get employees who are promoted in five years last

create function dbo.ex1(@year int)
returns table
as
return 
(
select emp_id,f_name,l_name,(year(getdate())-year_of_joining) as exper
from operations_team
where (year(getdate())-year_of_joining) >@year and  is_promoted = 1
);

select * from dbo.ex1(5);
----------------------------------------------------------------------------

--get the employees who has effeciency more than  75%
alter function dbo.efficiencyofemp(@effi int)
returns table
as
return( select emp_id, f_name, l_name, on_time_tasks, total_tasks ,is_promoted, (on_time_tasks * 100/total_tasks) as efficiency
from operations_team
where (on_time_tasks * 100/total_tasks) >= @effi and is_promoted = 1
);
go
select * from  dbo.efficiencyofemp(30);

--out of these who are promoted and who are not promoted
 alter function dbo.efficiencyofemp1(@effi int,@prompted bit)
returns table
as
return( select emp_id, f_name, l_name, on_time_tasks, total_tasks ,is_promoted, (on_time_tasks * 100/total_tasks) as efficiency
from operations_team
where (on_time_tasks * 100/total_tasks) >= @effi and is_promoted=@prompted
);
go
select count(*)as pass, (select count(*) from dbo.efficiencyofemp1(40,0) )as not_pass from dbo.efficiencyofemp1(40,1)  ;

--------------------------------------------------------------------------------------------------------------------------
select * from operations_team;


select* from operations_team as o1 , operations_team as o2 where o1.salary=o2.salary and o1.city !=o2.city;

-------------------------------------------------------------------------------------
--temporary tables

create table ##globaltempemployee(
empid int,
empname  varchar(10),
depi varchar(10)
);



insert into ##globaltempemployee(empid,empname,depi)
values
(1,'a', 'it'),
(2, 'b', 'hr'),
(3, 'c' , 'finance');
select * from ##globaltempemployee;
-----------------------------------------------------
--tempvariable
declare @tempemployee table(
empid int,
ename nvarchar(100),
dept nvarchar(50)
);

insert into @tempemployee values(1,'John Doe','IT'),(2,'Jane Smith','HR');

select * from @tempemployee;
-------------------------------------------------------------------------------
create table #testing_team(
emp_id int,
f_name varchar(10),
l_name varchar(10),
test_case_id int,
accuracy int,
points int,
city varchar(10),state varchar(10),
is_promoted bit,
year_of_joining date,
year_of_graduation date,
salary int)

insert into #testing_team values(1,'shekar','reddy',1,1,10,'hyd','telanagana','true','2024-06-24','2023-07-10',20000),(2,'navin','kumar',2,2,20,'chennai','tamil nadu','false','2024-06-20','2023-07-10',80000);
select * from #testing_team;
----------------------------------------------------------------------------------------
create table ##testing_team(
emp_id int,
f_name varchar(10),
l_name varchar(10),
test_case_id int,
accuracy int,
points int,
city varchar(10),state varchar(10),
is_promoted bit,
year_of_joining date,
year_of_graduation date,
salary int)

insert into ##testing_team values(1,'shekar','reddy',1,1,10,'hyd','telanagana','true','2024-06-24','2023-07-10',20000),(2,'navin','kumar',2,2,20,'chennai','tamil nadu','false','2024-06-20','2023-07-10',80000);
select * from ##testing_team;
-------------------------------------------------------------------------

--view
--2 types
--updatable and non updatable
--1)updatable
select * from operations_team;
alter view v_operations_team as(
select * from operations_team) ;

select * from v_operations_team;

--update operation on updateable view 
update v_operations_team
set f_name='Rajashekar'
where emp_id=101;

---to see query inside the view
sp_helptext v_operations_team;

--2)non updation
alter view v_empavgsal as
(select city ,avg(salary)  as avgsal from operations_team group by city);

select * from v_empavgsal;

--update on non-updation view
update v_empavgsal
set avgsal=2000
where city='chennai';

----------------------------------------------------------------------------------------
create view v_opdev as
select o.emp_id,o.f_name,o.is_promoted,d.In_progress_tasks from operations_team as o join dev_team as d on o.emp_id=d.emp_id;

select * from v_opdev;

update v_opdev
set is_promoted='false' where emp_id=102;

select * from v_opdev;

update v_opdev
set f_name='shekar'
where emp_id=102;
------------------------------------------------------------------------------
alter view v_unopdev as
select o.city,avg(o.salary) as avg_sal,o.emp_id,o.f_name,
o.is_promoted,d.In_progress_tasks 
from operations_team 
as o join dev_team as d on o.emp_id=d.emp_id group by  o.city,o.emp_id,o.f_name,
o.is_promoted,d.In_progress_tasks ;

select * from v_unopdev;

update v_unopdev
set f_name='suresh'
where emp_id=105;



alter view v_dist as
select distinct(salary),emp_id from operations_team ;

select * from v_dist;

update v_dist
set salary=10000
where emp_id=104;
--------------------------------------------------------------------------------
--Indexes
select* from operations_team as o1 , operations_team as o2 where o1.salary=o2.salary and o1.city !=o2.city;

alter view v_sams as
select * from operations_team;

select * from v_sams;

------------------------------------------------------------
--Indexes
--use matrix for reteieve the data faster way

create table emp1
(emp_id int ,emp_name varchar(15),salary int,primary key(emp_id));

insert into emp1 values(90,'vijaya',90000),(21,'suman',89);
insert into emp1 values (10,'devara',89);

create clustered index idx_empsal on emp1(salary);


select * from emp1;

create unique clustered index idx_emp on emp1(emp_id);--unique clustered

create  nonclustered index idx_emp on emp1(salary);
create  unique nonclustered index idx_emp on emp1(emp_id);
------------------------------------------------------------------
select 
name as index_name,
type_desc as index_type,
is_unique
from sys.indexes
where object_id=OBJECT_ID('emp1');
--------------------------------------------------------
select 
name as index_name,
type_desc as index_type,
is_unique
from sys.indexes;
----------------------------------------------
--Triggers
create database assignment3;
use assignment3
create table emp1(
emp_id int primary key,
employee_name varchar(30),
department_id int,
salary decimal(10,2)
);
create table dept(
department_id int primary key,
department_name varchar(30));
 
create table employeeaudit(
auditid int primary key identity(1,1),
operation varchar(10),
employee_id int,
employee_name varchar(30),
department_id int,
salary decimal(10,2),
changedate datetime default getdate());
 
alter table employeeaudit
add complete_details nvarchar(1000)
 
insert into dept(department_id, department_name)
values
(1, 'hr'),
(2,'finance'),
(3,'IT'),
(4,'marketing');
 
--create trigger
 
CREATE TRIGGER trg_afterinsert_emp1
ON emp1
AFTER INSERT
AS
BEGIN
    INSERT INTO employeeaudit (operation, employee_id, employee_name, department_id, salary, complete_details)
    SELECT 'INSERT', emp_id, employee_name, department_id, salary,
           'insert operation happened on employees table with details ' +
           CAST(emp_id AS VARCHAR(20)) + ' ' + employee_name + ' ' +
           CAST(department_id AS VARCHAR(20)) + ' ' + CAST(salary AS VARCHAR(30))     
    FROM inserted;
END;
 
alter TRIGGER trg_afterinsert_emp1
ON emp1
AFTER INSERT
AS
BEGIN
    INSERT INTO employeeaudit (operation, employee_id, employee_name, department_id, salary, complete_details)
    SELECT 'INSERT', emp_id, employee_name, department_id, salary,
           'insert operation happened on employees table with details ' +
           CAST(emp_id AS VARCHAR(20)) + ' ' + employee_name + ' ' +
           CAST(department_id AS VARCHAR(20)) + ' ' + CAST(salary AS VARCHAR(30))+ 'on' + cast(getdate() as nvarchar(50))    
    FROM inserted;
END;
 
insert into emp1 (emp_id, employee_name, department_id, salary)
values
(1, 'vaishu', 2, '40000');
select * from employeeaudit
select * from emp1
--update trigger
CREATE TRIGGER trg_afterupdate_emp1
ON emp1
AFTER UPDATE
AS
BEGIN
    INSERT INTO employeeaudit (operation, employee_id, employee_name, department_id, salary, complete_details)
    SELECT 'UPDATE', emp_id, employee_name, department_id, salary,
           'update operation happened on employees table with details ' +
           CAST(emp_id AS VARCHAR(20)) + ' ' + employee_name + ' ' +
           CAST(department_id AS VARCHAR(20)) + ' ' + CAST(salary AS VARCHAR(30))     
    FROM inserted;
END;
update emp1
set salary=30000
where emp_id=1
 
select * from employeeaudit
select * from emp1
 
CREATE TRIGGER trg_afterdelete_emp1
ON emp1
AFTER DELETE
AS
BEGIN
    INSERT INTO employeeaudit (operation, employee_id, employee_name, department_id, salary, complete_details)
    SELECT 'DELETE', emp_id, employee_name, department_id, salary,
           'delete operation happened on employees table with details ' +
           CAST(emp_id AS VARCHAR(20)) + ' ' + employee_name + ' ' +
           CAST(department_id AS VARCHAR(20)) + ' ' + CAST(salary AS VARCHAR(30))+'on' + cast(getdate() as nvarchar(50))     
    FROM deleted;
END;
delete from emp1 where emp_id= 1
select * from employeeaudit
select * from emp1

------------------------------------------------------------------

create view employeedeptview as
select e.emp_id, e.employee_name, d.department_name, e.salary
from emp1 e
join dept d on e.department_id = d.department_id;

-----------------------------------------------------------------
create trigger trg_insteadofupdate_employeedeptview
on employeedeptview
instead of update
as
begin
declare @emp_id int, @employee_name nvarchar(100), @department_name nvarchar(50), @salary decimal(10,2), @completedeatils nvarchar(100);
declare @department_id int;
select @emp_id= emp_id, @employee_name= employee_name,@department_name = department_name,@department_id=department_id, @salary = salary
from inserted;
select @department_id = department_id from dept where department_name = @department_name;
update emp1
set employee_name = @employee_name,
department_id=@department_id, salary=@salary
where emp_id = @emp_id;
insert into employeeaudit(operation, employee_id, employee_name, department_id, salary, complete_details)
values('UPDATE', @emp_id, @employee_name, @department_id, @salary, @completedeatils);
end;

------------------------------------------------------------------------------------
update employeedeptview
set employee_name='Rajashekar',salary=56000
where emp_id=1;

select * from employeeaudit;
select * from emp1;
select * from employeedeptview;
--------------------------------------------------------------------------------
create TRIGGER trg_insteadofinsert_employeedeptview
ON employeedeptview
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @emp_id INT, @employee_name NVARCHAR(100), @department_name NVARCHAR(50), @salary DECIMAL(10,2);
    DECLARE @department_id INT;
 
    -- Fetch values from inserted table (virtual table)
    SELECT @emp_id = emp_id, @employee_name = employee_name, @department_name = department_name, @salary = CAST(salary AS DECIMAL(10,2))
    FROM inserted;
 
    -- Determine department_id based on department_name
    SELECT @department_id = department_id
    FROM dept
    WHERE department_name = @department_name;
 
    -- Insert into emp1 table
    INSERT INTO emp1 (emp_id, employee_name, department_id, salary)
    VALUES (@emp_id, @employee_name, @department_id, @salary);
 
    -- Insert into employeeaudit table
    INSERT INTO employeeaudit (operation, employee_id, employee_name, department_id, salary)
    VALUES ('insert', @emp_id, @employee_name, @department_id, @salary);
END;
 
 
insert into employeedeptview(emp_id,employee_name, department_name, salary)
values
(4, 'vaishnavi', 'hr', 60000)
 
select * from employeeaudit
select * from emp1
select * from employeedeptview
-----------------------------------------------------------
alter TRIGGER trg_insteadofdelete_employeedeptview
ON employeedeptview
INSTEAD OF delete
AS
BEGIN
    DECLARE @emp_id INT, @employee_name NVARCHAR(100), @department_name NVARCHAR(50), @salary DECIMAL(10,2);
    DECLARE @department_id INT;
 
    -- Fetch values from inserted table (virtual table)
    SELECT @emp_id = emp_id, @employee_name = employee_name, @department_name = department_name, @salary = CAST(salary AS DECIMAL(10,2))
    FROM deleted;
 
    -- Determine department_id based on department_name
    SELECT @department_id = department_id
    FROM dept
    WHERE department_name = @department_name;
 
    delete from emp1
	where emp_id = @emp_id
 
	delete from employeeaudit
	where employee_id = @emp_id
 
    -- Insert into employeeaudit table
    INSERT INTO employeeaudit (operation, employee_id, employee_name, department_id, salary)
    VALUES ('DELETE', @emp_id, @employee_name, @department_id, @salary);
END;
 
delete from employeedeptview
where emp_id = 1
 
select * from employeeaudit
select * from emp1
select * from employeedeptview
----------------------------------------------------------------------------------------------
CREATE TABLE salestable (
    salesid INT PRIMARY KEY,
    proid INT,
    proname VARCHAR(50),
    quantity INT,
    totalsalesvalue DECIMAL(10, 2)
);
 
INSERT INTO salestable (salesid, proid, proname, quantity, totalsalesvalue)
VALUES
    (1, 101, 'phone', 5, 250.00),
    (2, 102, 'laptop', 3, 180.50),
    (3, 103, 'smartwatch', 2, 90.00),
    (4, 104, 'earbuds', 7, 420.75),
    (5, 105, 'powerbank', 4, 200.40),
    (6, 106, 'earphones', 6, 360.60);
 
CREATE TABLE stock_details (
    proid INT PRIMARY KEY,
    proname VARCHAR(50),
    stockvalue int,
    in_stock INT
);
 
INSERT INTO stock_details (proid, proname, stockvalue, in_stock)
VALUES
	 (101, 'phone', 20,15),
    (102, 'laptop', 10,8),
    (103, 'smartwatch', 30,21),
    (104, 'earbuds', 53,14),
    (105, 'powerbank', 40,24),
    (106, 'earphones', 13,7);
 
CREATE TABLE productdetails (
    proid INT PRIMARY KEY,
    proname VARCHAR(50),
    price DECIMAL(10, 2)
);
 
INSERT INTO productdetails (proid, proname, price)
VALUES
    (101, 'phone', 49.99),
    (102, 'laptop', 29.95),
    (103, 'smartwatch', 79.50),
    (104, 'earbuds', 99.00),
    (105, 'powerbank', 149.99),
    (106, 'earphones', 199.50);
 
CREATE TABLE audittable (
    auditid INT PRIMARY KEY identity(1,1),
    operation VARCHAR(50),
    complete_details NVARCHAR(MAX)
);
 
--create triggers as a new sales happens update audit table with complete sale details and also update the stock table

alter trigger trg_updatesalesdetail
on salestable
after insert
as
begin
	insert into audittable(operation,complete_details)
	select 'insert',concat(cast(salesid as varchar(20)),cast(proid as varchar(20)),proname ,
	                       cast(quantity as varchar(20)),cast(totalsalesvalue as varchar(20))) as insertedval
	from inserted;
	end;
 
insert into salestable values (8,'102','phone',5,100.05);
select * from salestable
select * from audittable
select * from stock_details
 
create view v_salesstock as
select sa.salesid,sa.proid,sa.proname,st.stockvalue,st.in_stock
from salestable sa join stock_details st
on sa.proid=st.proid;
 
CREATE trigger trg_updatesalesdetails
on salestable
after insert
as
begin
declare @quantity int,@product_id int
	insert into audittable(operation,complete_details)
	select 'insert',concat(cast(salesid as varchar(20)),cast(proid as varchar(20)),proname ,
	                       cast(quantity as varchar(20)),cast(totalsalesvalue as varchar(20))) as insertedval
	from inserted
	select @product_id=proid,@quantity=quantity from inserted
	update stock_details
	set stockvalue=stockvalue-@quantity ,in_stock= case when stockvalue-@quantity > 0 then 1 else 0 end
	where proid=@product_id;
	end;

	insert into salestable values(11,106,'earphones',7,200);
 
select * from productdetails

	-------------------------------------
	
	---try-catch
	begin try
	insert into emp1 values(1,'Rajesh',6,50000);
	print 'insert succeeded';
	end try
	begin catch
	print 'error occured during insert :'+error_message();
	end catch;
	--------------------------------------------------------------
	---ERROR HANDLING AND TRANSCATION
	begin try
		begin transaction;
		insert into emp1 values(1,'Rajesh',6,50000);
		COMMIT TRANSACTION;
		print 'insert succeeded';
	end try

	begin catch
		ROLLBACK TRANSACTION;
		print 'error occured during insert :'+error_message();
	end catch;
	-----------------------------------------------------------------
	begin try
		begin transaction;
		UPDATE EMP1 SET DEPARTMENT_ID=10 WHERE EMP_ID=1
		COMMIT TRANSACTION;
		print 'UPDATE succeeded';
	end try

	begin catch
		ROLLBACK TRANSACTION;
		print 'error occured during insert :'+error_message();
	end catch;
	-----------------------------------------------------------------------
	SELECT * FROM EMP1

	SELECT EMP_ID,EMPLOYEE_NAME,DEPARTMENT_ID,ISNULL(SALARY,0) FROM EMP1;

    SELECT EMP_ID,EMPLOYEE_NAME,DEPARTMENT_ID,COALESCE(SALARY,0) FROM EMP1;

	-----------------------------------------------------------------------

	---DUPLICATES RECORDS

	SELECT EMPLOYEE_NAME,COUNT(*)AS COUNT
	FROM emp1
	GROUP BY EMPLOYEE_NAME
	HAVING COUNT(*)>1;


	SELECT EMPLOYEE_NAME,COUNT(*)AS COUNT
	FROM emp1
	GROUP BY EMPLOYEE_NAME;

	--------------------------------------------------------------------------
	---DELETE DUPLICATE RECORDS

	WITH CTE AS(
	SELECT *,
			ROW_NUMBER() OVER (PARTITION BY EMPLOYEE_NAME ORDER BY SALARY)
			AS ROW_NUM
		FROM EMP1
		)
		DELETE FROM CTE
		WHERE ROW_NUM>1;

	------------------------------------------------------------------------

		---SYNONYMNS
		CREATE SYNONYM EMPLOYEESYN FOR DBO.EMP1;

		SELECT EMP_ID,EMPLOYEE_NAME,DEPARTMENT_iD,SALARY FROM EMPLOYEESYN;

		-------------------------------------------------------------------
		--SEQUENCES

		CREATE SEQUENCE EMPLOYEEiDSEQ1
		START WITH 10
		INCREMENT BY 1;

		INSERT INTO EMP1 
		VALUES
		(NEXT VALUE FOR EMPLOYEEiDSEQ1,'SUNIL GUPTA',2,60000),
		(NEXT VALUE FOR EMPLOYEEiDSEQ1,'RINA SINGH',3,72000);

		SELECT * FROM EMP1;
		--------------------------------------------------------------------
		SELECT * FROM AUDITTABLE;
		SELECT * FROM EMPLOYEE


		----------------------------------------------------------------------------------
		create table emp2(empid int,ename varchar(10),mid int);
		insert into emp2 values(1,'a',3),(2,'b',4),(3,'c',1),(4,'d',2);

		select * from emp2
		select e.ename, e1.ename
		from emp2 e join emp2 e1
		on e.mid=e1.empid;
