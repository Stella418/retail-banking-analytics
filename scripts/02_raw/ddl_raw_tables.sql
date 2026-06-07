/*
===================================================================================
DDL Script: Create Tables
===================================================================================
Script Purpose:
    This script drops and recreates all tables in the database.
    Run this script to reset and rebuild the table structure.
===================================================================================
*/



IF OBJECT_ID ('accounts', 'U') IS NOT NULL
	DROP TABLE accounts;
GO

CREATE TABLE accounts (
account_id              NVARCHAR (50) PRIMARY KEY,
customer_id             NVARCHAR (50),
account_type            NVARCHAR (50),
balance_usd             DECIMAL  (18,2),
open_date               DATE
);
GO


IF OBJECT_ID ('cards', 'U') IS NOT NULL
	DROP TABLE cards;
GO

CREATE TABLE cards (
card_id                NVARCHAR (50) PRIMARY KEY,
account_id             NVARCHAR (50),
card_type              NVARCHAR (50),
expiration_date        DATE
);
GO


IF OBJECT_ID ('customers', 'U') IS NOT NULL
	DROP TABLE customers;
GO

CREATE TABLE customers (
customer_id            NVARCHAR (50) PRIMARY KEY,
first_name             NVARCHAR (50),
last_name              NVARCHAR (50),
email                  NVARCHAR (50),
city                   NVARCHAR (50),
credit_score           INT,
created_at             DATE
);
GO


IF OBJECT_ID ('loans', 'U') IS NOT NULL
	DROP TABLE loans;
GO

CREATE TABLE loans (
loan_id               NVARCHAR (50) PRIMARY KEY,
customer_id           NVARCHAR (50),
loan_amount           DECIMAL  (18,2),
interest_rate         DECIMAL  (5,2),
start_date            DATE
);
GO


IF OBJECT_ID ('merchants', 'U') IS NOT NULL
	DROP TABLE merchants;
GO

CREATE TABLE merchants (
merchant_id           NVARCHAR (50) PRIMARY KEY,
merchant_name         NVARCHAR (50),
city                  NVARCHAR (50)
);
GO
