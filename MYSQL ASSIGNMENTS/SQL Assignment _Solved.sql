#SELECT clause with WHERE, AND,DISTINCT, Wild Card (LIKE)
#1.	Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with  employeenumber 1102
use classicmodels;
select * from employees;
select employeeNumber,firstName,LastName From employees 
where jobTitle="Sales Rep" and reportsTo=1102;

#2.	Show the unique productline values containing the word cars at the end from the products table.
select distinct productLine from productlines where productLine like '%Cars';


#CASE STATEMENTS for Segmentation
#. 1. Using a CASE statement, segment customers into three categories based on their country
select * from customers;
select customerNumber,customerName,
case when country in ("USA","CANADA") then "North America"
when country in ("UK","France","Germany") then "Europe"
else "Other"
end as CustomerSegment from customers;


#Group By with Aggregation functions and Having clause, Date and Time functions
#1.	Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.
select * from orderdetails;
select productcode,sum(quantityOrdered)as Total_Ordered from orderdetails
group by productcode
order by Total_Ordered desc
limit 10;

#2.	Company wants to analyze payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20

select * from payments;
select monthname("2024-01-01");
select monthname(paymentDate) as Payment_month,count(*) as Num_Payments from Payments
group by payment_month,month(paymentdate)
having count(*)>20
order by month(paymentdate);



#CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
#1.	Create a new database named Customers_Orders and add the following tables as per the description

#a.	Create a table named Customers to store customer information.

create database customers_orders;
use customers_orders;


create table Customers (Customer_id int primary key auto_increment,
First_Name varchar(50) Not Null,
Last_Name varchar(50) Not Null,
Email varchar(255) unique ,
Phone_Number varchar(20));

desc customers;

#b.	Create a table named Orders to store information about customer orders. Include the following columns:

create table Orders(Order_id int primary key auto_increment,
customer_id int ,
order_date date,
Total_Amount decimal(10,2) check(Total_Amount>0),
foreign key Orders(customer_id) references customers(customer_id));
desc orders;

#Joins
#1.	List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)

Use classicmodels;
select customers.country,count(orders.orderNumber) as order_count
 from customers inner join orders
 on (customers.customerNumber = orders.customerNumber)
group by customers.country  
order by order_count desc 
limit 5;

#SELF JOIN
#2.	Create a table project with below fields.

create table Project (Employee_id int primary key auto_increment,
FullName varchar(50) not null, Gender varchar(15) check (Gender in ("Male","Female")),
Manager_Id int);
desc project;

insert into Project (Employee_id,FullName,Gender,Manager_Id) values
(1,"Pranaya","Male",3),
(2,"Priyanka","Female",1),
(3,"Preety","Female",null),
(4,"Anurag","Male",1),
(5,"Sambit","Male",1),
(6,"Rajesh","Male",3),
(7,"Hina","Female",3);
select * from Project;

select 
emp.fullname as Managername,
mgr.fullname as Employeename
from Project emp inner join Project Mgr on (emp.employee_id=Mgr.Manager_id);

#DDL Commands: Create, Alter, Rename

create table Facility(Facility_id int, Name varchar(100),State varchar(100),Country varchar(100));
alter table Facility modify column Facility_id int primary key auto_increment;
desc facility;
alter table Facility add column City varchar(100) not null after name;

#Views in SQL
#1.	Create a view named product_category_sales that provides insights into sales performance by product category. This view should include the following information:
use classicmodels;
#create view Product_category_sales as 
select pl.productline,sum(od.quantityordered*od.priceEach)as Total_sales,count(distinct o.orderNumber) as Number_of_Orders 
from products p join orderdetails od 
on p.productcode=od.productcode
join orders o 
on od.ordernumber=o.ordernumber
join productlines pl 
on p.productline=pl.productline
group by pl.productLine;



#Window functions - Rank, dense_rank, lead and lag
use classicmodels;
select customers.CustomerName,count(orders.orderNumber) as Order_Count, 
dense_rank() over (order by count(orders.orderNumber)desc)as order_frequency_rnk 
from customers inner join orders 
on (customers.customerNumber=orders.customerNumber)
group by customerName;
 
 
 select C.CustomerName,count(o.orderNumber)as order_count,
 rank()over (order by count(o.OrderNumber)desc)as order_frequency_rnk
 from customers c inner join orders o 
 on c.customerNumber=o.customerNumber
 group by C.customerName;


#Stored Procedures in SQL with parameters

select* from customers;
select  year(p.paymentdate) as Year, cu.country as Country,Sum(p.amount) as TotalAmount 
from customers cu inner join  payments p 
on (cu.customerNumber=p.customerNumber)
where year(p.paymentdate) = Year and cu.country = Country
group by year,country;

call Get_country_payments(2003,"France");

create procedure Get_Country_Payments(year int,country varchar(225))
begin 
end;

#1b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.
use classicmodels;
select year(orderDate)as Year, date_format(orderDate,"%M")as Month, count(orderNumber) as "Total orders",
lag(count(orderNumber),1)over(order by year(orderDate),month(orderDate)) as "Previous",
concat(round((count(orderNumber)-lag(count(orderNumber),1)over(order by year(orderDate),month(orderDate)))/lag(count(orderNumber),1)over(order by year(orderDate),month(orderDate))*100),"%") as "% YOY Change"
 from orders
group by year(orderDate),date_format(orderDate,"%M"),month(orderDate);

#Subqueries and their applications

select productline,count(productline) as Total
from products where MSRP > (select avg(MSRP) from products) group by productline order by Total desc;

#ERROR HANDLING in SQL
create table EMP_EH (EMPID int primary key,Empname varchar(50),EmailAddress varchar (50));
insert into emp_eh (empid,empname,emailaddress) values(1, "Ram", "ram_1@gmail.com"),
(2,"Varun","varun_2@gmail.com");
select * from emp_eh;

##Stored Procedure ## 
#CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Duplicate_values`(empid int)
#begin 
#declare continue handler for 1062
#begin
#select 'Error Occured' as message;
#end;
#insert into EMP_EH(EMPID) values(empid);
#end
#Result:
#call classicmodels.Proc_Duplicate_values(2);


##TRIGGERS##
create table Emp_BIT (Name varchar(50),Occupation varchar(50),Working_Date date, Working_Hours int);
insert into emp_bit (name,occupation,working_date,working_hours)values
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11); 
insert into emp_bit (working_hours) values(-20);
select* from emp_bit; 

#CREATE DEFINER=`root`@`localhost` TRIGGER `emp_bit_BEFORE_INSERT` BEFORE INSERT ON `emp_bit` FOR EACH ROW BEGIN
#if new.working_hours<=0 then set new.working_hours = ABS(new.Working_Hours);
#END IF;
#end



