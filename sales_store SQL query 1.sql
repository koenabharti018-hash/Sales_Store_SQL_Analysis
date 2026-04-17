CREATE TABLE (
transaction_id VARCHAR(15),
customer_id VARCHAR(15),
customer_name VARCHAR(30), 
customer_age INT,
gender VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR(15),
quantiy INT,
prce FLOAT,
payment_mode VARCHAR(15),
payment_date DATE,
time_of_purchase TIME,
status VARCHAR(15)
);
SELECT * FROM sales_store

SET DATEFORMAT dmy
BULK INSERT sales_store
FROM "C:\Users\91975\OneDrive\career_KoenaB\Projects for Resume\sales_store_updated_allign_with_video.csv"
 WITH (
  FIRSTROW=2,
  FIELDTERMINATOR=',',
  ROWTERMINATOR='\n'
  );


  --DATA CLEANING 
  
  -- STEP 1- to check for duplicate

  SELECT transaction_id, COUNT (*)
  FROM sales_store
  GROUP BY transaction_id
  HAVING COUNT (transaction_id) >1
  

  --DUPLICATE transaction_id
TXN240646
TXN342128
TXN855235
TXN981773


  WITH CTE AS (
SELECT *,
 ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
 FROM sales_store
 )
 SELECT * FROM CTE
 WHERE Row_Num >1


   WITH CTE AS (
SELECT *,
 ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
 FROM sales_store
 )
 SELECT * FROM CTE
 WHERE transaction_id IN ('TXN240646', 'TXN342128', 'TXN855235', 'TXN981773')


 -- TO DELETE DUPLICATE RECORDS

   WITH CTE AS (
SELECT *,
 ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
 FROM sales_store
 )
--DELETE FROM CTE
--WHERE Row_Num = 2



--STEP2: CORRECTION OF HEADERS

SELECT * FROM sales_store

EXEC sp_rename'sales_store.quantiy','quantity','COLUMN'

EXEC sp_rename'sales_store.prce','price','COLUMN'


-- STEP3: TO CHECK DATA_TYPE

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='sales_store'


-- STEP4: TO CHECK NULL_VALUES

-- to check null count

