
/****************************************************************************************
							Customer Shipments Query
	Foreign keys are used to connect customer, shipment, and location table and 
    provide shipping status, origin, and destination cities.
****************************************************************************************/
USE asian_imports;


SELECT
    c.company_name AS customer,
    s.shipment_no,
    lo.location_name AS origin_city,
    lo.unlocode AS origin_unlo_code,
    ld.location_name AS destination_city,
	ld.unlocode AS dest_unlo_code,
    s.mode,
    s.status
FROM shipments s
JOIN customers c
	ON c.customer_id = s.customer_id
JOIN locations lo
	ON lo.location_id = s.origin_location_id
JOIN locations ld
	ON ld.location_id = s.destination_location_id;

