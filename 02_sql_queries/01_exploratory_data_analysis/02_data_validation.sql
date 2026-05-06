/* ================================================================
   FACT TABLE VALIDATION
   Objective: - Validate data grain
              - Check duplicates
              - Validate relationships
=================================================================== */

-- Validate data grain
SELECT TOP 10 SalesOrderNumber, SalesOrderLineNumber
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