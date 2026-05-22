/*
===================================================================================
DDL Script: Create Staging Tables
===================================================================================
Script Purpose:
    This script drops and recreates all staging tables in the database.
    Run this script to reset and rebuild the staging layer.
===================================================================================
*/


IF OBJECT_ID ('accounts_staging', 'U') IS NOT NULL
	DROP TABLE accounts_staging;
GO

CREATE TABLE accounts_staging (
account_id              NVARCHAR (50) PRIMARY KEY,
customer_id             NVARCHAR (50),
account_type            NVARCHAR (50),
balance_usd             DECIMAL  (18,2),
open_date               DATE
);
GO


IF OBJECT_ID ('cards_staging', 'U') IS NOT NULL
	DROP TABLE cards_staging;
GO

CREATE TABLE cards_staging (
card_id                NVARCHAR (50) PRIMARY KEY,
account_id             NVARCHAR (50),
card_type              NVARCHAR (50),
expiration_date        DATE
);
GO


IF OBJECT_ID ('customers_staging', 'U') IS NOT NULL
	DROP TABLE customers_staging;
GO

CREATE TABLE customers_staging (
customer_id            NVARCHAR (50) PRIMARY KEY,
first_name             NVARCHAR (50),
last_name              NVARCHAR (50),
email                  NVARCHAR (50),
city                   NVARCHAR (50),
credit_score           INT,
risk_category          NVARCHAR (50),
created_at             DATE,
customer_type          NVARCHAR (50)
);


IF OBJECT_ID ('loans_staging', 'U') IS NOT NULL
	DROP TABLE loans_staging;
GO

CREATE TABLE loans_staging (
loan_id               NVARCHAR (50) PRIMARY KEY,
customer_id           NVARCHAR (50),
loan_amount           DECIMAL  (18,2),
interest_rate         DECIMAL  (5,2),
start_date            DATE
);
GO


IF OBJECT_ID ('merchants_staging', 'U') IS NOT NULL
	DROP TABLE merchants_staging;
GO

CREATE TABLE merchants_staging (
merchant_id           NVARCHAR (50) PRIMARY KEY,
merchant_name         NVARCHAR (50),
city                  NVARCHAR (50)
);
GO


IF OBJECT_ID ('transactions_staging', 'U') IS NOT NULL
	DROP TABLE transactions_staging;
GO

CREATE TABLE transactions_staging (
transaction_id        NVARCHAR (50) PRIMARY KEY,
account_id            NVARCHAR (50),
merchant_id           NVARCHAR (50),
amount_usd            DECIMAL  (18, 2),
transaction_date      DATETIME
);
GO

