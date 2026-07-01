
/*
===============================================================================
ANNUAL TREND PERFORMANCE & YEAR OVER YEAR GROWTH ANALYSIS (ALL STATES)
Objective: 1. Analyze yearly revenue and order trend
           2. Analyze Year-over-Year (YoY) growth
Key Concepts: - Aggregation: SUM(), COUNT(DISTINCT)
              - Date Functions: YEAR()
              - Window Functions: LAG()
              - Data Formatting: CAST(), ROUND()
              - Subquery Aggregation
===============================================================================
*/

SELECT
    CAST(t.years AS date) AS years,
    t.total_orders,
    CAST(ROUND(t.total_sales,0) AS bigint) AS total_sales,
    CAST(LAG(t.total_sales) OVER(ORDER BY t.years) AS bigint) AS prev_year_sales,
    CAST(ROUND(100 * (t.total_sales - LAG(t.total_sales) OVER(ORDER BY t.years)) / LAG(t.total_sales) OVER(ORDER BY t.years),2) AS decimal (18,2)) AS growth_pct
FROM (
    SELECT 
        DATETRUNC(YEAR, fis.OrderDate) AS years,
        COUNT(DISTINCT fis.SalesOrderNumber) AS total_orders,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        DATETRUNC(YEAR, fis.OrderDate)

) t
ORDER BY t.years;


/*
===============================================================================
ANNUAL TREND PERFORMANCE & YEAR OVER YEAR GROWTH ANALYSIS (ACROSS STATES)
Objective: 1. Analyze yearly revenue and order trend
           2. Analyze Year-over-Year (YoY) growth
Key Concepts: - Aggregation: SUM(), COUNT(DISTINCT)
              - Date Functions: YEAR()
              - Window Functions: LAG()
              - Data Formatting: CAST(), ROUND()
              - Subquery Aggregation
===============================================================================
*/

SELECT
    t.years,
    t.state_code,
    t.state_name,
    t.total_orders,
    CAST(ROUND(t.total_sales,0) AS bigint) AS total_sales,
    CAST(LAG(t.total_sales) OVER(PARTITION BY state_code ORDER BY t.years) AS bigint) AS prev_year_sales,
    CAST(ROUND(100 * (t.total_sales - LAG(t.total_sales) OVER(PARTITION BY state_code ORDER BY t.years)) / LAG(t.total_sales) OVER(PARTITION BY state_code ORDER BY t.years),2) AS decimal (18,2)) AS growth_pct
FROM (
    SELECT 
        YEAR(fis.OrderDate) AS years,
        dg.StateProvinceCode AS state_code,
        dg.StateProvinceName AS state_name,
        COUNT(DISTINCT fis.SalesOrderNumber) AS total_orders,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        YEAR(fis.OrderDate),
        dg.StateProvinceCode,
        dg.StateProvinceName

) t
ORDER BY t.years;


/*
===============================================================================
MONTHLY PERFORMANCE TREND (ALL STATES)
Objective: 1. Monthly sales performance, rank by sales
           2. Compare each month's sales to the yearly average
           3. identify months performing above, below, or equal to the annual average
Key Concepts: - Aggregation: SUM(), COUNT(DISTINCT)
              - Date Functions: DATETRUNC() YEAR()
              - Window Functions: AVG() OVER()
              - Conditional Logic: CASE WHEN
              - Data Formatting: CAST(), ROUND()
              - Common Table Expressions (CTE)
===============================================================================
*/

WITH monthly_sales_metrics AS (
    SELECT 
        DATETRUNC(month, fis.OrderDate) AS order_date,
        COUNT(DISTINCT fis.SalesOrderNumber) AS total_orders,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY DATETRUNC(month, fis.OrderDate)
),
monthly_sales_comparison AS (
    SELECT
        *,
        DENSE_RANK() OVER(PARTITION BY YEAR(order_date) ORDER BY total_sales DESC) AS sales_rank,
        AVG(total_sales) OVER(PARTITION BY YEAR(order_date)) AS avg_per_year
    FROM monthly_sales_metrics
)
SELECT 
    CAST(order_date AS date) AS order_date,
    total_orders,
    CAST(ROUND(total_sales,0) AS bigint) AS total_sales,
    sales_rank,
    CAST(ROUND(avg_per_year,0) AS bigint) AS avg_per_year,
    CASE
        WHEN total_sales < avg_per_year THEN 'Below the Yearly Average'
        WHEN total_sales > avg_per_year THEN 'Above the Yearly Average'
        WHEN total_sales = avg_per_year THEN 'Equal to Yearly Average'
    END AS [below/above_the_average]
FROM monthly_sales_comparison
ORDER BY order_date;

