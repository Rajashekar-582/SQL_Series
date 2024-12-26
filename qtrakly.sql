create database Qtrakly
use Qtrakly

CREATE TABLE Users (
    user_id INT PRIMARY KEY identity(1,1),
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP

);
 
-- Create Tasks Table

CREATE TABLE Tasks (
    id INT PRIMARY KEY identity(1,1),
    Topic VARCHAR(255),
    SubTopic VARCHAR(255),
    [Activity] VARCHAR(255),
	[Status] VARCHAR(255),
    [Priority] VARCHAR(50),
	EstimatedEfforts decimal(10,2) default 0,
    CompletedEfforts decimal(10,2) default 0,
	 RemainingEfforts AS (EstimatedEfforts - CompletedEfforts) PERSISTED,
    DueDate DATE,
	createdon date default getdate(),
    Comments TEXT,
	Description TEXT,
	AssignedTo int,
    FOREIGN KEY (AssignedTo) REFERENCES Users(User_ID),
	check ([Status] in ('In Progress','Completed')),
	check ([Activity] in ('Session','Reading','Video','Assessment','Presentation')),
	check ([Priority] in (1,2,3,4))

);



insert into users (username,email) values ('Rajashekar Nerella','abd@gmail.com')
insert into users (username,email) values ('Shivaji','def@gmail.com')


select * from Tasks
select * from users

INSERT INTO Tasks (Topic, SubTopic, Activity, Status, Priority, DueDate, AssignedTo, EstimatedEfforts, CompletedEfforts) 
VALUES 
('SQL SERVER', 'Leetcode problem solving', 'Reading', 'Completed', '1', '2024-09-22', 1, 8.00, 8.00),
('SQL SERVER', 'Leetcode problem solving', 'Reading', 'Completed', '1', '2024-09-23', 1, 8.00, 8.00),
('SQL SERVER', 'Leetcode problem solving', 'Reading', 'Completed', '1', '2024-09-24', 1, 8.00, 8.00),
('SQL SERVER', 'Leetcode problem solving', 'Reading', 'Completed', '1', '2024-09-25', 1, 8.00, 8.00),
('SQL SERVER', 'Leetcode problem solving', 'Reading', 'Completed', '1', '2024-09-26', 1, 8.00, 8.00),
('SQL SERVER', 'Leetcode problem solving', 'Reading', 'Completed', '1', '2024-09-27', 1, 8.00, 8.00),
('SQL SERVER', 'Leetcode problem solving', 'Reading', 'Completed', '1', '2024-09-28', 1, 8.00, 8.00),
('SQL SERVER', 'Leetcode problem solving', 'Reading', 'Completed', '1', '2024-09-29', 1, 8.00, 8.00),
('SQL SERVER', 'Leetcode problem solving', 'Reading', 'Completed', '1', '2024-09-30', 1, 8.00, 8.00);



select * from tasks
-----------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GenerateWeeklyReport
AS
BEGIN
    DECLARE @StartOfWeek DATE = DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE));
    DECLARE @EndOfWeek DATE = DATEADD(DAY, 7 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE));

    -- Create a CTE to derive the DayOfWeek from DueDate
    WITH TaskData AS (
        SELECT 
            u.username,
            DATENAME(WEEKDAY, t.DueDate) AS DayOfWeek,
            t.EstimatedEfforts,
            t.CompletedEfforts,
            t.RemainingEfforts
        FROM 
            Tasks t
        JOIN 
            Users u ON t.AssignedTo = u.user_id
        WHERE 
            t.DueDate BETWEEN @StartOfWeek AND @EndOfWeek
    )

    -- Pivot the data to get days of the week as columns and insert into a temporary table
    SELECT 
        username,
        ISNULL([Monday], 0) AS Monday,
        ISNULL([Tuesday], 0) AS Tuesday,
        ISNULL([Wednesday], 0) AS Wednesday,
        ISNULL([Thursday], 0) AS Thursday,
        ISNULL([Friday], 0) AS Friday,
        ISNULL([Saturday], 0) AS Saturday,
        ISNULL([Sunday], 0) AS Sunday,
        (ISNULL([Monday], 0) + ISNULL([Tuesday], 0) + ISNULL([Wednesday], 0) + ISNULL([Thursday], 0) + ISNULL([Friday], 0) + ISNULL([Saturday], 0) + ISNULL([Sunday], 0)) AS TotalCompletedEfforts
    INTO 
        #WeeklyReport
    FROM 
        TaskData
    PIVOT (
        SUM(CompletedEfforts) 
        FOR DayOfWeek IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
    ) AS PivotTable
    ORDER BY 
        username;

		SELECT * FROM #WeeklyReport;
