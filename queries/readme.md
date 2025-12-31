## Queries Summary
| #  | Query                                                                      | Tables Joined                                                  |
|----|----------------------------------------------------------------------------|----------------------------------------------------------------|
| 01 | How are the tables related to one another in the schema?                   | na                                                             |
| 02 | What is the status for each customer's shipments?                          | `locations``shipments``customers`                              |
| 03 | Which country had the most shipments by count and by weight?               | `locations``shipments``countries`                              |
| 04 | How do we show traceability for the invoice payments                       | `payments``invoices``vendors`                                  |
| 05 | What shipments have been delivered and what are the invoices tied to them? | `invoices``shipments``vendors`                                 |
| 06 | What does the order lifecycle look like from customer order to shipment?   | `sales_orders``purchase_orders``vendors``shipments``customers` |
| 07 | How does the sales revenue compare to the vendor cost?                     | `sales_orders``purchase_orders``vendors``customers`            |

**[Full Data](../data/)**
