select * from students;

-- Insert values to the Studnets

-- Insert values
insert into students(id, student_name, age, city) values (1, "Prasanna Sundaram", 35, "Chennai");
insert into students(id, student_name, age, city) values (2, "Sundaram", 65, "Chennai");

-- in the above case, we are putting the id manually, however providing the id manually will result in cumbersome
-- it has to be auto-pupulated
-- Lets alter the table, in such a way that key is auto incremented
-- Auto increment column must be indexed, meaning it needs to be either A Primary Key or A Unique Key

alter table students
modify column id int not null auto_increment,
add primary key(id);

-- so now, we have added the PK with auto increment, let take a look at the table structure
describe students;

-- Having said that, we have auto increment in place, now needn't want to provide the id value while inserting the record

insert into students (student_name, age, city)
values 
("Sundar", 65, "Chennai"),
("Indra", 60, "Chennai"),
("Sri Vatsan", 17, "Chennai"),
("Ganesh", 27, "Pune");

-- Lets visit the table post insert

select * from students;

-- We know that column `ID` is now the PK, it will not allow to duplicate it
-- Execution of the below query will result in error
-- Error Code: 1062. Duplicate entry '1' for key 'students.PRIMARY'
insert into students(id, student_name, age, city) values (1, "Sundaram Seetharaman", 35, "Chennai");

-- updating the table
-- We know that, 3 record in our table having the student_name as Sundar, lets have it updated with a new name
update students set student_name="Sundaram Seetharam" where id = 3;
-- Simillary, we can also update multiple columns
-- As an illustration lets insert few more rows
insert into students (student_name, age, city)
values 
("Radha", 38, "Coimbatore"),
("Hari", 40, "Coimbatore");

select * from students;

update students set student_name="Radha Lakshmi", age = 39 where id=7;

select * from students;

-- It is possible to update multiple rows as well, this can be acheived by CASE statements

update students
set 
	student_name = case id
					when 7 then "Radha Lakshmi S"
                    when 8 then "Hariharan"
				   end,
	age = case id
			when 7 then 37
            when 8 then 47
		end
where id in (7, 8);

select * from students;

-- deleting a record 

delete from students where id = 8;

select * from students;

-- lets try deleting the record which does not exits
-- The query execution will still be successfull, will show 0 row(s) affected

delete from students where id = 8;

commit;
