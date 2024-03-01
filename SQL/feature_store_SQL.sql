CREATE TABLE retail_features(
    invoice_code VARCHAR2(50 BYTE),
    invoice_date DATE,
    date_year CHAR(4),
    date_month VARCHAR2(5 BYTE),
    date_quarter CHAR(1),
    date_day CHAR(2),
    day_of_week  VARCHAR2(25 BYTE),
    time_hour  CHAR(3),
    time_period  VARCHAR2(25 BYTE),
    customer_id VARCHAR2(50 BYTE),
    stock_code VARCHAR2(50 BYTE),
    quantity NUMBER(38,0),
    unit_price FLOAT,
    revenue_per_unit NUMBER(38,2)
);

INSERT INTO retail_features (  
  invoice_code,
  invoice_date,
  date_year,
  date_month,
  date_quarter,
  date_day,
  day_of_week,
  time_hour,
  time_period,
  customer_id,
  stock_code,
  quantity,
  unit_price,
  revenue_per_unit
)
SELECT
  invoice_code,
  invoice_date,
  TO_CHAR(invoice_date, 'YYYY'),
  TO_CHAR(invoice_date, 'MM'),
  TO_CHAR(invoice_date, 'Q'),
  TO_CHAR(invoice_date, 'DD'),
  LOWER(TO_CHAR(invoice_date, 'DAY')),
  SUBSTR(invoice_time, 0, INSTR(invoice_time, ':') - 1),
  CASE
    WHEN SUBSTR(invoice_time, 0, INSTR(invoice_time, ':') - 1) BETWEEN 0 AND 7 THEN 'early hours'
    WHEN SUBSTR(invoice_time, 0, INSTR(invoice_time, ':') - 1) BETWEEN 8 AND 11 THEN 'morning'
    WHEN SUBSTR(invoice_time, 0, INSTR(invoice_time, ':') - 1) BETWEEN 12 AND 16 THEN 'afternoon'
    WHEN SUBSTR(invoice_time, 0, INSTR(invoice_time, ':') - 1) BETWEEN 17 AND 20 THEN 'evening'
    ELSE 'night'
  END,
  customer_id,
  stock_code,
  quantity,
  unit_price,
  revenue_per_unit
FROM transformed_retail;
    