DECLARE @SQL NVARCHAR(MAX) = '';
SELECT @SQL = STRING_AGG(
 'SELECT ''' + COLUMN_NAME + ''' AS ColumnName,
  COUNT (*) AS NullCount
  FROM ' + QUOTENAME (TABLE_SCHEMA) + 'sales_store
  WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL ',
  ' UNION ALL '
  )
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='sales_store';

--EXECUTE THE DYNAMIC SQL
EXEC sp_executesql @SQL;


--treating null values

SELECT * 
FROM sales_store
WHERE transaction_id is null
OR
customer_id is null 
OR
customer_name is null
OR
customer_age is null
OR 
gender is null
OR
product_id is null
OR
product_name is null
OR 
product_category is null
OR 
quantity is null
OR
price is null
OR 
payment_mode is null
OR 
payment_date is null
OR 
time_of_purchase is null
OR 
status is null


--deleting the outlier 
DELETE FROM sales_store
WHERE transaction_id is null


--TREATING NULL VALUES

SELECT * FROM sales_store
WHERE customer_name = 'Ehsaan Ram'
UPDATE sales_store
SET customer_id = 'CUST9494'
WHERE transaction_id = 'TXN977900'


SELECT * FROM sales_store
WHERE customer_name = 'Damini Raju'
UPDATE sales_store
SET customer_id = 'CUST1401'
WHERE transaction_id = 'TXN985663'


SELECT * FROM sales_store
WHERE customer_id = 'CUST1003'
UPDATE sales_store
SET customer_name = 'Mahika Saini', customer_age = 35, gender = 'Male'
WHERE transaction_id = 'TXN432798'



-- STEP5: DATA CLEANING FOR GENDER AND PAYMENT_MODE

SELECT * FROM sales_store


SELECT DISTINCT gender
FROM sales_store

--CLEANING GENDER COLUMN
UPDATE sales_store
SET gender = 'MALE'
WHERE gender = 'M'


UPDATE sales_store
SET gender = 'FEMALE'
WHERE gender = 'F'

 
-- CLEANING PAYMENT_MODE 
SELECT DISTINCT payment_mode
FROM sales_store

UPDATE sales_store
SET payment_mode = 'Credit Card'
WHERE payment_mode = 'CC'



-- DATA ANALYSIS / BUSINESS INSIGHTS--
--Q1. WHAT ARE THE TOP 5 MOST SELLING PRODUCTS BY QUANTITY?

SELECT * FROM sales_store

SELECT DISTINCT status
FROM sales_store

SELECT TOP 5 product_name, SUM (quantity) AS total_quantity_sold
FROM sales_store
WHERE status = 'delivered'
GROUP BY product_name
ORDER BY total_quantity_sold DESC

-- BUSINESS PROBLEM: WE DON'T KNOW WHICH PRODUCTS ARE IN DEMAND
-- BUSINESS IMPACT: HELPS PRIORITIZE STOCKS AND BOOST SALES THROUGH TARGETED DEMAND

---------------------------------------------------------------------------------------------------------------------------------------

--Q2. WHICH PRODUCTS ARE MOST FREQUENTLY CANCELLED?

SELECT TOP 5 product_name, COUNT (*) AS total_cancelled
FROM sales_store
WHERE status = 'Cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC

--BUSINESS PROBLEM- FREQUENT CANCELLATION AFFECT REVENUE AND CUSTOMER TRUST
-- BUSINESS IMPACT : identify poor performing products to improve quality or remove from cataloge.

---------------------------------------------------------------------------------------------------------------------------------------

--Q3. WHAT TIME OF THE DAY HAS THE HIGHEST NUMBER OF PURCHASES?

SELECT * FROM sales_store
 
  SELECT 
       CASE 
           WHEN DATEPART (HOUR, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
           WHEN DATEPART (HOUR, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
           WHEN DATEPART (HOUR, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
           WHEN DATEPART (HOUR, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
        END AS time_of_day,
        COUNT (*) AS total_orders
    FROM sales_store
    GROUP BY
       CASE 
           WHEN DATEPART (HOUR, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
           WHEN DATEPART (HOUR, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
           WHEN DATEPART (HOUR, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
           WHEN DATEPART (HOUR, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
        END
    ORDER BY total_orders DESC

-- BUSINESS PROBLEM: FIND PEAK SALES TIME
-- BUSINESS IMPACT : OPTIMIZE STAFFING, PROMOTIONS AND SERVER LOADS.


---------------------------------------------------------------------------------------------------------------------------------------

--Q4. WHO ARE THE TOP 5 HIGHEST SPENDING CUSTOMERS?

SELECT TOP 5 customer_name,
     FORMAT(SUM(price*quantity), 'C0', 'en-IN')  AS total_spend     --- 'N' STANDS FOR 'Number Format' -- '0(zero)' stands for No Decimal Places-- -- 'C' stands for CURRENCY --  'IN' stands for Indian Currency----
FROM sales_store
GROUP BY customer_name
ORDER BY SUM(price*quantity) DESC

-- BUSINESS PROBLEM: IDENTIFY VIP CUSTOMERS 
-- BUSINESS IMPACT : personalized offers, loyalty rewards and retention.


---------------------------------------------------------------------------------------------------------------------------------------

--Q5. WHICH PRODUCT CATEGORY GENERATES THE HIGHEST REVENUE?

SELECT * FROM sales_store

SELECT product_category,
     FORMAT(SUM(price*quantity), 'C0', 'en-IN')  AS REVENUE     
     --- 'N' STANDS FOR 'Number Format' 
     -- '0(zero)' stands for No. of Decimal Places-- 
     -- 'C' stands for CURRENCY --  'IN' stands for Indian Currency----
FROM sales_store
GROUP BY product_category
ORDER BY SUM(price*quantity) DESC



-- BUSINESS PROBLEM: IDENTIFY TOP PERFORMING PRODUCT CATEGORIES
---- BUSINESS IMPACT : refine product strategy, supply chain, and promotions.
-- allowing the business to invest more in high margin or high demand categories.


---------------------------------------------------------------------------------------------------------------------------------------

--Q6. WHAT IS THE RETURN / CANCELLATION RATE PER PRODUCT CATEGORY IN % ?

SELECT * FROM sales_store
-- CANCELLATION
SELECT product_category,
   FORMAT (COUNT (CASE WHEN status = 'cancelled' THEN 1 END)*100.0/COUNT (*), 'N2')+' %' AS cancelled_percentage
 FROM sales_store 
 GROUP BY product_category
 ORDER BY cancelled_percentage DESC

 -- RETURN 
 SELECT product_category,
   FORMAT (COUNT (CASE WHEN status = 'returned' THEN 1 END)*100.0/COUNT (*), 'N2')+' %' AS return_percentage
 FROM sales_store 
 GROUP BY product_category 
 ORDER BY return_percentage DESC

 
-- BUSINESS PROBLEM: monitor dissatisfaction
---- BUSINESS IMPACT : refine product strategy, supply chain, and promotions.
-- allowing the business to invest more in high margin or high demand categories.


---------------------------------------------------------------------------------------------------------------------------------------

--Q7. WHAT IS THE MOST PREFERRED PAYMENT MODE?

SELECT * FROM sales_store

SELECT payment_mode, COUNT (payment_mode) AS total_count
FROM sales_store
GROUP BY payment_mode
ORDER BY total_count DESC


-- BUSINESS PROBLEM: KNOW WHICH PAYMENT OPTIONS CUSTOMERS PREFER
---- BUSINESS IMPACT : STREAMLINE  PAYMENT PROCESSING , PRIORITIZE POPULAR MODES


---------------------------------------------------------------------------------------------------------------------------------------

-- Q8.HOW DOES AGE GROUP AFFECT PURCHASING BEHAVIOUR?

SELECT * FROM sales_store
-- SELECT MIN (customer_age), MAX(customer_age)
--from sales_store

SELECT 
     CASE 
          WHEN customer_age BETWEEN 18 and 25 THEN '18-25'
          WHEN customer_age BETWEEN 26 and 35 THEN '26-35'
          WHEN customer_age BETWEEN 36 and 50 THEN '36-50'
      ELSE '51+'
    END AS customer_age,
FORMAT(SUM (quantity*price),'C0','en-IN') AS total_purchase
FROM sales_store
GROUP BY CASE 
          WHEN customer_age BETWEEN 18 and 25 THEN '18-25'
          WHEN customer_age BETWEEN 26 and 35 THEN '26-35'
          WHEN customer_age BETWEEN 36 and 50 THEN '36-50'
      ELSE '51+'
    END
ORDER BY SUM (quantity*price) DESC

-- BUSINESS PROBLEM: understand customer demographics
---- BUSINESS IMPACT : targeted marketing and product recommendations by age group 

---------------------------------------------------------------------------------------------------------------------------------------

--Q9. WHAT'S THE MONTHLY SALES TREND?

SELECT * FROM sales_store

--METHOD 1

SELECT
     FORMAT(payment_date,'yyyy-MM') AS 'month_year',
    FORMAT(SUM (quantity*price),'C0','en-IN') AS total_sales,
     SUM (quantity) AS total_quantity
FROM sales_store
GROUP BY FORMAT(payment_date,'yyyy-MM')


--METHOD 2 

SELECT* FROM sales_store

SELECT 
    YEAR (payment_date) AS Year,
    MONTH (payment_date) AS Month,
    FORMAT (SUM (price*quantity), 'C0', 'en-IN') AS total_sales,
    SUM (quantity) AS total_quantity
FROM sales_store
GROUP BY YEAR (payment_date), MONTH (payment_date)
ORDER BY Month


-- BUSINESS PROBLEM: SALES FLUCTUATIONS GO UNNOTICED
---- BUSINESS IMPACT :PLAN INVENTORY AND MARKETING ACCORDING TO SEASONAL TRENDS.

---------------------------------------------------------------------------------------------------------------------------------------

--Q10. ARE CERTAIN GENDER BUYING MORE PRODUCT CATEGORIES?

--METHOD 1

SELECT * FROM sales_store

SELECT gender, product_category, COUNT(product_category) AS total_purchase 
FROM sales_store
GROUP BY gender, product_category
ORDER BY gender


--METHOD 2
SELECT *
FROM (
      SELECT gender, product_category
      FROM sales_store
      ) AS source_table
PIVOT ( 
      COUNT (gender)
      FOR gender IN ([Male,Female])
      ) AS pivot_table
ORDER BY product_category

-- BUSINESS PROBLEM: GENDER BASED PRODUCT PREFERENCES
---- BUSINESS IMPACT :PERSONALIZED ADS, GENDER - FOCUSED CAMPAIGNS.


---------------------------------------------------------------------------------------------------------------------------------------

-- Q11. Write a SQL query to:
-- Retrieve the customer_name, product_name, payment_mode, and total amount
-- Only for customers who have placed orders
-- Sort the result by total_amount in descending order


SELECT * FROM sales_store


SELECT 
    customer_name,
    product_name,
    payment_mode,
    status,
    FORMAT(SUM(price * quantity), 'C0', 'en-IN') AS total_amount
FROM 
    sales_store
WHERE status = 'Delivered'
GROUP BY 
    customer_name,
    product_name,
    payment_mode,
    status
ORDER BY 
    SUM(price * quantity) DESC;