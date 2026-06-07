/*
==============================================================================================================
CUSTOMER ANALYSIS
--------------------------------------------------------------------------------------------------------------
  Purpose:
          Analyze customer demographics, risk segmentation,
          tenure distribution, and customer growth trends.
          
  Dataset:
          customers_staging
  
  Analysis Areas:
          1. Customer Profile Distribution by City
          2. Credit Risk Segmentation
          3. Customer Tenure Analysis
          4. Customer Growth Trends
==============================================================================================================
*/


/*
==================================================================================================
1. CUSTOMER PROFILE DISTRIBUTION BY CITY
--------------------------------------------------------------------------------------------------
Objective:
    Identify customer concentration across cities and evaluate geographical distribution patterns.
==================================================================================================
*/

-- Total number of unique cities represented in the dataset
SELECT 
    COUNT(DISTINCT city) AS total_cities
FROM customers_staging;


-- Top 10 cities with the highest customer concentration
SELECT TOP 10
    city,
    COUNT(customer_id) AS customers
FROM customers_staging
GROUP BY city
ORDER BY customers DESC;


-- Distribution of customer concentration across cities
-- Shows how many cities share similar customer volumes
WITH city_counts AS (
    SELECT
        city,
        COUNT(customer_id) AS customer_count
    FROM customers_staging
    GROUP BY city
)

SELECT
    customer_count,
    COUNT(*) AS number_of_cities,

    ROUND(
        100.0 * COUNT(*) 
        / SUM(COUNT(*)) OVER (),
        2
    ) AS percent_of_cities

FROM city_counts
GROUP BY customer_count
ORDER BY customer_count;


/*
==================================================================================================
2. CREDIT RISK SEGMENTATION
--------------------------------------------------------------------------------------------------
Objective:
    Analyze customer distribution across risk categories based on credit score classification.
==================================================================================================
*/

-- Customer distribution by risk category
SELECT 
    risk_category,

    COUNT(customer_id) AS total_customers,

    ROUND(
        COUNT(customer_id) * 100.0
        / SUM(COUNT(customer_id)) OVER (),
        2
    ) AS customer_percentage

FROM customers_staging
GROUP BY risk_category
ORDER BY total_customers DESC;


/*
==================================================================================================
3. CUSTOMER TENURE ANALYSIS
--------------------------------------------------------------------------------------------------
Objective:
    Evaluate the proportion of new versus old customers to understand customer maturity and 
    retention patterns.
==================================================================================================
*/

-- Distribution of customers by tenure category
SELECT
    customer_type,

    COUNT(customer_id) AS total_customers,

    ROUND(
        COUNT(customer_id) * 100.0
        / SUM(COUNT(customer_id)) OVER (),
        2
    ) AS customer_percentage

FROM customers_staging
GROUP BY customer_type
ORDER BY total_customers DESC;


/*
==================================================================================================
4. CUSTOMER GROWTH TREND ANALYSIS
--------------------------------------------------------------------------------------------------
Objective:
    Analyze customer acquisition trends over time to identify yearly growth patterns and 
    seasonality.
==================================================================================================
*/

-- Yearly customer acquisition trend
SELECT
    YEAR(created_at) AS year,
    COUNT(customer_id) AS new_customers

FROM customers_staging
GROUP BY YEAR(created_at)
ORDER BY year;

-- Monthly Cusomer Acquisition Trend
SELECT
    DATENAME(MONTH, created_at) AS month,
    COUNT(customer_id) AS new_customers
FROM customers_staging
GROUP BY
    DATENAME(MONTH, created_at)
ORDER BY MIN(MONTH(created_at));
