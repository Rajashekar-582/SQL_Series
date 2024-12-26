use practice
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

CREATE TABLE fact_student_registration
(
    studentid INT,
    college_code VARCHAR(5),
    course_code VARCHAR(5),
    dept_code VARCHAR(3),
    scholar_code INT,
    year_of_joining DATE,
    hallticket_no NVARCHAR(50),
    PRIMARY KEY (studentid),
    FOREIGN KEY (college_code) REFERENCES register(college_code),
    FOREIGN KEY (course_code) REFERENCES register(course_code),
    FOREIGN KEY (dept_code) REFERENCES department(dept_code),
    FOREIGN KEY (scholar_code) REFERENCES scholar(scholar_code)
);


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
insert into register (college_code,student_name,dept_name,scholar_type,year_of_joining)
values('N0','ram','ece','lateral','09-09-2024')

select * from register order by hallticket_no ;

select * from register
select * from scholar
select * from department

select * from register where student_name like 'v%'


CREATE PROCEDURE sp_generate_hallticket
AS
BEGIN
    DECLARE @stdid INT;
    DECLARE @scholar VARCHAR(10);
    DECLARE @dept VARCHAR(5);

    -- Get the inserted values
    SELECT @stdid = studentid, @scholar = scholar_type, @dept = dept_name FROM inserted;

    DECLARE @dept_code VARCHAR(2);
    SELECT @dept_code = dept_code FROM department WHERE dept_name = @dept;

    DECLARE @scholar_code INT;
    SELECT @scholar_code = scholar_code FROM scholar WHERE scholar_type = @scholar;

    WITH cte AS (
        SELECT
            studentid,
            ROW_NUMBER() OVER (PARTITION BY dept_name, YEAR(year_of_joining) ORDER BY studentid) AS row_num
        FROM register
    )
    UPDATE r
    SET hallticket_no = CONCAT(
        FORMAT(DATEADD(YEAR, 0, r.year_of_joining), 'yy'),
        r.college_code,
        @scholar_code,
        r.course_code,
        @dept_code,
        RIGHT('00' + CAST(c.row_num AS VARCHAR(2)), 2)
    )
    FROM register r
    JOIN cte c ON r.studentid = c.studentid
    WHERE r.studentid = @stdid;
END;



alter proc Hallticketno
as
begin
declare @stdid int;
declare @scholar varchar(10);
declare @dept varchar(5);

select @stdid = studentid,@scholar=scholar_type,@dept=dept_name from register;

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

exec Hallticketno;

select * from register

insert into register (student_name,dept_name,scholar_type,year_of_joining)
values('shekar','ece','day','09-09-2019'),('shekar','ece','day','09-09-2019'),('shekar','ece','day','09-09-2019')
--------------------------------------------------------------------------------------------------------
DECLARE @student_name VARCHAR(25);
DECLARE @dept_name VARCHAR(5);
DECLARE @scholar_type VARCHAR(10);
DECLARE @year_of_joining DATE;

-- Declare a cursor
DECLARE insert_cursor CURSOR FOR
SELECT 'shekar', 'ece', 'day', '2019-09-09'
UNION ALL
SELECT 'shekar', 'ece', 'day', '2019-09-09'
UNION ALL
SELECT 'shekar', 'ece', 'day', '2019-09-09';

-- Open the cursor
OPEN insert_cursor;

-- Fetch the first row
FETCH NEXT FROM insert_cursor INTO @student_name, @dept_name, @scholar_type, @year_of_joining;

-- Loop through the cursor and insert each row
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO register (student_name, dept_name, scholar_type, year_of_joining)
    VALUES (@student_name, @dept_name, @scholar_type, @year_of_joining);

    -- Fetch the next row
    FETCH NEXT FROM insert_cursor INTO @student_name, @dept_name, @scholar_type, @year_of_joining;
END;

-- Close and deallocate the cursor
CLOSE insert_cursor;
DEALLOCATE insert_cursor;
------------------------------------------------------------------------------------------------------------



create 