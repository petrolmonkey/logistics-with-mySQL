/****************************************************************************************
								Order Lifecycle Query
	This is a query that ties the customer order to the purchase order to the shipment.
****************************************************************************************/
USE asian_imports;
SELECT
  so.sales_order_id,
  so.so_number			 AS customer_order,
  so.status              AS sales_status,
  c.company_name         AS customer,
  po.po_number,
  po.status              AS po_status,
  v.company_name         AS vendor,
  s.shipment_no,
  s.status               AS shipment_status
FROM sales_orders so
JOIN customers c
  ON c.customer_id = so.customer_id
JOIN purchase_orders po
  ON po.po_id = so.po_id
JOIN vendors v
  ON v.vendor_id = po.vendor_id
JOIN shipments s
  ON s.customer_id = c.customer_id

