	-- Data exploration over time
	-- This query helps to view the different changes a bussines experiences over time
	-- this helps us to undertand and take actions based on historical records about the bussines
	-- this query uses a database created in my project SQL Datawarehouse on GIT.
	SELECT
		DATETRUNC(month, order_date),
		SUM(sales),
		SUM(quantity),
		AVG(sales)
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month, order_date)
	ORDER BY DATETRUNC(month, order_date);

	--Comulative analysis
	--Helps us to recognize if our bussines is growing or declining overtime, and take actions with this information
	SELECT
		orderdate,
		sales,
		SUM(sales) OVER(PARTITION BY DATETRUNC(year,orderdate) ORDER BY orderdate) running_total,
		AVG(avg_price) OVER(PARTITION BY DATETRUNC(year,orderdate) ORDER BY orderdate) running_avg
	FROM(
		SELECT
			DATETRUNC(month, order_date) orderdate,
			SUM(sales) sales,
			AVG(sales) avg_price
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL
		GROUP BY DATETRUNC(month, order_date))t;

	--Performance analysis
	--Helps us to compare our current progress with a established target
		--Helps us to recognize if our bussines is growing or declining overtime, and take actions with this information
	SELECT
		orderdate,
		sales,
		LAG(sales) OVER(ORDER BY orderdate) previous_month_sales,
		avg_price,
		LAG(avg_price) OVER(ORDER BY orderdate) previous_month_average
	FROM(
		SELECT
			DATETRUNC(year, order_date) orderdate,
			SUM(sales) sales,
			AVG(sales) avg_price
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL
		GROUP BY DATETRUNC(year, order_date))t;
	
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year-over-Year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;

--Part to whole analysis
--This analysis help us to understand wich category contributes the most in our bussines
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

--Data segmentation analysis
--Groups the data on a specific range, helps us understand the correlation between two measures
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
