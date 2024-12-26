create database uni
use uni

create table college
(
collegeid int identity(1,1) primary key,
college_code varchar(2)  not null,
college_name varchar(30)
)
insert into college values('TR','SCITS')

create table course
(
courseid int identity(1,1) primary key,
course_code varchar(2) not null,
course_name nvarchar(10)
)

insert into course values('A','b.tech')

create table dept
(dept_id int identity(1,1) primary key,
dept_name varchar(5) ,
)
insert into dept values ('civil'),('eee'),('mech'),('ece'),('cse')

create table years
(
year_id int identity(1,1) primary key,
years int
)

insert into years values(2019)

CREATE TABLE scholar (
    scholarid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    scholar_code VARCHAR(2),
    scholar_type VARCHAR(10)
);

INSERT INTO scholar VALUES ('1', 'day'), ('5', 'lateral');

select * from college
select * from course
select * from dept
select * from scholar
select * from years



create table student
(
studentid int identity(1,1) primary key,
 deptid int,
    collegeid INT,

    courseid int,
    scholar_id int,
    year_id INT,
    hallticket_no NVARCHAR(50),
	deptname varchar(10),
	section varchar(2),
	subject1 int,
	subject2 int,
	status nvarchar(10),
	foreign key (deptid) references dept(dept_id),
	foreign key (collegeid)references college(collegeid),
	foreign key (courseid) references course(courseid),
	foreign key (scholar_id)references scholar(scholarid),
	foreign key (year_id) references years(year_id)
	)

	

select * from student
drop table student

drop proc if exists hall;
go
create proc Hall
as
begin
    declare @deptid int, @deptname varchar(5);
    declare @collegeid int = 1, @collegecode varchar(5), @courseid int = 1, @coursecode varchar(5);
    declare @scholar_code varchar(2), @year int, @scholarid int = 1, @yearid int = 1, @hallticket_no varchar(25);
    declare @i int,@sec varchar(5),@mark1 int,@mark2 int,@status varchar(4);

    declare dept_cursor cursor for
    select dept_id, dept_name from dept;

    open dept_cursor;
    fetch next from dept_cursor into @deptid, @deptname;

    while @@FETCH_STATUS = 0
    begin
        set @i = 1;
        while @i <= 120
        begin
            select @year = years from years where year_id = @yearid;
            SELECT @collegecode = college_code FROM college WHERE collegeid = @collegeid;
            SELECT @coursecode = course_code FROM course WHERE courseid = @courseid;
            SELECT @scholar_code = scholar_code FROM scholar WHERE scholarid = @scholarid;
			if @i>60
			begin
			set @sec='B'
			end
			else
			begin 
			set @sec='A'
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

		    set @mark1 = CAST(RAND() * 100 AS INT);  -- Marks between 0 and 100
			set @mark2=cast(rand()*100 as int);

			if @mark1>=40
				begin
					if @mark2>=40
					begin
						set @status='PASS';
					end
					else
					begin
						set @status='FAIL';
					end
				end
			else
				begin
					set @status='FAIL';
				end

insert into student (deptid, collegeid, courseid, scholar_id, year_id, hallticket_no, deptname, section, subject1, subject2, status)
   values (@deptid, @collegeid, @courseid, @scholarid, @yearid, @hallticket_no, @deptname, @sec, @mark1, @mark2, @status);

            set @i = @i + 1;
        end
        fetch next from dept_cursor into @deptid, @deptname;
    END

    close dept_cursor;
    deallocate dept_cursor;
END;
GO

exec hall
select * from student
	

	select * from student where deptname='cse' and status='Pass'

	drop table student