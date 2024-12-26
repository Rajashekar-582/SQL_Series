create database facts_dimensions
use facts_dimensions

create table employee
(
empid int,
first_name nvarchar(25),
last_name nvarchar(25),
salary int,
department nvarchar(25)
);


INSERT INTO Employee (EmpID, First_Name, Last_Name, Salary, Department) VALUES
(1, 'John', 'Doe', 50000, 'HR'),
(2, 'Jane', 'Smith', 60000, 'Finance'),
(3, 'Michael', 'Johnson', 55000, 'IT'),
(4, 'Emily', 'Davis', 62000, 'Marketing'),
(5, 'James', 'Brown', 58000, 'Sales'),
(6, 'Mary', 'Wilson', 62000, 'IT'),
(7, 'Robert', 'Jones', 53000, 'HR'),
(8, 'Linda', 'Garcia', 70000, 'Finance'),
(9, 'David', 'Martinez', 48000, 'Sales'),
(10, 'Susan', 'Anderson', 61000, 'Marketing');



create table salary 
(
changeid int,
oldsalary int,
newsalary int
)
/*Employee: Empid, First Name, Last Name, Salary, Department
Salary: Changeid, Old salary, New salary*/

--1. Create a stored procedure named Employee_Details that returns all columns from the Employees table.
 
 create proc spEmployee_Details
 as
 begin
 select empid,first_name,last_name,salary,department from employee;
 end


 exec spEmployee_Details


--2. Start a transaction and update the salary of employee with ID 1 to 10. Insert a record into the Salary Changes table with the old and new salaries. Finally, commit the transaction.
 
 declare @id int;
 set @id=1;
 declare @old int,@new int;
 set @new=1000;

 while(@id<=10)
 begin
 select @old=salary from employee where empid=@id;

 update employee set salary=@new where empid=@id;

 insert into salary values (@id,@old,@new);

 set @id=@id+1;
 set @new=@new+500;
 end



 select * from employee
 select * from salary



--3. Write a query to Using a window function, rank employees based on their salary in descending order.
 
 select *,row_number()over(order by salary desc)as r from employee


--4. Write a query to Calculate the running total of salaries for all employees.
 
 select *,sum(salary)over(order by empid)as running_sum from employee

--5. Using a cursor, display each employee s full name (concatenating first name and last name) and their salary.
 

 DECLARE @FullName VARCHAR(100);
DECLARE @Salary DECIMAL(10, 2);

DECLARE EmployeeCursor CURSOR FOR
SELECT First_Name + ' ' + Last_Name AS FullName, Salary
FROM Employee;

OPEN EmployeeCursor;

FETCH NEXT FROM EmployeeCursor INTO @FullName, @Salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Employee: ' + @FullName + ', Salary: ' + CAST(@Salary AS VARCHAR);
    FETCH NEXT FROM EmployeeCursor INTO @FullName, @Salary;
END

CLOSE EmployeeCursor;
DEALLOCATE EmployeeCursor;



--6. Create a stored procedure named Insert _Employee to insert records into the Employees table.
 
 create proc spInsert_Employee
  @EmpID INT,
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Salary DECIMAL(10, 2),
    @Department VARCHAR(50)
	as
	begin
	insert into employee values (@empid,@FirstName,@LastName,@Salary,@Department);
	end


	exec spInsert_Employee 11,'Raja','shekar',5000,'Data Engineer'

	select * from employee

--7. Write a Query to Implement error handling to handle if any duplicate entry errors.
 
 begin try
 insert into employee values(12,'Ravi','kumar',4500,'Full stack')
 end try
 begin catch
 print('Error during inserting');
 end catch

 select * from employee



--8. Start a transaction. Within this transaction, insert a new record into the Employees table and then update the salary of the employee with ID 2. Commit to the changes if successful, otherwise, rollback the entire transaction.
 
 begin transaction
 begin try 
 insert into employee values(13,'Rohit','Sharma',4500,'Mumbai');
 
 update employee set salary=2000 where empid=2;
 end try

 begin catch
 rollback transaction
 end catch
 commit transaction

 select * from employee


--9. Create a stored procedure named Update_Employee_Salary to update the salary of an employee. Use TRY...CATCH block to handle any errors that may occur during the update.
 

 create proc spUpdate_Employee_Salary
 @id int,
 @salary int
 as
 begin
	 begin try
		update employee set salary=@salary where empid=@id;
	 end try
	 begin catch
		 print('Error during yhe updation');
	 end catch
 end

 exec spUpdate_Employee_Salary 1,5000

 select * from employee


 
--10. How to calculate the average salary of employees, partitioned by their departments.

select *,avg(salary)over(partition by department)as avg_salary from employee


----------------------------------------------------------------------------------------------
/*Tables Information:
1. STU.Student_Table--- stu_id, stu_name, dob, doj (date of Joining)
2. STU.Student_Class---stu_id, class, section, rollnumber
3. STU.Subject_Table ----sub_id, sub_name
4. STU.Student_Marks --- marks_id, sub_id, marks, examdate
5. ADM.Department--- dept_id, dept_name
6. ADM.Employee ---- emp_id, emp_name
*/

