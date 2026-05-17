/*
=============================================================
Create Database
=============================================================
Script Purpose:
    This script drops and recreates the 'RetailBanking' database.

WARNING:
    Running this script will permanently delete the database if it exists.
=============================================================
*/

USE master;
GO

-- Drop the 'RetailBanking' database if exists
IF DB_ID('RetailBanking') IS NOT NULL
BEGIN
    ALTER DATABASE RetailBanking SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RetailBanking;
END
GO

-- Recreate database
CREATE DATABASE RetailBanking;
GO