/*
===============================================================================
MONTHLY PERFORMANCE TREND (ACROSS STATES)
Objective: 1. Monthly sales performance, rank by sales
           2. Compare each month's sales to the yearly average
           3. identify months performing above, below, or equal to the annual average
Key Concepts: - Aggregation: SUM(), COUNT(DISTINCT)
              - Date Functions: DATETRUNC() YEAR()
              - Window Functions: AVG() OVER()
              - Conditional Logic: CASE WHEN
              - Data Formatting: CAST(), ROUND()
              - Common Table Expressions (CTE)
===============================================================================
*/

WITH monthly_sales_metrics AS (
    SELECT 
        DATETRUNC(month, fis.OrderDate) AS order_date,
        dg.StateProvinceCode AS state_code,
        dg.StateProvinceName AS state_name,
        COUNT(DISTINCT fis.SalesOrderNumber) AS total_orders,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        DATETRUNC(month, fis.OrderDate),
        dg.StateProvinceCode,
        dg.StateProvinceName
),
monthly_sales_comparison AS (
    SELECT
        *,
        AVG(total_sales) OVER(PARTITION BY YEAR(order_date)) AS avg_per_year
    FROM monthly_sales_metrics
)
SELECT 
    CAST(order_date AS date) AS order_date,
    state_code,
    state_name,
    total_orders,
    CAST(ROUND(total_sales,0) AS bigint) AS total_sales,
    CAST(ROUND(avg_per_year,0) AS bigint) AS avg_per_year,
    CASE
        WHEN total_sales < avg_per_year THEN 'Below the Yearly Average'
        WHEN total_sales > avg_per_year THEN 'Above the Yearly Average'
        WHEN total_sales = avg_per_year THEN 'Equal to Yearly Average'
    END AS [below/above_the_average]
FROM monthly_sales_comparison
ORDER BY order_date, total_sales DESC;

/*
===============================================================================
CUMULATIVE ANALYSIS OVER TIME (ALL STATES)
Objective: 1. Analyze monthly sales performance using:
              - Total Sales
              - Running Total (cumulative per year)
              - Moving Average (trend over time)
Key Concepts: - Aggregation: SUM(), AVG()
              - Date Functions: YEAR(), DATETRUNC()
              - Window Functions: SUM() OVER(), AVG() OVER()
              - Data Formatting: CAST(), ROUND()
              - Subquery Aggregation
===============================================================================
*/

SELECT
    CAST(t.order_date AS date) AS order_date,
    CAST(ROUND(t.total_sales,0) AS bigint) AS total_sales,
    CAST(ROUND(SUM(t.total_sales) OVER(PARTITION BY YEAR(t.order_date) ORDER BY t.order_date),0) AS bigint) AS running_total,
    CAST(ROUND(AVG(t.total_sales) OVER(PARTITION BY YEAR(t.order_date) ORDER BY t.order_date),0) AS bigint) AS moving_avg
FROM (
    SELECT 
        DATETRUNC(month, fis.OrderDate) AS order_date,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        DATETRUNC(month, fis.OrderDate), 
        YEAR(fis.OrderDate)
) t
ORDER BY order_date;

/*
===============================================================================
CUMULATIVE ANALYSIS OVER TIME (ACROSS STATES)
Objective: 1. Analyze monthly sales performance using:
              - Total Sales
              - Running Total (cumulative per year)
              - Moving Average (trend over time)
Key Concepts: - Aggregation: SUM(), AVG()
              - Date Functions: YEAR(), DATETRUNC()
              - Window Functions: SUM() OVER(), AVG() OVER()
              - Data Formatting: CAST(), ROUND()
              - Subquery Aggregation
===============================================================================
*/

SELECT
    CAST(t.order_date AS date) AS order_date,
    t.state_code,
    t.state_name,
    CAST(ROUND(t.total_sales,0) AS bigint) AS total_sales,
    CAST(ROUND(SUM(t.total_sales) OVER(PARTITION BY YEAR(t.order_date) ORDER BY t.order_date),0) AS bigint) AS running_total,
    CAST(ROUND(AVG(t.total_sales) OVER(PARTITION BY YEAR(t.order_date) ORDER BY t.order_date),0) AS bigint) AS moving_avg
FROM (
    SELECT 
        DATETRUNC(month, fis.OrderDate) AS order_date,
        dg.StateProvinceCode AS state_code,
        dg.StateProvinceName AS state_name,
        SUM(fis.SalesAmount) AS total_sales
    FROM FactInternetSales fis
    LEFT JOIN DimCustomer dc
        ON fis.CustomerKey = dc.CustomerKey
    LEFT JOIN DimGeography dg
        ON dc.GeographyKey = dg.GeographyKey
    WHERE dg.CountryRegionCode = 'US' AND
        YEAR(fis.OrderDate) BETWEEN 2011 AND 2013
    GROUP BY 
        DATETRUNC(month, fis.OrderDate),
        dg.StateProvinceCode,
        dg.StateProvinceName
) t
ORDER BY order_date, total_sales DESC;
