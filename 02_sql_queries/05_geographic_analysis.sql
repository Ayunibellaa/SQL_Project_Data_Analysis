/*
===============================================================================
GEOGRAPHIC ANALYSIS OF SALES BY COUNTRY (ALL TIME)
Objective: 1. Analyze sales performance by country
           2. Measure customer and city activity per country
           3. Evaluate average sales per customer and sales contribution
Key Concepts: - Aggregation: SUM(), COUNT(DISTINCT)
              - Conditional Aggregation: CASE WHEN
              - Window Functions: SUM() OVER()
              - Data Formatting: CAST(), ROUND()
              - Subquery Aggregation
===============================================================================
*/

SELECT 
    t.country_code,
    t.country_name,
    t.total_active_cities,
    t.total_active_customers,
    CAST(t.total_sales AS bigint) AS total_sales,
    CAST(t.total_sales AS bigint) / t.total_active_customers AS avg_sales_per_customer,
    ROUND (100 * t.total_sales / SUM(t.total_sales) OVER(),2) AS sales_contribution_pct
FROM (
    SELECT 
        DimGeography.CountryRegionCode AS country_code,
        DimGeography.EnglishCountryRegionName AS country_name,
        COUNT(DISTINCT CASE
                    WHEN FactInternetSales.SalesAmount IS NOT NULL THEN DimGeography.City 
        END) AS total_active_cities,
        COUNT(DISTINCT FactInternetSales.CustomerKey) AS total_active_customers,
        SUM(FactInternetSales.SalesAmount) AS total_sales
    FROM DimCustomer
    LEFT JOIN DimGeography
        ON DimCustomer.GeographyKey = DimGeography.GeographyKey
    LEFT JOIN FactInternetSales
        ON DimCustomer.CustomerKey = FactInternetSales.CustomerKey
    GROUP BY 
        DimGeography.CountryRegionCode,
        DimGeography.EnglishCountryRegionName
) t
ORDER BY sales_contribution_pct DESC;

/*
===============================================================================
GEOGRAPHIC ANALYSIS OF SALES BY COUNTRY (YEARLY)
Objective: 1. Analyze yearly sales performance by country
           2. Measure yearly customer and city activity per country
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
    t.years,
    t.country_code,
    t.country_name,
    t.total_active_cities,
    t.total_active_customers,
    CAST(t.total_sales AS bigint) AS total_sales,
    CAST(t.total_sales AS bigint) / t.total_active_customers AS avg_sales_per_customer,
    ROUND (100 * t.total_sales / SUM(t.total_sales) OVER(),2) AS sales_contribution_pct
FROM (
    SELECT 
        YEAR(OrderDate) AS years,
        DimGeography.CountryRegionCode AS country_code,
        DimGeography.EnglishCountryRegionName AS country_name,
        COUNT(DISTINCT CASE
                    WHEN FactInternetSales.SalesAmount IS NOT NULL THEN DimGeography.City 
        END) AS total_active_cities,
        COUNT(DISTINCT FactInternetSales.CustomerKey) AS total_active_customers,
        SUM(FactInternetSales.SalesAmount) AS total_sales
    FROM DimCustomer
    LEFT JOIN DimGeography
        ON DimCustomer.GeographyKey = DimGeography.GeographyKey
    LEFT JOIN FactInternetSales
        ON DimCustomer.CustomerKey = FactInternetSales.CustomerKey
    GROUP BY 
        YEAR(OrderDate),
        DimGeography.CountryRegionCode,
        DimGeography.EnglishCountryRegionName
) t
ORDER BY t.years, sales_contribution_pct DESC;

/*
===============================================================================
GEOGRAPHIC ANALYSIS OF SALES BY COUNTRY & PRODUCT CATEGORY (ALL TIME)
Objective: 1. Analyze sales performance by country and product category
           2. Measure customer and city activity per category within each country
           3. Rank product categories by sales within each country
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
        DimGeography.CountryRegionCode AS country_code,
        DimGeography.EnglishCountryRegionName AS country_name,
        DimProductCategory.EnglishProductCategoryName AS product_category,
        COUNT(DISTINCT CASE
                    WHEN FactInternetSales.SalesAmount IS NOT NULL THEN DimGeography.City 
        END) AS total_active_cities,
        COUNT(DISTINCT FactInternetSales.CustomerKey) AS total_active_customers,
        SUM(FactInternetSales.SalesAmount) AS total_sales
    FROM DimCustomer
    LEFT JOIN DimGeography
        ON DimCustomer.GeographyKey = DimGeography.GeographyKey
    LEFT JOIN FactInternetSales
        ON DimCustomer.CustomerKey = FactInternetSales.CustomerKey
    LEFT JOIN DimProduct
        ON FactInternetSales.ProductKey = DimProduct.ProductKey
    LEFT JOIN DimProductSubcategory
        ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
    LEFT JOIN DimProductCategory
        ON DimProductCategory.ProductCategoryKey = DimProductSubcategory.ProductCategoryKey
    GROUP BY 
        DimGeography.CountryRegionCode,
        DimGeography.EnglishCountryRegionName,
        DimProductCategory.EnglishProductCategoryName
),
ranked_country_category AS (
    SELECT 
        *,
        DENSE_RANK() OVER(PARTITION BY country_name ORDER BY total_sales DESC) AS sales_category_rank
    FROM country_category_metrics
)
SELECT 
    country_code,
    country_name,
    product_category,
    total_active_cities,
    total_active_customers,
    CAST(total_sales AS bigint) AS total_sales,
    CAST(total_sales AS bigint) / total_active_customers AS avg_sales_per_customer,
    ROUND (100 * total_sales / SUM(total_sales) OVER(),2) AS sales_contribution_pct,
    sales_category_rank
FROM ranked_country_category
ORDER BY 
    CASE country_code
        WHEN 'US' THEN 1
        WHEN 'AU' THEN 2
        WHEN 'GB' THEN 3
        WHEN 'DE' THEN 4
        WHEN 'FR' THEN 5
        WHEN 'CA' THEN 6
    END,
    sales_category_rank;