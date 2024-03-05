--Query to build the rfm dataset usign percent_rank for the monetary
WITH rfm_cte AS (
    SELECT 
        DISTINCT
        customer_id, 
        TO_DATE('10-DEC-11', 'DD-MON-YY') - MAX(invoice_date) OVER(PARTITION BY customer_id) AS recency,
        COUNT(DISTINCT invoice_code) OVER(PARTITION BY customer_id) AS frequency,
        ROUND(PERCENT_RANK() OVER (ORDER BY revenue_per_unit)*100) AS monetary_rank
    FROM retail_features
)

SELECT 
    DISTINCT
    customer_id, 
    recency, 
    frequency, 
    MAX(monetary_rank) OVER (PARTITION BY customer_id) AS monetary
FROM rfm_cte
ORDER BY customer_id;

