--RFM Modeling
--Function Mapper for Customer Segmentation
CREATE OR REPLACE FUNCTION map_customer_segment(recency_score IN NUMBER, fm_score IN NUMBER)
RETURN VARCHAR2
IS
    customer_segment VARCHAR2(50 BYTE);
BEGIN
    CASE
        WHEN recency_score = 5 AND fm_score = 5 THEN customer_segment := 'Champions';
        WHEN recency_score = 5 AND fm_score = 4 THEN customer_segment := 'Champions';
        WHEN recency_score = 4 AND fm_score = 5 THEN customer_segment := 'Champions';
        WHEN recency_score = 5 AND fm_score = 2 THEN customer_segment := 'Potential Loyalists';
        WHEN recency_score = 4 AND fm_score = 2 THEN customer_segment := 'Potential Loyalists';
        WHEN recency_score = 3 AND fm_score = 3 THEN customer_segment := 'Potential Loyalists';
        WHEN recency_score = 4 AND fm_score = 3 THEN customer_segment := 'Potential Loyalists';
        WHEN recency_score = 5 AND fm_score = 3 THEN customer_segment := 'Loyal Customers';
        WHEN recency_score = 4 AND fm_score = 4 THEN customer_segment := 'Loyal Customers';
        WHEN recency_score = 3 AND fm_score = 5 THEN customer_segment := 'Loyal Customers';
        WHEN recency_score = 3 AND fm_score = 4 THEN customer_segment := 'Loyal Customers';
        WHEN recency_score = 5 AND fm_score = 1 THEN customer_segment := 'Recent Customers';
        WHEN recency_score = 4 AND fm_score = 1 THEN customer_segment := 'Promising';
        WHEN recency_score = 3 AND fm_score = 1 THEN customer_segment := 'Promising';
        WHEN recency_score = 3 AND fm_score = 2 THEN customer_segment := 'Customers Needing Attention';
        WHEN recency_score = 2 AND fm_score = 2 THEN customer_segment := 'Customers Needing Attention';
        WHEN recency_score = 2 AND fm_score = 3 THEN customer_segment := 'Customers Needing Attention';
        WHEN recency_score = 2 AND fm_score = 5 THEN customer_segment := 'At Risk';
        WHEN recency_score = 2 AND fm_score = 4 THEN customer_segment := 'At Risk';
        WHEN recency_score = 1 AND fm_score = 3 THEN customer_segment := 'At Risk';
        WHEN recency_score = 1 AND fm_score = 4 THEN customer_segment := 'Cant Lose Them';
        WHEN recency_score = 1 AND fm_score = 5 THEN customer_segment := 'Cant Lose Them';
        WHEN recency_score = 1 AND fm_score = 2 THEN customer_segment := 'Hibernating';
        WHEN recency_score = 1 AND fm_score = 1 THEN customer_segment := 'Lost';
        ELSE customer_segment := 'Other';
    END CASE;
    
    RETURN customer_segment;
END map_customer_segment;
/


--Query to build the rfm dataset using sum for monetary calculation
CREATE OR REPLACE VIEW customer_segmentation_view AS
with rfm as (
    SELECT 
            DISTINCT
            customer_id,
            TO_DATE('10-DEC-11', 'DD-MON-YY') - MAX(invoice_date) OVER(PARTITION BY customer_id) AS recency,
            COUNT(DISTINCT invoice_code) OVER(PARTITION BY customer_id) AS frequency,
            SUM(revenue_per_unit) OVER(PARTITION BY customer_id) AS monetary
    FROM transformed_retail
), 
 scaling_monetary_helper AS(
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        MAX(frequency) OVER() as max_freq,
        MIN(monetary) OVER () AS min_monetary,
        MAX(monetary) OVER () AS max_monetary
    FROM 
        rfm
 ),
 scaling_monetary AS(
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        ROUND(((monetary - min_monetary) / (max_monetary - min_monetary)) * max_freq, 2) AS scaled_monetary
    FROM scaling_monetary_helper 
 ),
average_scores AS(
    SELECT
            customer_id,
            recency,
            frequency,
            monetary,
            (scaled_monetary) / 2 AS avg_rm
    FROM scaling_monetary
 ),
 ranking AS(
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        avg_rm,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY avg_rm) AS fm_score
    FROM average_scores)
SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        avg_rm,
        r_score,
        fm_score,
        map_customer_segment(r_score, fm_score) AS customer_segment
FROM ranking;

--total revenue per each segment
SELECT 
    csvt.customer_segment,
    SUM(revenue_per_unit) AS total_sales
FROM customer_segmentation_view csvt
JOIN retail_features rf
on csvt.customer_id = rf.customer_id
GROUP BY csvt.customer_segment
ORDER BY total_sales DESC;

--count for each customer segment and it's percentage    
SELECT
  DISTINCT
  customer_segment,
  COUNT(*) OVER(PARTITION BY customer_segment) AS segment_count,
  ROUND(COUNT(*) OVER(PARTITION BY customer_segment) / COUNT(*) OVER(), 3) * 100 AS segment_percentage
FROM customer_segmentation_view
ORDER BY segment_percentage DESC;
