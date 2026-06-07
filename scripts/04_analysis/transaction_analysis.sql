/* =================================================================================
   TRANSACTION ANALYSIS
   Objective: Analyze transaction activity, identify high-value
   customers, and detect unusual transaction behavior.
====================================================================================
*/


/* ============================================================
   1. TRANSACTION OVERVIEW

   Purpose:
   Provides a high-level summary of transaction activity across
   the bank, including total transaction value, transaction
   volume, average transaction size, and transaction range.

   Business Value:
   Serves as a baseline performance indicator for evaluating
   customer engagement, transaction behavior, and operational
   scale.
=============================================================== */
SELECT 
	SUM(amount_usd) AS total_transaction_amount,
	COUNT(transaction_id) AS total_transactions,
	AVG(amount_usd) AS average_transaction_amount,
	MIN(amount_usd) AS minimum_transaction_amount,
	MAX(amount_usd) AS maximum_transaction_amount
FROM transactions_staging;
   
   
/* ============================================================
   2. TOP 5 CUSTOMERS BY TOTAL TRANSACTION VALUE

   Purpose:
   Identifies the customers who generated the highest cumulative
   transaction value across all accounts. This helps uncover
   high-value customers for retention strategies, premium banking
   services, and cross-selling opportunities.
=============================================================== */
SELECT TOP 5
	c.customer_name,
	SUM(amount_usd) AS total_spent
FROM transactions_staging t
JOIN accounts_staging a
	ON t.account_id = a.account_id 
JOIN customers_staging c
	ON a.customer_id = c.customer_id 
GROUP BY c.customer_name
ORDER BY total_spent DESC;


/* ============================================================
   3. CUSTOMERS WITH UNUSUALLY LARGE TRANSACTIONS

   Purpose:
   Detects customers whose largest transaction exceeds three
   times their average transaction amount. This analysis helps
   identify transaction spikes, unusual spending patterns,
   potential fraud risks, or customers requiring further review.

   Logic:
   Max Transaction > 3 × Average Transaction
============================================================== */
SELECT
    c.customer_name,
    MAX(amount_usd) AS max_transaction,
   ROUND(AVG(amount_usd), 2) AS avg_transaction
FROM transactions_staging t
JOIN accounts_staging a
	ON t.account_id = a.account_id 
JOIN customers_staging c
	ON a.customer_id = c.customer_id 
GROUP BY c.customer_name 
HAVING MAX(amount_usd) > 3 * AVG(amount_usd)
ORDER BY max_transaction DESC;
