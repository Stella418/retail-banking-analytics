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
          2. Top Mechants by Transaction Value
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

/*
==================================================================================================
2. TOP MERCHANTS
--------------------------------------------------------------------------------------------------
Objective:
    Identify top 5 merchants by transcation value
==================================================================================================
*/
SELECT TOP 5
	m.merchant_name,
	SUM(t.amount_usd) as total_transaction_amount
FROM transactions_staging t
JOIN merchants_staging m
	ON t.merchant_id = m.merchant_id
GROUP BY 
	m.merchant_name
ORDER BY total_transaction_amount DESC;

