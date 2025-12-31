# Logistics Database

## Objective
To create a database with linked tables that account for the movement of goods across the Pacific.

## Sample Result: Shipment Status
| customer       | shipment_no   | origin_city | origin_unlo_code | destination_city | dest_unlo_code | mode  | status       |
|----------------|---------------|-------------|------------------|------------------|----------------|-------|--------------|
| Ranch 88       | SHP-2025-0001 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | ocean | Delivered    |
| Ranch 88       | SHP-2025-0002 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | air   | Delivered    |
| Ranch 88       | SHP-2025-0003 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | ocean | In Transit   |
| Shinjuku Stars | SHP-2025-0004 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | ocean | Customs Hold |
| Shinjuku Stars | SHP-2025-0005 | Bangkok     | THBKK            | Los Angeles      | USLAX          | air   | Delivered    |

**Query:** [02-customer-shipments.sql](./queries/02-customer-shipments.sql)
