/*
===================================================================================
STAGING LAYER LOAD SCRIPT
===================================================================================
Purpose:
    This script refreshes all staging tables from raw source tables using a
    TRUNCATE + INSERT pattern.

    It also applies basic data validation rules during load:
    - Loans must be created after customer registration
    - Transactions must occur after account creation

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
  open_date
)
SELECT
	account_id,
	customer_id,
	account_type,
	balance_usd,
	open_date
FROM accounts;



/* =========================================================
   REFRESH: BRANCHES STAGING
   - Direct copy (no transformation required)
========================================================= */

TRUNCATE TABLE branches_staging;

INSERT INTO branches_staging (
	branch_id,
	branch_name,
	manager_name
)
SELECT 
	branch_id,
	branch_name,
	manager_name
FROM branches;



/* =========================================================
   REFRESH: CARDS STAGING
   - Direct copy from raw cards table
========================================================= */

TRUNCATE TABLE cards_staging;

INSERT INTO cards_staging (
	card_id,
	account_id,
	card_type,
	expiration_date
)
SELECT
	card_id,
	account_id,
	card_type,
	expiration_date
FROM cards;



/* =========================================================
   REFRESH: CUSTOMERS STAGING
   - Direct copy from raw customers table
========================================================= */

TRUNCATE TABLE customers_staging;

INSERT INTO customers_staging (
	customer_id,
	first_name,
	last_name,
	email,
	city,
	credit_score,
	created_at
)
SELECT
	customer_id,
	first_name,
	last_name,
	email,
	city,
	credit_score,
	created_at
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
