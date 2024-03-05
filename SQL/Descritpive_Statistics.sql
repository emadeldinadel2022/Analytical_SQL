--Total counts per invoice, stocks, customers
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT invoice_code) AS invoice_counts,
    COUNT(DISTINCT stock_code) AS stock_counts,
    COUNT(DISTINCT customer_id) AS customers_counts
FROM transformed_retail;

--Some Descriptive Statistics
SELECT
    MIN(invoice_date) OVER () AS min_invoice_date,
    MAX(invoice_date) OVER () AS max_invoice_date,
    AVG(quantity) OVER () AS avg_quantity,
    MIN(quantity) OVER () AS min_quantity,
    MAX(quantity) OVER () AS max_quantity,
    AVG(unit_price) OVER () AS avg_unit_price,
    MIN(unit_price) OVER () AS min_unit_price,
    MAX(unit_price) OVER () AS max_unit_price,
    AVG(revenue_per_unit) OVER () AS avg_revenue_per_unit,
    MIN(revenue_per_unit) OVER () AS min_revenue_per_unit,
    MAX(revenue_per_unit) OVER () AS max_revenue_per_unit
FROM retail_features;


--Get Gross Sales, and Quantity Sold
SELECT *
FROM (
    SELECT revenue_per_unit, quantity, date_year
    FROM retail_features
)
PIVOT (
    SUM(revenue_per_unit) AS gross_sales,
    SUM(quantity) AS quantity_sold
    FOR date_year IN (2010 AS "2010", 2011 AS "2011")
);

--Get total quantity and revenue per each month, for each year
SELECT 
    date_year, 
    month_name, 
    SUM(quantity) AS total_quantity, 
    SUM(revenue_per_unit) AS total_revenue
FROM 
    retail_features
GROUP BY 
    date_year, month_name
ORDER BY 
    date_year,
    TO_DATE(TO_CHAR(TO_DATE(month_name, 'Month'), 'MM'), 'MM');
    
--detailed query for summation for quantity and revenue_per_unit
CREATE OR REPLACE VIEW yearly_summation_report AS
SELECT 
    date_year,
    SUM(quantity) OVER (PARTITION BY date_year) AS yearly_total_quantity,
    SUM(revenue_per_unit) OVER (PARTITION BY date_year) AS yearly_total_revenue,
    date_quarter,
    SUM(quantity) OVER (PARTITION BY date_year, date_quarter) AS quarterly_total_quantity,
    SUM(revenue_per_unit) OVER (PARTITION BY date_year, date_quarter) AS quarterly_total_revenue,
    date_month,
    SUM(quantity) OVER (PARTITION BY date_year, date_month) AS monthly_total_quantity,
    SUM(revenue_per_unit) OVER (PARTITION BY date_year, date_month) AS monthly_total_revenue,
    date_day,
    SUM(quantity) OVER (PARTITION BY date_year, date_month, date_day) AS daily_total_quantity,
    SUM(revenue_per_unit) OVER (PARTITION BY date_year, date_month, date_day) AS daily_total_revenue,
    day_of_week,
    SUM(quantity) OVER (PARTITION BY date_year, date_month, day_of_week) AS day_of_week_total_quantity,
    SUM(revenue_per_unit) OVER (PARTITION BY date_year, date_month, day_of_week) AS day_of_week_total_revenue,
    time_period,
    SUM(quantity) OVER (PARTITION BY date_year, date_month, day_of_week, time_period) AS time_period_total_quantity,
    SUM(revenue_per_unit) OVER (PARTITION BY date_year, date_month, day_of_week, time_period) AS time_period_total_revenue
FROM retail_features
ORDER BY date_year DESC, date_quarter, date_month, date_day;


