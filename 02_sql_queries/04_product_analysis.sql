
/*
===============================================================================
SALES PERFORMANCE ANALYSIS BY PRODUCT CATEGORY (ALL TIME)
Objective: 1. Analyze total sales and quantity sold by product category
           2. Measure each category's contribution to overall sales
Key Concepts: - Aggregation: SUM()
              - Joins: LEFT JOIN
              - Window Functions: SUM() OVER()
              - Data Formatting: CAST(), ROUND()
              - Subquery Aggregation
===============================================================================
*/

SELECT 
    t.category_key,
    t.category_name,
    t.quantity_sold,
    CAST(ROUND(t.total_sales,0) AS bigint) AS total_sales,
    ROUND(100 * t.total_sales / SUM(t.total_sales) OVER(),2) AS contribution_pct
FROM (
    SELECT 
        dpc.ProductCategoryKey AS category_key,
        dpc.EnglishProductCategoryName AS category_name,
        SUM(fis.OrderQuantity) AS quantity_sold,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimProduct dp
    ON fis.ProductKey = dp.ProductKey
    LEFT JOIN DimProductSubcategory dps
    ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    LEFT JOIN DimProductCategory dpc
    ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    GROUP BY 
        dpc.ProductCategoryKey, 
        dpc.EnglishProductCategoryName
) t
ORDER BY total_sales DESC;


/*
===============================================================================
SALES PERFORMANCE ANALYSIS BY PRODUCT CATEGORY (YEARLY)
Objective: 1. Analyze yearly sales and quantity sold by product category
           2. Measure each category's contribution to total sales per year
Key Concepts: - Aggregation: SUM()
              - Date Functions: DATETRUNC() YEAR()
              - Subquery Aggregation
              - Joins: LEFT JOIN
              - Window Functions: SUM() OVER()
              - Data Formatting: CAST(), ROUND()
===============================================================================
*/

WITH category_metrics AS (
    SELECT 
        YEAR(fis.OrderDate) AS years,
        dpc.ProductCategoryKey AS category_key,
        dpc.EnglishProductCategoryName AS category_name,
        SUM(fis.OrderQuantity) AS quantity_sold,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimProduct dp
    ON fis.ProductKey = dp.ProductKey
    LEFT JOIN DimProductSubcategory dps
    ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    LEFT JOIN DimProductCategory dpc
    ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    GROUP BY 
        YEAR(fis.OrderDate),
        dpc.ProductCategoryKey, 
        dpc.EnglishProductCategoryName
),
ranked_category AS (
    SELECT 
        *,
        DENSE_RANK() OVER(PARTITION BY years ORDER BY total_sales DESC) AS sales_rank
    FROM category_metrics
)
SELECT 
    years,
    category_key,
    category_name,
    quantity_sold,
    CAST(ROUND(total_sales,0) AS bigint) AS total_sales,
    ROUND(100 * total_sales / SUM(total_sales) OVER(PARTITION BY years),2) AS contribution_pct_by_year,
    sales_rank
FROM ranked_category
ORDER BY years, total_sales DESC;


/*
===============================================================================
TOP 10 BEST-SELLING PRODUCTS (ALL TIME)
Objective: 1. Identify top-performing products based on total sales
           2. Measure product sales contribution to overall revenue
           3. Rank products by sales performance
Key Concepts: - Aggregation: SUM()
              - Common Table Expressions (CTE)
              - Window Functions: DENSE_RANK(), SUM() OVER()
              - Data Formatting: CAST(), ROUND()
===============================================================================
*/

WITH product_metrics AS (
    SELECT 
        dp.ProductKey AS product_key,
        dp.EnglishProductName AS product_name,
        SUM(fis.OrderQuantity) AS quantity_sold,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimProduct dp
    ON fis.ProductKey = dp.ProductKey
    LEFT JOIN DimProductSubcategory dps
    ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    LEFT JOIN DimProductCategory dpc
    ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    GROUP BY 
        dp.ProductKey,
        dp.EnglishProductName 
),
ranked_products AS (
    SELECT 
        *,
        DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
    FROM product_metrics
)
SELECT 
    product_key,
    product_name,
    quantity_sold,
    CAST(ROUND(total_sales,0) AS bigint) AS total_sales,
    ROUND(100 * total_sales / SUM(total_sales) OVER(),2) AS contribution_pct
FROM ranked_products
WHERE sales_rank <=10
ORDER BY total_sales DESC;


/*
===============================================================================
TOP 10 BEST-SELLING PRODUCTS (YEARLY)
Objective: 1. Identify top-performing products by year based on total sales
           2. Measure yearly product sales contribution
           3. Rank products within each year
Key Concepts: - Aggregation: SUM()
              - Date Functions: YEAR()
              - Common Table Expressions (CTE)
              - Window Functions: DENSE_RANK(), SUM() OVER(PARTITION BY)
              - Data Formatting: CAST(), ROUND()
===============================================================================
*/

WITH product_metrics AS (
    SELECT 
        YEAR(fis.OrderDate) AS years,
        dp.ProductKey AS product_key,
        dp.EnglishProductName AS product_name,
        SUM(fis.OrderQuantity) AS quantity_sold,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimProduct dp
        ON fis.ProductKey = dp.ProductKey
    LEFT JOIN DimProductSubcategory dps
        ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    LEFT JOIN DimProductCategory dpc
        ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    GROUP BY 
        YEAR(fis.OrderDate),
        dp.ProductKey,
        dp.EnglishProductName 
),
ranked_products AS (
    SELECT 
        *,
        DENSE_RANK() OVER(PARTITION BY years ORDER BY total_sales DESC) AS sales_rank_per_year
    FROM product_metrics
)
SELECT 
    years,
    product_key,
    product_name,
    quantity_sold,
    CAST(ROUND(total_sales,0) AS bigint) AS total_sales,
    ROUND(100 * total_sales / SUM(total_sales) OVER(PARTITION BY years),2) AS contribution_pct_by_year,
    sales_rank_per_year
FROM ranked_products
WHERE sales_rank_per_year <=10
ORDER BY years, total_sales DESC;
