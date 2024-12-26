create database result
use result

CREATE TABLE college (
    collegeid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    collegecode VARCHAR(10)
);

INSERT INTO college VALUES ('TR'), ('N0'), ('TK'), ('ND');

CREATE TABLE department (
    deptid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    deptname VARCHAR(5) not null
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


create table semester
(
semesterid int identity(1,1) primary key,
semester varchar(15)
)

insert into semester values('semester-1'),('semester-2'),('semester-3'),('semester-4');

CREATE TABLE subject (
    subject_id INT PRIMARY KEY IDENTITY(1,1),
    subject_name VARCHAR(50),
    deptid INT,
    courseid INT,
    semesterid INT,
    FOREIGN KEY (deptid) REFERENCES department(deptid),
    FOREIGN KEY (semesterid) REFERENCES semester(semesterid)
);


INSERT INTO subject (subject_name, deptid, courseid, semesterid)
VALUES
    ('Engineering Mathematics I', 1, 1, 1),  -- Civil, B.Tech, Semester 1
    ('Mechanics of Materials', 1, 1, 1),     -- Civil, B.Tech, Semester 2
    ('Electrical Circuits', 2, 1, 1),        -- EEE, B.Tech, Semester 1
    ('Power Systems', 2, 1, 1),              -- EEE, B.Tech, Semester 2
    ('Thermodynamics', 3, 1, 1),             -- Mechanical, B.Tech, Semester 1
    ('Fluid Mechanics', 3, 1, 1),            -- Mechanical, B.Tech, Semester 2
    ('Analog Electronics', 4, 1, 1),         -- ECE, B.Tech, Semester 1
    ('Digital Systems', 4, 1, 1),            -- ECE, B.Tech, Semester 2
    ('Programming Fundamentals', 5, 1, 1),   -- CSE, B.Tech, Semester 1
    ('Data Structures', 5, 1, 1);           -- CSE, B.Tech, Semester 2
	
	create table student
(
studentid int identity(1,1) primary key,
 deptid int,
    collegeid INT,
	student_name varchar(25),
    courseid int,
    scholar_id int,
    year_id INT,
    hallticket_no NVARCHAR(50),
	deptname varchar(10),
	section varchar(2),
	semesterid int default 1,
	status nvarchar(15) default 'in-progress',
	foreign key (deptid) references department(deptid),
	foreign key (collegeid)references college(collegeid),
	foreign key (courseid) references course(courseid),
	foreign key (scholar_id)references scholar(scholarid),
	foreign key (year_id) references years(year_id),
	foreign key (semesterid) references semester(semesterid)
	)

	create table marks(
	mark_id int not null primary key identity(1,1),
	studentid int,
	Hallticket_no varchar(15),
	subject_id1 int,
	marks1 int,
	subject_id2 int,
	marks2 int,
	semester int,
	passFailStatus nvarchar(10),
    foreign key (studentid) references student(studentid),
	foreign key (subject_id1) references subject(subject_id),
	foreign key(subject_id2) references subject(subject_id)
);

CREATE TABLE fact (
    fact_id INT PRIMARY KEY IDENTITY(1,1),
    deptid INT,
    collegeid INT,
    courseid INT,
    scholarid INT ,
	year_id int,
    years INT,
	studentid int,
	semesterid int,
	marksid int,
	foreign key(marksid)references marks(mark_id),
	foreign key(semesterid)references semester(semesterid),
	Foreign key(studentid) references student(studentid),
    FOREIGN KEY (deptid) REFERENCES department(deptid),
    FOREIGN KEY (collegeid) REFERENCES college(collegeid),
    FOREIGN KEY (courseid) REFERENCES course(courseid),
	 FOREIGN KEY (collegeid) REFERENCES college(collegeid),
    FOREIGN KEY (year_id) REFERENCES years(year_id)
);
	
	select * from student
	
	select * from marks
	select * from fact

	
	select * from student


drop proc if exists hall1;
go
create proc Hall1
as
begin
    declare @deptid int, @deptname varchar(5);
    declare @collegeid int = 1, @collegecode varchar(5), @courseid int = 1, @coursecode varchar(5);
    declare @scholar_code varchar(2), @year int, @scholarid int = 1, @yearid int = 1, @hallticket_no varchar(25);
    declare @i int,@sec varchar(5),@mark1 int,@mark2 int,@status varchar(4),@pass varchar(5),@subjectid int,@stdid int,@subjectid2 int;

    declare dept_cursor cursor for
    select deptid, deptname from department;

    open dept_cursor;
    fetch next from dept_cursor into @deptid, @deptname;

    while @@FETCH_STATUS = 0
    begin
        set @i = 1;
        while @i <= 120
        begin
		declare @semid int=1;
            select @year = years from years where year_id = @yearid;
            SELECT @collegecode = collegecode FROM college WHERE collegeid = @collegeid;
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

insert into student (deptid,student_name,collegeid, courseid, scholar_id, year_id, deptname, section,hallticket_no)
   values (@deptid, concat('student',@i),@collegeid, @courseid, @scholarid, @yearid, @deptname, @sec,@hallticket_no);

            set @i = @i + 1;
        end
        fetch next from dept_cursor into @deptid, @deptname;
    END

    close dept_cursor;
    deallocate dept_cursor;
END;

	
	exec hall1
	select * from student
	select * from semester
	select * from department
	select * from subject
	select * from marks
	select * from fact
	
	create proc spGetPassFail(@semester int)
as
begin
	
	declare @n int,@i int;
	set @n=(select count(*) from student);
	set @i=1;
	while @i<=@n
	begin

	declare @sem int=@semester,@stdid int,@scholar varchar(10),@status varchar(5),@semid int,@subjectid int,@subjectid2 int,@deptid int;
	declare @mark1 int,@mark2 int,@hall varchar(15),@pass varchar(5);
	declare @collegeid int,@courseid int, @scholarid int, @year_id int,@year int,@marksid int,@ss int;
	

	set @mark1=cast(rand()*100 as int);
	set @mark2=cast(rand()*100 as int);

	

	select @deptid=deptid,@stdid=studentid,@hall=hallticket_no from student where studentid=@i;

	select @scholar=scholar_id from student where studentid=@stdid;
	set @subjectid =(select  top 1 subject_id from subject where deptid=@deptid);
				set @subjectid2=(@subjectid)+1;

				if @mark1>=40
				begin
					if @mark2>=40
					begin
						set @pass='PASS';
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
	
	insert into marks (studentid,hallticket_no,subject_id1,marks1,subject_id2,marks2,semester,passFailStatus)
	values (@stdid,@hall,@subjectid,@mark1,@subjectid2,@mark2,@sem,@pass);

	if @pass='PASS'
	begin 
	update student set status='promoted' , semesterid=@sem+1 where studentid=@stdid;
	end
	else
	begin
		update student set status='Backlog' ,semesterid=@sem where studentid=@stdid;
	end	

	select @marksid=mark_id,@ss=semester from marks where studentid=@stdid;
	select @collegeid=collegeid,@courseid=courseid,@scholarid=scholar_id,@year_id=year_id from student where studentid=@stdid;

	select @year=years from years where year_id=@year_id;
	insert into fact (deptid,collegeid,courseid,scholarid,year_id,years,studentid,semesterid,marksid)
	values (@deptid,@collegeid,@courseid,@scholarid,@year_id,@year,@stdid,@ss,@marksid);

	set @i=@i+1;
	end
end;
	


	exec spGetPassFail @semester=1

	

	select * from fact
	select * from student
	select * from marks

	
	
	
	create proc supply(@semid int)
	as
	begin
	declare @sem int=@semid,@stdid int;
	
	create table #v_supply (studentid int,status varchar(15))

	insert into #v_supply
	select m.studentid,s.status from student s join marks m on s.studentid=m.studentid where s.status='Backlog' ;

	 declare supply_cursor cursor for
    select studentid from #v_supply;

    open supply_cursor;
    fetch next from supply_cursor into @stdid;

    while @@FETCH_STATUS = 0
    begin
	

	declare @scholar varchar(10),@status varchar(5),@semester int,@subjectid int,@subjectid2 int,@deptid int;
	declare @mark1 int,@mark2 int,@hall varchar(15),@pass varchar(5);
	declare @collegeid int,@courseid int, @scholarid int, @year_id int,@year int,@marksid int,@ss int;
	

	set @mark1=cast(rand()*100 as int);
	set @mark2=cast(rand()*100 as int);

	

	select @deptid=deptid,@stdid=studentid,@hall=hallticket_no from student where studentid=@stdid;

	select @scholar=scholar_id from student where studentid=@stdid;
	set @subjectid =(select  top 1 subject_id from subject where deptid=@deptid);
				set @subjectid2=(@subjectid)+1;

				if @mark1>=40
				begin
					if @mark2>=40
					begin
						set @pass='PASS';
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
	
	insert into marks (studentid,hallticket_no,subject_id1,marks1,subject_id2,marks2,semester,passFailStatus)
	values (@stdid,@hall,@subjectid,@mark1,@subjectid2,@mark2,@sem,@pass);

	if @pass='PASS'
	begin 
	update student set status='promoted' , semesterid=@sem+1 where studentid=@stdid;
	end
	else
	begin
		update student set status='Backlog' ,semesterid=@sem where studentid=@stdid;
	end	

	select @marksid=mark_id,@ss=semester from marks where studentid=@stdid;
	select @collegeid=collegeid,@courseid=courseid,@scholarid=scholar_id,@year_id=year_id from student where studentid=@stdid;

	select @year=years from years where year_id=@year_id;
	insert into fact (deptid,collegeid,courseid,scholarid,year_id,years,studentid,semesterid,marksid)
	values (@deptid,@collegeid,@courseid,@scholarid,@year_id,@year,@stdid,@ss,@marksid);

	fetch next from supply_cursor into @stdid;
    END
	
    close supply_cursor;
    deallocate supply_cursor;
	drop view #v_supply;
	end;

	exec supply @semid=1

	drop proc supply

	select count(*) from student where semesterid=1
	select * from marks
	

	
	