/****************************************************************************************
							Customer Revenue Query
	How the sales revenue compares to the vendor cost.
****************************************************************************************/
USE asian_imports;

SELECT
  c.company_name                      AS customer,
  v.company_name                      AS vendor,
  so.so_number,
  so.order_date,
  so.total_amount                     AS sales_amount,
  po.po_number,
  po.total_amount                     AS purchase_amount
FROM sales_orders so
JOIN customers c
  ON c.customer_id = so.customer_id
JOIN purchase_orders po  
  ON po.po_id = so.po_id
JOIN vendors v
  ON v.vendor_id = po.vendor_id

