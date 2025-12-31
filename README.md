# Asian Imports Logistics - Database Design

**A production ready logistics database for for the movement of goods across the Pacific** modeling the complete supply chain: **Customers → Sales Orders → Purchase Orders → Vendors → Shipments → Invoices → Payments → Documents**.

## Key Features 
- **Normalized schema** (6NF) with 11 interconnected tables
- **Foreign key relationships** enforcing data integrity
- **Business logic** via generated columns, enums, constraints
- **Complex JOIN queries** revealing supply chain insights
- **Realistic sample data** (customers, vendors, shipments from JP/KR/TH→US)

## Business Metrics
| Metric           | Value                          | Query        |
|------------------|--------------------------------|--------------|
| Total Shipments  | 10 (4 Delivered, 3 In Transit) | shipments    |
| Revenue          | $98,250                        | sales_orders |
| Invoices         | $5,656 (2 Open)                | invoices     |
| On-Time Delivery | 75%                            | `shipments`  |




### Shipment Status
| customer       | shipment_no   | origin_city | origin_unlo_code | destination_city | dest_unlo_code | mode  | status       |
|----------------|---------------|-------------|------------------|------------------|----------------|-------|--------------|
| Ranch 88       | SHP-2025-0001 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | ocean | Delivered    |
| Ranch 88       | SHP-2025-0002 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | air   | Delivered    |
| Ranch 88       | SHP-2025-0003 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | ocean | In Transit   |
| Shinjuku Stars | SHP-2025-0004 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | ocean | Customs Hold |
| Shinjuku Stars | SHP-2025-0005 | Bangkok     | THBKK            | Los Angeles      | USLAX          | air   | Delivered    |

**Query:** [02-customer-shipments.sql](./queries/02-customer-shipments.sql)
