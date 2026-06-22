-- 1. Data Quality Check
/*Checking items table*/

SELECT TOP 5 * FROM items

--Total rows
SELECT COUNT(*) AS Total_rows from items

/*Fidning Null values.
Found:-No null values*/
SELECT * FROM items WHERE 
item IS NULL OR calories IS NULL OR fat IS NULL
OR carb IS NULL OR fiber IS NULL OR protein IS NULL OR type IS NULL
OR ID IS NULL

/*Checking for duplicate records.
Found:- No duplicate records*/
SELECT COUNT(*) AS Duplicate_records from items
GROUP BY item,calories,fat,carb,fiber,protein,type,ID
HAVING COUNT(*)>1

/*Checking if ID is primary key or not.
*/
SELECT COUNT(*) AS Duplicate_ids FROM items
GROUP BY ID
HAVING COUNT(*)>1

------------------------------------------------------------------------------------------------------
/*Checking customers table*/

SELECT TOP 5 * FROM customers

--Total rows
SELECT COUNT(*) AS Total_rows from customers

/*Fidning Null values.
Found:-No null values*/
SELECT * FROM customers WHERE 
customer_id IS NULL OR customer_name IS NULL OR customer_email IS NULL
OR customer_phone IS NULL OR customer_age IS NULL OR customer_gender IS NULL

/*Checking for duplicate records.
Found:- No duplicate records*/
SELECT COUNT(*) AS Duplicate_records from customers
GROUP BY customer_id,customer_name,customer_email,customer_phone,customer_age,customer_gender
HAVING COUNT(*)>1

/*Checking if customer_id is primary key or not.
*/
SELECT COUNT(*) AS Duplicate_customer_ids FROM customers
GROUP BY customer_id
HAVING COUNT(*)>1
------------------------------------------------------------------------------------------------------------------
/*Checking sales table */

SELECT TOP 5 * FROM sales


 -- Total rows=10000
SELECT COUNT(*) AS ROW_COUNT FROM sales 


/* Checking null values
  Found:- No null values  */
SELECT * FROM sales
WHERE transaction_id IS NULL OR 
store_id IS NULL OR customer_id IS NULL OR 
item_id IS NULL OR datetime IS NULL OR 
quantity IS NULL OR price IS NULL OR 
total_amount IS NULL OR payment_mode
IS NULL OR customer_type IS NULL;


/* Checking if transation_id is primary key or not.
Found:-Distinct transaction_ids=9936, Shared transaction_ids=64 */
SELECT  COUNT(DISTINCT transaction_id) FROM sales 


SELECT transaction_id,COUNT(*) AS duplicate_count FROM sales
GROUP BY transaction_id
having count(*)>1;


/*Checking whether Shared transaction_ids correspond to exact duplicate records.
Found:-Duplicate_records=0*/
SELECT COUNT(*) AS Duplicate_records
FROM sales
GROUP BY transaction_id,store_id,datetime,customer_id,item_id,quantity,price,total_amount,
payment_mode,customer_type
HAVING COUNT(*)>1;


/*Checking which combination was used as effective business key.
Found:- Combination of transaction_id,store_id,customer_id was unique in sales table and 
was used as effective business */
SELECT COUNT(*) AS TotalRows,
       COUNT(DISTINCT CONCAT(transaction_id,'-',store_id)) AS CompositeCount
FROM sales; --> TotalRows!=CompositeCount

SELECT COUNT(*) AS TotalRows,
       COUNT(DISTINCT CONCAT(transaction_id,'-',store_id,'-',customer_id)) AS CompositeCount
FROM sales; -->TotalRows=CompositeCount


/*Check invalid customer_ids in sales(Customer in sales table but not in customer table)
Found:- No invalid customer_ids*/
SELECT s.customer_id FROM 
sales AS s LEFT JOIN customers AS c ON s.customer_id=c.customer_id
WHERE c.customer_id IS NULL


/*Check invalid item_ids in sales(Item in sales table but not in customer table)
Found:- No invalid item_ids*/
SELECT s.item_id FROM 
sales AS s LEFT JOIN items AS i ON s.item_id=i.ID
WHERE i.ID IS NULL


--Checking data types of columns
EXEC sp_help 'sales';


/*Checking for non numeric values in quantity,price,total_amount and datetime
and changing column types */
SELECT *
FROM sales
WHERE TRY_CAST(quantity AS INT) IS NULL
AND quantity IS NOT NULL

ALTER TABLE sales ALTER COLUMN [quantity] INT


SELECT *
FROM sales
WHERE TRY_CAST(price AS DECIMAL(10,2)) IS NULL
AND price IS NOT NULL

ALTER TABLE sales ALTER COLUMN [price] DECIMAL(10,2)

SELECT *
FROM sales
WHERE TRY_CAST(total_amount AS DECIMAL(10,2)) IS NULL
AND total_amount IS NOT NULL

ALTER TABLE sales ALTER COLUMN [total_amount] DECIMAL(10,2)

SELECT *
FROM sales
WHERE TRY_CAST(datetime AS datetime2) IS NULL
AND datetime IS NOT NULL

ALTER TABLE sales ALTER COLUMN [datetime] DATETIME2


/*Checking negative or zero quantities,prices,total_amount */
SELECT * FROM sales
WHERE quantity<=0 OR price<=0 OR total_amount<=0

