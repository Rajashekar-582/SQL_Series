create table empl
(
id int primary key identity,
[name] nvarchar(50),
email nvarchar(50),
department nvarchar(50))

set nocount on
declare @counter int =1
while (@counter<=1000000)
begin
declare @name nvarchar(50)='ABC' +RTRIM(@counter)
declare @email nvarchar(50)='abc'+RTRIM(@counter)+'@quadranth.com'
declare @dept nvarchar(50)='dept'+RTRIM(@counter)

insert into empl values (@name,@email,@dept)
set @counter=@counter+1

if (@counter%100000=0)
	print RTRIM(@counter)+ 'row inserted'
end


select * from empl where id=932000

select * from empl where name='ABC932000'