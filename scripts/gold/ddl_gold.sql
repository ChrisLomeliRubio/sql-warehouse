-- Drop existing views in the gold schema if they exist
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;

GO

-- Create customer dimension view
-- Combines customer data from CRM (core), ERP (additional attributes), and location (country)
-- Generates a surrogate key (customer_key) using ROW_NUMBER for data warehousing
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) customer_key,  -- Surrogate key for the dimension
	ci.cst_id customer_id,
	ci.cst_key customer_number,
	ci.cst_firstname firstname,
	ci.cst_lastname lastname,
	lc.cntry country,
	ca.bdate birthday,
	ci.cst_marital_status marital_status,
	-- If gender is unknown ('N/A'), fallback to the ERP source (ca.gen), else use CRM value
	CASE WHEN UPPER(ci.cst_gndr) = 'N/A' THEN COALESCE(ca.gen, 'n/a')
		 ELSE ci.cst_gndr
		 END gender,
	ci.cst_create_date create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 lc
ON ci.cst_key = lc.cid;

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
	DROP VIEW gold.dim_product;

GO

-- Create product dimension view
-- Joins product information with category details; filters to active products (prd_end_dt IS NULL)
-- Generates a surrogate key ordered by start date and product number
CREATE VIEW gold.dim_products AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY pin.prd_start_dt, pin.prd_key ) product_key,  -- Surrogate key
	pin.prd_id product_id,
	pin.prd_key product_number,
	pin.prd_nm product_name,
	pin.cat_id category_id,
	ca.cat category,
	ca.subcat subcategory,
	pin.prd_line product_line,
	ca.maintenance,
	pin.prd_cost cost,
	pin.prd_start_dt start_date
FROM silver.crm_prd_info pin
LEFT JOIN silver.erp_px_cat_g1v2 ca
ON pin.cat_id = ca.id
WHERE pin.prd_end_dt IS NULL;  -- Only currently active products

IF OBJECT_ID('gold.fact_salest', 'V') IS NOT NULL  -- Note: typo 'salest' but kept as is
	DROP VIEW gold.fact_sales;

GO

-- Create sales fact view
-- Links sales details to product and customer dimensions via natural keys to obtain surrogate keys
-- Provides measures: sales, quantity, price, and date fields
CREATE VIEW gold.fact_sales AS
SELECT
	sl.sls_ord_num order_number,
	gp.product_key,          -- Surrogate key from dim_products
	gc.customer_key,         -- Surrogate key from dim_customers
	sl.sls_order_dt order_date,
	sl.sls_ship_dt ship_date,
	sl.sls_due_dt due_date,
	sl.sls_sales sales,
	sl.sls_quantity quantity,
	sl.sls_price price
FROM silver.crm_sales_details sl
LEFT JOIN gold.dim_products gp
ON sl.sls_prd_key = gp.product_number   -- Join on business key (product_number)
LEFT JOIN gold.dim_customers gc
ON sl.sls_cust_id = gc.customer_id;     -- Join on business key (customer_id)
