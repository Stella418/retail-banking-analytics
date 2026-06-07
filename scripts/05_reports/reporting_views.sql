/*
==============================================================================================================
REPORTING VIEWS
--------------------------------------------------------------------------------------------------------------
Purpose:
        Create centralized reporting views for customer, transaction, loan, card, and KPI analysis.

        These views consolidate data from staging tables into analysis-ready datasets that support
        reporting, dashboard development, KPI monitoring, pivot tables, and business intelligence workflows.

Views Created:
        1. customer_report
        2. transaction_report
        3. loan_report
        4. card_report
        5. KPIs
==============================================================================================================
*/

/*
==================================================================================================
1. CUSTOMER REPORT
--------------------------------------------------------------------------------------------------
Purpose:
        Provides a customer-level dataset containing demographic, risk, and customer segmentation 
		information for customer growth, risk profiling, and portfolio analysis.
==================================================================================================
*/
IF OBJECT_ID('customer_report', 'V') IS NOT NULL
	DROP VIEW customer_report;

CREATE VIEW customer_report AS

SELECT 
	customer_id,
	customer_name,
	city,
	credit_score,
	risk_category,
	created_at,
	customer_type 
FROM customers_staging;

/*
==================================================================================================
2. TRANSACTION REPORT
--------------------------------------------------------------------------------------------------
Purpose:
        Combines customer, account, transaction, and merchant data into a single reporting view
        for transaction analysis, spending trends, merchant activity, and customer behavior 
        reporting.
==================================================================================================
*/

IF OBJECT_ID('transaction_report', 'V') IS NOT NULL
	DROP VIEW transaction_report;

CREATE VIEW transaction_report AS

SELECT 
	c.customer_id, 
	c.customer_name, 
	c.city AS customer_city, 
	c.credit_score, 
	c.risk_category, 
	c.created_at,
	c.customer_type,
	a.account_id,
	a.account_type,
	a.balance_usd,
	a.balance_category,
	a.open_date,
	t.transaction_id,
	t.amount_usd,
	t.transaction_date,
	m.merchant_id, 
	m.merchant_name, 
	m.city AS merchant_city
FROM transactions_staging t
JOIN accounts_staging a
	ON t.account_id = a.account_id
JOIN customers_staging c
	ON a.customer_id = c.customer_id
LEFT JOIN merchants_staging m
	ON t.merchant_id = m.merchant_id;

/*
==================================================================================================
3. LOAN REPORT
--------------------------------------------------------------------------------------------------
Purpose:
        Combines customer and loan information into a reporting view for loan portfolio analysis,
        lending performance monitoring, and risk assessment.
==================================================================================================
*/

IF OBJECT_ID('loan_report', 'V') IS NOT NULL
	DROP VIEW loan_report;

CREATE VIEW loan_report AS

SELECT
	c.customer_id,
	c.customer_name,
	c.city AS customer_city,
	c.credit_score,
	c.risk_category,
	c.created_at,
	c.customer_type,
	l.loan_id,
	l.loan_amount,
	l.loan_category,
	l.interest_rate,
	l.interest_category,
	l.start_date
FROM loans_staging l
JOIN customers_staging c
	ON l.customer_id = c.customer_id;


/*
==================================================================================================
4. CARD REPORT
--------------------------------------------------------------------------------------------------
Purpose:
        Combines customer, account, and card data into a reporting view for card portfolio 
		analysis, card usage monitoring, and account-card relationship reporting.
==================================================================================================
*/

IF OBJECT_ID('card_report', 'V') IS NOT NULL
	DROP VIEW card_report;

CREATE VIEW card_report AS

SELECT 
	cs.customer_id,
	cs.customer_name,
	cs.city AS customer_city,
	cs.credit_score,
	cs.risk_category,
	cs.customer_type,
	a.account_id,
	a.account_type,
	a.balance_usd,
	a.balance_category,
	a.open_date,
	c.card_id,
	c.card_type,
	c.expiration_date,
	c.card_status 
FROM cards_staging c
JOIN accounts_staging a
	ON c.account_id = a.account_id
JOIN customers_staging cs 
	ON a.customer_id = cs.customer_id;


/*
==================================================================================================
5. KPI REPORT
--------------------------------------------------------------------------------------------------
Purpose:
        Aggregates key banking performance indicators into a single reporting view for executive 
		dashboards, business performance monitoring, and strategic decision-making.

KPIs Included:
        - Total Customers
        - Transaction Volume
        - Total Transaction Value
        - Total Loan Amount
        - Total Account Balance
        - Total Cards Issued
        - Average Account Balance
        - Average Credit Score
        - High Risk Customers
        - Low Risk Customers
        - Average Loan Amount
        - Average Interest Rate
        - Largest Loan Amount
        - Average Transaction Value
        - Total Merchants
        - Expired Card Count
==================================================================================================
*/

IF OBJECT_ID('KPIs', 'V') IS NOT NULL
	DROP VIEW KPIs;

CREATE VIEW KPIs AS

SELECT 
	'Total Customers' AS KPI,
	COUNT(DISTINCT(customer_id)) AS Value
FROM customers_staging
UNION ALL
SELECT
	'Transaction Volume',
	COUNT(transaction_id)
FROM transactions_staging
UNION ALL
SELECT
	'Total Transaction Value',
	SUM(amount_usd)
FROM transactions_staging
UNION ALL 
SELECT
	'Total Loan Amount',
	SUM(loan_amount)
FROM loans_staging
UNION ALL 
SELECT
	'Total Account Balance',
	SUM(balance_usd)
FROM accounts_staging
UNION ALL 
SELECT
	'Total Cards Issued',
	COUNT(DISTINCT(card_id))
FROM cards_staging
UNION ALL 
SELECT
	'Average Account Balance',
	AVG(balance_usd)
FROM accounts_staging
UNION ALL 
SELECT
	'Average Credit Score',
	AVG(credit_score)
FROM customers_staging
UNION ALL 
SELECT
	'High Risk Customers',
	COUNT(risk_category)
FROM customers_staging
WHERE risk_category = 'High Risk'
UNION ALL 
SELECT
	'Low Risk Customers',
	COUNT(risk_category)
FROM customers_staging
WHERE risk_category = 'Low Risk'
UNION ALL 
SELECT
	'Average Loan Amount',
	AVG(loan_amount)
FROM loans_staging
UNION ALL 
SELECT
	'Average Interest Rate',
	AVG(interest_rate)
FROM loans_staging
UNION ALL 
SELECT
	'Largest Loan Amount',
	MAX(loan_amount)
FROM loans_staging
UNION ALL
SELECT
	'Average Transaction Value',
	AVG(amount_usd)
FROM transactions_staging
UNION ALL 
SELECT
	'Total Merchants',
	COUNT(DISTINCT(merchant_id))
FROM merchants_staging
UNION ALL
SELECT
	'Expired Card Count',
	COUNT(card_status)
FROM cards_staging
WHERE card_status = 'Expired'
