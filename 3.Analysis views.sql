/*======================BASE VIEW===============================*/
/*
  VIEW: vw_sales_analysis_base

  Business Purpose:- Sales data contains raw transaction timestamps.

  Most business analyses require:
    ---> Date,Year,Month,Month Name,Day Name,Hour,Weekend vs Weekday

  Creating these fields once prevents duplication
  across future reporting views.

  Business Questions Supported:
  Q1. Which months generate the highest revenue?

  Q2. Which days contribute most to sales?

  Q3. What are Starbucks' peak operating hours?

  Q4. Do weekends perform differently from weekdays?
*/
CREATE VIEW vw_sales_analysis_base
AS
SELECT  s.transaction_id,s.store_id,s.customer_id,s.item_id
        ,s.datetime,
        CAST(s.datetime as DATE) AS order_date,
        YEAR(s.datetime) AS order_year,
        MONTH(s.datetime) AS order_month,
        DATENAME(MONTH,s.datetime) as month_name,
        DATENAME(WEEKDAY,s.datetime) as day_name,
        DATEPART(HOUR,s.datetime) as order_hour,
        CASE 
           WHEN DATENAME(WEEKDAY,s.datetime) IN ('Saturday','Sunday') 
           THEN 'Weekend'
           ELSE 'Weekday'
           END AS day_type,
        s.quantity,s.price,s.total_amount,s.payment_mode,s.customer_type
FROM sales s;
GO

--Validation Check
SELECT TOP 10 * FROM vw_sales_analysis_base

/*======================EXECUTIVE OVERVIEW===============================*/

/* Business Question:- How is overall business performance trending? */

/* Purpose:- Create core KPIs for executive reporting and dashboard cards.*/

CREATE VIEW vw_revenue_summary 
AS

SELECT
   SUM(total_amount) AS total_revenue,
   COUNT(*) AS total_orders,
   COUNT(DISTINCT customer_id) AS total_customers,
   ROUND(SUM(totaL_amount)*1.0/COUNT(*),2) AS average_order_value,
   ROUND(SUM(totaL_amount)*1.0/COUNT(DISTINCT customer_id),2) AS revenue_per_customer,
   ROUND(SUM(quantity)*1.0/COUNT(*),2) AS average_basket_size
FROM vw_sales_analysis_base;
GO

--Validation
SELECT * FROM vw_revenue_summary

--Observation:- Provides high-level business KPIs for executive monitoring.

/*======================REVENUE TREND ANALYSIS===============================*/

/* Business Question:- Is revenue increasing or declining over time?
*/

/* Purpose:- Track daily business performance trends.*/

CREATE VIEW vw_revenue_trend
AS
SELECT 
   order_date,
   SUM(total_amount) AS revenue,
   COUNT(*) AS total_orders,
   COUNT(DISTINCT customer_id) AS csutomers,
   ROUND(SUM(total_amount)*1.0/COUNT(*),2) AS average_order_value
FROM vw_sales_analysis_base
GROUP BY order_date;
GO

--->Correcting column name
ALTER VIEW vw_revenue_trend AS
  SELECT 
   order_date,
   SUM(total_amount) AS revenue,
   COUNT(*) AS total_orders,
   COUNT(DISTINCT customer_id) AS customers,
   ROUND(SUM(total_amount)*1.0/COUNT(*),2) AS average_order_value
FROM vw_sales_analysis_base
GROUP BY order_date;
GO

--Validating
SELECT TOP 20 * FROM vw_revenue_trend

--Observation:-Supports daily trend analysis for revenue, orders, customers and AOV.


/*======================MONTHLY PERFORMANCE ANALYSIS===============================*/

/* Business Question:- Which months contribute the most revenue?*/

/* Purpose:-Identify seasonality and monthly performance.*/

CREATE VIEW vw_monthly_performance
AS
SELECT
   order_year,
   order_month,
   month_name,
   SUM(total_amount) AS revenue,
   COUNT(*) AS total_orders,
   COUNT(DISTINCT customer_id) AS customers,
   ROUND(SUM(total_amount)*1.0/COUNT(*),2) AS average_order_value
FROM vw_sales_analysis_base
GROUP BY
   order_year,
   order_month,
   month_name;
GO

--Validating
SELECT * FROM vw_monthly_performance
ORDER BY order_year,order_month;

/* Observation:- Highlights monthly revenue and customer trends.*/


/*======================CUSTOMER ANALYTICS===============================*/

/* Business Question:-Who are Starbucks' most valuable customers?*/

/* Purpose:-Create customer-level performance metrics.*/
CREATE VIEW vw_customer_summary
AS
SELECT 
   c.customer_id,
   c.customer_name,
   c.customer_gender,
   c.customer_age,
   MIN(s.order_date) AS first_purchase_order,
   MAX(s.order_date) AS last_purchase_order,
   COUNT(*) AS total_orders,
   SUM(s.quantity) AS total_quantity,
   SUM(s.total_amount) AS total_spend,
   ROUND(SUM(total_amount)*1.0/COUNT(*),2) AS average_order_value,
   DATEDIFF(DAY,MIN(s.order_date) ,MAX(s.order_date) ) AS customer_lifespan_days
FROM vw_sales_analysis_base AS s JOIN customers AS c on
   s.customer_id=c.customer_id
GROUP BY 
    c.customer_id,
   c.customer_name,
   c.customer_gender,
   c.customer_age;
GO

--Validation 
SELECT TOP 20 *
FROM vw_customer_summary
ORDER BY total_spend DESC;