END;

exec GenerateWeeklyReport
-- Weekly report for tasks by user, grouped by day of the week
/*
DECLARE @StartOfWeek DATE = DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE));
DECLARE @EndOfWeek DATE = DATEADD(DAY, 7 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE));

-- Create a CTE to derive the DayOfWeek from DueDate
WITH TaskData AS (
    SELECT 
        u.username,
        DATENAME(WEEKDAY, t.DueDate) AS DayOfWeek,
        t.EstimatedEfforts,
        t.CompletedEfforts,
        t.RemainingEfforts
    FROM 
        Tasks t
    JOIN 
        Users u ON t.AssignedTo = u.user_id
    WHERE 
        t.DueDate BETWEEN @StartOfWeek AND @EndOfWeek
)

-- Pivot the data to get days of the week as columns and insert into a temporary table
SELECT 
    username,
    ISNULL([Monday], 0) AS Monday,
    ISNULL([Tuesday], 0) AS Tuesday,
    ISNULL([Wednesday], 0) AS Wednesday,
    ISNULL([Thursday], 0) AS Thursday,
    ISNULL([Friday], 0) AS Friday,
    ISNULL([Saturday], 0) AS Saturday,
    ISNULL([Sunday], 0) AS Sunday,
    (ISNULL([Monday], 0) + ISNULL([Tuesday], 0) + ISNULL([Wednesday], 0) + ISNULL([Thursday], 0) + ISNULL([Friday], 0) + ISNULL([Saturday], 0) + ISNULL([Sunday], 0)) AS TotalCompletedEfforts
INTO 
    #WeeklyReport
FROM 
    TaskData
PIVOT (
    SUM(CompletedEfforts) 
    FOR DayOfWeek IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) AS PivotTable
ORDER BY 
    username;

-- Verify the contents of the temporary table
SELECT * FROM #WeeklyReport;

*/

-- Calculate the start and end dates of the current year
/*
DECLARE @StartOfYear DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
DECLARE @EndOfYear DATE = DATEFROMPARTS(YEAR(GETDATE()), 12, 31);

-- Create a CTE to derive the Month from DueDate
WITH TaskData AS (
    SELECT 
        u.username,
        DATENAME(MONTH, t.DueDate) AS MonthName,
        t.EstimatedEfforts,
        t.CompletedEfforts,
        t.RemainingEfforts
    FROM 
        Tasks t
    JOIN 
        Users u ON t.AssignedTo = u.user_id
    WHERE 
        t.DueDate BETWEEN @StartOfYear AND @EndOfYear
)

-- Pivot the data to get months as columns and insert into a temporary table
SELECT 
    username,
    ISNULL([January], 0) AS January,
    ISNULL([February], 0) AS February,
    ISNULL([March], 0) AS March,
    ISNULL([April], 0) AS April,
    ISNULL([May], 0) AS May,
    ISNULL([June], 0) AS June,
    ISNULL([July], 0) AS July,
    ISNULL([August], 0) AS August,
    ISNULL([September], 0) AS September,
    ISNULL([October], 0) AS October,
    ISNULL([November], 0) AS November,
    ISNULL([December], 0) AS December,
    (ISNULL([January], 0) + ISNULL([February], 0) + ISNULL([March], 0) + ISNULL([April], 0) + ISNULL([May], 0) + ISNULL([June], 0) + ISNULL([July], 0) + ISNULL([August], 0) + ISNULL([September], 0) + ISNULL([October], 0) + ISNULL([November], 0) + ISNULL([December], 0)) AS TotalCompletedEfforts
INTO 
    #YearlyReport
FROM 
    TaskData
PIVOT (
    SUM(CompletedEfforts) 
    FOR MonthName IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December])
) AS PivotTable
ORDER BY 
    username;

SELECT * FROM #YearlyReport;
*/



