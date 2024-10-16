-- Hey all these are some leetcode style questions that I got asked during my interviews with tech companies!
-- Give them a shot and let me know if you find them difficult! :)
-- Remeber to create your schema called myownschema!
--------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATE SCHEMA myownschema;

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Run this once!
DROP TABLE myownschema.numbers;

CREATE TABLE myownschema.numbers (
	index INT
);

INSERT INTO myownschema.numbers (index)
VALUES
	(1),
	(2),
	(3),
	(4),
	(6),
	(7),
	(9),
	(10),
	(12),
	(16);
-- Explore the table:

SELECT *
FROM myownschema.numbers;

-- Q1: Write a SQL query to find only the numbers that start a sequence of at least three consecutive numbers in the table. 
-- Form the additional two columns to illustrate the sequence of at least three consecutive numbers. Do not include numbers that can't form three consecutive numbers.

-- For example, your output should look something like this.

/*
col1 col2 col3
4    5    6
10   11   12
*/

-- Answer
SELECT * 
FROM myownschema.numbers AS col1
INNER JOIN myownschema.numbers AS col2 
		ON col1.index + 1 = col2.index
INNER JOIN myownschema.numbers AS col3
		ON col2.index + 1 = col3.index;
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Run these once!

CREATE TABLE myownschema.stars (
	star VARCHAR(1)
);

INSERT INTO myownschema.stars (star)
VALUES (
	('*')
);

-- Explore the table:
SELECT *
FROM myownschema.stars;

-- Q2: Form a triangle that has three rows, 3 stars at the top row and 1 star at the bottom row and rectangle with 3 rows and 2 columns using this table only.

-- Rectangle Answer:
(
SELECT * 
FROM myownschema.stars AS col1
INNER JOIN myownschema.stars AS col2
		ON col1.star = col2.star
)
UNION ALL
(
SELECT * 
FROM myownschema.stars AS col1
INNER JOIN myownschema.stars AS col2
		ON col1.star = col2.star
)
UNION ALL
(
SELECT * 
FROM myownschema.stars AS col1
INNER JOIN myownschema.stars AS col2
		ON col1.star = col2.star
)

-- Triangle Answer: 
(
SELECT * 
FROM myownschema.stars AS col1
INNER JOIN myownschema.stars AS col2
		ON col1.star = col2.star
INNER JOIN myownschema.stars AS col3
		ON col2.star = col3.star
)
UNION ALL
(
SELECT *, '' 
FROM myownschema.stars AS col1
INNER JOIN myownschema.stars AS col2
		ON col1.star = col2.star
)
UNION ALL
(
SELECT *,'','' 
FROM myownschema.stars AS col1
)

-- EG
DROP TABLE myownschema.shapes;
CREATE TABLE myownschema.shapes(
	shapes TEXT
);
INSERT INTO myownschema.shapes (shapes)
VALUES
	('Circle'),
	('Square'),
	('Triangle'),
	('Rectangle'),
	('Polygon');
SELECT * FROM myownschema.shapes;

SELECT *
FROM myownschema.shapes AS shapes1
INNER JOIN myownschema.shapes AS shapes2
		ON shapes1.shapes = shapes2.shapes;
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Q3:

-- New TikTok users sign up with their emails. They confirmed their signup by replying to the text confirmation to activate their accounts. Users may receive multiple text messages 
-- for account confirmation until they have confirmed their new account.

-- A senior analyst is interested to know the activation rate of specified users in the emails table. Write a query to find the activation rate. Round the percentage to 2 decimal places.

-- Definitions:

-- emails table contain the information of user signup details.
-- texts table contains the users' activation information.
-- Assumptions:

-- The analyst is interested in the activation rate of specific users in the emails table, which may not include all users that could potentially be found in the texts table.
-- For example, user 123 in the emails table may not be in the texts table and vice versa.

-- Create emails table
CREATE TABLE myownschema.emails (
    email_id INT,
    user_id INT,
    signup_date TIMESTAMP
);

-- Create texts table
CREATE TABLE myownschema.texts (
    text_id INT,
    email_id INT,
    signup_action VARCHAR(20)
);

-- Insert sample data into emails table
INSERT INTO myownschema.emails (email_id, user_id, signup_date)
VALUES
(125, 7771, '2022-06-14 00:00:00'),
(236, 6950, '2022-07-01 00:00:00'),
(433, 1052, '2022-07-09 00:00:00');