create table studenttable 
(
stu_id int,
stu_name nvarchar(25),
dob date,
doj date,
primary key(stu_id)
)
create table studentclass
(
stu_id int,
class nvarchar(25),
section char(2),
rollnumber nvarchar(25)
)

create table subject_table
(
sub_id int,
sub_name nvarchar(25)
)

create table student_marks
(
stu_id int,
marks_id int,
sub_id int,
marks int,
examdate date,
foreign key (stu_id) references studenttable(stu_id)
)
 
 create table adm_department
 (
 dept_id int,
 dept_name nvarchar(25),
 primary key(dept_id)
 )

 create table adm_employee
 (
 emp_id int,
 emp_name nvarchar(25),
 dept_id int,
 primary key(emp_id),
 foreign key(dept_id) references adm_department(dept_id)
 )

 drop table adm_department
 drop table adm_employee


 -- Insert records into studenttable
INSERT INTO studenttable (stu_id, stu_name, dob, doj) VALUES
(1, 'Alice Johnson', '2005-01-15', '2021-09-01'),
(2, 'Bob Smith', '2006-02-20', '2021-09-01'),
(3, 'Charlie Brown', '2005-03-05', '2021-09-01'),
(4, 'Daisy White', '2004-04-10', '2021-09-01'),
(5, 'Ethan Green', '2006-05-25', '2021-09-01');

-- Insert records into studentclass
INSERT INTO studentclass (stu_id, class, section, rollnumber) VALUES
(1, '10th Grade', 'A1', '001'),
(2, '10th Grade', 'A1', '002'),
(3, '10th Grade', 'A1', '003'),
(4, '10th Grade', 'A1', '004'),
(5, '10th Grade', 'A1', '005');

-- Insert records into subject_table
INSERT INTO subject_table (sub_id, sub_name) VALUES
(1, 'Mathematics'),
(2, 'Science'),
(3, 'English'),
(4, 'History'),
(5, 'Geography');

-- Insert records into student_marks
INSERT INTO student_marks (marks_id, sub_id, marks, examdate,stu_id) VALUES
(1, 1, 85, '2023-05-01',5),
(2, 2, 90, '2023-05-01',4),
(3, 3, 78, '2023-05-01',3),
(4, 4, 88, '2023-05-01',2),
(5, 5, 92, '2023-05-01',1);

-- Insert records into adm_department
INSERT INTO adm_department (dept_id, dept_name) VALUES
(1, 'Administration'),
(2, 'Teaching'),
(3, 'Sports'),
(4, 'Counseling'),
(5, 'Maintenance');

-- Insert records into adm_employee
INSERT INTO adm_employee (emp_id, emp_name,dept_id) VALUES
(1, 'John Doe',5),
(2, 'Jane Smith',4),
(3, 'Michael Brown',3),
(4, 'Emily Davis',2),
(5, 'David Wilson',1);


select * from studenttable
select * from studentclass
select * from student_marks
select * from adm_employee
select * from adm_department
select * from subject_table
--Triggers:
/*1. Create a trigger to Ensure that a students date of birth (dob)
is not after their date of joining (doj) and when Automatically assign a new student to a default class
and section when they are added to the Student_Table*/