CREATE PROCEDURE GenerateYearlyReport
AS
BEGIN
    DECLARE @StartOfYear DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
    DECLARE @EndOfYear DATE = DATEFROMPARTS(YEAR(GETDATE()), 12, 31);

    -- Create a CTE to derive the Month from DueDate
    WITH TaskData AS (
        SELECT 
            u.username,
            DATENAME(MONTH, t.DueDate) AS MonthName,
            t.EstimatedEfforts,
            t.CompletedEfforts,
            t.RemainingEfforts
        FROM 
            Tasks t
        JOIN 
            Users u ON t.AssignedTo = u.user_id
        WHERE 
            t.DueDate BETWEEN @StartOfYear AND @EndOfYear
    )

    -- Pivot the data to get months as columns and insert into a temporary table
    SELECT 
        username,
        ISNULL([January], 0) AS January,
        ISNULL([February], 0) AS February,
        ISNULL([March], 0) AS March,
        ISNULL([April], 0) AS April,
        ISNULL([May], 0) AS May,
        ISNULL([June], 0) AS June,
        ISNULL([July], 0) AS July,
        ISNULL([August], 0) AS August,
        ISNULL([September], 0) AS September,
        ISNULL([October], 0) AS October,
        ISNULL([November], 0) AS November,
        ISNULL([December], 0) AS December,
        (ISNULL([January], 0) + ISNULL([February], 0) + ISNULL([March], 0) + ISNULL([April], 0) + ISNULL([May], 0) + ISNULL([June], 0) + ISNULL([July], 0) + ISNULL([August], 0) + ISNULL([September], 0) + ISNULL([October], 0) + ISNULL([November], 0) + ISNULL([December], 0)) AS TotalCompletedEfforts
    INTO 
        #YearlyReport
    FROM 
        TaskData
    PIVOT (
        SUM(CompletedEfforts) 
        FOR MonthName IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December])
    ) AS PivotTable
    ORDER BY 
        username;

    SELECT * FROM #YearlyReport;
END;


exec GenerateYearlyReport;
----------------------------------------------------------------------------------------------------------------
create table Topics(
	Topic_Id int not null,
	Topic_Name nvarchar(50),
	Subtopic_Id int not null,
	Subtopic_Name nvarchar(100),
	Video_Links nvarchar(max),
	--Status nvarchar(20) default 'Yet to Start',
	--check (Status in ('Yet to Start', 'In Progress', 'Completed')),
	primary key(Topic_Id, Subtopic_Id)
);
 
insert into Topics (Topic_Id, Topic_Name, Subtopic_Id, Subtopic_Name, Video_Links)
values
(1, 'SQL', 1, 'SQL Basics', 'https://www.youtube.com/watch?v=sql_basics_1,https://www.youtube.com/watch?v=sql_basics_2'),
(1, 'SQL', 2, 'SQL Joins', 'https://www.youtube.com/watch?v=sql_joins_1,https://www.youtube.com/watch?v=sql_joins_2'),
(1, 'SQL', 3, 'SQL Subqueries', 'https://www.youtube.com/watch?v=sql_subqueries_1,https://www.youtube.com/watch?v=sql_subqueries_2'),
 
(2, 'Python', 1, 'Python Basics', 'https://www.youtube.com/watch?v=python_basics_1,https://www.youtube.com/watch?v=python_basics_2'),
(2, 'Python', 2, 'Python Data Structures', 'https://www.youtube.com/watch?v=python_data_structures_1,https://www.youtube.com/watch?v=python_data_structures_2'),
(2, 'Python', 3, 'Python File Handling', 'https://www.youtube.com/watch?v=python_file_handling_1,https://www.youtube.com/watch?v=python_file_handling_2'),
 
