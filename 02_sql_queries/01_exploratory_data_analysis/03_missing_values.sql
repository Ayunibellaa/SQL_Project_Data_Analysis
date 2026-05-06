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