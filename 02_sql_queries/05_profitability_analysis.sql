
/*
===============================================================================
PROFITABILITY ANALYSIS BY PRODUCT CATEGORY (ALL TIME)
Objective: 1. Analyze sales, cost, and profit by product category
           2. Measure profit margin percentage for each category
           3. Identify the most profitable product categories
Key Concepts: - Aggregation: SUM()
              - Subquery Aggregation
              - Joins: LEFT JOIN
              - Data Formatting: CAST(), ROUND()
===============================================================================
*/

SELECT 
    t.category_key,
    t.category_name,
    t.quantity_sold,
    CAST(ROUND(t.total_sales,0) AS bigint) AS total_sales,
    CAST(ROUND(t.total_cost,0)AS bigint) AS total_cost,
    CAST(ROUND(t.total_sales - t.total_cost,0) AS bigint) AS profit,
    ROUND(100 * (t.total_sales - t.total_cost) / t.total_sales,2) AS margin_profit_pct
FROM (
    SELECT 
        dpc.ProductCategoryKey AS category_key,
        dpc.EnglishProductCategoryName AS category_name,
        SUM(fis.OrderQuantity) AS quantity_sold,
        SUM(fis.SalesAmount) AS total_sales,
        SUM(fis.TotalProductCost) AS total_cost
    FROM FactInternetSales fis
    LEFT JOIN DimProduct dp
        ON fis.ProductKey = dp.ProductKey
    LEFT JOIN DimProductSubcategory dps
        ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    LEFT JOIN DimProductCategory dpc
        ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        dpc.ProductCategoryKey, 
        dpc.EnglishProductCategoryName
) t
ORDER BY profit DESC;


/*
===============================================================================
PROFITABILITY ANALYSIS BY PRODUCT CATEGORY (YEARLY)
Objective: 1. Analyze yearly sales, cost, and profit by product category
           2. Measure profit margin percentage for each category
           3. Rank the most profitable categories within each year
Key Concepts: - Aggregation: SUM()
              - Date Functions: YEAR()
              - Common Table Expressions (CTE)
              - Arithmetic Calculations: Profit, Profit Margin
              - Window Functions: DENSE_RANK() OVER(PARTITION BY)
              - Data Formatting: CAST(), ROUND()
===============================================================================
*/

WITH category_metrics AS (
    SELECT 
        YEAR(fis.OrderDate) AS years,
        dpc.ProductCategoryKey AS category_key,
        dpc.EnglishProductCategoryName AS category_name,
        SUM(fis.OrderQuantity) AS quantity_sold,
        SUM(fis.SalesAmount) AS total_sales,
        SUM(fis.TotalProductCost) AS total_cost
    FROM FactInternetSales fis
    LEFT JOIN DimProduct dp
        ON fis.ProductKey = dp.ProductKey
    LEFT JOIN DimProductSubcategory dps
        ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    LEFT JOIN DimProductCategory dpc
        ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        YEAR(fis.OrderDate),
        dpc.ProductCategoryKey,
        dpc.EnglishProductCategoryName
),
category_profit_metrics AS (
    SELECT
        *,
        total_sales - total_cost AS profit,
        ROUND(100 * (total_sales - total_cost) / total_sales,2) AS margin_profit_pct
    FROM category_metrics
),
ranked_category AS (
    SELECT 
        *,
        DENSE_RANK() OVER(PARTITION BY years ORDER BY profit DESC) AS profit_rank_by_year
    FROM category_profit_metrics
)
SELECT 
    years,
    category_key,
    category_name,
    quantity_sold,
    CAST(ROUND(total_sales,0) AS bigint) AS total_sales,
    CAST(ROUND(total_cost,0) AS bigint) AS total_cost,
    CAST(ROUND(profit,0) AS bigint) AS profit,
    margin_profit_pct,
    profit_rank_by_year
FROM ranked_category
WHERE profit_rank_by_year <= 10
ORDER BY years, profit DESC;


/*
===============================================================================
TOP 10 PRODUCTS BY PROFIT (ALL TIME)
Objective: 1. Analyze sales, cost, and profit by product
           2. Measure profit margin percentage for each product
           3. Identify the most profitable products
Key Concepts: - Aggregation: SUM()
              - Arithmetic Calculations: Profit, Profit Margin
              - Data Formatting: CAST(), ROUND()
              - Subquery Aggregation
              - Ranking: TOP
===============================================================================
*/

SELECT TOP 10
    t.product_key,
    t.product_name,
    t.quantity_sold,
    CAST(ROUND(t.total_sales,0) AS bigint) AS total_sales,
    CAST(ROUND(t.total_cost,0)AS bigint) AS total_cost,
    CAST(ROUND(t.total_sales - t.total_cost,0) AS bigint) AS profit,
    ROUND(100 * (t.total_sales-t.total_cost) / t.total_sales,2) AS margin_profit_pct

FROM (
    SELECT 
        dp.ProductKey AS product_key,
        dp.EnglishProductName AS product_name,
        SUM(fis.OrderQuantity) AS quantity_sold,
        SUM(fis.SalesAmount) AS total_sales,
        SUM(fis.TotalProductCost) AS total_cost
    FROM FactInternetSales fis
    LEFT JOIN DimProduct dp
        ON fis.ProductKey = dp.ProductKey
    LEFT JOIN DimProductSubcategory dps
        ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    LEFT JOIN DimProductCategory dpc
        ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        dp.ProductKey,
        dp.EnglishProductName
) t
ORDER BY profit DESC;

/*
===============================================================================
TOP 10 PRODUCTS BY PROFIT (YEARLY)
Objective: 1. Analyze yearly sales, cost, and profit by product
           2. Measure profit margin percentage for each product
           3. Rank the most profitable products within each year
Key Concepts: - Aggregation: SUM()
              - Date Functions: YEAR()
              - Common Table Expressions (CTE)
              - Arithmetic Calculations: Profit, Profit Margin
              - Window Functions: DENSE_RANK() OVER(PARTITION BY)
              - Data Formatting: CAST(), ROUND()
===============================================================================
*/

WITH product_metrics AS (
    SELECT 
        YEAR(fis.OrderDate) AS years,
        dp.ProductKey AS product_key,
        dp.EnglishProductName AS product_name,
        SUM(fis.OrderQuantity) AS quantity_sold,
        SUM(fis.SalesAmount) AS total_sales,
        SUM(fis.TotalProductCost) AS total_cost
    FROM FactInternetSales fis
    LEFT JOIN DimProduct dp
        ON fis.ProductKey = dp.ProductKey
    LEFT JOIN DimProductSubcategory dps
        ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    LEFT JOIN DimProductCategory dpc
        ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        YEAR(fis.OrderDate),
        dp.ProductKey,
        dp.EnglishProductName 
),
product_profit_metrics AS (
    SELECT
        *,
        total_sales - total_cost AS profit,
        ROUND(100 * (total_sales - total_cost) / total_sales,2) AS margin_profit_pct
    FROM product_metrics
),
ranked_products AS (
    SELECT 
        *,
        DENSE_RANK() OVER(PARTITION BY years ORDER BY profit DESC) AS profit_rank_by_year
    FROM product_profit_metrics
)
SELECT
    years,
    product_key,
    product_name,
    quantity_sold,
    CAST(ROUND(total_sales,0) AS bigint) AS total_sales,
    CAST(ROUND(total_cost,0) AS bigint) AS total_cost,
    CAST(ROUND(profit,0) AS bigint) AS profit,
    margin_profit_pct,
    profit_rank_by_year
FROM ranked_products
WHERE profit_rank_by_year <= 10
ORDER BY years, profit DESC;