-- Insert sample data into texts table
INSERT INTO myownschema.texts (text_id, email_id, signup_action)
VALUES
(6878, 125, 'Confirmed'),
(6920, 236, 'Not Confirmed'),
(6994, 236, 'Confirmed');

-- Explore: 
SELECT *
FROM myownschema.emails;

SELECT *
FROM myownschema.texts;

-- Answer:
SELECT *
FROM myownschema.emails
FULL JOIN myownschema.texts ON emails.email_id = texts.email_id;

--Perma joint table
CREATE TABLE myownschema.joined AS
SELECT
	e.email_id,
    e.user_id,
    e.signup_date,
    t.text_id,
    t.signup_action
FROM myownschema.emails AS e
FULL JOIN myownschema.texts AS t ON e.email_id = t.email_id;

SELECT *
FROM myownschema.joined;

SELECT signup_action, COUNT(*) AS ocurrence
FROM myownschema.joined
GROUP BY signup_action
ORDER BY ocurrence DESC;

--including null value
SELECT 
    (COUNT(CASE WHEN signup_action = 'Confirmed' THEN 1 END) * 100.0 / COUNT(*)) AS activation_rate
FROM 
    myownschema.joined; 
--50%

--excluding null value
SELECT 
    (COUNT(CASE WHEN signup_action = 'Confirmed' THEN 1 END) * 100.0 / 
    NULLIF(COUNT(CASE WHEN signup_action IS NOT NULL THEN 1 END), 0)) AS activation_rate
	--NULLIF(x,0) prevents division by 0 by returning null value if there are 0 rows
FROM 
    myownschema.joined;
--66.67%

--Model Ans 
SELECT 
    ROUND(
        (COUNT(DISTINCT CASE WHEN t.signup_action = 'Confirmed' THEN e.email_id END) * 100.0) /
        NULLIF(COUNT(DISTINCT e.email_id), 0), 
        2
    ) AS activation_rate
FROM 
    myownschema.emails e
FULL JOIN 
    myownschema.texts t ON e.email_id = t.email_id;
--66.67%
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Q4:
-- Zomato is a leading online food delivery service that connects users with various restaurants and cuisines, allowing them to browse menus, place orders, and get meals delivered to their doorsteps.

-- Recently, Zomato encountered an issue with their delivery system. Due to an error in the delivery driver instructions, each item's order was swapped with the item in the subsequent row. 
-- As a data analyst, you're asked to correct this swapping error and return the proper pairing of order ID and item.

-- If the last item has an odd order ID, it should remain as the last item in the corrected data. For example, if the last item is Order ID 7 Tandoori Chicken, 
-- then it should remain as Order ID 7 in the corrected data.

-- In the results, return the correct pairs of order IDs and items.
DROP TABLE myownschema.zomato_orders;
CREATE TABLE myownschema.zomato_orders (
    order_id INT,
    item VARCHAR(100)
);

INSERT INTO myownschema.zomato_orders (order_id, item)
VALUES
(1, 'Chow Mein'),
(2, 'Pizza'),
(3, 'Pad Thai'),
(4, 'Butter Chicken'),
(5, 'Eggrolls'),
(6, 'Burger'),
(7, 'Tandoori Chicken');

-- Explore:
SELECT *
FROM myownschema.zomato_orders;

-- Answer:
UPDATE myownschema.zomato_orders AS current
SET item = (
    SELECT item
    FROM myownschema.zomato_orders AS next
    WHERE next.order_id = current.order_id + 1
)
WHERE current.order_id < (SELECT MAX(order_id) FROM myownschema.zomato_orders)
OR (
    current.order_id = (SELECT MAX(order_id) FROM myownschema.zomato_orders) 
    AND (SELECT MAX(order_id) FROM myownschema.zomato_orders) % 2 = 0
);

SELECT *
FROM myownschema.zomato_orders;


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Q5:
-- Assume you're given a table containing information about Wayfair user transactions for different products. Write a query to calculate the year-on-year growth rate for the total 
-- spend of each product, grouping the results by product ID.

-- The output should include the year in ascending order, product ID, current year's spend, previous year's spend and year-on-year growth percentage, rounded to 2 decimal places.
DROP TABLE myownschema.user_transactions;
CREATE TABLE myownschema.user_transactions (
    transaction_id INT,
    product_id INT,
    spend DECIMAL(10, 2),
    transaction_date TIMESTAMP
);

INSERT INTO myownschema.user_transactions (transaction_id, product_id, spend, transaction_date)
VALUES
(1341, 123424, 1500.60, '2019-12-31 12:00:00'),
(1423, 123424, 1000.20, '2020-12-31 12:00:00'),
(1623, 123424, 1246.44, '2021-12-31 12:00:00'),
(1322, 123424, 2145.32, '2022-12-31 12:00:00');

