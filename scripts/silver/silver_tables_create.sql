/*=============================================================================
        This script helps to create the whole silver layer tables
        use it (with bronze layer already created) to obtain
        the clean data tranformed from the bronze layer
==============================================================================*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
    BEGIN
        BEGIN TRY
            --Truncate table to avoid duplicated data
            PRINT '========================================';
            PRINT 'Truncating table silver.crm_cust_info';
            TRUNCATE TABLE silver.crm_cust_info;
            -- CTE for data cleaning and standarization
            PRINT 'Inserting data into table silver.crm_cust_info';
            WITH cst_ranked_functions AS (
                SELECT
                    cst_id,
                    cst_key,
                    TRIM(cst_firstname) AS cst_firstname,
                    TRIM(cst_lastname) AS cst_lastname,
                    CASE 
                        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                        ELSE 'N/A'
                    END AS cst_marital_status,
                    CASE 
                        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                        ELSE 'N/A'
                    END AS cst_gndr,
                    cst_create_date,
                    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS cst_rankedflag
                FROM bronze.crm_cust_info
                WHERE cst_id IS NOT NULL
            )
            --Insert the data into silver.cst_cust_info

            INSERT INTO silver.crm_cust_info (
                cst_id,
                cst_key,
                cst_firstname,
                cst_lastname,
                cst_marital_status,
                cst_gndr,
                cst_create_date
            )
            --Main query
            SELECT 
                cst_id,
                cst_key,
                cst_firstname,
                cst_lastname,
                cst_marital_status,
                cst_gndr,
                cst_create_date
            FROM cst_ranked_functions
            WHERE cst_rankedflag = 1;


            --TRUNCATE TABLE TO AVOID DUPLICATE DATA
            PRINT '========================================';
            PRINT 'Truncating table silver.crm_prd_info';
            TRUNCATE TABLE silver.crm_prd_info;
            --Insert data into table silver.crm_prd_info
            PRINT 'Inserting data into table silver.crm_prd_info';
            INSERT INTO silver.crm_prd_info(
                prd_id,
                cat_id,
                prd_key,
                prd_nm,
                prd_cost,
                prd_line,
                prd_start_dt,
                prd_end_dt
            )

            -- Main query to filter and prepare data
            SELECT 
                prd_id,
                REPLACE(SUBSTRING(prd_key,1,5), '-', '_') cat_id,
                SUBSTRING(prd_key, 7, LEN(prd_key)) prd_key,
                prd_nm,
                ISNULL(prd_cost, 0) prd_cost,
                CASE WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	                 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	                 WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	                 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	                 ELSE 'N/A'
	                 END prd_line,
                CAST(prd_start_dt AS DATE) prd_start_dt,
                CAST(DATEADD(DAY, -1,(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt))) AS DATE) AS prd_end_dt
            FROM bronze.crm_prd_info;

            --Trunacte table to avoid duplicates
            PRINT '========================================';
            PRINT 'Truncating table silver.crm_sales_details';
            TRUNCATE TABLE silver.crm_sales_details;
            --Insert data into silver.crm_sales_details
            PRINT 'Inserting data into table silver.crm_sales_details';
            INSERT INTO silver.crm_sales_details(
                sls_ord_num,
                sls_prd_key,
                sls_cust_id,
                sls_order_dt,
                sls_ship_dt,
                sls_due_dt,
                sls_sales,
                sls_price,
                sls_quantity
            )
            --Main query with data erinchment and normalization
            SELECT [sls_ord_num]
                  ,[sls_prd_key]
                  ,[sls_cust_id]
                  ,CASE WHEN [sls_order_dt] = 0 OR LEN([sls_order_dt]) != 8 THEN NULL
                       ELSE CAST(CAST([sls_order_dt] AS NVARCHAR) AS DATE)
                       END sls_order_dt
                  ,CASE WHEN [sls_ship_dt] = 0 OR LEN([sls_ship_dt]) != 8 THEN NULL
                       ELSE CAST(CAST([sls_ship_dt] AS NVARCHAR) AS DATE)
                       END [sls_ship_dt]
                  ,CASE WHEN [sls_due_dt] = 0 OR LEN([sls_due_dt]) != 8 THEN NULL
                       ELSE CAST(CAST([sls_due_dt] AS NVARCHAR) AS DATE)
                       END sls_due_dt
                  ,CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                        THEN sls_quantity * ABS(sls_price) 
                        ELSE sls_sales
                        END sls_sales
                  ,CASE WHEN sls_price IS NULL OR sls_price <= 0
                        THEN sls_sales / NULLIF(sls_quantity, 0)
                        ELSE sls_price
                        END sls_price
                  , sls_quantity
              FROM [DataWarehouse].[bronze].[crm_sales_details];

              --Truncate silver.erp_cust_az12 if exist to avoid duplicated data
            PRINT '========================================';
            PRINT 'Truncating table silver.erp_cust_az12';
            TRUNCATE TABLE silver.erp_cust_az12;
            --Inserting Data into silver.erp_cust_az12
            PRINT 'Inserting data into table silver.erp_cust_az12';
            INSERT INTO silver.erp_cust_az12(
                cid,
                bdate,
                gen
            )
            --Main query with data cleaning
            SELECT
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	             ELSE cid
	             END cid,
            CASE WHEN DATEDIFF(year,GETDATE(),bdate) <= -100 OR GETDATE() < bdate THEN NULL
	             ELSE bdate
	             END bdate,
            CASE WHEN UPPER(TRIM(gen)) = 'F'THEN 'Female'
	             WHEN UPPER(TRIM(gen)) = 'M'THEN 'Male'
	             WHEN UPPER(TRIM(gen)) = 'MALE' THEN gen
	             WHEN UPPER(TRIM(gen)) = 'FEMALE'THEN gen
	             ELSE 'n/a'
	             END gen
            FROM bronze.erp_cust_az12;

            --Truncate table silver.erp_loc_a101 to avoid duplicated data
            PRINT '========================================';
            PRINT 'Truncating table silver.erp_loc_a101';
            TRUNCATE TABLE silver.erp_loc_a101;

            --Insert data into table silver.erp_loc_a101
            PRINT 'Inserting data into table silver.erp_loc_a101';
            INSERT INTO silver.erp_loc_a101(
	            cid,
	            cntry)

            --Main query, data standarization
            SELECT
            REPLACE(cid,'-','') cid,
            CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	             WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	             WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
	             ELSE TRIM(cntry)
	             END cntry
            FROM bronze.erp_loc_a101;

            --Truncate table silver.erp_px_cat_g1v2 to avoid duplicated data
            PRINT '========================================';
            PRINT 'Truncating table silver.erp_px_cat_g1v2';
            TRUNCATE TABLE silver.erp_px_cat_g1v2;

            --Insert Data into table silver.erp_px_cat_g1v2
            PRINT 'Inserting data into table silver.erp_px_cat_g1v2';
            INSERT INTO silver.erp_px_cat_g1v2(
                id,
                cat,
                subcat,
                maintenance
            )

            --Clean data (preventive features)
            SELECT
                id cat_id,
                TRIM(cat),
                TRIM(subcat),
                maintenance
            FROM bronze.erp_px_cat_g1v2;
        END TRY

	    BEGIN CATCH
		    PRINT'DATA INSERT FAILED, CHECK SOURCES AND SYNTAX'
		    PRINT'Error Message: ' + ERROR_MESSAGE()
		    PRINT'Error number: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
	    END CATCH
END