(3, 'Pyspark', 1, 'Pyspark Basics', 'https://www.youtube.com/watch?v=pyspark_basics_1,https://www.youtube.com/watch?v=pyspark_basics_2'),
(3, 'Pyspark', 2, 'Pyspark DataFrames', 'https://www.youtube.com/watch?v=pyspark_dataframes_1,https://www.youtube.com/watch?v=pyspark_dataframes_2'),
(3, 'Pyspark', 3, 'Pyspark Machine Learning', 'https://www.youtube.com/watch?v=pyspark_machine_learning_1,https://www.youtube.com/watch?v=pyspark_machine_learning_2');




-- Create Learning_Progress Table
create table Learning_Progress(
	id int not null primary key identity(1,1),
	user_id int,
	Topic_Id int,
	Subtopic_Id int,
	[Session] nvarchar(20) default 'Yet to Start',
	[Practice] nvarchar(20) default 'Yet to Start',
	[Video] nvarchar(20) default 'Yet to Start',
	[Assessment] nvarchar(20) default 'Yet to Start',
	Started_On date default getdate(),
	Completed_On date,
	Progress decimal(10,2),
	check ([Session] in ('Yet to Start', 'In Progress', 'Completed')),
	check ([Practice] in ('Yet to Start', 'In Progress', 'Completed')),
	check ([Video] in ('Yet to Start', 'In Progress', 'Completed')),
	check ([Assessment] in ('Yet to Start', 'In Progress', 'Completed')),
	foreign key (user_id) references Users(user_id),
	foreign key (Topic_Id, Subtopic_Id) references Topics(Topic_Id, Subtopic_Id)
);
-- Create Topics Table

select * from Topics
select * from Learning_Progress


create proc progressstatus
@userid int,
@topicid int,
@subtopicid int,
@session varchar(25),
@practice varchar(25),
@video varchar(25),
@assessment varchar(25)
as
begin
if not exists (
			select 1
			from learning_Progress
			where user_id = @userid and Topic_Id =@topicid and Subtopic_Id = @subtopicid
		)
		begin
		insert into learning_progress (user_id,topic_id,subtopic_id,[session],[practice],[video],[assessment],started_on)
values (@userid,@topicid,@subtopicid,@session,@practice,@video,@assessment,getdate())

		end;
		else 
		begin
		update learning_progress set session=@session
		where @session !='In Progress' and @session!='Yet to Start';

		update learning_progress set video=@video
		where @video !='In Progress' and @video !='Yet to Start';

		update learning_progress set practice=@practice
		where @practice !='In Progress' and @practice !='Yet to Start';

		update learning_progress set assessment=@assessment
		where @assessment !='In Progress' and @assessment!='Yet to Start';

		end

update learning_progress set progress= CASE 
            WHEN [session] = 'Completed' AND [video] = 'Completed' AND [Practice] = 'Completed' AND [Assessment] = 'Completed' THEN 100.00
            WHEN [session] = 'Completed' AND [video] = 'Completed' AND [Practice] = 'Completed' THEN 75.00
            WHEN [session] = 'Completed' AND [video] = 'Completed' THEN 50.00
            WHEN [session] = 'Completed' THEN 25.00
            ELSE 0.00
        END
		where USER_ID=@userid and topic_id=@topicid and subtopic_id=@subtopicid; 

		update learning_progress set Completed_On=getdate() where [session] = 'Completed' AND [video] = 'Completed' AND [Practice] = 'Completed' AND [Assessment] = 'Completed';
end

exec progressstatus
@userid=1,
@topicid=1,
@subtopicid=2,
@session='Completed',
@video='Completed',
@practice='Completed',
@assessment='In Progress';


select * from learning_progress

--------------------------------------------------------------------------------------------------------------------
create table assessments (
    assessment_id int not null primary key identity(1,1),
    user_id int,
    topic_id int,
    subtopic_id int,
    assessment_date date,
    score decimal(5, 2),
    status nvarchar(50) default 'Completed',
    foreign key(user_id) references users(user_id),
    foreign key(topic_id, subtopic_id) references topics(topic_id, subtopic_id)
);
 
