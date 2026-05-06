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