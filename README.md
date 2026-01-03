# Asian Imports Logistics - Database Design

**A production ready logistics database for modeling the supply chain and complete business lifecycle: **Customers → Sales Orders → Purchase Orders → Vendors → Shipments → Invoices → Payments → Documents**.

## Key Features 
- **Normalized schema** with 10 interconnected tables
- **Foreign key relationships** enforcing data integrity
- **Business logic** via generated columns, enums, constraints
- **Complex JOIN queries** revealing supply chain insights
- **Realistic sample data** (customers, vendors, shipments from JP/KR/TH→US)

## Business Metrics at a Glance
| Metric           | Value                          | Table        |
|------------------|--------------------------------|--------------|
| Total Shipments  | 10 (4 Delivered, 3 In Transit) | `shipments`    |
| Revenue          | $98,250                        | `sales_orders` |
| Invoices         | $5,656 (2 Open)                | `invoices`     |
| On-Time Delivery | 75%                            | `shipments`  |

### Sample Queries: Customer Revenue
| customer       | vendor           | so_number    | order_date | sales_amount | po_number    | purchase_amount |
|----------------|------------------|--------------|------------|--------------|--------------|-----------------|
| Peachy Spa     | Sakamoto Noodles | SO-2025-0001 | 2025-01-03 |     18750.00 | PO-2025-0001 |        11900.00 |
| Ranch 88       | Topok Express    | SO-2025-0002 | 2025-02-10 |     57000.00 | PO-2025-0002 |        37320.00 |
| Shinjuku Stars | Rama Wellness    | SO-2025-0003 | 2025-03-01 |     22500.00 | PO-2025-0003 |        14808.00 |

**Query:** [07-customer-revenue.sql](./queries/07-customer-revenue.sql)

### Sample Queries: Shipment Status
| customer       | shipment_no   | origin_city | origin_unlo_code | destination_city | dest_unlo_code | mode  | status       |
|----------------|---------------|-------------|------------------|------------------|----------------|-------|--------------|
| Ranch 88       | SHP-2025-0001 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | ocean | Delivered    |
| Ranch 88       | SHP-2025-0002 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | air   | Delivered    |
| Ranch 88       | SHP-2025-0003 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | ocean | In Transit   |
| Shinjuku Stars | SHP-2025-0004 | Tokyo       | JPTYO            | Los Angeles      | USLAX          | ocean | Customs Hold |
| Shinjuku Stars | SHP-2025-0005 | Bangkok     | THBKK            | Los Angeles      | USLAX          | air   | Delivered    |

**Query:** [02-customer-shipments.sql](./queries/02-customer-shipments.sql)


**[Run schema→](./schema/asian-import-database.sql)** | **[Explore queries →](./queries/)**