create table test_assessments (
    test_id int not null primary key identity(1,1),
    assessment_id int,
    question text,
    option1 text,
    option2 text,
    option3 text,
    option4 text,
    correct_answer text,
    foreign key (assessment_id) references assessments(assessment_id)
);
 
create table evaluation_assessments (
    evaluation_id int not null primary key identity(1,1),
    assessment_id int,
    evaluation_type nvarchar(50),
    evaluation_score decimal(5, 2),
    foreign key (assessment_id) references assessments(assessment_id)
);
 
CREATE TABLE ranking_assessments (
    ranking_id INT PRIMARY KEY IDENTITY(1,1),
    assessment_id INT,
    user_id int,
    rank INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (assessment_id) REFERENCES assessments(assessment_id)
);
 
CREATE TABLE report_assessments (
    report_id INT PRIMARY KEY IDENTITY(1,1),
    assessment_id INT,
	user_id int,
    report_type VARCHAR(50),
    report_score DECIMAL(5, 2),
	foreign key (user_id) references users(user_id),
    FOREIGN KEY (assessment_id) REFERENCES assessments(assessment_id)
);
 
CREATE TABLE feedback (
    feedback_id INT PRIMARY KEY IDENTITY(1,1),
    user_id int,
    task_id INT,
    feedback_text TEXT,
    feedback_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (task_id) REFERENCES tasks(id)
);

create table questions(
question_id int primary key identity(1,1),
assessment_id int,
question_text nvarchar(500) not null,
question_type nvarchar(50)not null,
foreign key (assessment_id) references assessments(assessment_id)
);

create table answers(
answer_id int primary key identity(1,1),
question_id int,
user_id int,
answer_text nvarchar(500) not null,
is_correct bit null,
foreign key (question_id)references questions(question_id)
);
 
CREATE TABLE create_feedback (
    create_feedback_id INT PRIMARY KEY IDENTITY(1,1),
    feedback_id INT,
    details TEXT,
    FOREIGN KEY (feedback_id) REFERENCES feedback(feedback_id)
);
 
ALTER PROCEDURE add_assessment_and_update
    @user_id INT,
    @topic_id INT,
    @subtopic_id INT,
    @assessment_date DATE,
    @score DECIMAL(5, 2),
    @question TEXT,
    @option1 TEXT,
    @option2 TEXT,
    @option3 TEXT,
    @option4 TEXT,
    @correct_answer TEXT,
    @evaluation_type VARCHAR(50),
    @evaluation_score DECIMAL(5, 2),
    @report_type VARCHAR(50)
AS
BEGIN
    DECLARE @assessment_id INT;
    INSERT INTO assessments (user_id, topic_id, subtopic_id, assessment_date, score)
    VALUES (@user_id, @topic_id, @subtopic_id, @assessment_date, @score);
    SET @assessment_id = SCOPE_IDENTITY();

    DECLARE @rank INT;
    WITH RankedAssessments AS (
        SELECT 
            assessment_id,
            RANK() OVER (ORDER BY score DESC) AS rank
        FROM assessments
        WHERE topic_id = @topic_id
    )
    SELECT @rank = rank
    FROM RankedAssessments
    WHERE assessment_id = @assessment_id;

    INSERT INTO ranking_assessments (assessment_id, user_id, rank) 
    VALUES (@assessment_id, @user_id, @rank);

    INSERT INTO test_assessments (assessment_id, question, option1, option2, option3, option4, correct_answer)
    VALUES (@assessment_id, @question, @option1, @option2, @option3, @option4, @correct_answer);

    INSERT INTO evaluation_assessments (assessment_id, evaluation_type, evaluation_score)
    VALUES (@assessment_id, @evaluation_type, @evaluation_score);

	declare @report_score float;
	select @report_score= (sum(score)/(100*(select count(topic_id) from assessments where user_id=@user_id)))*100 from assessments where user_id=@user_id;

    INSERT INTO report_assessments (assessment_id,user_id, report_type, report_score)
    VALUES (@assessment_id,@user_id,@report_type, @report_score);

    -- Update ranks in ranking_assessments based on the latest scores
    ;WITH UpdatedRanks AS (
        SELECT 
            ra.assessment_id,
            Dense_RANK() OVER (ORDER BY a.score DESC) AS new_rank
        FROM assessments a
        JOIN ranking_assessments ra ON a.assessment_id = ra.assessment_id
        WHERE a.topic_id = @topic_id
    )
    UPDATE ra
    SET ra.rank = ur.new_rank
    FROM ranking_assessments ra
    JOIN UpdatedRanks ur ON ra.assessment_id = ur.assessment_id;
