CREATE TABLE customer_purchases(
    cust_id VARCHAR2(25 BYTE),
    calendar_dt DATE,
    amt_le NUMBER
)

--First Question
--solution 1
with next_purchase AS(
SELECT 
    cust_id,
    calendar_dt,
    LEAD(calendar_dt) OVER(PARTITION BY cust_id ORDER BY calendar_dt) AS next_purchase_date
FROM customer_purchases
), differences AS(
SELECT
    cust_id,
    calendar_dt,
    next_purchase_date,
    NVL(next_purchase_date - calendar_dt, 0) as diff
FROM next_purchase
),
days_count AS(
SELECT  
    cust_id,
    COUNT(*) OVER(PARTITION BY cust_id) + 1 AS count_days
FROM differences
WHERE diff = 1)
SELECT 
    DISTINCT
    cust_id, 
    MAX(count_days) OVER(PARTITION BY cust_id) as max_consec_days
FROM days_count;

--solution 2
WITH purchase_dates AS (
    SELECT 
        cust_id,
        calendar_dt AS purchase_date,
        LAG(calendar_dt) OVER (PARTITION BY cust_id ORDER BY calendar_dt) AS prev_purchase_date
    FROM customer_purchases
),
consec_days AS (
SELECT 
    cust_id,
    COUNT(*) AS consecutive_days
FROM (
    SELECT 
        cust_id,
        purchase_date,
        ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY purchase_date) - ROW_NUMBER() 
        OVER (PARTITION BY cust_id, CASE WHEN prev_purchase_date IS NULL THEN 1 ELSE 0 END ORDER BY purchase_date) AS grp
    FROM purchase_dates
)
GROUP BY cust_id, grp
ORDER BY cust_id, MIN(purchase_date))
SELECT 
    DISTINCT
    cust_id,
    MAX(consecutive_days) OVER(PARTITION BY cust_id) as max_consec_days
FROM consec_days;

--solution 3
WITH daily_purchases AS (
  SELECT
    cust_id,
    calendar_dt AS purchase_date
  FROM customer_purchases
),
customer_gaps AS (
  SELECT
    cust_id,
    purchase_date,
    LAG(purchase_date) OVER (PARTITION BY cust_id ORDER BY purchase_date) AS prev_purchase_date
  FROM daily_purchases
),
consecutive_days AS (
  SELECT
    cust_id,
    CASE WHEN prev_purchase_date IS NULL THEN 1
         ELSE 1 + (purchase_date - prev_purchase_date) END AS consecutive_days
  FROM customer_gaps
)
SELECT
  cust_id,
  MAX(consecutive_days) AS max_consecutive_days
FROM consecutive_days
GROUP BY cust_id
ORDER BY max_consecutive_days DESC;

--Second Question
with accumlative_sum AS(
SELECT 
    cust_id,
    calendar_dt,
    SUM(amt_le) OVER(PARTITION BY cust_id ORDER BY calendar_dt) AS accumlative_spend,
    ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY calendar_dt) AS count_dates
FROM customer_purchases
WHERE amt_le <> 0
ORDER BY cust_id
), threshold AS(
SELECT 
    DISTINCT
    cust_id,
    MIN(count_dates) OVER(PARTITION BY cust_id) AS min_days
FROM accumlative_sum
WHERE accumlative_spend >= 250
)
SELECT ROUND(AVG(min_days)) AS on_avg_days
FROM threshold;
