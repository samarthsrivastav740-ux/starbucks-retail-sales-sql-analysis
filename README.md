## **Starbucks Retail Sales Analysis (SQL Server)** 

## **Project Overview** 

This project analyzes Starbucks retail sales data using SQL Server, following a structured analytics workflow from data validation to business-focused analysis. 

The objective was to transform raw transactional data into analytical views that support customer, revenue, and product performance analysis. 

## **Dataset Structure** 

## **Sales (Fact Table)** 

- transaction_id • store_id • datetime • customer_id • item_id • quantity • price • total_amount • payment_mode • customer_type 

## **Customers (Dimension Table)** 

- customer_id • customer_name • customer_email • customer_phone • customer_age • customer_gender 

## **Items (Dimension Table)** 

- ID • item • calories • fat • carb • fiber • protein • type 

1 

## **Project Workflow** 

## **1. Data Quality Check** 

File:- 1.Data_quality_check.sql 

Performed data validation and quality assessment including: 

- Row count verification 

- Null value checks 

- Duplicate record analysis 

- Business key identification 

- Invalid customer ID checks 

- Invalid item ID checks 

- Data type inspection 

- Negative and zero value validation 

Key Finding: 

- `(transaction_id, store_id, customer_id)` was identified as the effective business key for 

- the sales table. 

## **2. Data Modeling** 

File: `2_Data_Modeling.sql` 

Implemented data model improvements including: 

- Data type standardization 

- NOT NULL constraints 

- Primary Key creation 

- Foreign Key relationships 

- Star Schema design 

Schema Structure: 

- Fact Table: Sales • Dimension Tables: Customers, Items 

## **3. Analysis Views** 

File: `3_Analysis_Views.sql` 

2 

Created reusable analytical views for reporting and business analysis. 

Views Created: 

- vw_sales_analysis_base 

- vw_revenue_summary 

- vw_revenue_trend 

- vw_monthly_performance 

- vw_customer_summary 

- vw_customer_segments 

- vw_pareto_analysis 

- vw_product_summary 

- vw_product_mix 

## **Key Analyses** 

## **Revenue Analysis** 

- Revenue Summary 

- Revenue Trends 

- Monthly Performance Analysis 

## **Customer Analysis** 

- Customer Spending Behavior 

- Customer Segmentation 

- Pareto (80/20) Analysis 

## **Product Analysis** 

- Product Performance Analysis 

- Product Mix Optimization 

- Star / Dog / Opportunity / Volume Driver Classification 

## **Key Findings** 

- Revenue is relatively distributed across the customer base. 

- The top 20% of customers contribute approximately 27% of total revenue, indicating low customer concentration risk. 

- Bakery products dominate the highest revenue-generating product list. 

- Product portfolio analysis identified Star, Dog, Opportunity, and Volume Driver products based on revenue and sales volume performance. 

3 

## **SQL Concepts Used** 

- Joins 

- Aggregations 

- CASE Statements 

- Views 

- Common Table Expressions (CTEs) 

- Window Functions 

- Ranking Functions 

- Date & Time Intelligence 

## **Tools Used** 

- SQL Server • SQL Server Management Studio (SSMS) 

## **Project Outcome** 

This project demonstrates a complete SQL analytics workflow covering data quality assessment, data modeling, analytical view creation, customer analysis, Pareto analysis, and product portfolio optimization using SQL Server. 

4 