END;


 
--1)
EXEC add_assessment_and_update 
    @user_id =1,  
    @topic_id = 1,
    @subtopic_id = 1,
    @assessment_date = '2024-09-26', 
    @score = 85.00, 
    @question = 'What is the SQL command to create a new table?', 
    @option1 = 'CREATE TABLE', 
    @option2 = 'INSERT INTO', 
    @option3 = 'UPDATE TABLE', 
    @option4 = 'DELETE FROM', 
    @correct_answer = 'CREATE TABLE',
    @evaluation_type = 'Quiz',
    @evaluation_score = 85.00,
    @report_type = 'Quiz';
--2)
EXEC add_assessment_and_update 
    @user_id = 2,  
    @topic_id = 1,
    @subtopic_id = 1,
    @assessment_date = '2024-09-26', 
    @score = 70.00, 
    @question = 'How do you insert a new record into a table in SQL?', 
    @option1 = 'INSERT INTO', 
    @option2 = 'UPDATE TABLE', 
    @option3 = 'DELETE FROM', 
    @option4 = 'SELECT FROM', 
    @correct_answer = 'INSERT INTO',
    @evaluation_type = 'Quiz',
    @evaluation_score = 90.00,
    @report_type = 'Quiz';


	EXEC add_assessment_and_update 
    @user_id =1,  
    @topic_id = 2,
    @subtopic_id = 1,
    @assessment_date = '2024-09-26', 
    @score = 85.00, 
    @question = 'What is the SQL command to create a new table?', 
    @option1 = 'CREATE TABLE', 
    @option2 = 'INSERT INTO', 
    @option3 = 'UPDATE TABLE', 
    @option4 = 'DELETE FROM', 
    @correct_answer = 'CREATE TABLE',
    @evaluation_type = 'Quiz',
    @evaluation_score = 85.00,
    @report_type = 'Quiz';
	EXEC add_assessment_and_update 
    @user_id = 2,  
    @topic_id = 2,
    @subtopic_id = 1,
    @assessment_date = '2024-09-26', 
    @score = 80.00, 
    @question = 'How do you insert a new record into a table in SQL?', 
    @option1 = 'INSERT INTO', 
    @option2 = 'UPDATE TABLE', 
    @option3 = 'DELETE FROM', 
    @option4 = 'SELECT FROM', 
    @correct_answer = 'INSERT INTO',
    @evaluation_type = 'Quiz',
    @evaluation_score = 90.00,
    @report_type = 'Quiz';

 ---------------------------------------------------------------------
SELECT * FROM assessments;
SELECT * FROM test_assessments;
SELECT * FROM evaluation_assessments;
SELECT * FROM report_assessments;
SELECT * FROM ranking_assessments;




create procedure createfeedbackandresponses
    @user_id int,
    @task_id int,
    @feedback_text text
as
begin
    declare @feedback_id int;
    -- Insert feedback
    insert into feedback (user_id,task_id, feedback_text, feedback_date)
    values (@user_id, @task_id, @feedback_text, getdate());
    set @feedback_id = scope_identity();
    -- No response insertion since the response table has been dropped
end;
-- Execute the procedure
exec createfeedbackandresponses
    @user_id = 1,  -- Use the ID of the newly created user
    @task_id = 1,  -- assuming task_id 1 exists
    @feedback_text = 'lack in all';


	select * from feedback



	create proc 







