/*
===================================================================================
STAGING LAYER LOAD SCRIPT
-----------------------------------------------------------------------------------
Purpose:
    This script refreshes all staging tables from raw source tables using a
    TRUNCATE + INSERT pattern.

	This layer also performs data transformation, enrichment and validation to prepare 
	analysis-ready datasets for downstream reporting.

Validation & Business Rules Applied:
	1. Loans must be issued on or after customer registration date
	2. Transactions must occur on or after account opening date
	3. Customer risk categories derived from credit scores
	4. Account balance segmentation applied
	5. Card status derived from expiration dates

Raw source tables remain unchanged to preserve data integrity nd maintain a 
reliable audit trail.
===================================================================================
*/


/* =========================================================
   REFRESH: ACCOUNTS STAGING
	- Full reload from raw accounts table
	- Derives balance category for customer segmentation
	- Prepares account data for reporting and analytics 
========================================================= */

TRUNCATE TABLE accounts_staging;

INSERT INTO accounts_staging (
  account_id,
  customer_id,
  account_type,
  balance_usd,
  balance_category,
  open_date
)
SELECT
	account_id,
	customer_id,
	account_type,
	balance_usd,
	CASE WHEN balance_usd < 10000 THEN 'Low'
		 WHEN balance_usd < 50000 THEN 'Moderate'
		 WHEN balance_usd < 100000 THEN 'High'
		 WHEN balance_usd < 150000 THEN 'Premium'
		 ELSE 'Elite'
	END AS balance_category,
	open_date
FROM accounts;



/* =========================================================
   REFRESH: CARDS STAGING
	- Full reload from raw cards table
	- Derives card status based on expiration date
	- Classifies cards as Active, Near Expiry or Expired

========================================================= */

TRUNCATE TABLE cards_staging;

INSERT INTO cards_staging (
	card_id,
	account_id,
	card_type,
	expiration_date,
	card_status
)
SELECT
	card_id,
	account_id,
	card_type,
	expiration_date,
	CASE WHEN expiration_date < '2025-12-31' THEN 'Expired'
		 WHEN expiration_date BETWEEN '2026-01-01' AND DATEADD(MONTH, 6, '2026-01-01') THEN 'Near Expiry'
		 ELSE 'Active'
	END AS card_status
FROM cards;



/* =========================================================
   REFRESH: CUSTOMERS STAGING
	- Full reload from raw customers table
	- Removes unnecessary attributes
	- Combines first and last names into customer_name
	- Derives customer risk category from credit score
	- Classifies customers as New or Old, based on 
	  onboarding date
========================================================= */

TRUNCATE TABLE customers_staging;

INSERT INTO customers_staging (
	customer_id,
	customer_name,
	city,
	credit_score,
	risk_category,
	created_at,
	customer_type
)
SELECT
	customer_id,
	CONCAT(first_name, ' ', last_name) AS customer_name,
	city,
	credit_score,
	CASE WHEN credit_score >= 750 THEN 'Low Risk'
		 WHEN credit_score BETWEEN 600 AND 749 THEN 'Medium Risk'
		 ELSE 'High Risk'
	END AS risk_category,
	created_at,
	CASE WHEN created_at >= '2024-12-31' THEN 'New Customer'
		 ELSE 'Old Customer'
	END AS customer_type
FROM customers;



/* =========================================================
   REFRESH + VALIDATION: LOANS STAGING
	- Full reload from raw loans table
	- Applies business rule validation
	- Ensures loan start date is not earlier than customer
	  registration date
	- Derives loan size category
	- Derives interest rate category
========================================================= */

TRUNCATE TABLE loans_staging;

INSERT INTO loans_staging (
	loan_id,
	customer_id,
	loan_amount,
	loan_category,
	interest_rate,
	interest_category,
	start_date
)
SELECT 
	l.loan_id,
	l.customer_id,
	l.loan_amount,
	CASE WHEN loan_amount < 50000 THEN 'Small Loan'
		 WHEN loan_amount <= 150000 THEN 'Medium Loan'
		 WHEN loan_amount <= 250000 THEN 'Large Loan'
		 ELSE 'Very Large Loan'
	END AS loan_category,
	l.interest_rate,
	CASE WHEN interest_rate < 5 THEN 'Low Interest'
		 WHEN interest_rate <= 10 THEN 'Medium Interest'
		 ELSE 'High Interest'
	END AS interest_category,
	l.start_date
FROM loans l
JOIN customers c 
	ON l.customer_id = c.customer_id 
WHERE l.start_date >= c.created_at;



/* =========================================================
   REFRESH: MERCHANTS STAGING
	- Full reload from raw merchants table
========================================================= */

TRUNCATE TABLE merchants_staging;

INSERT INTO merchants_staging (
	merchant_id,
	merchant_name,
	city
)
SELECT
	merchant_id,
	merchant_name,
	city
FROM merchants;



/* =========================================================
   REFRESH + VALIDATION: TRANSACTIONS STAGING
	- Full reload from raw transactions table
	- Applies business rule validation
	- Ensures transaction date is not earlier than account
	  opening date
	- Filters logically invalid transaction records
	- Produces clean transaction dataset for reporting
========================================================= */

TRUNCATE TABLE transactions_staging;

INSERT INTO transactions_staging (
	transaction_id,
	account_id,
	merchant_id,
	amount_usd,
	transaction_date
)
SELECT
	t.transaction_id,
	t.account_id,
	t.merchant_id,
	t.amount_usd,
	t.transaction_date
FROM transactions t
JOIN accounts a
	ON t.account_id = a.account_id
WHERE t.transaction_date  >= a.open_date;
