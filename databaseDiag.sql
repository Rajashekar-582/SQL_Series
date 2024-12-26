create database q
use q
create table users (
    user_id int primary key identity(1,1),
    username varchar(50) not null,
    email varchar(100) not null unique,
    role varchar(20) not null check (role in ('admin', 'user')),
    created_at datetime default current_timestamp
);
insert into users (username, email, role) values
('john_doe', 'john@example.com', 'user'),
('jane_smith', 'jane@example.com', 'user'),
('alice_jones', 'alice@example.com', 'user');

create table tasks (
    task_id int primary key identity(1,1),
    task_name varchar(100) not null,
	topic varchar(100),
    subtopic varchar(100),
    activity text,
    hourstaken decimal(5, 2),
    description text,
    assigned_to int,
    due_date date,
	created_at datetime default current_timestamp,
    status varchar(20) not null check (status in ('pending', 'completed', 'in-progress')),
    foreign key (assigned_to) references users(user_id)
);
create table weektimesheet (
    week_id int primary key identity(1,1),
    user_id int,
    week_start_date date,
    week_end_date date,
    foreign key (user_id) references users(user_id)
);
create table dailyworkhours (
    entry_id int primary key identity(1,1),
    user_id int,
    work_date date,
    hours_worked decimal(5, 2),
    week_id int,
    foreign key (user_id) references users(user_id),
    foreign key (week_id) references weektimesheet(week_id)
);
--select * from dailyworkhours
create table timesheet (
    timesheet_id int primary key identity(1,1),
    week_id int,
    task_id int,
    hours_worked_per_month decimal(5, 2),
    foreign key (week_id) references weektimesheet(week_id),
    foreign key (task_id) references tasks(task_id)
);
create table learningprogress (
    progress_id int primary key identity(1,1),
    user_id int,
    topic_id int,
    progress_percentage decimal(5, 2),
    foreign key (user_id) references users(user_id)
);
create table topics (
    topic_id int primary key identity(1,1),
    topic_name varchar(100) not null
);
insert into topics (topic_name) values
('Artificial Intelligence'),
('Machine Learning'),
('Data Science'),
('Web Development'),
('Cybersecurity');

create table assessments (
    assessment_id int primary key identity(1,1),
    user_id int,
    topic_id int,
    assessment_date date,
    score decimal(5, 2),
    foreign key (user_id) references users(user_id),
    foreign key (topic_id) references topics(topic_id)
);
create table createassessment (
    create_id int primary key identity(1,1),
    assessment_id int,
    details text,
    foreign key (assessment_id) references assessments(assessment_id)
);
create table testassessment (
    test_id int primary key identity(1,1),
    assessment_id int,
    test_details text,
    foreign key (assessment_id) references assessments(assessment_id)
);
create table evaluationassessment (
    evaluation_id int primary key identity(1,1),
    assessment_id int,
    evaluation_details text,
    foreign key (assessment_id) references assessments(assessment_id)
);
create table rankingassessment (
    ranking_id int primary key identity(1,1),
    assessment_id int,
    rank int,
    foreign key (assessment_id) references assessments(assessment_id)
);
create table reportassessment (
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
    foreign key (task_id) references tasks(task_id)
);
create table createfeedback (
    create_feedback_id int primary key identity(1,1),
    feedback_id int,
    details text,
    foreign key (feedback_id) references feedback(feedback_id)
);
create table responses (
    response_id int primary key identity(1,1),
    form_id int,
    user_id int,
    response_text text,
    response_date date,
    foreign key (user_id) references users(user_id)
);
 

create procedure addtaskandupdatetimesheetdailys
   @task_name varchar(100),
   @description text,
   @assigned_to int,
   @due_date date,
   @hours_worked decimal(5, 2), -- hours worked on that particular day
   @work_date date,
   @topic varchar(100) -- new parameter for topic
as
begin
   declare @task_id int;
   declare @week_start date = dateadd(day, -datepart(weekday, @work_date) + 1, @work_date);
   declare @week_end date = dateadd(day, 7 - datepart(weekday, @work_date), @work_date);
   declare @week_id int;
 
   -- Insert the new task
   insert into tasks (task_name, description, assigned_to, due_date, status, created_at, hourstaken, topic)
   values (@task_name, @description, @assigned_to, @due_date, 'pending', getdate(), @hours_worked, @topic);
   set @task_id = scope_identity();
 
   -- Check if a week entry exists for the user in the current week
   select @week_id = week_id
   from weektimesheet
   where user_id = @assigned_to
     and week_start_date = @week_start
     and week_end_date = @week_end;
 
   -- If no week entry exists, create one
   if @week_id is null
   begin
       insert into weektimesheet (user_id, week_start_date, week_end_date)
       values (@assigned_to, @week_start, @week_end);
       set @week_id = scope_identity();
   end
 
   -- Insert daily work hours
   insert into dailyworkhours (user_id, work_date, hours_worked, week_id)
   values (@assigned_to, @work_date, @hours_worked, @week_id);
 
   -- Optional: update the task's total hours taken
   update tasks
   set hourstaken = (select sum(hours_worked)
                     from dailyworkhours
                     where user_id = @assigned_to)
   where task_id = @task_id;
 
   -- Insert into timesheet
   insert into timesheet (week_id, task_id, hours_worked_per_month)
   values (@week_id, @task_id, @hours_worked * 30);  -- approximate monthly hours
 
   -- Return the task details
   select * from tasks where task_id = @task_id;
