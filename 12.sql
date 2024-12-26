create database marks
use marks
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



CREATE TABLE student (
    studentid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    student_name VARCHAR(25),
    deptname VARCHAR(10),
    collegeid INT,
    coursename VARCHAR(10),
    scholar_type VARCHAR(10),
    year_id INT,
    hallticket_no NVARCHAR(50),
	semesterid int default 1,
	semester varchar(15),
	result_status varchar(15)
   
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
VALUES ('suman', 'civil', 2, 'b.tech', 'day', 2, NULL);

EXEC Hall;

INSERT INTO student (student_name, deptname, collegeid, coursename, scholar_type, year_id, hallticket_no)
VALUES ('Ram', 'cse', 3,'b.tech', 'lateral', 4, NULL);

exec hall;

select *  from student
select * from fact

CREATE TABLE marks (
    marks_id INT PRIMARY KEY IDENTITY(1,1),
    studentid INT,
    subject_id INT,
	semesterid int,
    marks_obtained INT,
	status varchar(10),
	foreign key(semesterid) references semester(semesterid),
    FOREIGN KEY (studentid) REFERENCES student(studentid),
    FOREIGN KEY (subject_id) REFERENCES subject(subject_id)
);

INSERT INTO marks (studentid,semesterid, subject_id, marks_obtained)
VALUES
    (1,2, 1, 50),  -- Example: Suman's marks for subject 1
    (1,2, 2, 49)  -- Example: Suman's marks for subject 2
   
   select * from marks
  -- Drop the procedure if it exists
DROP PROCEDURE IF EXISTS UpdateStudentStatus;
GO

-- Create the stored procedure
CREATE PROCEDURE UpdateStudentStatus
AS
BEGIN
	declare @sem varchar(15),@semid int;

	select @semid= semesterid from marks;
	select @sem=semester from semester where semesterid=@semid;
    -- Update status in marks table based on marks obtained
    UPDATE marks
    SET status = CASE 
        WHEN marks_obtained >= 40 THEN 'Pass'
        ELSE 'Fail'
    END;

    -- Check the number of subjects for each student per semester
    DECLARE @required_subjects INT = 2;

    -- Update marks table to set status to 'Fail' if the number of subjects is less than required
    UPDATE marks
    SET status = 'Fail'
    WHERE studentid IN (
        SELECT studentid
        FROM marks
        GROUP BY studentid
        HAVING COUNT(subject_id) < @required_subjects
    );

    -- Update result_status and semester in student table

UPDATE student
SET result_status = CASE 
    WHEN m.pass_count >= 2 THEN 'Pass'
    WHEN EXISTS (
        SELECT 1 
        FROM marks 
        WHERE s.studentid = marks.studentid 
        AND marks.status = 'Fail'
    ) THEN 'Fail'
    ELSE result_status
END,
semester = CONCAT('semester', s.semesterid)
FROM student s
JOIN (
    SELECT studentid, COUNT(*) AS pass_count
    FROM marks
    WHERE status = 'Pass'
    GROUP BY studentid
) m ON s.studentid = m.studentid;


END;
GO

EXEC UpdateStudentStatus;

SELECT * FROM student;

SELECT * FROM marks;






select * from scholar
select * from course
select * from college
select * from department
select * from years

