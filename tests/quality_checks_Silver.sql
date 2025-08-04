-- Check for duplicates or null
-- Expectation = no results

SELECT
    prd_id,
    COUNT(*)
    FROM Bronze.crm_prd_info
    GROUP BY prd_id
    Having count(*) > 1 or prd_id is null 

-- Check for unwanted spaces
-- Expectation : No results

SELECT prd_nm
FROM Bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) 

-- Check for null or negative numbers
-- Expectation : No results

SELECT prd_cost
FROM Bronze.crm_prd_info
WHERE prd_cost < 0 or prd_cost is null

-- DATA Standardization and consistency
SELECT DISTINCT prd_line
FROM Bronze.crm_prd_info

--Check for invalid date orders
SELECT *
FROM Bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt


Select *
FROM Silver.crm_prd_info

-- Quality chech for cust_slaes_details

-- check for Invalid Dates
SELECT
NULLIF(sls_order_dt, 0) sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt <= 0
OR sls_order_dt > 231435111

-- CHECK for invalid Date Orders

SELECT *
FROM Silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency between Sales , quantitiy and price
-- >> Sales = Quantity * Price
-- Values must not be null, zero or negtaive
SELECT DISTINCT
sls_sales AS old_sales,
sls_quantity,
sls_price AS old_price,

CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity *ABS(sls_price)
        ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
END AS sls_price
FROM Bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity , sls_price

SELECT * FROM Silver.crm_sales_details

-- quality check for cust_erp_az12

SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
     ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'FEMALE'
     WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'MALE'
     ELSE 'n/a'
END AS gen
FROM Silver.erp_cust_az12;

-- Quality check for erp_loc_a101
SELECT
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry
FROM Bronze.erp_loc_a101;

SELECT * FROM Silver.erp_loc_a101

-- quality check for erp_px_cat_g1v2
SELECT
id,
cat,
subcat,
maintenance
FROM Bronze.erp_px_cat_g1v2

SELECT * FROM Silver.erp_px_cat_g1v2
