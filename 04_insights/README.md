
# SQL Project Analysis

## Introduction

This project was created to strengthen my SQL and business analytics skills by analyzing AdventureWorksDW2025, a retail sales data warehouse. Using SQL Server, I explored sales trends, customer behavior, product performance, profitability, and geographic performance to uncover business insights that support data-driven decision making.

### Dashboard File
This project contains SQL scripts organized by business analysis topics.  
1. [Data Exploration](https://github.com/Ayunibellaa/SQL_Project_Data_Analysis/tree/main/02_sql_queries/01_exploratory_data_analysis) 
2. [Trend Analysis](https://github.com/Ayunibellaa/SQL_Project_Data_Analysis/blob/main/02_sql_queries/02_trend_analysis.sql)
3. [Customer Analysis](https://github.com/Ayunibellaa/SQL_Project_Data_Analysis/blob/main/02_sql_queries/03_customer_analysis.sql)
4. [Product Analysis](https://github.com/Ayunibellaa/SQL_Project_Data_Analysis/blob/main/02_sql_queries/04_product_analysis.sql)
5. [Profitability Analysis](https://github.com/Ayunibellaa/SQL_Project_Data_Analysis/blob/main/02_sql_queries/05_profitability_analysis.sql)
6. [geographic_analysis](https://github.com/Ayunibellaa/SQL_Project_Data_Analysis/blob/main/02_sql_queries/06_geographic_analysis.sql)

### Questions to Analyze

To understand the business performance, I asked the following questions:

1. **How has sales performance changed over time?**
2. **What customer segments generate the highest business value?**
3. **Which products contribute the most to revenue?**
4. **Which products and categories generate the highest profit?**
5. **Which geographic markets contribute the most to business performance?**

### SQL Skills Used

The following SQL techniques were applied throughout this project:

- **🗃️ JOINs**
- **📊 Aggregate Functions**
- **🪟 Window Functions**
- **🧮 Common Table Expressions (CTEs)**
- **🔍 Subqueries**
- **📅 Date Functions**
- **🔢 Ranking Functions**
- **⚡ CASE WHEN**
- **📈 Running Totals & Moving Average**

### Data Jobs Dataset

The dataset used for this project is AdventureWorksDW2025, Microsoft's sample data warehouse for business intelligence and analytics.  
The project analyzes Internet Sales between 2011–2013 across customers, products, sales territories, and time.  
It includes detailed information on:

- **🛒 Sales Transactions**
- **👥 Customer Information**
- **🚲 Product Hierarchy**
- **🌎 Geographic Data**
- **📅 Calendar Dimension**

## 1️⃣ How has sales performance changed over time?

### 🔍 Skill:  

- Aggregate Functions
- Window Functions
- CTE
- Running Total
- Moving Average
- Date Functions

### 𝄜 Analysis:  

To evaluate business growth, I analyzed annual sales trends, Year-over-Year growth, monthly performance, running totals, and moving averages. I also compared performance across US states to identify regional trends and seasonality.

### 💡 Insights:  

- Sales declined by 41.5% in 2012 before rebounding 280.1% in 2013.
- California consistently generated the highest revenue.
- Sales peaked during Q4 (October–December).
- Running totals showed continuous long-term growth.
- California contributed the majority of revenue growth.

### 🤔 So What

These findings indicate strong seasonality and heavy dependence on California. Businesses should prepare inventory before Q4 while expanding growth strategies into other states to reduce market concentration.

## 2️⃣ What customer segments generate the highest business value?

### 🔍 Skill:

- CTE
- CASE WHEN
- Aggregate Functions
- Window Functions
- ROW_NUMBER()

### 𝄜 Analysis:  

Customers were segmented by loyalty and annual income to evaluate purchasing behavior, average order value, revenue contribution, and preferred product categories.

### 💡 Insights:  

- More than 80% of customers were New Customers.
- Long-Term Customers generated the highest Average Order Value.
- Middle-Income customers produced the largest sales.
- Bikes dominated spending across every income segment.

### 🤔 So What
These findings indicate strong seasonality and heavy dependence on California. Businesses should prepare inventory before Q4 while expanding growth strategies into other states to reduce market concentration.

## 3️⃣ Which products contribute the most to revenue?

### 🔍 Skill:

- JOINs
- Aggregate Functions
- CTE
- DENSE_RANK()
- Window Functions

### 𝄜 Analysis:  

Product categories and individual products were ranked based on revenue contribution across all years and annually.

### 💡 Insights:  

- Bikes generated approximately 96% of total revenue.
- Revenue became slightly more diversified in 2013.
- Road Bikes and Mountain Bikes consistently ranked as the best-selling products.

### 🤔 So What

Although Bikes remain the core business, growing Accessories and Clothing could reduce dependence on a single product category.

## 4️⃣ Which products generate the highest profit?

### 🔍 Skill:

- Aggregate Functions
- Profit Calculations
- CTE
- DENSE_RANK()
- Window Functions

### 𝄜 Analysis:  

Sales, cost, profit, and profit margins were calculated for both product categories and individual products.

### 💡 Insights:  

- Bikes generated the highest total profit.
- Accessories achieved the highest profit margin (62.6%).
- Road-150 and Mountain-200 products consistently produced the largest profits.

### 🤔 So What

The company should continue investing in Bikes while increasing sales of Accessories to maximize profitability through their higher margins.

## 5️⃣ Which geographic regions drive business performance?

### 🔍 Skill:

- JOINs
- Aggregate Functions
- Window Functions
- DENSE_RANK()

### 𝄜 Analysis:  

Sales performance was analyzed across US states by measuring revenue contribution, active customers, active cities, and product category performance.

### 💡 Insights:  

- California generated approximately 61% of total revenue.
- Washington and Oregon ranked as the next strongest markets.
- Many states contributed only a small percentage of total sales.
- California consistently maintained market leadership.

### 🤔 So What

The business should diversify its revenue by expanding into high-potential states while replicating successful sales strategies from California.


## Conclusion

The analysis showed that the business relies heavily on a few key drivers, particularly California, Bikes, and Middle-Income customers. Strong seasonal demand during Q4 and the recovery in 2013 highlight opportunities for strategic planning and inventory optimization. At the same time, expanding sales in underperforming states and increasing the contribution of high-margin categories like Accessories could reduce business risk and improve long-term profitability.
