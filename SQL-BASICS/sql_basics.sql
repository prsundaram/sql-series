create database mysql_series; -- Create a database

commit; -- commit it

use mysql_series; -- select the database

-- Create table

create table student(id int, student_name varchar(100), age int);

select * from student;

-- Alter table

alter table student add column city varchar(10);

-- Rename the table 
rename table student to students;

-- Read the records
select * from students;

-- Truncate --> Removes all the record from the table, however, it retains the table structure
truncate table students;

select * from students;

-- Delete the table

drop table students;

