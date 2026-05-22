/*
===================================================================================
DATA QUALITY & VALIDATION SCRIPT
===================================================================================
Purpose:
    This script performs comprehensive data quality checks across all tables,
    including completeness, duplicates, standardization, formatting issues,
    integrity, and business rules validation.

    It also compares raw vs cleaned (staging) datasets.
===================================================================================
*/


/* =========================================================
   1. ROW COUNT VALIDATION
========================================================= */

SELECT 'accounts' AS table_name, COUNT(*) AS row_count FROM accounts
UNION ALL
SELECT 'cards', COUNT(*) FROM cards
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'loans', COUNT(*) FROM loans
UNION ALL
SELECT 'merchants', COUNT(*) FROM merchants
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions;



/* =========================================================
   2. NULL VALUE CHECKS
========================================================= */

-- Accounts
SELECT *
FROM accounts
WHERE account_id IS NULL
   OR customer_id IS NULL
   OR account_type IS NULL
   OR balance_usd IS NULL
   OR open_date IS NULL;

-- Cards
SELECT *
FROM cards
WHERE card_id IS NULL
   OR account_id IS NULL
   OR card_type IS NULL
   OR expiration_date IS NULL;

-- Customers
SELECT *
FROM customers
WHERE customer_id IS NULL
   OR first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL
   OR city IS NULL
   OR credit_score IS NULL
   OR created_at IS NULL;

-- Loans
SELECT *
FROM loans
WHERE loan_id IS NULL
   OR customer_id IS NULL
   OR loan_amount IS NULL
   OR interest_rate IS NULL
   OR start_date IS NULL;

-- Merchants
SELECT *
FROM merchants
WHERE merchant_id IS NULL
   OR merchant_name IS NULL
   OR city IS NULL;

-- Transactions
SELECT *
FROM transactions
WHERE transaction_id IS NULL
   OR account_id IS NULL
   OR merchant_id IS NULL
   OR amount_usd IS NULL
   OR transaction_date IS NULL;



/* =========================================================
   3. DUPLICATE CHECKS
========================================================= */

SELECT account_id, COUNT(*) AS duplicate_count
FROM accounts
GROUP BY account_id
HAVING COUNT(*) > 1;

SELECT card_id, COUNT(*) AS duplicate_count
FROM cards
GROUP BY card_id
HAVING COUNT(*) > 1;

SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT loan_id, COUNT(*) AS duplicate_count
FROM loans
GROUP BY loan_id
HAVING COUNT(*) > 1;

SELECT transaction_id, COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


/* =========================================================
   4. UNWANTED SPACES CHECK
========================================================= */
-- Accounts
SELECT account_id
FROM accounts
WHERE account_id != TRIM(account_id);

SELECT customer_id 
FROM accounts
WHERE customer_id != TRIM(customer_id);

SELECT account_type  
FROM accounts
WHERE account_type != TRIM(account_type);

-- Cards
SELECT card_id 
FROM cards
WHERE card_id != TRIM(card_id);

SELECT account_id   
FROM cards
WHERE account_id != TRIM(account_id);

SELECT card_type  
FROM cards
WHERE card_type != TRIM(card_type);

-- Customers
SELECT customer_id  
FROM customers
WHERE customer_id != TRIM(customer_id);

SELECT first_name   
FROM customers
WHERE first_name != TRIM(first_name);

SELECT last_name    
FROM customers
WHERE last_name != TRIM(last_name);

SELECT email    
FROM customers
WHERE email != TRIM(email);

SELECT city     
FROM customers
WHERE city != TRIM(city);

-- Loans
SELECT loan_id     
FROM loans
WHERE loan_id != TRIM(loan_id);

SELECT customer_id      
FROM loans
WHERE customer_id != TRIM(customer_id);

-- Merchants
SELECT merchant_id       
FROM merchants
WHERE merchant_id != TRIM(merchant_id);

SELECT merchant_name        
FROM merchants
WHERE merchant_name != TRIM(merchant_name);

SELECT city        
FROM merchants
WHERE city != TRIM(city);

-- Transactions
SELECT transaction_id         
FROM transactions
WHERE transaction_id != TRIM(transaction_id);

