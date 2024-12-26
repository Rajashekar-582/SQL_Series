create database dim
use dim

create table dimProduct
(
productid int primary key,
productname nvarchar(25) not null,
category nvarchar(25) not null
);

create table dimcustomer
(
customerid int primary key,
customername nvarchar(25) not null,
location nvarchar(25) not null
);

create table factsales
(
salesid int identity(1,1) primary key,
productid int not null,
customerid int not null,
quantity int not null,
saledate date not null,
foreign key (productid) references dimProduct(productid),
foreign key(customerid) references dimcustomer(customerid)
);

create trigger trg_insertdimproduct
on dimproduct
after insert
as
begin
	insert into factsales (productid,customerid,quantity,saledate)
	select productid,(select top 1 customerid from dimcustomer order by customerid),1,getdate() from inserted;

	print('Trigger executed:new product added,entry inserted intofactsales');
end;

create trigger trg_insertdimcustomer
on dimcustomer
after insert
as
begin
insert into factsales (productid,customerid,quantity,saledate)
	select customerid,(select top 1 customerid from dimproduct order by customerid),1,getdate() from inserted;
		print('Trigger executed:new customer added,entry inserted intofactsales');
end;

insert into dimProduct(productid,productname,category) values(1,'tv','electronic');