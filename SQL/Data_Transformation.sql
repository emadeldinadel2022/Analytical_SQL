--create the tranformed table to store the data after transformation from the raw table
CREATE TABLE transformed_retail(
    invoice_code VARCHAR2(50 BYTE),
    invoice_date DATE,
    invoice_time VARCHAR2(25 BYTE),
    customer_id VARCHAR2(50 BYTE),
    stock_code VARCHAR2(50 BYTE),
    quantity NUMBER(38,0),
    unit_price FLOAT,
    revenue_per_unit NUMBER(38,2)
);

--insert data from raw table to transformed table in suitable shape
INSERT INTO transformed_retail(
    invoice_code,
    invoice_date,
    invoice_time,
    customer_id,
    stock_code,
    quantity,
    unit_price,
    revenue_per_unit
)
SELECT 
    invoice,
    TO_DATE(SUBSTR(invoicedate, 0, INSTR(invoicedate, ' ') - 1), 'MM/DD/YYYY'),
    SUBSTR(invoicedate, INSTR(invoicedate, ' ')),
    customer_id,
    stockcode,
    quantity,
    price,
    ROUND((quantity*price), 2)  
FROM tableretail;
