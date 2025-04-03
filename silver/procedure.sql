CREATE OR REPLACE PROCEDURE load_silver_layer()
LANGUAGE plpgsql
AS $$
DECLARE 
    batch_start_time TIMESTAMP := NOW();
    batch_end_time TIMESTAMP;
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '==============================================';

    BEGIN
        -- Loading silver.crm_cust_info
        RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        
        RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id, 
            cst_key, 
            cst_firstname, 
            cst_lastname, 
            cst_marital_status, 
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status, 
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr, 
            cst_create_date
        FROM (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;
        
        RAISE NOTICE '>> Successfully Loaded: silver.crm_cust_info';
    
        -- Loading silver.crm_sales_details
        RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::TEXT) != 8 THEN NULL
                ELSE TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
            END AS sls_order_dt,
            CASE 
                WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::TEXT) != 8 THEN NULL
                ELSE TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
            END AS sls_ship_dt,
            CASE 
                WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::TEXT) != 8 THEN NULL
                ELSE TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
            END AS sls_due_dt,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0 
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price
        FROM bronze.crm_sales_details;

        RAISE NOTICE '>> Successfully Loaded: silver.crm_sales_details';
    
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE '==============================================';
            RAISE NOTICE 'ERROR OCCURRED DURING LOADING SILVER LAYER';
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE NOTICE 'Error Code: %', SQLSTATE;
            RAISE NOTICE '==============================================';
    END;

    batch_end_time := NOW();
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Loading Silver Layer Completed';
    RAISE NOTICE '   - Total Load Duration: % seconds', EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
    RAISE NOTICE '==============================================';
END $$;
CALL load_silver_layer()