SELECT account_id          
FROM transactions
WHERE account_id != TRIM(account_id);

SELECT merchant_id
FROM transactions
WHERE merchant_id != TRIM(merchant_id);



/* =========================================================
   5. STANDARDIZATION CHECKS
========================================================= */

SELECT DISTINCT account_type FROM accounts;
SELECT DISTINCT card_type FROM cards;
SELECT DISTINCT city FROM customers;



/* =========================================================
   6. INVALID VALUE CHECKS
========================================================= */

-- Accounts: negative balances
SELECT *
FROM accounts
WHERE balance_usd < 0;

-- Customers: invalid credit scores
SELECT *
FROM customers
WHERE credit_score < 300 OR credit_score > 850;

-- Loans: invalid interest rates
SELECT *
FROM loans
WHERE interest_rate < 0 OR interest_rate > 100;

-- Transactions: negative amounts
SELECT *
FROM transactions
WHERE amount_usd < 0;



/* =========================================================
   7. DATE VALIDATION CHECKS
========================================================= */

SELECT *
FROM accounts
WHERE open_date > '2025-12-31';

SELECT *
FROM customers
WHERE created_at > '2025-12-31';

SELECT *
FROM loans
WHERE start_date > '2025-12-31';



/* =========================================================
   8. BUSINESS RULE VALIDATION (PRE-CLEANING)
========================================================= */

-- Transactions before account creation
WITH totals AS (
    SELECT COUNT(*) AS total_transactions
    FROM transactions
),
invalids AS (
    SELECT COUNT(*) AS invalid_transactions
    FROM transactions t
    JOIN accounts a
        ON t.account_id = a.account_id
    WHERE t.transaction_date < a.open_date
)
SELECT
    invalid_transactions,
    invalid_transactions * 100.0 / total_transactions AS invalid_percentage
FROM invalids
CROSS JOIN totals;



-- Loans before customer creation
WITH totals AS (
    SELECT COUNT(*) AS total_loans
    FROM loans
),
invalids AS (
    SELECT COUNT(*) AS invalid_loans
    FROM loans l
    JOIN customers c
        ON l.customer_id = c.customer_id
    WHERE l.start_date < c.created_at
)
SELECT
    invalid_loans,
    invalid_loans * 100.0 / total_loans AS invalid_percentage
FROM invalids
CROSS JOIN totals;



/* =========================================================
   9. BUSINESS RULE VALIDATION (POST-CLEANING)
========================================================= */

-- Transactions cleaned validation
SELECT COUNT(*) AS invalid_transactions_cleaned
FROM transactions_staging t
JOIN accounts_staging a
    ON t.account_id = a.account_id
WHERE t.transaction_date < a.open_date;

-- Loans cleaned validation
SELECT COUNT(*) AS invalid_loans_cleaned
FROM loans_staging l
JOIN customers_staging c
    ON l.customer_id = c.customer_id
WHERE l.start_date < c.created_at;



/* =========================================================
   10. REFERENTIAL INTEGRITY CHECKS
========================================================= */

-- Cards without valid accounts
SELECT *
FROM accounts
WHERE account_id NOT IN (
	SELECT account_id
	FROM cards
);

-- Accounts without valid customers
SELECT *
FROM accounts
WHERE customer_id NOT IN (
	SELECT customer_id
	FROM customers
);

-- Loans without valid customers
SELECT *
FROM loans
WHERE customer_id NOT IN (
	SELECT customer_id
	FROM customers
);

-- Transactions without valid accounts
SELECT *
FROM transactions
WHERE account_id NOT IN (
	SELECT account_id
	FROM accounts
);



/* =========================================================
   11. BUSINESS INTERPRETATION SUMMARY
=========================================================

- Significant data quality issues detected in raw dataset:
    • Transactions and loans had major temporal inconsistencies
    • Referential integrity gaps exist but are expected in synthetic datasets
    • Data required cleaning before analysis

- Cleaned staging tables were created for analytical use
- All invalid records were excluded based on business rules:
    • transaction_date >= account.open_date
    • loan.start_date >= customer.created_at

========================================================= */
