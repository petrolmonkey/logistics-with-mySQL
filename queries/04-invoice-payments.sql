/****************************************************************************************
								Invoice Payments Query
	Summary of which invoices have been paid.
****************************************************************************************/

USE asian_imports;
SELECT
	v.company_name AS vendor,
    i.invoice_number,
    i.invoice_date,
    i.amount AS invoice_amount,
    i.status AS invoice_status,
    p.reference_num,
    p.date AS payment_date,
    p.amount AS payment_amount    
FROM vendors v
JOIN invoices i
  ON i.vendor_id = v.vendor_id
LEFT JOIN payments p
  ON p.invoice_id = i.invoice_id
ORDER BY v.company_name, i.invoice_date;
    
