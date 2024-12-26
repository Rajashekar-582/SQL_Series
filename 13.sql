
create database dup
use dup

CREATE TABLE college (
    collegeid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    collegecode VARCHAR(10)
);

INSERT INTO college (collegecode) VALUES ('TR'), ('N0'), ('TK'), ('ND');


CREATE TABLE department (
    deptid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    deptname VARCHAR(5)
);

INSERT INTO department (deptname) VALUES ('civil'), ('eee'), ('mech'), ('ece'), ('cse');


CREATE TABLE course (
    courseid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    course_code VARCHAR(3),
    course_name VARCHAR(10)
);

INSERT INTO course (course_code, course_name) VALUES ('A', 'B.tech'), ('B', 'B.pharm'), ('C', 'M.tech');

CREATE TABLE scholar (
    scholarid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    scholar_code VARCHAR(2),
    scholar_type VARCHAR(10)
);

INSERT INTO scholar (scholar_code, scholar_type) VALUES ('1', 'day'), ('5', 'lateral');

CREATE TABLE years (
    year_id INT PRIMARY KEY IDENTITY(1,1),
    years INT
);

INSERT INTO years (years) VALUES (2019), (2020), (2021), (2022), (2023), (2024);

CREATE TABLE student (
    studentid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    student_name VARCHAR(25),
    deptname VARCHAR(10),
    collegeid INT,
    coursename VARCHAR(10),
    scholar_type VARCHAR(10),
    year_id INT,
    hallticket_no NVARCHAR(50),
    semester INT DEFAULT 1,
    semester_passed_status VARCHAR(4),
    current_semester INT DEFAULT 1,
    FOREIGN KEY (collegeid) REFERENCES college(collegeid),
    FOREIGN KEY (year_id) REFERENCES years(year_id)
);



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

    
END;

INSERT INTO student (student_name, deptname, collegeid, coursename, scholar_type, year_id, hallticket_no, semester, semester_passed_status, current_semester)
VALUES ('suman', 'ece', 2, 'B.pharm', 'day', 2, NULL, 1, NULL, 1);
exec hall;

INSERT INTO student (student_name, deptname, collegeid, coursename, scholar_type, year_id, hallticket_no, semester, semester_passed_status, current_semester)
values ('Ram', 'cse', 3, 'B.tech', 'lateral', 4, NULL, 1, NULL, 1);


select * from student
	   CREATE TABLE subjects (
    subjectid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    subject_code VARCHAR(10),
    subject_name VARCHAR(50)
);

INSERT INTO subjects (subject_code, subject_name)
VALUES 
    ('CS101', 'Programming Languages'), 
    ('CS102', 'Data Structures'), 
    ('CS103', 'Operating Systems'), 
    ('CS104', 'DBMS'), 
    ('CS105', 'Computer Networks'), 
    ('CS106', 'Software Engineering'), 
    ('CS107', 'Web Technologies'), 
    ('CS108', 'AI & ML'), 
    ('CS109', 'Computer Architecture'), 
    ('CS110', 'Cyber Security'), 
    ('CS111', 'Cloud Computing'), 
    ('CS112', 'Big Data Analytics'),
    ('ECE101', 'Digital Signal Processing'), 
    ('ECE102', 'Analog Electronics'), 
    ('ECE103', 'Communication Systems'), 
    ('ECE104', 'VLSI Design'), 
    ('ECE105', 'Embedded Systems'), 
    ('ECE106', 'Control Systems'), 
    ('ECE107', 'Microwave Engineering'), 
    ('ECE108', 'Optical Communication'), 
    ('ECE109', 'Wireless Communication'), 
    ('ECE110', 'Network Analysis'), 
    ('ECE111', 'Antenna Design'), 
    ('ECE112', 'Microprocessors');

	CREATE TABLE department_subjects (
    dept_subject_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    deptid INT,
    subjectid INT,
    semester INT,
    FOREIGN KEY (deptid) REFERENCES department(deptid),
    FOREIGN KEY (subjectid) REFERENCES subjects(subjectid)
);

select * from department_subjects

-- Get the deptid for CSE and ECE departments
DECLARE @cse_deptid INT, @ece_deptid INT;
SELECT @cse_deptid = deptid FROM department WHERE deptname = 'cse';
SELECT @ece_deptid = deptid FROM department WHERE deptname = 'ece';

-- Insert CSE department related subjects into department_subjects table
INSERT INTO department_subjects (deptid, subjectid, semester)
SELECT @cse_deptid, subjectid, 1 FROM subjects WHERE subject_code IN ('CS101', 'CS102', 'CS103', 'CS104')
UNION ALL
SELECT @cse_deptid, subjectid, 2 FROM subjects WHERE subject_code IN ('CS105', 'CS106', 'CS107', 'CS108')
UNION ALL
SELECT @cse_deptid, subjectid, 3 FROM subjects WHERE subject_code IN ('CS109', 'CS110', 'CS111', 'CS112');

