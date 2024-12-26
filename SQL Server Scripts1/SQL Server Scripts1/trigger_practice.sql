create table E(
EmpId int primary key,
Empname nvarchar(10),
DepId int Foreign Key references D(DepId));
 
create table D(
depid int primary key,
depName varchar(10));
 
insert into D
values
(1,'IT'),
(2,'Finance'),
(3,'HR');
 
insert into E
values
(1,'vember',1),
(2,'rajasher',1),
(3,'vaishnavi',2),
(4,'suresh',3),
(5,'Harshitha',2);
 
 
 
create view ViewED
as
select E.EmpId,E.Empname,D.depid,D.depName
from E
join D on E.DepId = D.depid
 
 select * from e
 select * from d
 
 
 select * from ViewED
 update ViewED
 set depName='it'
 where depid=3
alter Trigger Trg_insteadofUpdate
on ViewED
instead of update 
as
begin

declare @emp_id int, @empname nvarchar(100);
declare @deptid int;
select @emp_id= empid, @empname= empname,@deptid = depid
from inserted;


select * from ViewED
update e
set Empname = @empname,
DepId=@deptid
where empid = @emp_id;

end;
 
Update ViewED
set depName = 'Finance',depid=2
where EmpId = 5;
 
 
select * from E
Select * from D
Select * from ViewED