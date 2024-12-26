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
	('BE Electronics', 4, 1, 2),         -- ECE, B.Tech, Semester 1
    ('Circuit Systems', 4, 1, 2),  
    ('Programming Fundamentals', 5, 1, 1),   -- CSE, B.Tech, Semester 1
    ('Data Structures', 5, 1, 1),            -- CSE, B.Tech, Semester 2
	('C Fundamentals', 5, 1, 2),   -- CSE, B.Tech, Semester 1
    ('oops', 5, 1, 2),   
    ('Pharmaceutical Chemistry', 2, 2, 1),   -- EEE, B.Pharm, Semester 1
    ('Pharmacology', 2, 2, 1);               -- EEE, B.Pharm, Semester 2
	select * from subject
	alter table subject

	CREATE TABLE student (
    studentid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    student_name VARCHAR(25),
    deptname VARCHAR(10),
    collegeid INT,
    coursename VARCHAR(10),
    scholar_type VARCHAR(10),
    year_id INT,
    hallticket_no NVARCHAR(50),
	previous_semester int default 1,
	semester varchar(15),
	current_semester int default 1,
		 FOREIGN KEY (collegeid) REFERENCES college(collegeid),
		     FOREIGN KEY (year_id) REFERENCES years(year_id)

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
	semesterid int,
	subject_id int,
	foreign key(subject_id)references subject(subject_id),
	foreign key(semesterid)references semester(semesterid),
	Foreign key(studentid) references student(studentid),
    FOREIGN KEY (deptid) REFERENCES department(deptid),
    FOREIGN KEY (collegeid) REFERENCES college(collegeid),
    FOREIGN KEY (courseid) REFERENCES course(courseid),
	 FOREIGN KEY (collegeid) REFERENCES college(collegeid),
    FOREIGN KEY (year_id) REFERENCES years(year_id),
	foreign key(scholarid) references scholar(scholarid)

);

create TRIGGER trg_check_all_columns
ON student
INSTEAD OF INSERT
AS
BEGIN
    if exists (select 1 from inserted i 
               where not exists (select 1 from department d where d.deptname = i.deptname)
               or NOT exists (select 1 from college c WHERE c.collegeid = i.collegeid)
               or NOT exists (select 1 from course co WHERE co.course_name = i.coursename)
			   or NOT exists (select 1 from scholar s WHERE s.scholar_type = i.scholar_type)
               or NOT exists (select 1 from years y WHERE y.year_id = i.year_id))
    BEGIN
        RAISERROR ('Error: One or more values are invalid', 16, 1);
		rollback;
    END
    ELSE
    BEGIN
        INSERT INTO student (student_name, deptname, collegeid, coursename, scholar_type, year_id, hallticket_no, previous_semester, semester, current_semester)
        SELECT student_name, deptname, collegeid, coursename, scholar_type, year_id, hallticket_no, previous_semester, semester, current_semester
        FROM inserted;
    END
END;

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
VALUES ('Rajashekar', 'cse', 1, 'b.tech', 'day', 4, NULL);

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

alter proc spGetPassFail
as
begin
	
	declare @sem int,@stdid int,@scholar varchar(10),@status varchar(5),@semid int,@subjectid int;
	select @sem=semester,@stdid=studentid,@subjectid=subject_id from marks where  passFailStatus is Null;
	select @scholar=scholar_type from student where studentid=@stdid;
	
	update marks 
	set passFailStatus = case 
	when marks >= 40 then 'Pass' else 'Fail' end
	where passFailStatus is Null;

	UPDATE student
SET  semester = CASE 
    WHEN m.pass_count >= 2 THEN 'Pass'
    WHEN EXISTS (
        SELECT 1 
        FROM marks 
        WHERE s.studentid = marks.studentid 
        AND marks.passFailStatus = 'Fail'
    ) THEN 'Fail'
    ELSE semester
END

FROM student s
JOIN (
    SELECT studentid, COUNT(*) AS pass_count
    FROM marks
    WHERE passFailStatus = 'Pass' 
    GROUP BY studentid
) m ON s.studentid = m.studentid;

if @scholar='day'
	begin

 update student set previous_semester=@sem where studentid=@stdid;
 update student set current_semester=current_semester+1  
 where semester='Pass' and studentid=@stdid;
 end
 else
 begin
 update student set previous_semester=@sem where studentid=@stdid;
 select @status=semester from student where studentid=@stdid;
 if @status='Pass'
 begin
 update student set current_semester=previous_semester+1  
 where semester='pass' and studentid=@stdid;
 end
 else if @status='Fail'
 begin
 update student set current_semester=previous_semester  
 where semester='Fail' and studentid=@stdid;
 end
 end

 update fact set semesterid=@sem,subject_id=@subjectid where studentid=@stdid;
end;

select * from fact 



-- Drop the procedure if it already exists


insert into marks (studentid, subject_id, marks, semester)values 
(1,1,50,1),
(1,2,40,1);


exec spGetPassFail

select * from student
select * from marks
select * from fact
insert into marks (studentid, subject_id, marks, semester)values 
(2,3,50,3),
(2,4,35,3);

exec spGetPassFail

select * from student
select * from marks
insert into marks (studentid, subject_id, marks, semester)values 
(2,1,50,3),
(2,2,40,3);


insert into marks (studentid, subject_id, marks, semester)values 
(3,1,50,3),
(3,2,40,3),(4,1,50,1),
(4,2,40,1);

exec spGetPassFail

insert into marks (studentid, subject_id, marks, semester)values 
(2,1,50,1),
(2,2,40,1);

exec spGetPassFail


insert into marks (studentid, subject_id, marks, semester)values 
(4,1,50,1),
(4,2,40,1);

exec spGetPassFail

select * from student
select * from marks






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
