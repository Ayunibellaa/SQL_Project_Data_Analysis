/* =========================================================
   STEP 1: DATA OVERVIEW
   Purpose: Understand dataset size and structure
========================================================= */

-- Count total number of tables in the database (optional)
-- Helps understand overall database structure
SELECT COUNT(*) AS total_nr_of_tables
FROM INFORMATION_SCHEMA.TABLES;

-- Count total rows in the main fact table
-- Provides an initial idea of data volume
SELECT COUNT(*) AS total_rows
FROM FactInternetSales;


/* =========================================================
   STEP 2: FACT TABLE VALIDATION
   Purpose: Validate data integrity and structure of fact table
========================================================= */

-- Check data grain (1 row should represent 1 order line)
SELECT SalesOrderNumber, SalesOrderLineNumber
FROM FactInternetSales
WHERE SalesOrderNumber IN(
    SELECT SalesOrderNumber
    FROM FactInternetSales
    GROUP BY SalesOrderNumber
    HAVING COUNT(*) > 1)
ORDER BY SalesOrderNumber, SalesOrderLineNumber;

-- Check for duplicate records based on composite primary key
-- Ensures no duplicated transactions exist
SELECT SalesOrderNumber, SalesOrderLineNumber, COUNT(*) AS duplicate_count
FROM FactInternetSales
GROUP BY SalesOrderNumber, SalesOrderLineNumber
HAVING COUNT(*) > 1;

-- Check for NULL values in foreign keys
-- Foreign keys should not be NULL in a well-structured data warehouse
SELECT *
FROM FactInternetSales
WHERE ProductKey IS NULL
   OR CustomerKey IS NULL
   OR OrderDateKey IS NULL;

-- Check for NULL values in important measures
-- Measures are critical for analysis and should not be missing
SELECT *
FROM FactInternetSales
WHERE SalesAmount IS NULL
   OR OrderQuantity IS NULL
   OR TotalProductCost IS NULL;

-- Check data time range
-- Helps understand the coverage period of the dataset
SELECT 
    MIN(OrderDate) AS start_date,
    MAX(OrderDate) AS end_date
FROM FactInternetSales;


/* =========================================================
   STEP 3: DIMENSION JOIN VALIDATION
   Purpose: Ensure referential integrity between fact and dimension tables
========================================================= */

-- Check for unmatched ProductKey (missing product dimension)
-- Identifies broken relationships between fact and dimension
SELECT COUNT(*) AS unmatched_products
FROM FactInternetSales f
LEFT JOIN DimProduct p ON f.ProductKey = p.ProductKey
WHERE p.ProductKey IS NULL;

-- Check for unmatched CustomerKey (missing customer dimension)
-- Ensures all transactions are linked to valid customers
SELECT COUNT(*) AS unmatched_customers
FROM FactInternetSales f
LEFT JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE c.CustomerKey IS NULL;


/* =========================================================
   STEP 4: PRODUCT ANALYSIS
   Purpose: Explore product structure and category distribution
========================================================= */

-- Count number of products per category
-- Helps understand product distribution across categories
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

-- Check products without category (missing hierarchy)
-- Identifies incomplete product classification
SELECT COUNT(*) AS missing_category
FROM DimProduct p
LEFT JOIN DimProductSubcategory s 
    ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
WHERE s.ProductCategoryKey IS NULL;

/* =========================================================
   STEP 5: CUSTOMER EXPLORATION
   Purpose: Understand customer income distribution
========================================================= */

-- Check minimum and maximum customer income
-- Provides a high-level overview of income range
-- Helps define segmentation thresholds for further analysis
SELECT 
    MIN(YearlyIncome) AS min_salary, 
    MAX(YearlyIncome) AS max_salary
FROM DimCustomer;

-- Check unique values of marital status
-- Helps understand customer segmentation possibilities
SELECT DISTINCT MaritalStatus
FROM DimCustomer;

-- Check number of children distribution
-- Understand household composition for potential segmentation
SELECT DISTINCT NumberChildrenAtHome
FROM DimCustomer;




