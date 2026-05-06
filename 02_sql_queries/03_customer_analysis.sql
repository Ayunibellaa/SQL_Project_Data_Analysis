
/*
===============================================================================
CUSTOMER LOYALTY & SPENDING ANALYSIS
Objective: 1. Segment customers based on lifespan (loyalty level)
           2. Analyze customer spending and order behavior
           3. Evaluate key metrics: frequency, AOV, and revenue share

Loyalty Segments:
* New Customer (lifespan < 1 year)
* Existing Customer (lifespan 1-2 years)
* Long-Term Customer (lifespan > 2 years)

Key Concepts: - Aggregation: SUM(), COUNT(), MIN(), MAX()
              - Date Functions: DATEDIFF()
              - Conditional Logic: CASE WHEN
              - Window Functions: SUM() OVER()
              - Data Formatting: CAST(), ROUND()
              - Common Table Expressions (CTE)
===============================================================================
*/

WITH customer_lifespan_metrics AS (     -- Calculate individual customer lifetime metrics
    SELECT 
        fis.CustomerKey,
        COUNT(DISTINCT fis.SalesOrderNumber) AS orders,
        DATEDIFF(year, MIN(fis.OrderDate), MAX(fis.OrderDate)) AS lifespan,
        SUM(fis.SalesAmount) AS spending
    FROM FactInternetSales fis
    GROUP BY fis.CustomerKey
),
customer_loyalty_segment_metrics AS ( ---- Segment customers based on lifecycle (lifespan) and aggregate metrics per segment
    SELECT 
        CASE WHEN lifespan < 1 THEN 'New Customer'
             WHEN lifespan BETWEEN 1 AND 2 THEN 'Existing Customer'
             ELSE 'Long-Term Customer'
        END AS loyalty_segment,
        COUNT(*) AS total_customers,
        SUM(spending) AS spending,
        SUM(orders) AS total_orders
    FROM customer_lifespan_metrics
    GROUP BY
        CASE WHEN lifespan < 1 THEN 'New Customer'
             WHEN lifespan BETWEEN 1 AND 2 THEN 'Existing Customer'
             ELSE 'Long-Term Customer'
        END
)
SELECT      -- final output: evaluate performance per loyalty segment
    loyalty_segment,
    total_customers,
    CAST(ROUND(spending,0) AS bigint) AS total_spending,
    total_orders,
    total_orders / total_customers AS purchase_frequency,
    CAST(ROUND(spending / total_orders,0) AS bigint) AS [average_order_value(AOV)],
    CAST(ROUND(100 * spending / SUM(spending) OVER (),2) AS decimal (18,2)) AS [revenue_share(%)]
FROM customer_loyalty_segment_metrics
ORDER BY total_spending DESC;


/*
===============================================================================
INCOME SEGMENT vs PRODUCT CATEGORY ANALYSIS
Objective: 1. Analyze product category performance per income segment
           2. Identify which product categories each income segment spends the most on
           3. Compare spending behavior across different income groups

Income Segments:
* Low Income (Yearly Income < 60k)
* Middle Income (Yearly Income 60k - 100k)
* High Income (Yearly Income >100k)

Key Concepts: - Aggregation: SUM(), COUNT(DISTINCT)
              - Conditional Logic: CASE WHEN
              - Joins: INNER JOIN
              - Window Functions: ROW_NUMBER()
              - Data Formatting: CAST(), ROUND()
              - Common Table Expressions (CTE)
===============================================================================
*/

WITH customer_income_segment AS (      -- Assign income segment to each customer
    SELECT 
        dc.CustomerKey AS customer_key,
        dc.YearlyIncome AS yearly_income,
        CASE WHEN dc.YearlyIncome < 60000 THEN 'Low Income'
             WHEN dc.YearlyIncome BETWEEN 60000 AND 100000 THEN 'Middle Income'
             ELSE 'High Income'
        END AS income_segment
    FROM DimCustomer dc
),
income_category_spending_summary AS (     -- Aggregate metrics by income segment and category
    SELECT
        income_segment,
        dpc.EnglishProductCategoryName AS product_category,
        COUNT(DISTINCT customer_key) AS total_customers,
        COUNT(DISTINCT fis.SalesOrderNumber) AS total_orders,
        SUM(SalesAmount) AS spending
    FROM FactInternetSales fis
    INNER JOIN customer_income_segment cis
        ON fis.CustomerKey = cis.customer_key
    INNER JOIN DimProduct dp
        ON fis.ProductKey = dp.ProductKey
    INNER JOIN DimProductSubcategory dps
        ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    INNER JOIN DimProductCategory dpc 
        ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    GROUP BY
        income_segment,
        dpc.EnglishProductCategoryName
),
ranked_income_category_spending AS (    -- Rank categories within each income segment
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY income_segment ORDER BY spending DESC) AS category_rank
    FROM income_category_spending_summary
)
SELECT      -- final output: evaluate performance per income segment
    income_segment,
    product_category,
    total_customers,
    total_orders,
    CAST(ROUND(spending,0) AS bigint) AS total_spending,
    category_rank
FROM ranked_income_category_spending
ORDER BY income_segment, category_rank;

