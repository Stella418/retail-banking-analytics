/*
==============================================================================================================
MERCHANT ANALYSIS
--------------------------------------------------------------------------------------------------------------
  Purpose:
          Analyze merchant distribution across cities and identify
          geographic concentration of merchant activity.
          
  Dataset:
          merchants_staging
  
  Analysis Areas:
          1. Merchant City Concentration
==============================================================================================================
*/


/*
==================================================================================================
1. MERCHANT CITY CONCENTRATION
--------------------------------------------------------------------------------------------------
Objective:
    Identify cities with the highest number of merchants and understand
    geographic clustering of merchant activity.
==================================================================================================
*/
-- Merchant distribution by city (Top 10 cities)

WITH merchant_city_counts AS (
    SELECT
        city,
        COUNT(merchant_id) AS total_merchants
    FROM merchants_staging
    GROUP BY city
)
SELECT TOP 10
    city,
    total_merchants,
    DENSE_RANK() OVER (ORDER BY total_merchants DESC) AS city_rank
FROM merchant_city_counts
ORDER BY total_merchants DESC;