-- Explore:

SELECT *
FROM myownschema.user_transactions;

-- Answer:
-- flat value
SELECT 
    *, 
    spend - LAG(spend, 1) OVER (ORDER BY transaction_date) AS Growth_Rate
FROM 
    myownschema.user_transactions;

--as a percentage
SELECT 
    *, 
    ((spend - LAG(spend, 1) OVER (ORDER BY transaction_date)) / LAG(spend, 1) OVER (ORDER BY transaction_date)) * 100 AS Growth_Rate_P
FROM 
    myownschema.user_transactions;



--------------------------------------------------------------------------------------------------------------------------------------------------

-- Q6

-- Imagine you work at Netflix and you have 3 tables to work with:

-- Instructions:

-- Your task is to find the top 3 highest-rated actors for every single customer, their corresponding movie name, 
-- alongside the ratings the customer gave and ranking based on the rating

-- Table for actsin
-- A bridging table
CREATE TABLE myownschema.actsin (
    actor_id INT,
    rental_id INT
);

-- Table for renting
CREATE TABLE myownschema.renting (
    rental_id INT,
    rating DECIMAL(2, 1),
    customer_id INT,
    movie_id INT,
    customer_age INT,
    customer_name VARCHAR(100),
    customer_address VARCHAR(200)
);

-- Table for actor
CREATE TABLE myownschema.actor (
    actor_id INT,
    actor_name VARCHAR(100),
    gender VARCHAR(10),
    country VARCHAR(100),
    movie_name VARCHAR(100)
);


-- Populate actsin table
INSERT INTO myownschema.actsin (actor_id, rental_id)
VALUES (1, 101), (2, 102), (1, 103), (3, 104), (4, 105), (2, 106);

-- Populate renting table
INSERT INTO myownschema.renting (rental_id, rating, customer_id, movie_id, customer_age, customer_name, customer_address)
VALUES (101, 4.5, 201, 1001, 30, 'John Doe', '123 Elm St'),
       (102, 5.0, 202, 1002, 25, 'Jane Smith', '456 Oak St'),
       (103, 3.0, 203, 1003, 40, 'Alice Brown', '789 Maple St'),
       (104, 4.8, 204, 1004, 22, 'Bob Green', '101 Pine St'),
       (105, 4.9, 201, 1005, 30, 'John Doe', '123 Elm St'),
       (106, 4.7, 202, 1006, 25, 'Jane Smith', '456 Oak St');

-- Populate actor table
INSERT INTO myownschema.actor (actor_id, actor_name, gender, country, movie_name)
VALUES (1, 'Tom Hanks', 'Male', 'USA', 'Forrest Gump'),
       (2, 'Meryl Streep', 'Female', 'USA', 'The Iron Lady'),
       (3, 'Leonardo DiCaprio', 'Male', 'USA', 'Inception'),
       (4, 'Natalie Portman', 'Female', 'Israel', 'Black Swan');

-- Explore:

SELECT *
FROM myownschema.actsin;

SELECT *
FROM myownschema.renting;

SELECT *
FROM myownschema.actor;

-- Answers:
CREATE TABLE myownschema.ar_netflix AS
SELECT
	a.actor_id, 
	a.rental_id,
	r.rating, 
	r.customer_id, 
	r.movie_id, 
	r.customer_age, 
	r.customer_name, 
	r.customer_address
FROM myownschema.actsin AS a
FULL JOIN myownschema.renting AS r ON a.rental_id = r.rental_id;

SELECT *
FROM myownschema.ar_netflix;

CREATE TABLE myownschema.j_netflix AS
SELECT
	a.actor_id, a.rental_id,
	a.rating, a.customer_id, 
	a.movie_id, a.customer_age, 
	a.customer_name, a.customer_address,
	ac.actor_name, ac.gender, ac.country, ac.movie_name
	
FROM myownschema.ar_netflix AS a
FULL JOIN myownschema.actor AS ac ON a.actor_id = ac.actor_id;

SELECT *
FROM myownschema.j_netflix;

SELECT *
FROM myownschema.j_netflix AS j
GROUP BY j.customer_id, 
    j.actor_id, 
    j.rental_id, 
    j.rating, 
    j.movie_id, 
    j.customer_age, 
    j.customer_name, 
    j.customer_address, 
    j.actor_name, 
    j.gender, 
    j.country, 
    j.movie_name
