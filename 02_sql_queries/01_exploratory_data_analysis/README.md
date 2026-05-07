## Exploratory Data Analysis Summary

### Data Overview
36 tables;  
60,398 rows (fact table)
  
Structured as a data warehouse (fact & dimension tables).  
Data volume is sufficient for analysis and trend evaluation.

### Data Validation  
Grain:  
1 row = 1 product per order line.  
Confirmed line-level granularity (unique per order line).

No duplicate records.  
Ensures accurate aggregation.

Referential Integrity:  
No unmatched ProductKey or CustomerKey.  
Relationships are fully valid and reliable.

### Missing Values
No NULL values in both Foreign Keys & Key Measures.  
Data is complete and analysis-ready.

### Data Distribution
Time Range:  
Dec 2010 – Jan 2014  
Suitable for trend and YoY analysis.
  
Product Distribution:  
4 Categories: Accessories (35 products), Bikes (125 products), Clothing (48 products), Components (189 products).  
Components dominate product count.  
Uneven distribution, potential sales concentration by category.

Customer Income:  
Range:  
10K – 170K yearly income  
Covers low to high income segments → good for segmentation.

---  
**Overall Summary:**  
The dataset is mostly clean, with no duplicate records or missing critical values in fact tables.  
Valid table relationships, ensuring reliable joins.  
No data quality issues were identified, and the dataset is considered analysis-ready.




  
