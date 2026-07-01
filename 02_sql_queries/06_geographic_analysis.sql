/*
===============================================================================
GEOGRAPHIC ANALYSIS OF SALES ACROSS US STATES (ALL TIME)
Objective: 1. Analyze sales performance across states
           2. Measure customer and city activity across states
           3. Evaluate average sales per customer and sales contribution
Key Concepts: - Aggregation: SUM(), COUNT(DISTINCT)
              - Conditional Aggregation: CASE WHEN
              - Window Functions: SUM() OVER()
              - Data Formatting: CAST(), ROUND()
              - Subquery Aggregation
===============================================================================
*/

SELECT 
    t.country_name,
    t.state_code,
    t.state_name,
    t.total_active_cities,
    t.total_active_customers,
    CAST(t.total_sales AS bigint) AS total_sales,
    CAST(t.total_sales AS bigint) / t.total_active_customers AS avg_sales_per_customer,
    ROUND (100 * t.total_sales / SUM(t.total_sales) OVER(),2) AS sales_contribution_pct
FROM (
    SELECT 
        DimGeography.EnglishCountryRegionName AS country_name,
        DimGeography.StateProvinceCode AS state_code,
        DimGeography.StateProvinceName AS state_name,
        COUNT(DISTINCT DimGeography.City) AS total_active_cities,
        COUNT(DISTINCT FactInternetSales.CustomerKey) AS total_active_customers,
        SUM(FactInternetSales.SalesAmount) AS total_sales
    FROM FactInternetSales
    INNER JOIN DimCustomer
        ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
    INNER JOIN DimGeography
        ON DimCustomer.GeographyKey = DimGeography.GeographyKey
    WHERE DimGeography.CountryRegionCode = 'US' AND
        YEAR(FactInternetSales.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        DimGeography.EnglishCountryRegionName,
        DimGeography.StateProvinceCode,
        DimGeography.StateProvinceName
) t
ORDER BY sales_contribution_pct DESC;

/*
===============================================================================
GEOGRAPHIC ANALYSIS OF SALES ACROSS US STATES (YEARLY)
Objective: 1. Analyze yearly sales performance across states
           2. Measure yearly customer and city activity across states
           3. Evaluate average sales per customer and yearly sales contribution
Key Concepts: - Aggregation: SUM(), COUNT(DISTINCT)
              - Date Functions: YEAR()
              - Conditional Aggregation: CASE WHEN
              - Window Functions: SUM() OVER(PARTITION BY)
              - Data Formatting: CAST(), ROUND()
              - Subquery Aggregation
===============================================================================
*/

SELECT 
    CAST(t.years AS date) AS years,
    t.country_name,
    t.state_code,
    t.state_name,
    t.total_active_cities,
    t.total_active_customers,
    CAST(t.total_sales AS bigint) AS total_sales,
    CAST(t.total_sales AS bigint) / t.total_active_customers AS avg_sales_per_customer,
    ROUND (100 * t.total_sales / SUM(t.total_sales) OVER(),2) AS sales_contribution_pct
FROM (
    SELECT 
        DATETRUNC(YEAR,OrderDate) AS years,
        DimGeography.EnglishCountryRegionName AS country_name,
        DimGeography.StateProvinceCode AS state_code,
        DimGeography.StateProvinceName AS state_name,
        COUNT(DISTINCT DimGeography.City) AS total_active_cities,
        COUNT(DISTINCT FactInternetSales.CustomerKey) AS total_active_customers,
        SUM(FactInternetSales.SalesAmount) AS total_sales
    FROM FactInternetSales
    INNER JOIN DimCustomer
        ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
    INNER JOIN DimGeography
        ON DimCustomer.GeographyKey = DimGeography.GeographyKey
    WHERE DimGeography.CountryRegionCode = 'US' AND
        YEAR(FactInternetSales.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        DATETRUNC(YEAR,OrderDate),
        DimGeography.EnglishCountryRegionName,
        DimGeography.StateProvinceCode,
        DimGeography.StateProvinceName
) t
ORDER BY years, sales_contribution_pct DESC;

/*
===============================================================================
GEOGRAPHIC ANALYSIS OF SALES ACROSS US STATES & PRODUCT CATEGORY (ALL TIME)
Objective: 1. Analyze sales performance across states and product category
           2. Measure customer and city activity per category across states
           3. Rank product categories by sales across states
           4. Evaluate sales contribution and average sales per customer
Key Concepts: - Aggregation: SUM(), COUNT(DISTINCT)
              - Conditional Aggregation: CASE WHEN
              - Common Table Expressions (CTE)
              - Window Functions: DENSE_RANK(), SUM() OVER(PARTITION BY)
              - Data Formatting: CAST(), ROUND()
===============================================================================
*/

WITH country_category_metrics AS (
    SELECT 
        DimGeography.EnglishCountryRegionName AS country_name,
        DimGeography.StateProvinceCode AS state_code,
        DimGeography.StateProvinceName AS state_name,
        DimProductCategory.EnglishProductCategoryName AS product_category,
        COUNT(DISTINCT DimGeography.City) AS total_active_cities,
        COUNT(DISTINCT FactInternetSales.CustomerKey) AS total_active_customers,
        SUM(FactInternetSales.SalesAmount) AS total_sales
    FROM FactInternetSales
    INNER JOIN DimCustomer
        ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
    INNER JOIN DimGeography
        ON DimCustomer.GeographyKey = DimGeography.GeographyKey
    INNER JOIN DimProduct
        ON FactInternetSales.ProductKey = DimProduct.ProductKey
    INNER JOIN DimProductSubcategory
        ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
    INNER JOIN DimProductCategory
        ON DimProductSubcategory.ProductCategoryKey = DimProductCategory.ProductCategoryKey
    WHERE DimGeography.CountryRegionCode = 'US' AND
        YEAR(FactInternetSales.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        DimGeography.EnglishCountryRegionName,
        DimGeography.StateProvinceCode,
        DimGeography.StateProvinceName,
        DimProductCategory.EnglishProductCategoryName
),
ranked_country_category AS (
    SELECT 
        *,
        DENSE_RANK() OVER(PARTITION BY state_name ORDER BY total_sales DESC) AS sales_category_rank
    FROM country_category_metrics
)
SELECT 
    country_name,
    state_code,
    state_name,
    product_category,
    total_active_cities,
    total_active_customers,
    CAST(total_sales AS bigint) AS total_sales,
    CAST(total_sales AS bigint) / total_active_customers AS avg_sales_per_customer,
    ROUND (100 * total_sales / SUM(total_sales) OVER(),2) AS sales_contribution_pct,
    sales_category_rank
FROM ranked_country_category
ORDER BY
    state_code,
    sales_category_rank;