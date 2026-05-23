/*
===================================================================================
STAGING LAYER LOAD SCRIPT
-----------------------------------------------------------------------------------
Purpose:
    This script refreshes all staging tables from raw source tables using a
    TRUNCATE + INSERT pattern.

    It also applies basic data validation rules during load:
    - Loans must be created after customer registration
    - Transactions must occur after account creation
    - Customer risk classification derived from credit score

    Raw tables remain untouched to preserve data integrity.
===================================================================================
*/


/* =========================================================
   REFRESH: ACCOUNTS STAGING
   - Full reload from raw accounts table
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
	- Direct copy from raw cards table
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
	- Loads customer data 
	- Removes unneccessary columns
	- Concatenates first_name and last_name
	- Derives risk classification based on credit score
	- Derives customer type from created_at
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
   - Includes business rule validation
   - Ensures loans are created after customer registration
========================================================= */

TRUNCATE TABLE loans_staging;

INSERT INTO loans_staging (
	loan_id,
	customer_id,
	loan_amount,
	interest_rate,
	start_date
)
SELECT 
	l.loan_id,
	l.customer_id,
	l.loan_amount,
	l.interest_rate,
	l.start_date
FROM loans l
JOIN customers c 
	ON l.customer_id = c.customer_id 
WHERE l.start_date >= c.created_at;



/* =========================================================
   REFRESH: MERCHANTS STAGING
   - Direct copy from raw merchants table
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
   - Ensures transactions occur after account creation
   - Filters out logically invalid records
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
