/*================================================================================
||  Bulk the data from the CSV files to tables. This changes depending in where  ||
||  you have stored the files in yout machine. You must modify	        				 ||
||  this code to your context in order for it to work properly.			        		 ||
||  Then create a store procedure.												                       ||
=================================================================================*/
--Create stored procedure
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_load_bronze DATETIME, @end_time_load_bronze DATETIME
	BEGIN TRY
		PRINT'LOADING DATA'
		PRINT'========================================'
		PRINT'LOADING CRM TABLES'
		PRINT'========================================'
		--Truncate the table in order to not load duplicate data
		SET @start_time_load_bronze = GETDATE();
		SET @start_time = GETDATE();
		PRINT'TRUNCATING TABLE bronze.crm_cust_info'
		PRINT'========================================'
		TRUNCATE TABLE bronze.crm_cust_info;
		-- Bulk insert data into crm_cust_info
		PRINT'INSERTING DATA IN TABLE bronze.crm_cust_info'
		PRINT'========================================'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\crist\Documents\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2, --Set the initial row for that in the second position
			FIELDTERMINATOR = ',', -- Use the , delimitador
			TABLOCK --Lock the table while loading it with data
		);
		SET @end_time = GETDATE();
		--Gets the total duration of the process with the variables declared on line 11
		PRINT'Process Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT'- - - - - - - - - - - - - - - - - - - - - - - - - -'


		--Truncate the table in order to not load duplicate data
		PRINT'TRUNCATING TABLE bronze.crm_prd_info'
		PRINT'========================================'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info;
		-- Bulk insert data into crm_prd_info
		PRINT'INSERTING DATA IN TABLE bronze.crm_prd_info'
		PRINT'========================================'
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\crist\Documents\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2, --Set the initial row for that in the second position
			FIELDTERMINATOR = ',', -- Use the , delimitador
			TABLOCK --Lock the table while loading it with data
		);
		SET @end_time = GETDATE();
		PRINT'Process Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT'- - - - - - - - - - - - - - - - - - - - - - - - - -'

		--Truncate the table in order to not load duplicate data
		PRINT'TRUNCATING TABLE bronze.crm_sales_details'
		PRINT'========================================'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_sales_details;
		-- Bulk insert data into crm_sales_details
		PRINT'INSERTING DATA IN TABLE bronze.crm_sales_details'
		PRINT'========================================'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\crist\Documents\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2, --Set the initial row for that in the second position
			FIELDTERMINATOR = ',', -- Use the , delimitador
			TABLOCK --Lock the table while loading it with data
		);
		SET @end_time = GETDATE();
		--Gets the total duration of the process with the variables declared on line 11
		PRINT'Process Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT'- - - - - - - - - - - - - - - - - - - - - - - - - -'

		PRINT'============================================='
		PRINT'LOADING ERP'
		PRINT'============================================='

		--Truncate the table in order to not load duplicate data
		PRINT'TRUNCATING TABLE bronze.erp_cust_az12'
		PRINT'========================================'
		SET @start_time =  GETDATE();
		TRUNCATE TABLE bronze.erp_cust_az12;
		-- Bulk insert data into erp_cust_az12
		PRINT'INSERTING DATA IN TABLE bronze.erp_cust_az12'
		PRINT'========================================'
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\crist\Documents\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			FIRSTROW = 2, --Set the initial row for that in the second position
			FIELDTERMINATOR = ',', -- Use the , delimitador
			TABLOCK --Lock the table while loading it with data
		);
		SET @end_time = GETDATE();
		--Gets the total duration of the process with the variables declared on line 11
		PRINT'Process Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT'- - - - - - - - - - - - - - - - - - - - - - - - - -'

		--Truncate the table in order to not load duplicate data
		PRINT'TRUNCATING TABLE bronze.erp_loc_a101'
		PRINT'========================================'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_loc_a101;
		-- Bulk insert data into erp_loc_a101
		PRINT'INSERTING DATA IN TABLE bronze.erp_loc_a101'
		PRINT'========================================'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\crist\Documents\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
			FIRSTROW = 2, --Set the initial row for that in the second position
			FIELDTERMINATOR = ',', -- Use the , delimitador
			TABLOCK --Lock the table while loading it with data
		);
		SET @end_time =  GETDATE();
		--Gets the total duration of the process with the variables declared on line 11
		PRINT'Process Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT'- - - - - - - - - - - - - - - - - - - - - - - - - -'

		--Truncate the table in order to not load duplicate data
		PRINT'TRUNCATING TABLE TABLE bronze.erp_px_cat_g1v2'
		PRINT'========================================'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		-- Bulk insert data into erp_px_cat_g1v2
		PRINT'INSERTING DATA IN TABLE bronze.erp_px_cat_g1v2'
		PRINT'========================================'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\crist\Documents\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
			FIRSTROW = 2, --Set the initial row for that in the second position
			FIELDTERMINATOR = ',', -- Use the , delimitador
			TABLOCK --Lock the table while loading it with data
		);
		SET @end_time = GETDATE();
		--Gets the total duration of the process with the variables declared on line 11
		PRINT'Process Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT'- - - - - - - - - - - - - - - - - - - - - - - - - -'
		SET @end_time_load_bronze = GETDATE();
		PRINT'Total time of execution: ' + CAST(DATEDIFF(second, @start_time_load_bronze, @end_time_load_bronze) AS NVARCHAR);
	END TRY

	BEGIN CATCH
		PRINT'DATA INSERT FAILED, CHECK SOURCES AND SYNTAX'
		PRINT'Error Message: ' + ERROR_MESSAGE()
		PRINT'Error number: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
	END CATCH

END