-- Insert ECE department related subjects into department_subjects table
INSERT INTO department_subjects (deptid, subjectid, semester)
SELECT @ece_deptid, subjectid, 1 FROM subjects WHERE subject_code IN ('ECE101', 'ECE102', 'ECE103', 'ECE104')
UNION ALL
SELECT @ece_deptid, subjectid, 2 FROM subjects WHERE subject_code IN ('ECE105', 'ECE106', 'ECE107', 'ECE108')
UNION ALL
SELECT @ece_deptid, subjectid, 3 FROM subjects WHERE subject_code IN ('ECE109', 'ECE110', 'ECE111', 'ECE112');

CREATE TABLE marks (
    markid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    studentid INT,
    subjectid INT,
    marks INT,
    semester INT,
    status VARCHAR(4),
    FOREIGN KEY (studentid) REFERENCES student(studentid),
    FOREIGN KEY (subjectid) REFERENCES subjects(subjectid)
);

-- Insert sample data into marks table for department-specific subjects with semester information
INSERT INTO marks (studentid, subjectid, marks, semester)
VALUES 
    (1, (SELECT subjectid FROM subjects WHERE subject_code = 'CS101'), 85, 1), -- Student 1 with Programming Languages in Semester 1
    (1, (SELECT subjectid FROM subjects WHERE subject_code = 'CS102'), 78, 1), -- Student 1 with Data Structures in Semester 1
    (2, (SELECT subjectid FROM subjects WHERE subject_code = 'ECE101'), 90, 1), -- Student 2 with Digital Signal Processing in Semester 1
    (2, (SELECT subjectid FROM subjects WHERE subject_code = 'ECE102'), 88, 1); -- Student 2 with Analog Electronics in Semester 1

-- Select data from marks table to verify the insertion
SELECT * FROM marks;

-- Drop the procedure if it exists
-- Drop the procedure if it exists
DROP PROCEDURE IF EXISTS CheckAndUpdateStatus;
GO

-- Create the stored procedure
CREATE PROCEDURE CheckAndUpdateStatus
AS
BEGIN
    -- Update status based on marks
    UPDATE marks
    SET status = CASE 
        WHEN marks >= 40 THEN 'Pass'
        ELSE 'Fail'
    END;

    -- Check the number of subjects for each student per semester
    DECLARE @required_subjects INT = 4;

    -- Update marks table to set status to 'Fail' if the number of subjects is less than required
    UPDATE marks
    SET status = 'Fail'
    WHERE studentid IN (
        SELECT studentid
        FROM marks
        GROUP BY studentid, semester
        HAVING COUNT(subjectid) < @required_subjects
    );

    -- Update semester_passed_status in student table
    UPDATE student
    SET semester_passed_status = CASE 
        WHEN NOT EXISTS (
            SELECT 1 
            FROM marks 
            WHERE student.studentid = marks.studentid 
            AND marks.status = 'Fail'
        ) THEN 'Pass'
        ELSE 'Fail'
    END;

    -- Increment current_semester if the student has passed the current semester
    UPDATE student
    SET current_semester = current_semester + 1
    WHERE semester_passed_status = 'Pass';
END;
GO

-- Execute the stored procedure
EXEC CheckAndUpdateStatus;

-- Select data from student table to verify the update
SELECT * FROM student;

-- Select data from marks table to verify the update
SELECT * FROM marks;


-- Select data from student table to verify the update
SELECT * FROM student;

CREATE TABLE result (
    resultid INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    studentid INT,
    hallticket_no NVARCHAR(50),
    semester INT,
    total_marks INT,
    semester_status VARCHAR(4),
    FOREIGN KEY (studentid) REFERENCES student(studentid)
);

-- Drop the procedure if it exists
DROP PROCEDURE IF EXISTS UpdateResults;
GO

-- Create the stored procedure
CREATE PROCEDURE UpdateResults
AS
BEGIN
    -- Insert or update result table with total marks, hallticket_no, and semester_status
    MERGE result AS r
    USING (
        SELECT 
            s.studentid, 
            s.hallticket_no, 
            m.semester, 
            SUM(m.marks) AS total_marks, 
            s.semester_passed_status AS semester_status
        FROM student s
        JOIN marks m ON s.studentid = m.studentid
        GROUP BY s.studentid, s.hallticket_no, m.semester, s.semester_passed_status
    ) AS src
    ON r.studentid = src.studentid AND r.semester = src.semester
    WHEN MATCHED THEN
        UPDATE SET 
            r.hallticket_no = src.hallticket_no,
            r.total_marks = src.total_marks,
            r.semester_status = src.semester_status
    WHEN NOT MATCHED THEN
        INSERT (studentid, hallticket_no, semester, total_marks, semester_status)
        VALUES (src.studentid, src.hallticket_no, src.semester, src.total_marks, src.semester_status);
END;
GO

-- Execute the stored procedure
EXEC UpdateResults;

-- Select data to verify the updates
SELECT * FROM result;


SELECT * FROM student;



SELECT * FROM student;

SELECT * FROM marks;

-- Verify data in result table
SELECT * FROM result;