ORDER BY j.customer_id,j.rating;

--MODEL ANS
-- Join the three tables (actsin, renting, and actor)
SELECT 
    r.customer_id,
    r.customer_name,
    ac.actor_name,
    r.rating,
    ac.movie_name,
    ROW_NUMBER() OVER (PARTITION BY r.customer_id ORDER BY r.rating DESC) AS actor_ranking
FROM 
    myownschema.actsin AS a
JOIN 
    myownschema.renting AS r ON a.rental_id = r.rental_id
JOIN 
    myownschema.actor AS ac ON a.actor_id = ac.actor_id;

-- Select the top 3 actors for each customer based on the ranking
WITH ranked_actors AS (
    SELECT 
        r.customer_id,
        r.customer_name,
        ac.actor_name,
        r.rating,
        ac.movie_name,
        ROW_NUMBER() OVER (PARTITION BY r.customer_id ORDER BY r.rating DESC) AS actor_ranking
    FROM 
        myownschema.actsin AS a
    JOIN 
        myownschema.renting AS r ON a.rental_id = r.rental_id
    JOIN 
        myownschema.actor AS ac ON a.actor_id = ac.actor_id
)
-- Filter the top 3 actors per customer
SELECT 
    customer_id,
    customer_name,
    actor_name,
    rating,
    movie_name,
    actor_ranking
FROM 
    ranked_actors
WHERE 
    actor_ranking <= 3
ORDER BY 
    customer_id, actor_ranking;
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Q7: Imagine you are a data analyst at Foodpanda, responsible for improving customer experience. 
-- Your task is to find the top three favourite stores for each customer of all time.

-- Instructions:

-- Write a query or script to identify the top three favourite stores for each customer based on the number of orders.

-- Run this once!
CREATE TABLE myownschema.customer (
    customer_id INT PRIMARY KEY,
    home_address VARCHAR(255),
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    phone_number VARCHAR(20)
);

CREATE TABLE myownschema.orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),
    location VARCHAR(255),
    store_id INT,
    store_name VARCHAR(100),
    date DATE,
    rider VARCHAR(100),
    time TIME,
    zone VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES myownschema.customer(customer_id) -- Pretty neat way of stating the PK and FK
);

INSERT INTO myownschema.customer (customer_id, home_address, name, age, gender, phone_number)
VALUES
    (1, '123 Main St', 'Alice Smith', 30, 'Female', '555-1234'),
    (2, '456 Oak Ave', 'Bob Johnson', 25, 'Male', '555-5678'),
    (3, '789 Pine Rd', 'Carol Williams', 28, 'Female', '555-8765');

