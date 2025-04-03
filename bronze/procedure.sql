
CREATE OR REPLACE PROCEDURE  bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
    start_time TIMESTAMP;
    end_time TIMESTAMP;

BEGIN
    batch_start_time := NOW();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    -- CRM Tables
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
    COPY bronze.crm_cust_info FROM 'F:/SQL_DataWarehouse_Project/datasets/source_crm/cust_info.csv' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info FROM 'F:/SQL_DataWarehouse_Project/datasets/source_crm/prd_info.csv' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details FROM 'F:/SQL_DataWarehouse_Project/datasets/source_crm/sales_details.csv' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

    -- ERP Tables
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101 FROM 'F:/SQL_DataWarehouse_Project/datasets/source_erp/loc_a101.csv' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12 FROM 'F:/SQL_DataWarehouse_Project/datasets/source_erp/cust_az12.csv' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2 FROM 'F:/SQL_DataWarehouse_Project/datasets/source_erp/px_cat_g1v2.csv' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

    batch_end_time := NOW();
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE '   - Total Load Duration: % seconds', EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
    RAISE NOTICE '==========================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '==========================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE '==========================================';
END;
$$;

--Calling the stored Procuure
CALL bronze.load_bronze();