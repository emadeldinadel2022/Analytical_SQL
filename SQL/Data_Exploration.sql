--Total counts per invoice, stocks, customers
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT invoice) AS invoice_counts,
    COUNT(DISTINCT stockcode) AS stock_counts,
    COUNT(DISTINCT customer_id) AS customers_counts
FROM tableretail;