INSERT INTO myownschema.orders (order_id, customer_id, customer_name, location, store_id, store_name, date, rider, time, zone)
VALUES
    -- Orders for Alice Smith (Customer ID: 1)
    (1, 1, 'Alice Smith', '123 Main St', 1, 'Pizza Palace', '2021-01-01', 'Rider A', '12:00:00', 'Zone 1'),
    (2, 1, 'Alice Smith', '123 Main St', 1, 'Pizza Palace', '2021-01-05', 'Rider B', '13:00:00', 'Zone 1'),
    (3, 1, 'Alice Smith', '123 Main St', 1, 'Pizza Palace', '2021-01-10', 'Rider C', '14:00:00', 'Zone 1'),
    (4, 1, 'Alice Smith', '123 Main St', 1, 'Pizza Palace', '2021-01-15', 'Rider D', '15:00:00', 'Zone 1'),
    (5, 1, 'Alice Smith', '123 Main St', 1, 'Pizza Palace', '2021-01-20', 'Rider E', '16:00:00', 'Zone 1'),
    (6, 1, 'Alice Smith', '123 Main St', 2, 'Burger Barn', '2021-02-01', 'Rider F', '17:00:00', 'Zone 1'),
    (7, 1, 'Alice Smith', '123 Main St', 2, 'Burger Barn', '2021-02-05', 'Rider G', '18:00:00', 'Zone 1'),
    (8, 1, 'Alice Smith', '123 Main St', 2, 'Burger Barn', '2021-02-10', 'Rider H', '19:00:00', 'Zone 1'),
    (9, 1, 'Alice Smith', '123 Main St', 3, 'Sushi Central', '2021-03-01', 'Rider I', '20:00:00', 'Zone 1'),
    (10, 1, 'Alice Smith', '123 Main St', 3, 'Sushi Central', '2021-03-05', 'Rider J', '21:00:00', 'Zone 1'),

    -- Orders for Bob Johnson (Customer ID: 2)
    (11, 2, 'Bob Johnson', '456 Oak Ave', 2, 'Burger Barn', '2021-01-02', 'Rider K', '12:30:00', 'Zone 2'),
    (12, 2, 'Bob Johnson', '456 Oak Ave', 2, 'Burger Barn', '2021-01-06', 'Rider L', '13:30:00', 'Zone 2'),
    (13, 2, 'Bob Johnson', '456 Oak Ave', 2, 'Burger Barn', '2021-01-11', 'Rider M', '14:30:00', 'Zone 2'),
    (14, 2, 'Bob Johnson', '456 Oak Ave', 2, 'Burger Barn', '2021-01-16', 'Rider N', '15:30:00', 'Zone 2'),
    (15, 2, 'Bob Johnson', '456 Oak Ave', 3, 'Sushi Central', '2021-02-02', 'Rider O', '16:30:00', 'Zone 2'),
    (16, 2, 'Bob Johnson', '456 Oak Ave', 3, 'Sushi Central', '2021-02-06', 'Rider P', '17:30:00', 'Zone 2'),
    (17, 2, 'Bob Johnson', '456 Oak Ave', 3, 'Sushi Central', '2021-02-11', 'Rider Q', '18:30:00', 'Zone 2'),
    (18, 2, 'Bob Johnson', '456 Oak Ave', 4, 'Taco Town', '2021-03-02', 'Rider R', '19:30:00', 'Zone 2'),
    (19, 2, 'Bob Johnson', '456 Oak Ave', 4, 'Taco Town', '2021-03-06', 'Rider S', '20:30:00', 'Zone 2'),

    -- Orders for Carol Williams (Customer ID: 3)
    (20, 3, 'Carol Williams', '789 Pine Rd', 1, 'Pizza Palace', '2021-01-03', 'Rider T', '12:15:00', 'Zone 3'),
    (21, 3, 'Carol Williams', '789 Pine Rd', 1, 'Pizza Palace', '2021-01-07', 'Rider U', '13:15:00', 'Zone 3'),
    (22, 3, 'Carol Williams', '789 Pine Rd', 1, 'Pizza Palace', '2021-01-12', 'Rider V', '14:15:00', 'Zone 3'),
    (23, 3, 'Carol Williams', '789 Pine Rd', 3, 'Sushi Central', '2021-02-03', 'Rider W', '15:15:00', 'Zone 3'),
    (24, 3, 'Carol Williams', '789 Pine Rd', 3, 'Sushi Central', '2021-02-07', 'Rider X', '16:15:00', 'Zone 3'),
    (25, 3, 'Carol Williams', '789 Pine Rd', 3, 'Sushi Central', '2021-02-12', 'Rider Y', '17:15:00', 'Zone 3'),
    (26, 3, 'Carol Williams', '789 Pine Rd', 3, 'Sushi Central', '2021-02-17', 'Rider Z', '18:15:00', 'Zone 3'),
    (27, 3, 'Carol Williams', '789 Pine Rd', 5, 'Pasta Place', '2021-03-03', 'Rider AA', '19:15:00', 'Zone 3'),
    (28, 3, 'Carol Williams', '789 Pine Rd', 5, 'Pasta Place', '2021-03-07', 'Rider BB', '20:15:00', 'Zone 3');

-- Explore the table:
SELECT *
FROM myownschema.customer;

SELECT *
FROM myownschema.orders;

-- Answer:
SELECT 
        o.customer_id,
        o.customer_name,
        o.store_id,
        o.store_name,
        COUNT(o.order_id) AS total_orders,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY COUNT(o.order_id) DESC) AS store_rank
    FROM 
        myownschema.orders AS o
    GROUP BY 
        o.customer_id, o.customer_name, o.store_id, o.store_name

-- if each customer orders from more than 3 different stores
WITH store_order_count AS (
    SELECT 
        o.customer_id,
        o.customer_name,
        o.store_id,
        o.store_name,
        COUNT(o.order_id) AS total_orders,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY COUNT(o.order_id) DESC) AS store_rank
    FROM 
        myownschema.orders AS o
    GROUP BY 
        o.customer_id, o.customer_name, o.store_id, o.store_name
)
SELECT 
    customer_id,
    customer_name,
    store_id,
    store_name,
    total_orders,
    store_rank
FROM 
    store_order_count
WHERE 
    store_rank <= 3 
ORDER BY 
    customer_id, store_rank;
	