CREATE OR REPLACE VIEW customers_report AS
SELECT 
    customer_id,
    SUM(quantity) OVER (PARTITION BY customer_id) AS quantity_per_cust,
    SUM(revenue_per_unit) OVER (PARTITION BY customer_id) AS revenue_per_cust,
    date_year,
    SUM(quantity) OVER (PARTITION BY customer_id, date_year) AS year_quantity_per_cust,
    SUM(revenue_per_unit) OVER (PARTITION BY customer_id, date_year) AS year_revenue_per_cust,
    ROUND(AVG(revenue_per_unit) OVER (PARTITION BY customer_id, date_year), 2) AS avg_year_revenue_per_cust,
    date_quarter,
    SUM(quantity) OVER (PARTITION BY customer_id, date_quarter) AS quantity_per_cust_quart,
    SUM(revenue_per_unit) OVER (PARTITION BY customer_id, date_quarter) AS revenue_per_cust_quart,
    ROUND(AVG(revenue_per_unit) OVER (PARTITION BY customer_id, date_quarter), 2) AS avg_quart_revenue_per_cust,
    date_month,
    SUM(quantity) OVER (PARTITION BY customer_id, date_month) AS quantity_per_cust_month,
    SUM(revenue_per_unit) OVER (PARTITION BY customer_id, date_month) AS revenue_per_cust_month,
    ROUND(AVG(revenue_per_unit) OVER (PARTITION BY customer_id, date_month), 2) AS avg_month_revenue_per_cust,
    date_day,
    SUM(quantity) OVER (PARTITION BY customer_id, date_year, date_month, date_day) AS quantity_per_cust_day,
    SUM(revenue_per_unit) OVER (PARTITION BY customer_id, date_year, date_month, date_day) AS revenue_per_cust_day,
    ROUND(AVG(revenue_per_unit) OVER (PARTITION BY customer_id, date_year, date_month, date_day), 2) AS avg_day_revenue_per_cust,
    day_of_week,
    SUM(quantity) OVER (PARTITION BY customer_id, date_year, date_month, day_of_week) AS quantity_per_cust_day_of_week,
    SUM(revenue_per_unit) OVER (PARTITION BY customer_id, date_year, date_month, day_of_week) AS revenue_per_cust_day_of_week,
    ROUND(AVG(revenue_per_unit) OVER (PARTITION BY customer_id, date_year, date_month, day_of_week), 2) AS avg_dayofweek_revenue_per_cust,
    time_period,
    SUM(quantity) OVER (PARTITION BY customer_id, date_year, date_month, day_of_week, time_period) AS quantity_per_cust_time_period,
    SUM(revenue_per_unit) OVER (PARTITION BY customer_id, date_year, date_month, day_of_week, time_period) AS revenue_per_cust_time_period,
    ROUND(AVG(revenue_per_unit) OVER (PARTITION BY customer_id, date_year, date_month, day_of_week, time_period), 2) AS avgtimeperiod_revenue_per_cust
FROM retail_features
ORDER BY customer_id, date_quarter, date_month, date_day;


--Yearly-Monthly Report
CREATE OR REPLACE VIEW yearly_monthly_report AS
SELECT DISTINCT
    date_year,
    month_name,
    COUNT(*) OVER (PARTITION BY date_year,month_name) as count_orders,
    SUM(quantity) OVER (PARTITION BY date_year,month_name) as total_products_sold,
    ROUND(AVG(quantity) OVER (PARTITION BY date_year,month_name), 2) as avg_products_sold,
    SUM(revenue_per_unit) OVER (PARTITION BY date_year,month_name) as total_sales,
    ROUND(AVG(quantity) OVER (PARTITION BY date_year,month_name), 2) as avg_sales
FROM retail_features;

--there is a problem here------>>>>>
WITH product_quantity AS(
SELECT 
        stock_code,
        date_year,
        SUM(quantity) OVER (PARTITION BY stock_code, date_year) AS yearly_quantity,
        date_quarter,
        SUM(quantity) OVER (PARTITION BY stock_code, date_year, date_quarter) AS quarter_quantity,
        date_month,
       SUM(quantity) OVER (PARTITION BY stock_code, date_year, date_month) AS month_quantity
FROM retail_features
)
SELECT 
        date_year,
        stock_code,
        yearly_quantity,
        DENSE_RANK() OVER(PARTITION BY date_year ORDER BY yearly_quantity) AS rank_year,
        date_quarter,
        quarter_quantity,
        DENSE_RANK() OVER(PARTITION BY date_year, date_quarter ORDER BY quarter_quantity) AS rank_quarter,
        date_month,
        quarter_quantity,
        DENSE_RANK() OVER(PARTITION BY date_year, date_month ORDER BY month_quantity) AS rank_month
FROM product_quantity;

--Customer retention rate over time:
SELECT 
        DISTINCT
        date_year, 
       COUNT(DISTINCT customer_id) OVER (PARTITION BY date_year) AS total_customers,
       COUNT(DISTINCT customer_id) OVER (PARTITION BY date_year, date_month) AS retained_customers,
       ROUND((COUNT(DISTINCT customer_id) OVER (PARTITION BY date_year, date_month) /
        COUNT(DISTINCT customer_id) OVER (PARTITION BY date_year)), 2) AS retention_rate
FROM retail_features;

with purchasing as(
    select customer_id,
    COUNT(invoice_code) OVER (PARTITION BY customer_id) as purchases
    from retail_features
)
SELECT
    distinct
    customer_id,
       AVG(purchases) OVER(PARTITION BY customer_id) AS avg_purchase_frequency
FROM purchasing;

