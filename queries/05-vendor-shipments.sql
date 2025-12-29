/****************************************************************************************
								Vendor Shipments Query
****************************************************************************************/

USE asian_imports;

SELECT
  s.shipment_id,
  s.shipment_no,
  s.mode,
  s.status                  AS shipment_status,
  v.company_name            AS vendor,
  i.invoice_number,
  i.invoice_date,
  i.amount,
  i.status                  AS invoice_status
FROM shipments s
JOIN invoices i
  ON i.shipment_id = s.shipment_id
JOIN vendors v
  ON v.vendor_id = i.vendor_id
ORDER BY s.shipment_id, i.invoice_date;
    
