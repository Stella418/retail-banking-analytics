/*
==============================================================================================================
REPORTING VIEWS
--------------------------------------------------------------------------------------------------------------
	Purpose:
			Create centralized reporting views for transaction, loan, and card analytics.

			These views combine multiple staging tables into analysis-ready datasets for reporting, dashboards,
			pivot tables, and business intelligence workflows.
          
	Views Created:
				1. transaction_report
				2. loan_report
				3. card_report
==============================================================================================================
*/


/*
==================================================================================================
1. TRANSACTION REPORT
--------------------------------------------------------------------------------------------------
Objective:
		Create a customer-account-transaction reporting dataset for:
        - Transaction analysis
        - Customer spending behavior
        - Merchant activity analysis
        - Account performance reporting
==================================================================================================
*/

CREATE OR ALTER VIEW transaction_report AS

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
2. LOAN REPORT
--------------------------------------------------------------------------------------------------
Objective:
		Create a customer-loan reporting dataset for:
        - Loan portfolio analysis
        - Borrowing behavior analysis
        - Credit risk assessment
        - Loan growth monitoring
==================================================================================================
*/

CREATE OR ALTER VIEW loan_report AS

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
3. CARD REPORT
--------------------------------------------------------------------------------------------------
Objective:
		Create a customer-account-card reporting dataset for:
        - Card usage analysis
        - Card product analysis
        - Account-card relationship analysis
        - Card status monitoring
==================================================================================================
*/

CREATE OR ALTER VIEW card_report AS

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
