/* ================================================================
   DATA DISTRIBUTION
   Objective: Explores data patterns and spreads
=================================================================== */

-- Check data time range
SELECT 
    MIN(OrderDate) AS start_date,
    MAX(OrderDate) AS end_date
FROM FactInternetSales;

-- Count product distribution across categories
SELECT 
    c.EnglishProductCategoryName AS category,
    COUNT(DISTINCT p.ProductKey) AS total_products
FROM DimProduct p
LEFT JOIN DimProductSubcategory s 
    ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
LEFT JOIN DimProductCategory c 
    ON s.ProductCategoryKey = c.ProductCategoryKey
GROUP BY c.EnglishProductCategoryName
ORDER BY total_products DESC;

-- Check customer Income Range
SELECT 
    MIN(YearlyIncome) AS min_salary, 
    MAX(YearlyIncome) AS max_salary
FROM DimCustomer;

-- Check marital status distribution
SELECT DISTINCT MaritalStatus
FROM DimCustomer;

-- Check number of children distribution
SELECT DISTINCT NumberChildrenAtHome
FROM DimCustomer;