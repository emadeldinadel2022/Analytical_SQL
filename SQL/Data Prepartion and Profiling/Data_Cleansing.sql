--Check for null values
SELECT 
    COUNT(*) AS null_count_invoice, COUNT(*) AS null_count_stockcode, COUNT(*) AS null_count_quantity, 
    COUNT(*) AS null_count_invoicedate, COUNT(*) AS null_count_price, COUNT(*) AS null_count_customer_id, 
    COUNT(*) AS null_count_country
FROM 
    tableretail
WHERE 
    invoice IS NULL OR stockcode IS NULL OR quantity IS NULL 
    OR invoicedate IS NULL OR price IS NULL OR customer_id IS NULL OR country IS NULL;

--Check incomplete in dataset
SELECT COUNT(*) AS incomplete_records
FROM tableretail
WHERE invoice IS NULL OR invoicedate IS NULL OR customerid IS NULL;

--Check for invalid in dataset
SELECT COUNT(*) AS invalid_price_count
FROM tableretail
WHERE price < 0;

SELECT COUNT(*) as invalid_quantity_count
FROM tableretail
WHERE quantity = 0 or MOD(quantity, 1) != 0;

--check for inconsistent in dataset
SELECT DISTINCT country
FROM tableretail;

SELECT DISTINCT customer_id
FROM tableretail;

--invalid date format
SELECT invoice, invoicedate FROM tableretail
WHERE invoicedate NOT LIKE '%/%/%';

--invalid time format
SELECT invoice, invoicedate FROM tableretail
WHERE invoicedate NOT LIKE '%:%';


--check for duplications
SELECT invoice, stockcode, quantity, COUNT(*) AS  count_prod_quant
FROM tableretail
GROUP BY invoice, stockcode, quantity
HAVING COUNT(*) > 1;

--consistent between the customer_id and invoice
SELECT invoice
FROM tableretail
GROUP BY invoice
HAVING COUNT(DISTINCT customer_id) <> 1;


