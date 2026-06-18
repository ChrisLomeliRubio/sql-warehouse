/*
========================================================================================
Create Database (if not EXISTS) and create schemas
========================================================================================
This script will create the Database 'DataWarehouse' after checking if the database exists
in case it exist the code will DROP the database and create a new one.
WARNING*
This will drop any database with the name 'DataWarehouse' if you have already a database
of the same name, be cautious
*/
USE master;
GO

--Drop and recreate database if EXISTS, IF NOT EXISTS do nothing
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
  BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK INMEDIATE;
    DROP DATABASE DataWarehouse;
  END;

--Create Database
CREATE DATABASE DataWarehouse;
GO
--Use the newly created database
USE DataWarehouse;
GO
--Create Schemas (bronze, silver, gold)
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
