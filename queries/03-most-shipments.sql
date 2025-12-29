/****************************************************************************************
								Most Shipments Query
	Queries which origin country had the most shipments.
****************************************************************************************/
USE asian_imports;

SELECT
  co.country_name AS origin_country,
  COUNT(DISTINCT s.shipment_id) AS shipments_count,
  SUM(s.total_weight) AS total_weight_kg
FROM shipments s
JOIN locations lo 
  ON s.origin_location_id = lo.location_id
JOIN countries co 
  ON lo.country_id = co.country_id
GROUP BY co.country_name
ORDER BY shipments_count DESC;

