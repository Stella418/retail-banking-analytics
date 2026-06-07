/*
==============================================================================================================
ACCOUNT ANALYSIS
--------------------------------------------------------------------------------------------------------------
  Purpose:
          Analyze account distribution, balance behavior,
          account opening trends, and customer-account relationships.
          
  Dataset:
          accounts_staging
  
  Analysis Areas:
          1. Account Type Distribution
          2. Balance Analysis
          3. Account Activity Timing
          4. Customer - Account Relationship
==============================================================================================================
*/


/*
==================================================================================================
1. ACCOUNT TYPE DISTRIBUTION
--------------------------------------------------------------------------------------------------
Objective:
    Analyze the distribution of account types and identify the most commonly used account products.
==================================================================================================
*/

-- Distribution of accounts across account types
SELECT 
	account_type,
	COUNT(account_id) AS total_accounts,
	ROUND(COUNT(account_id) * 100.0 / SUM(COUNT(account_id)) OVER (), 2) AS percentage
FROM accounts_staging
GROUP BY account_type
ORDER BY total_accounts DESC;


/*
==================================================================================================
2. BALANCE ANALYSIS
--------------------------------------------------------------------------------------------------
Objective:
    Evaluate account balance behavior across account types and balance segments to understand
    customer wealth distribution.
==================================================================================================
*/

-- Average balance per account type
SELECT
	account_type,
	ROUND(AVG(balance_usd), 2) AS avg_balance
FROM accounts_staging
GROUP BY account_type
ORDER BY avg_balance DESC;

-- Distribution of accounts accross balance categories
SELECT 
	balance_category,
	COUNT(account_id) AS total_accounts,
	ROUND(COUNT(account_id) * 100.0 / SUM(COUNT(account_id)) OVER (), 2) AS percentage
FROM accounts_staging
GROUP BY balance_category
ORDER BY total_accounts DESC;


/*
==================================================================================================
3. ACCOUNT ACTIVITY TIMING
--------------------------------------------------------------------------------------------------
Objective:
    Analyze account opening patterns across months and years to identify growth trends and
    seasonality in account creation.
==================================================================================================
*/

--Monthly account opening trend
SELECT
    DATENAME(MONTH, open_date) AS opening_month,
    COUNT(account_id) AS accounts_opened
FROM accounts_staging
GROUP BY DATENAME(MONTH, open_date)
ORDER BY MIN(MONTH(open_date));

--Yearly account opening trend
SELECT
    YEAR(open_date) AS opening_year,
    COUNT(account_id) AS accounts_opened
FROM accounts_staging
GROUP BY YEAR(open_date)
ORDER BY opening_year;


/*
==================================================================================================
4. CUSTOMER - ACCOUNT RELATIONSHIP
--------------------------------------------------------------------------------------------------
Objective:
    Evaluate account ownership behavior by identifying how many accounts customers typically own.
==================================================================================================
*/

-- Distribution of customers by number of accounts owned
SELECT 
	t.total_accounts,
	COUNT(t.customer_id) AS total_customers,
	ROUND(COUNT(customer_id) * 100.0 
		/ SUM(COUNT(customer_id)) OVER (), 2) AS customer_percentage
FROM (
	SELECT 
		customer_id,
		COUNT(account_id) AS total_accounts
	FROM accounts_staging
	GROUP BY customer_id
)t
GROUP BY t.total_accounts
ORDER BY t.total_accounts DESC;
