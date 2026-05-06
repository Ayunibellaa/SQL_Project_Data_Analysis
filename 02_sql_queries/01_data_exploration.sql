/* ================================================================
   DATA OVERVIEW
   Objective: Understand dataset size and structure
=================================================================== */

-- Count Total Number of Tables
SELECT COUNT(*) AS total_nr_of_tables
FROM INFORMATION_SCHEMA.TABLES;

-- Count Total Rows in Fact Table
SELECT COUNT(*) AS total_rows
FROM FactInternetSales;

/* ================================================================
   FACT TABLE VALIDATION
   Objective: - Validate data grain
              - Check duplicates
              - Validate relationships
=================================================================== */

-- Validate data grain
SELECT SalesOrderNumber, SalesOrderLineNumber
FROM FactInternetSales
WHERE SalesOrderNumber IN(
    SELECT SalesOrderNumber
    FROM FactInternetSales
    GROUP BY SalesOrderNumber
    HAVING COUNT(*) > 1)
ORDER BY SalesOrderNumber, SalesOrderLineNumber;

-- Duplicate Check
SELECT SalesOrderNumber, SalesOrderLineNumber, COUNT(*) AS duplicate_count
FROM FactInternetSales
GROUP BY SalesOrderNumber, SalesOrderLineNumber
HAVING COUNT(*) > 1;

-- Unmatched ProductKey
SELECT COUNT(*) AS unmatched_products
FROM FactInternetSales f
LEFT JOIN DimProduct p ON f.ProductKey = p.ProductKey
WHERE p.ProductKey IS NULL;

-- Unmatched CustomerKey
SELECT COUNT(*) AS unmatched_customers
FROM FactInternetSales f
LEFT JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.CustomerKey IS NULL;

/* ================================================================
   MISSING VALUES
   Objective: Checks for missing values in critical columns
=================================================================== */

-- NULL Check in Foreign Keys
SELECT *
FROM FactInternetSales
WHERE ProductKey IS NULL
   OR CustomerKey IS NULL
   OR OrderDateKey IS NULL
   OR SalesTerritoryKey IS NULL;

-- NULL Check in Key Measures
SELECT *
FROM FactInternetSales
WHERE SalesAmount IS NULL
   OR OrderQuantity IS NULL
   OR TotalProductCost IS NULL;

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

/* ================================================================
   DATA QUALITY
   Objective: Identifies incomplete product classification
=================================================================== */

-- Check products without category (missing hierarchy)
SELECT COUNT(*) AS missing_category
FROM DimProduct p
LEFT JOIN DimProductSubcategory s 
    ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
WHERE s.ProductCategoryKey IS NULL;







