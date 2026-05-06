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