drop table test_assessments
drop table evaluation_assessments
drop table report_assessments
drop table assessments
drop table ranking_assessments
drop table report_assessments
drop table questions
drop table answers















/*create table assessments (
    assessment_id int primary key identity(1,1),
    user_id int,
    topic_id int,
	subtopic_id int,
    assessment_date date,
    score decimal(5, 2),
    foreign key (user_id) references users(user_id),
    foreign key (topic_id,subtopic_id) references topics(topic_id,subtopic_id)
);
create table create_assessment (
    create_id int primary key identity(1,1),
    assessment_id int,
    details text,
    foreign key (assessment_id) references assessments(assessment_id)
);
create table test_assessment (
    test_id int primary key identity(1,1),
    assessment_id int,
    test_details text,
    foreign key (assessment_id) references assessments(assessment_id)
);
create table evaluation_assessment (
    evaluation_id int primary key identity(1,1),
    assessment_id int,
    evaluation_details text,
    foreign key (assessment_id) references assessments(assessment_id)
);
create table rankingassessment (
    ranking_id int primary key identity(1,1),
    assessment_id int,
	user_id int,
    rank int,
	foreign key(user_id)references users (user_id),
    foreign key (assessment_id) references assessments(assessment_id)
);



create table questions(
question_id int primary key identity(1,1),
assessment_id int,
question_text nvarchar(500) not null,
question_type nvarchar(50)not null,
foreign key (assessment_id) references assessments(assessment_id)
);


create table answers(
answer_id int primary key identity(1,1),
question_id int,
answer_text nvarchar(500) not null,
is_correct bit null,
foreign key (question_id)references questions(question_id)
);
create table report_assessment (
    report_id int primary key identity(1,1),
    assessment_id int,
    report_details text,
    foreign key (assessment_id) references assessments(assessment_id)
);
create table feedback (
    feedback_id int primary key identity(1,1),
    user_id int,
    task_id int,
    feedback_text text,
    feedback_date date,
    foreign key (user_id) references users(user_id),
    foreign key (task_id) references tasks(id)
);
create table createfeedback (
    create_feedback_id int primary key identity(1,1),
    feedback_id int,
    details text,
    foreign key (feedback_id) references feedback(feedback_id)
);
 
create PROCEDURE addassessmentandupdate
    @user_id INT,
    @topic_id INT,
	@subtopic_id int,
    @assessment_date DATE,
    @score DECIMAL(5, 2),
    @test_details TEXT,
    @evaluation_details TEXT,
    @report_details TEXT
AS
BEGIN
    DECLARE @assessment_id INT;
    INSERT INTO assessments (user_id, topic_id,subtopic_id, assessment_date, score)
    VALUES (@user_id, @topic_id,@subtopic_id, @assessment_date, @score);
 
    SET @assessment_id = SCOPE_IDENTITY();
 
    DECLARE @rank INT;
 
    SELECT @rank = RANK() OVER (ORDER BY score DESC)
    FROM assessments
    WHERE topic_id = @topic_id;
 
    INSERT INTO rankingassessment (assessment_id,user_id, rank) 
    VALUES (@assessment_id,@user_id, @rank);
 
 
    INSERT INTO test_assessment (assessment_id, test_details) 
    VALUES (@assessment_id, @test_details);
    INSERT INTO evaluation_assessment (assessment_id, evaluation_details) 
    VALUES (@assessment_id, @evaluation_details);
    INSERT INTO report_assessment (assessment_id, report_details) 
    VALUES (@assessment_id, @report_details);
END;
 
EXEC addassessmentandupdate 
    @user_id = 1,  
    @topic_id = 1,
	@subtopic_id=1,
    @assessment_date = '2024-09-26', 
    @score = 85.00, 
    @test_details = 'Test on SQL Basics', 
    @evaluation_details = 'Good understanding of SQL', 
    @report_details = 'Passed with a score of 85';

	select * from assessments
	select * from report_assessment
	select * from test_assessment
	select * from rankingassessment
	select * from evaluation_assessment

	select a.assessment_id,u.username,a.assessment_date,a.score from assessments a
	join users u on a.user_id=u.user_id
	*/