end;
exec addtaskandupdatetimesheetdailys
   @task_name = 'develop new feature',
   @description = 'implement the new user authentication feature.',
   @assigned_to = 2,  
   @due_date = '2024-10-15',
   @hours_worked = 4.00,
   @work_date = '2024-09-26',
   @topic = 'Authentication';
 
create procedure addassessmentandupdate
    @user_id int,
    @topic_id int,
    @assessment_date date,
    @score decimal(5, 2),
    @details text,
    @test_details text,
    @evaluation_details text,
    @report_details text
as
begin
    declare @assessment_id int;
    -- insert new assessment
    insert into assessments (user_id, topic_id, assessment_date, score)
    values (@user_id, @topic_id, @assessment_date, @score);
    set @assessment_id = scope_identity();
    -- insert into related tables
    insert into createassessment (assessment_id, details) values (@assessment_id, @details);
    insert into testassessment (assessment_id, test_details) values (@assessment_id, @test_details);
    insert into evaluationassessment (assessment_id, evaluation_details) values (@assessment_id, @evaluation_details);
    insert into reportassessment (assessment_id, report_details) values (@assessment_id, @report_details);
end;
exec addassessmentandupdate
    @user_id = 1,  -- assuming user_id 1 exists
    @topic_id = 2,  -- assuming topic_id 2 exists
    @assessment_date = '2024-09-30',
    @score = 85.50,
    @details = 'assessment on user authentication completed successfully.',
    @test_details = 'test cases executed: 10, passed: 9, failed: 1.',
    @evaluation_details = 'overall performance satisfactory.',
    @report_details = 'assessment report generated and sent to user.';

create procedure createfeedbackandresponse
    @user_id int,
    @task_id int,
    @feedback_text text,
    @response_text text
as
begin
    declare @feedback_id int;
    -- insert feedback
    insert into feedback (user_id, task_id, feedback_text, feedback_date)
    values (@user_id, @task_id, @feedback_text, getdate());
    set @feedback_id = scope_identity();
    -- insert response
    insert into createfeedback (feedback_id, details)
    values (@feedback_id, @response_text);
end;
 
exec createfeedbackandresponse
    @user_id = 1,  
    @task_id = 1,  
    @feedback_text = 'great job on the feature implementation!',
    @response_text = 'thank you for the feedback!';
select * from tasks
select * from weektimesheet
insert into users (username, email, role) values
('new_user', 'new_user@example.com', 'user');



CREATE PROCEDURE UpdateLearningProgress
    @TopicID INT,
    @SubTopicName NVARCHAR(100),
    @UserID INT,
    @Session VARCHAR(25),
    @Video VARCHAR(25),
    @Practice VARCHAR(25),
    @Assessment VARCHAR(25)
AS
BEGIN
    -- Ensure Learning_Progress table has the correct topic_id and subtopic_id
    IF NOT EXISTS (SELECT 1 FROM Learning_Progress WHERE topic_id = @TopicID AND subtopic_id = (SELECT subtopic_id FROM Topics WHERE subtopic_name = @SubTopicName))
    BEGIN
        INSERT INTO Learning_Progress (topic_id, user_id, subtopic_id, startedon)
        VALUES (@TopicID, @UserID, (SELECT subtopic_id FROM Topics WHERE subtopic_name = @SubTopicName), GETDATE());
    END

    -- Insert into Topics table
    INSERT INTO Topics (topic_id, subtopic_name, user_id, [session], [video], [Practice], [Assessment])
    VALUES (@TopicID, @SubTopicName, @UserID, @Session, @Video, @Practice, @Assessment);

    -- Update Learning_Progress table
    UPDATE lp
    SET lp.progress_percentage = 
        CASE 
            WHEN t.[session] = 'Completed' AND t.[video] = 'Completed' AND t.[Practice] = 'Completed' AND t.[Assessment] = 'Completed' THEN 100.00
            WHEN t.[session] = 'Completed' AND t.[video] = 'Completed' AND t.[Practice] = 'Completed' THEN 75.00
            WHEN t.[session] = 'Completed' AND t.[video] = 'Completed' THEN 50.00
            WHEN t.[session] = 'Completed' THEN 25.00
            ELSE 0.00
        END
    FROM Learning_Progress lp
    JOIN Topics t ON lp.topic_id = t.topic_id AND lp.subtopic_id = t.subtopic_id;

    -- Update Learning_Progress table
    UPDATE Learning_Progress
    SET topic_id = @TopicID,
        subtopic_id = (SELECT subtopic_id FROM Topics WHERE subtopic_name = @SubTopicName),
        user_id = @UserID,
        startedon = GETDATE()
    WHERE user_id = @UserID AND topic_id = @TopicID;
END;