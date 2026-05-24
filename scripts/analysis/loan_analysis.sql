/*
==============================================================================================================
LOAN ANALYSIS
--------------------------------------------------------------------------------------------------------------
  Purpose:
          Analyze customer borrowing behavior, loan distribution,
          loan growth trends, and customer loan exposure.
          
  Dataset:
          loans_staging
  
  Analysis Areas:
          1. Loan Distribution
          2. Loan Timing
          3. Top Borrowing Customers
==============================================================================================================
*/


/*
==================================================================================================
1. LOAN DISTRIBUTION
--------------------------------------------------------------------------------------------------
Objective:
	Evaluate customer borrowing behavior by analyzing loan exposure, loan size distribution,
	and loan frequency patterns.
==================================================================================================
*/

-- ------------------------------------------------------------------------------------------------
-- Customer Loan Exposure
-- ------------------------------------------------------------------------------------------------
SELECT 
	customer_id,
	COUNT(loan_id) AS loan_count,
	SUM(loan_amount) AS total_loan_amount,
	AVG(loan_amount) AS avg_loan_amount
FROM loans_staging
GROUP BY customer_id
ORDER BY total_loan_amount DESC;


-- ------------------------------------------------------------------------------------------------
-- Loan Size Distribution
-- ------------------------------------------------------------------------------------------------
SELECT 
	loan_category,
	COUNT(loan_id) AS total_loans
FROM loans_staging
GROUP BY loan_category
ORDER BY total_loans DESC;


-- ------------------------------------------------------------------------------------------------
-- Customer Loan Frequency
-- ------------------------------------------------------------------------------------------------
WITH customer_loans AS (
	SELECT 
		customer_id,
		COUNT(loan_id) AS loan_count
	FROM loans_staging
	GROUP BY customer_id
)
SELECT 
	loan_count,
	COUNT(customer_id) AS number_of_customers
FROM customer_loans
GROUP BY loan_count
ORDER BY loan_count DESC;

/*
==================================================================================================
2. LOAN TIMING
--------------------------------------------------------------------------------------------------
Objective:
    Analyze loan issuance trends over time to identify borrowing growth patterns and seasonality.
==================================================================================================
*/


-- ------------------------------------------------------------------------------------------------
-- Monthly loan growth trend
-- ------------------------------------------------------------------------------------------------
SELECT 
	FORMAT(start_date, 'yyyy-MM') AS loan_month,
	SUM(loan_amount) AS total_loan_amount
FROM loans_staging
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY loan_month;


/*
==================================================================================================
3. TOP BORROWING CUSTOMERS
--------------------------------------------------------------------------------------------------
Objective:
    Identify customers with the highest borrowing amounts to understand major loan exposure.
==================================================================================================
*/

-- ------------------------------------------------------------------------------------------------
-- Top 10 customers by total loan amount borrowed
-- ------------------------------------------------------------------------------------------------
SELECT TOP 10
	customer_id,
	SUM(loan_amount) AS total_borrowed
FROM loans_staging
GROUP BY customer_id 
ORDER BY total_borrowed DESC;
