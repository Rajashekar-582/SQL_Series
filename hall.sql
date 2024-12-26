use hall
create table college
(collegeid int primary key not null identity(1,1),
collegecode varchar(10)
)


insert into college values ('TR'),('N0'),('TK'),('ND');

create table department
(
deptid int primary key not null identity(1,1),
deptname varchar(5)
)

insert into department values ('civil'),('eee'),('mech'),('ece'),('cse');

create table course
(
courseid int primary key not null identity(1,1),
course_code varchar(3),
course_name varchar(10)
)

insert into course values('A','B.tech'),('B','B.pharm'),('C','M.tech')

create table scholar
(scholarid int primary key not null identity(1,1),
scholar_code varchar(2),
scholar_type varchar(10)
)

insert into scholar values ('5','day'),('1','lateral')


create table years
(year_id int primary key identity(1,1),
years int
)

insert into years values (2019),(2020),(2021),(2022),(2023),(2024)

CREATE TABLE student
(
    studentid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    student_name VARCHAR(25),
    deptname varchar(10),
    collegeid INT,
    coursename varchar(10),
    scholar_type varchar(10),
    year_id int,
    hallticket_no NVARCHAR(50),
    FOREIGN KEY (collegeid) REFERENCES college(collegeid),
	foreign key(year_id) references years(year_id)

);



create table fact
(
fact_id int primary key identity(1,1),
deptid int,
collegeid int,
courseid int,
scholarid int,
years int,
foreign key(deptid) references department(deptid),
foreign key(collegeid) references college(collegeid),
foreign key(courseid) references course(courseid),
)


drop proc hall
exec hall
create proc Hall
as
begin 

declare @stdid int,@deptid int,@deptname varchar(5);
declare @collegeid int,@collegecode varchar(5),@courseid int,@coursecode varchar(5),@coursename varchar(10),
@scholar_code int,@scholartype varchar(5),@year int, @scholarid int,@yearid int;

select @stdid=studentid,@deptname=deptname,@collegeid=collegeid,@coursename=coursename,@scholartype=scholar_type,@yearid=year_id from student

select @year=years from years where year_id=@yearid;
select @deptid=deptid from department where deptname=@deptname;

select @collegecode=collegecode from college where collegeid=@collegeid;

select @coursecode=course_code,@courseid=courseid from course where course_name=@coursename;

select @scholarid=scholarid, @scholar_code=scholar_code from scholar where scholar_type=@scholartype;

with cte as (
        select
            studentid,
            ROW_NUMBER() OVER (PARTITION BY deptname,collegeid,year_id,coursename,scholar_type ORDER BY studentid) AS row_num
        from student
    )
    UPDATE r
    SET hallticket_no = CONCAT(
        right(@year,2),
        @collegecode,
        @scholar_code,
        @coursecode,
 RIGHT('00' + CAST(@deptid AS
		VARCHAR(2)), 2),
		RIGHT('00' + CAST(c.row_num AS
		VARCHAR(2)), 2)
    )
    from student r
    join CTE c on r.studentid = c.studentid
    where r.studentid = @stdid;

	insert into fact values(@deptid,@collegeid,@courseid,@scholar_code,@year)

	end;

	insert into student values('Raju','cse',1,'b.tech','day',1,null)
exec hall



---------------------------------------------------------------------------------------

insert into student values('sumanth','ece',2,'b.pharm','lateral',2,null)
exec hall




select * from student
select * from fact
select * from course
select * from college
select * from department
select * from scholar
select * from years




select scholarid,scholar_code from scholar where scholar_type='lateral'

select right(years,2)as code from years
---------------------------------------------------------------------------------------------------------

-- Create and populate tables
CREATE TABLE college (
    collegeid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    collegecode VARCHAR(10)
);

INSERT INTO college VALUES ('TR'), ('N0'), ('TK'), ('ND');

CREATE TABLE department (
    deptid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    deptname VARCHAR(5)
);

INSERT INTO department VALUES ('civil'), ('eee'), ('mech'), ('ece'), ('cse');

CREATE TABLE course (
    courseid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    course_code VARCHAR(3),
    course_name VARCHAR(10)
);

INSERT INTO course VALUES ('A', 'B.tech'), ('B', 'B.pharm'), ('C', 'M.tech');

CREATE TABLE scholar (
    scholarid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    scholar_code VARCHAR(2),
    scholar_type VARCHAR(10)
);

INSERT INTO scholar VALUES ('1', 'day'), ('5', 'lateral');

CREATE TABLE years (
    year_id INT PRIMARY KEY IDENTITY(1,1),
    years INT
);

INSERT INTO years VALUES (2019), (2020), (2021), (2022), (2023), (2024);

CREATE TABLE student (
    studentid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    student_name VARCHAR(25),
    deptname VARCHAR(10),
    collegeid INT,
    coursename VARCHAR(10),
    scholar_type VARCHAR(10),
    year_id INT,
    hallticket_no NVARCHAR(50),
   
);

CREATE TABLE fact (
    fact_id INT PRIMARY KEY IDENTITY(1,1),
    deptid INT,
    collegeid INT,
    courseid INT,
    scholarid INT,
	year_id int,
    years INT,
	studentid int,
	Foreign key(studentid) references student(studentid),
    FOREIGN KEY (deptid) REFERENCES department(deptid),
    FOREIGN KEY (collegeid) REFERENCES college(collegeid),
    FOREIGN KEY (courseid) REFERENCES course(courseid),
	 FOREIGN KEY (collegeid) REFERENCES college(collegeid),
    FOREIGN KEY (year_id) REFERENCES years(year_id)
);

-- Drop and create stored procedure
DROP PROCEDURE IF EXISTS Hall;
GO

CREATE PROCEDURE Hall
AS
BEGIN
    DECLARE @stdid INT, @deptid INT, @deptname VARCHAR(5);
    DECLARE @collegeid INT, @collegecode VARCHAR(5), @courseid INT, @coursecode VARCHAR(5), @coursename VARCHAR(10);
    DECLARE @scholar_code INT, @scholartype VARCHAR(5), @year INT, @scholarid INT, @yearid INT;

    SELECT @stdid = studentid, @deptname = deptname, @collegeid = collegeid, @coursename = coursename, @yearid = year_id
    FROM student;

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
VALUES ('suman', 'ece', 2, 'b.pharm', 'day', 2, NULL);

EXEC Hall;

INSERT INTO student (student_name, deptname, collegeid, coursename, scholar_type, year_id, hallticket_no)
VALUES ('Ram', 'cse', 3,'b.tech', 'lateral', 4, NULL);

exec hall;

select *  from student
select * from fact
select * from scholar
select * from course
select * from college
select * from department
select * from years

-----------------------------------------------------------------------------------------------------------