CREATE TRIGGER trg_Student_Insert
ON studenttable
AFTER INSERT
AS
BEGIN
    -- Check DOB is not after DOJ
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE dob > doj
    )
    BEGIN
        RAISERROR('Date of Birth cannot be after Date of Joining.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Automatically assign a new student to a default class and section
    DECLARE @stu_id INT;
    DECLARE @default_class NVARCHAR(25) = 'Default Class';
    DECLARE @default_section CHAR(2) = 'A1';

    DECLARE student_cursor CURSOR FOR
    SELECT stu_id FROM inserted;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @stu_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Insert into studentclass for the new student
        INSERT INTO studentclass (stu_id, class, section, rollnumber)
        VALUES (@stu_id, @default_class, @default_section, CAST(@stu_id AS NVARCHAR(25)));

        FETCH NEXT FROM student_cursor INTO @stu_id;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END;

insert into studenttable values (6,'Raja shekar','2000-06-06','2024-11-28');

 
 select * from studenttable
 select * from studentclass

/*2. Create a trigger When a new student is added to the STU.Student_Class table,
a trigger should automatically assign a unique roll number to the student 
based on the stu_id and the current class.*/

CREATE TRIGGER trg_student_rollnumber
ON studentclass
AFTER INSERT
AS
BEGIN
    DECLARE @stu_id INT;
    DECLARE @class NVARCHAR(25);
    DECLARE @new_rollnumber NVARCHAR(25);

    DECLARE student_cursor CURSOR FOR
    SELECT stu_id, class FROM inserted;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @stu_id, @class;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generate a unique roll number based on stu_id and class
        SET @new_rollnumber = CONCAT(@class, '-', @stu_id);

        -- Update the rollnumber in the studentclass table
        UPDATE studentclass
        SET rollnumber = @new_rollnumber
        WHERE stu_id = @stu_id AND class = @class;

        FETCH NEXT FROM student_cursor INTO @stu_id, @class;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END;

INSERT INTO studentclass (stu_id, class, section) VALUES (7, '10th Grade', 'A1');

select * from studenttable
select * from studentclass
 
/*3. Create a trigger when a new student is added to the STU.Student_Table, 
a trigger should check if the students age is above a certain threshold (e.g., 5 years old).
If not, the insertion should be rejected.Update Employees Department When Department is Renamed
*/
create trigger trg_student2
on studenttable
instead of insert
as
begin
	declare @age int;
	declare @stdid int,@sname nvarchar(25),@dob date,@doj date;
	select @stdid=stu_id,@sname=stu_name,@dob=dob,@doj=doj,@age=year(getdate())-year(dob) from inserted;

	if @age>5
	begin
		insert into studenttable values (@stdid,@sname,@dob,@doj);

		
	end
end

insert into studenttable values (7,'Rohit sharma','2000-06-06','2024-11-29')

select * from studenttable
select * from studentclass




 /*
Transactions:
4. What is SQL Transaction and why it is use?
*/

 
/*5. Create a Transaction for Calculating the total average marks for each subject and each student
for a period of two years from the date of joining (DOJ)*/


select * from studenttable s
join student_marks m on s.stu_id=m.stu_id

begin transaction
 begin try 

 -----------------------------------------------------------------------------------------------------

 ---practice
create table sales (
product_id int,
period_start date,
period_end date,
average_daily_sales int
);
 
insert into sales values
(1,'2019-01-25','2019-02-28',100),
(2,'2018-12-01','2020-01-01',10),
(3,'2019-12-01','2020-01-31',1);

select * from sales

select *,(datediff(day,period_start,period_end)+1)as days,
(datediff(day,period_start,period_end)+1)*average_daily_sales as sales_done,
datediff(month,period_start,period_end)as months from sales;


DECLARE @strt DATE = '2019-01-01';
DECLARE @end DATE = '2021-01-15';

select  datediff(year,@strt,EOMONTH()+1 as years




DECLARE @strt DATE = '2019-12-12';
declare @crt date=@strt;

while(year(@strt)=year(@crt))
begin
	declare @end date=eomonth(@crt);
	if month(@crt)=12
		begin
			print(eomonth(@crt))
		end
	set @crt=dateadd(day,1,@end);
end



DECLARE @strt DATE = '2019-01-01';
declare @end date ='2021-01-15';
DECLARE @crt DATE = @strt;

while(year(@end)=year(@crt))
begin
	declare @end1 date=eomonth(@crt);
	if month(@crt)=12
		begin
			declare @p1 date =eomonth(@crt);
			print(concat(year(@strt),'->',datediff(day,@strt,@p1)+1))
		end
	set @crt=dateadd(day,1,@end1);
end

DECLARE @lastDayOfYear DATE = DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, @crt) + 1, 0));

PRINT CAST(@lastDayOfYear AS VARCHAR(10));
	
	





----------------------------------------------------------------------------------------------------
DECLARE @strt DATE = '2019-01-01';
DECLARE @end DATE = '2022-01-15';

WITH YearlyDays AS (
    -- Calculate days for the first year
    SELECT 
        YEAR(@strt) AS Year,
        DATEDIFF(DAY, @strt, DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, @strt) + 1, 0))) + 1 AS DaysInYear

    UNION ALL

    -- Calculate for the full years in between
    SELECT 
        YEAR(DATEADD(YEAR, number, @strt)) AS Year,
        CASE 
            WHEN (YEAR(DATEADD(YEAR, number, @strt)) % 4 = 0 AND 
                  (YEAR(DATEADD(YEAR, number, @strt)) % 100 != 0 OR 
                   YEAR(DATEADD(YEAR, number, @strt)) % 400 = 0)) 
            THEN 366 
            ELSE 365 
        END AS DaysInYear
    FROM master..spt_values
    WHERE type = 'P' AND number BETWEEN 1 AND DATEDIFF(YEAR, @strt, @end) - 1

    UNION ALL

    -- Calculate days for the last year
    SELECT 
        YEAR(@end) AS Year,
        DATEDIFF(DAY, DATEFROMPARTS(YEAR(@end), 1, 1), @end) + 1 AS DaysInYear
)

SELECT 
    Year, 
    SUM(DaysInYear) AS TotalDays
FROM 
    YearlyDays
GROUP BY 
    Year
ORDER BY 
    Year;

--------------------------------------------------------------------------------------------------

with cte as(
select cast('2018-01-01' as date) as dateCol
union all
select cast(DATEADD(day,1,dateCol)  as date) as dateCol from cte
where dateCol<= GETDATE() --'2021-01-01'
)
select * 
into #calender
from cte
OPTION (MAXRECURSION 0);
 
select s.product_id, year(dateCol) year, sum(average_daily_sales) as totalSales
from sales s
join #calender c on c.dateCol between s.period_start and s.period_end
group by product_id, year(dateCol)
order by product_id, year(dateCol);