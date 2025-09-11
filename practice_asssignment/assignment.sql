-- Select all records 
select * from customer_details;

-- List all customers who are from 'New York City, New York'.
select * from customer_details where City="New York City, New York";

-- Find all customers who hold a 'Gold' credit card with a limit ≥ $500,000.
select * from customer_details where Credit_Card_Product="Gold" and Cust_Limit>=500000;

-- Count the number of customers in each Segment.
select 
	Segment,
    count(*) as customer_count
from customer_details
	group by Segment
    order by customer_count desc;
    
-- Find the average age of customers for each City.
select City, avg(Age) as avg_age from customer_details group by City;

--  List the 5 youngest customers along with their Credit Card Product and Limit.
select id, Customer, Age, Credit_Card_Product, Cust_Limit
from customer_details
order by age asc
limit 5;

-- Find the number of customers holding each type of Credit Card Product

select Credit_Card_Product, count(*) as customer_count from customer_details group by Credit_Card_Product order by customer_count desc;

-- List all customers who are younger than 18 and have a Limit > $100,000.
select * from customer_details where Age < 18 and Cust_Limit > 100000;

-- Which Segment has the highest average Credit Card Limit?
select Segment, avg(Cust_Limit) as avg_limit from customer_details group by Segment order by avg_limit desc limit 1;

-- Find the cities with more than 5 customers.
select City, count(*) as customer_count from customer_details group by City having customer_count > 5;

-- List customers whose names start with 'J' and who are from 'Chicago, Illinois'.
Select * from customer_details where Customer like "J%" and City="Chicago, Illinois";

-- Find the Segment with the highest number of 'Silver' Credit Card holders.
-- Error Code: 1054. Unknown column 'Segment' in 'field list'

Select Segment, count(*) as segment_count from customer_details 
where Credit_Card_Product="Silver" group by Segment order by segment_count desc limit 1;