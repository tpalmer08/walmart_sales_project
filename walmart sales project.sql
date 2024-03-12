
-- Create database
CREATE DATABASE IF NOT EXISTS walmart_ssalesales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);
-- -------------------------------------------------
-- ------------ Feature Engineering-------

-- Add Column Time Of Day

select
	`time`,
    (Case
		When `time` BETWEEN '00:00:00' AND '12:00:00' Then 'Morning'
        When `time` BETWEEN '12:00:00' AND '16:00:00' Then 'Afternoon'
        Else 'Evening'
	End) as time_of_day
	from sales
;

ALTER TABLE sales ADD COLUMN time_of_day varchar (20);

UPDATE sales Set time_of_day =  (
		Case
				When `time` BETWEEN '00:00:00' AND '12:00:00' Then 'Morning'
				When `time` BETWEEN '12:00:00' AND '16:00:00' Then 'Afternoon'
				Else 'Evening'
			End) ;


-- Add Column Day of Week
select `date`, dayname(`date`)
	from sales
;
ALTER TABLE sales ADD COLUMN day_of_week varchar(10);
UPDATE sales SET day_of_week = dayname(`date`);

-- Add Column Month Name
select `date`, monthname(`date`)
	from sales
;
ALTER TABLE sales ADD COLUMN Month varchar(20);
UPDATE sales SET Month = monthname(`date`);
-- ----------------------------------------------------

-- ---------------------------------------------------------------------Exploratory Data Analysis (EDA)---------------------------------------------------

-- -------------------------------------
-- Generic Question

-- How many unique cities does the data have?
SELECT DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT DISTINCT city, branch
FROM sales;
-- ------------------------------------------------

-- ---------------------------------------------------
-- Product Question

-- How many unique product lines does the data have?
SELECT DISTINCT product_line
FROM sales;

-- What is the most common payment method?
SELECT DISTINCT payment, count(payment)
FROM sales
GROUP BY payment
ORDER BY count(payment) DESC;

-- What is the most selling product line?
SELECT DISTINCT product_line, count(product_line)
FROM sales
GROUP BY product_line
ORDER BY count(product_line) DESC;

-- What is the total revenue by month?
SELECT `Month`,
ROUND(SUM(total), 2) AS Revenue
FROM sales
GROUP BY `Month`
ORDER BY `Month` ASC;

-- What month had the largest COGS?
SELECT `Month`,
SUM(cogs) as Cogs
FROM sales
GROUP BY `Month`
ORDER BY Cogs DESC;

-- What product line had the largest revenue?
SELECT product_line,
ROUND(SUM(total), 2) AS Revenue
FROM sales
GROUP BY product_line
ORDER BY product_line DESC;

-- What is the city with the largest revenue?
SELECT city,
ROUND(SUM(total), 2) AS Revenue
FROM sales
GROUP BY city
ORDER BY city DESC;

-- What product line had the largest VAT?
SELECT product_line,
AVG(tax_pct) AS VAT
FROM sales
GROUP BY product_line
ORDER BY VAT DESC;

-- Which branch orders sold more products than average product sold?
SELECT branch, quantity
FROM sales
Having quantity > (select avg(quantity) From sales);

-- What is the most common product line by gender?
SELECT product_line, gender, count(gender) as count
FROM sales
GROUP BY product_line, gender
ORDER BY count DESC
;

-- What is the average rating of each product line?
SELECT product_line, AVG(rating)
FROM sales
GROUP BY product_line; 

-- Fetch each product line and add a column to those product line showing "Good" or "Bad". Good if its greater than average sales
SELECT product_line, total
FROM sales
Having total > (select avg(total) From sales);
-- -------------------------------------------------

-- ----------------------------------------------------------------
-- ---Sales Questions------------

-- Total of revenue  made in each time of the day per weekday
SELECT day_of_week, time_of_day, sum(total)
FROM sales
GROUP BY day_of_week, time_of_day
ORDER BY day_of_week DESC;

-- Which of the customer types brings the most revenue?
SELECT customer_type, ROUND(SUM(total),2) as Total_Revenue
FROM sales
GROUP BY customer_type
ORDER BY Total_Revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, avg(tax_pct)
FROM sales
GROUP BY city
ORDER BY avg(tax_pct) DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type, avg(tax_pct)
FROM sales
GROUP BY customer_type
ORDER BY avg(tax_pct) DESC;
-- --------------------------------------------------

-- -------------------------------------
--  Customer Questions

-- How many unique customer types does the data have?
SELECT  DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT  DISTINCT payment
FROM sales;

-- What is the most common customer type?
SELECT  customer_type, COUNT(customer_type)
FROM sales
GROUP BY customer_type;

-- Which customer type buys the most?
SELECT  customer_type, SUM(total) AS total
FROM sales
GROUP BY customer_type
ORDER BY total DESC;

-- What is the gender of most of the customers?
SELECT  gender, COUNT(gender) AS count
FROM sales
GROUP BY gender
ORDER BY count DESC;

-- What is the gender distribution per branch?
SELECT  branch, gender, COUNT(gender) AS count
FROM sales
GROUP BY branch, gender
ORDER BY branch;

-- Which time of the day do customers give highest ratings?
SELECT time_of_day, AVG(rating) AS Rating
FROM sales
GROUP BY time_of_day
ORDER BY Rating DESC;

-- Which time of the day do customers give highest ratings per branch?
SELECT branch, time_of_day, AVG(rating) AS Rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY Rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT day_of_week, AVG(rating) AS Rating
FROM sales
GROUP BY day_of_week
ORDER BY Rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT branch, day_of_week, AVG(rating) AS Rating
FROM sales
GROUP BY branch, day_of_week
ORDER BY Rating DESC;

