/*
==============================================================================================================
CARD ANALYSIS
--------------------------------------------------------------------------------------------------------------
  Purpose:
          Analyze card usage patterns, card expiry status,
          and account-card relationships.
          
  Dataset:
          cards_staging
  
  Analysis Areas:
          1. Card Type Usage
          2. Expiry Analysis
          3. Account Linkage
==============================================================================================================
*/


/*
==================================================================================================
1. CARD TYPE USAGE
--------------------------------------------------------------------------------------------------
Objective:
    Analyze the distribution of card types to understand customer preference and card product usage.
==================================================================================================
*/

-- Distribution of cards across card types
SELECT 
	card_type,
	COUNT(card_id) AS total_cards,
	ROUND(COUNT(card_id) * 100.0 / SUM(COUNT(card_id)) OVER(), 2) AS percent_share
FROM cards_staging
GROUP BY card_type;


/*
==================================================================================================
2. EXPIRY ANALYSIS
--------------------------------------------------------------------------------------------------
Objective:
    Evaluate the distribution of card expiry status to identify expired, active,
    or soon-to-expire cards.
==================================================================================================
*/

-- Distribution of cards by expiry status
SELECT 
	card_status,
	COUNT(card_id) AS total_cards,
	ROUND(COUNT(card_id) * 100.0 / SUM(COUNT(card_id)) OVER(), 2) AS percent_share
FROM cards_staging
GROUP BY card_status
ORDER BY total_cards DESC;


/*
==================================================================================================
3. ACCOUNT LINKAGE
--------------------------------------------------------------------------------------------------
Objective:
    Analyze how cards are linked to accounts by identifying accounts with multiple cards.
==================================================================================================
*/

-- Distribution of accounts by number of cards owned
WITH accounts_with_multiple_cards AS (
	SELECT
		account_id,
		COUNT(card_id) AS total_cards
	FROM cards_staging
	GROUP BY account_id
	
	-- Focus only on accounts with more than one card
	HAVING COUNT(card_id) > 1
)
SELECT 
	total_cards,
	COUNT(account_id) AS total_accounts,
	ROUND(COUNT(account_id) * 100.0 
		/ SUM(COUNT(account_id)) OVER (), 2) AS account_percentage
FROM accounts_with_multiple_cards
GROUP BY total_cards
ORDER BY total_cards DESC;