/* Observation:
Summarizes customer purchase behavior and value.
*/

--==================================
SELECT
    MIN(total_spend) AS min_spend,
    MAX(total_spend) AS max_spend,
    AVG(total_spend) AS avg_spend
FROM vw_customer_summary;
--=================================


/*======================CUSTOMER SEGMENTATION===============================*/

/* Business Question:
Which customer segments drive revenue?
*/

/* Purpose:
Group customers based on spending behavior.
*/

CREATE VIEW vw_customer_segments
AS

SELECT
  customer_id
, customer_name
, total_orders
, total_spend

, CASE

      WHEN total_spend >= 250
      THEN 'VIP'

      WHEN total_spend >= 150
      THEN 'Regular'

      ELSE 'Casual'

  END AS customer_segment


FROM vw_customer_summary;
GO

/* Validation */

SELECT
customer_segment,
COUNT(*) AS customers,
SUM(total_spend) AS revenue
FROM vw_customer_segments
GROUP BY customer_segment;

/* Observation:
Segments customers by spending behavior
for targeted marketing and loyalty strategies.
*/
SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(total_spend) AS revenue
FROM vw_customer_segments
GROUP BY customer_segment;

/*======================PARETO ANALYSIS===============================*/

/* Business Question:
Is revenue concentrated among a small group of customers?
*/

/* Purpose:
Measure customer revenue concentration.
*/

CREATE VIEW vw_pareto_analysis
AS
WITH customer_revenue AS
(
SELECT 
   customer_id,
   customer_name,
   total_spend,
   ROW_NUMBER() OVER (ORDER BY total_spend DESC) AS customer_rank,
   SUM(total_spend) OVER (ORDER BY total_spend DESC ROWS UNBOUNDED PRECEDING) AS cumulative_revenue,
   SUM(total_spend) OVER () AS total_revenue
   FROM vw_customer_summary
)
SELECT customer_id,
   customer_name,
   total_spend,
   customer_rank,
   cumulative_revenue,
   ROUND((
      cumulative_revenue*100.0/total_revenue
   ),2) AS cumulative_revenue_pct
FROM customer_revenue
GO

/* Validation */

SELECT TOP 20 *
FROM vw_pareto_analysis
ORDER BY customer_rank;

/* Observation:
Identifies revenue concentration among customers.
*/


/* Pareto KPI:
Revenue Contribution of Top 20% Customers
*/

WITH ranked_customers AS
(
SELECT
customer_id,
total_spend,
ROW_NUMBER() OVER
      (
        ORDER BY total_spend DESC
      ) AS customer_rank
FROM vw_customer_summary
)
SELECT
ROUND(SUM(CASE
           WHEN customer_rank <= 100
           THEN total_spend
           ELSE 0
           END) * 100.0/ SUM(total_spend)
  ,2) AS top_20pct_customer_revenue_pct
FROM ranked_customers;

/* Observation:
   Revenue is relatively distributed across the customer base.

   The top 20% of customers contribute approximately
   27% of total revenue, indicating low customer
   concentration risk.
*/

/*===================PRODUCT PERFORMANCE ANALYSIS===========================*/

/* Business Question:
Which products generate the most revenue?
*/

/* Purpose:
Evaluate product-level sales performance.
*/

CREATE VIEW vw_product_summary
AS
SELECT
i.ID AS item_id,
i.item,
i.type,
SUM(s.quantity) AS total_quantity_sold,
SUM(s.total_amount) AS total_revenue,
COUNT(*) AS total_orders,
ROUND(SUM(s.total_amount) * 1.0/COUNT(*),2) AS avg_revenue_per_order
FROM vw_sales_analysis_base s
INNER JOIN items i
ON s.item_id = i.ID
GROUP BY
  i.ID
, i.item
, i.type;

GO

/* Validation */

SELECT TOP 20 *
FROM vw_product_summary
ORDER BY total_revenue DESC;

/* Observation:
Identifies top and bottom revenue-generating products.
*/
SELECT TOP 10 *
FROM vw_product_summary
ORDER BY total_revenue DESC;

SELECT TOP 10 *
FROM vw_product_summary
ORDER BY total_revenue ASC;

/*===========================================================
PRODUCT MIX OPTIMIZATION
===========================================================*/

/* Business Question:
Which products should be promoted,
maintained or reviewed?
*/

/* Purpose:
Classify products based on revenue
and sales volume performance.
*/

CREATE VIEW vw_product_mix
AS

WITH product_metrics AS
(
SELECT
      item_id
    , item
    , type

    , total_quantity_sold
    , total_revenue

    , AVG(total_quantity_sold) OVER()
      AS avg_quantity

    , AVG(total_revenue) OVER()
      AS avg_revenue

FROM vw_product_summary

)

SELECT
  item_id
, item
, type

, total_quantity_sold
, total_revenue

, CASE

      WHEN total_quantity_sold >= avg_quantity
       AND total_revenue >= avg_revenue
      THEN 'Star'

      WHEN total_quantity_sold < avg_quantity
       AND total_revenue < avg_revenue
      THEN 'Dog'

      WHEN total_quantity_sold < avg_quantity
       AND total_revenue >= avg_revenue
      THEN 'Opportunity'

      ELSE 'Volume Driver'

  END AS product_category

FROM product_metrics;
GO

/* Validation */

SELECT
product_category,
COUNT(*) AS products
FROM vw_product_mix
GROUP BY product_category;

/* Observation:
Categorizes products for portfolio optimization.
*/
