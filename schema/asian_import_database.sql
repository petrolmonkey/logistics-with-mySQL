DROP DATABASE IF EXISTS asian_imports;
CREATE DATABASE asian_imports;
USE asian_imports;


/****************************************************************************************
									Customers Table
****************************************************************************************/
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id      INT AUTO_INCREMENT PRIMARY KEY,
    company_name     VARCHAR(100) NOT NULL,
    contact_first    VARCHAR(50),
    contact_last     VARCHAR(50),
    address_line1    VARCHAR(100),
    address_line2    VARCHAR(100),
    city             VARCHAR(50),
    state_region     VARCHAR(50),
    postal_code      VARCHAR(20),
    country_code     CHAR(2),       -- ISO 3166-1 alpha-2
    email            VARCHAR(100),
    phone            VARCHAR(20),
    customer_type    ENUM('IMPORTER','RETAILER','MANUFACTURER','DISTRIBUTOR','OTHER')
);

INSERT INTO customers (
    customer_id, company_name, contact_first, contact_last,
    address_line1, city, state_region, postal_code, country_code,
    email, phone, customer_type
	) VALUES
	(100, 'Ranch 88', 'Shen', 'Wang',
	 '17713 Pioneer Blvd', 'Artesia', 'CA', '90701', 'US',
	 'swang@gmail.com', '+1-562-924-8899', 'IMPORTER'),

	(200, 'Shinjuku Stars', 'Baker', 'Mayflower',
	 '5131 Beach Blvd Suite A', 'Buena Park', 'CA', '90621', 'US',
	 'bmayflower@gmail.com', '+1-714-868-8910', 'RETAILER'),

	(300, 'Peachy Spa', 'Brent', 'Chen',
	 '30 Serendipity Trail', 'Sedona', 'AZ', '86336', 'US',
	 'bchen@gmail.com', '+1-928-203-4180', 'IMPORTER');


/****************************************************************************************
									Countries Table
	Creating this table to be referenced by locations table for normalization.
    
****************************************************************************************/
DROP TABLE IF EXISTS countries;
CREATE TABLE countries (
	country_ID 		INT PRIMARY KEY, 
    iso2_code 		CHAR(2), 
    country_name 	CHAR(40),
    region 			CHAR(20)
);

INSERT INTO countries (country_ID, iso2_code, country_name, region) VALUES
	(3100, "US", "United States of America", "North America"), 
    (3201, "JP", "Japan", "Asia"),
    (3202, "KR", "South Korea", "Asia"),
    (3203, "TH", "Thailand", "Asia");

/****************************************************************************************
									Locations Table
****************************************************************************************/

DROP TABLE IF EXISTS locations;
CREATE TABLE locations (
	location_ID 	INT PRIMARY KEY,
	location_name 	VARCHAR(20),
    unlocode 		CHAR(5),
    country_ID 		INT,
    timezone 		VARCHAR(20), 
    CONSTRAINT FK_country FOREIGN KEY (country_ID) REFERENCES countries(country_ID)
);

INSERT INTO locations (location_ID, location_name, unlocode, country_ID, timezone) VALUES
	(1001, "Los Angeles", "USLAX", 3100, "PST"),
	(2001, "Tokyo", "JPTYO", 3201, "JST"),
    (3001, "Bangkok", "THBKK", 3203, "ICT"),
    (4001, "Seoul", "KRSEL", 3202, "KST");
  

/****************************************************************************************
									Shipments Table
	NULL values for dates are either unkown or cancelled
    add later: latest_event column calculated from tracking events table
****************************************************************************************/

DROP TABLE IF EXISTS shipments;
CREATE TABLE shipments (
	shipment_id 			INT PRIMARY KEY,
    customer_id 			INT,
    origin_location_id 		INT, 
    destination_location_id INT, 
    shipment_no 			VARCHAR(20), 
    mode 					ENUM("ocean", "air"), 
    incoterms 				ENUM("EXW", "FCA", "FOB", "CIF", "DDP"), 
    planned_ship_date 		DATE, 
    planned_deliver_date 	DATE, 
    actual_ship_date 		DATE, 
    actual_deliver_date 	DATE, 
    status					ENUM("Planned", "In Transit", "Customs Hold", "Delivered", "Cancelled"), 
    total_packages 			INT, 
    total_weight 			FLOAT, 
    weight_uom 				CHAR(3),
    CONSTRAINT FK_origin FOREIGN KEY (origin_location_ID) REFERENCES locations(location_ID),
    CONSTRAINT FK_destination FOREIGN KEY (destination_location_ID) REFERENCES locations(location_ID),
    CONSTRAINT FK_customer FOREIGN KEY (customer_ID) REFERENCES customers(customer_ID)
);

INSERT INTO shipments (shipment_id, customer_id, origin_location_id, destination_location_id, shipment_no, 
	mode, incoterms, planned_ship_date, planned_deliver_date, actual_ship_date, actual_deliver_date, 
    status, total_packages, total_weight, weight_uom) VALUES

(1,  100, 2001,  1001, 'SHP-2025-0001', 'ocean', 'FOB', '2025-01-05', '2025-02-02', '2025-01-05', '2025-02-01', 'Delivered',     520, 10850.0, 'KG'),
(2,  100, 2001,  1001, 'SHP-2025-0002', 'air',   'CIF', '2025-01-08', '2025-01-15', '2025-01-09', '2025-01-16', 'Delivered',      24,   980.5, 'KG'),
(3,  100, 2001,  1001, 'SHP-2025-0003', 'ocean', 'FOB', '2025-01-10', '2025-02-05', '2025-01-11', NULL,         'In Transit',    310,  7200.0, 'KG'),
(4,  200, 2001,  1001, 'SHP-2025-0004', 'ocean', 'CIF', '2025-01-12', '2025-02-09', '2025-01-13', '2025-02-12', 'Customs Hold',  180,  4550.0, 'KG'),
(5,  200, 3001,  1001, 'SHP-2025-0005', 'air',   'FCA', '2025-01-15', '2025-01-20', '2025-01-15', '2025-01-19', 'Delivered',      12,   430.0, 'KG'),
(6,  200, 3001,  1001, 'SHP-2025-0006', 'ocean', 'FOB', '2025-01-18', '2025-02-14', NULL,         NULL,         'Planned',       640, 13200.0, 'KG'),
(7,  300, 3001,  1001, 'SHP-2025-0007', 'ocean', 'CIF', '2025-01-20', '2025-02-18', '2025-01-21', NULL,         'In Transit',    420,  9850.0, 'KG'),
(8,  300, 4001,  1001, 'SHP-2025-0008', 'air',   'DDP', '2025-01-22', '2025-01-29', '2025-01-23', '2025-01-28', 'Delivered',      30,  1150.0, 'KG'),
(9,  300, 4001,  1001, 'SHP-2025-0009', 'ocean', 'FOB', '2025-01-25', '2025-02-22', '2025-01-26', NULL,         'In Transit',    270,  6100.0, 'KG'),
(10, 300, 4001,  1001, 'SHP-2025-0010', 'air',   'EXW', '2025-01-27', '2025-02-01', NULL,         NULL,         'Cancelled',      0,     0.0, 'KG');


/****************************************************************************************
									Vendors Table
	Since this is a fictitious table, SCAC code is NULL
****************************************************************************************/
DROP TABLE IF EXISTS vendors;
CREATE TABLE vendors (
    vendor_id      INT AUTO_INCREMENT PRIMARY KEY,
    company_name   VARCHAR(100) NOT NULL,
    contact_first  VARCHAR(50),
    contact_last   VARCHAR(50),
    address_line1  VARCHAR(100),
    address_line2  VARCHAR(100),
    city           VARCHAR(50),
    state_region   VARCHAR(50),
    postal_code    VARCHAR(20),
    country_code   CHAR(2),       -- ISO 3166-1 alpha-2
    email          VARCHAR(100),
    phone          VARCHAR(20),
    scac           CHAR(4),      
    vendor_type    ENUM('CARRIER','BROKER','WAREHOUSE','CUSTOMS','OTHER')
);

INSERT INTO vendors (vendor_id, company_name, contact_first, contact_last, 
	address_line1, city, state_region, postal_code, country_code, email, phone, scac, vendor_type
)	VALUES
	(562, 'Sakamoto Noodles', 'Taro', 'Sakamoto', 
    '2 Chome-8-1 Nishishinjuku', 'Shinjuku City', 'Tokyo', '160-0023', 'JP', 'staro@gmail.com', '+81-3-5322-0255', NULL, 'CARRIER'),

	(310, 'Topok Express', 'Jun', 'Han', 
    '56 Seongchon-gil', 'Seocho District', 'Seoul', NULL, 'KR', 'hjung@gmail.com', '+82-2-3482-8388', NULL, 'CARRIER'),

	(714, 'Rama Wellness', 'Lucky', 'Isarangcharoen', 
    'E Pak Chong', 'Nakhon Ratchasima', NULL, '30130', 'TH', 'luckyrama@gmail.com', '+66-96-051-8111', NULL, 'CARRIER');


/****************************************************************************************
									Invoices Table
	Vendor ID linked as a foreign key to create internal controls that prevent duplicates
	add later: add line-item details table
****************************************************************************************/

DROP TABLE IF EXISTS invoices;
CREATE TABLE invoices (
	invoice_id 			INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number 		VARCHAR(20),
    invoice_date 		DATE,
    vendor_id 			INT,
    amount 				DECIMAL(8,2),
    currency 			CHAR(3),
    payment_terms 		ENUM("NET30", "NET60", "CIA", "COD", "LC"),
    shipment_ID 		INT,
    status 				ENUM('OPEN','CLOSED'),
    CONSTRAINT FK_shipment FOREIGN KEY (shipment_ID) REFERENCES shipments(shipment_ID),
    CONSTRAINT FK_vendor FOREIGN KEY (vendor_ID) REFERENCES vendors(vendor_ID)
);

INSERT INTO invoices (invoice_ID, invoice_number, invoice_date, vendor_id, amount, currency, 
	payment_terms, shipment_ID, status) 
    
    VALUES
	(1, 'INV-2025-0001', '2025-02-03', 562,  4820.50, 'USD', 'NET30', 1, 'CLOSED'),
	(2, 'INV-2025-0002', '2025-01-16', 714,  1950.75, 'USD', 'NET30', 2, 'CLOSED'),
	(3, 'INV-2025-0003', '2025-02-13', 310,  3280.00, 'USD', 'NET60', 4, 'OPEN'),
	(4, 'INV-2025-0004', '2025-01-20', 562,  1125.40, 'USD', 'NET30', 5, 'CLOSED'),
	(5, 'INV-2025-0005', '2025-01-29', 714,  2375.90, 'USD', 'NET30', 8, 'OPEN');


/****************************************************************************************
								Purchase Orders Table
****************************************************************************************/

DROP TABLE IF EXISTS purchase_orders;
CREATE TABLE purchase_orders (
    po_id           INT AUTO_INCREMENT PRIMARY KEY,
    po_number       VARCHAR(20) UNIQUE NOT NULL,
    part_number     VARCHAR(20),
    description     VARCHAR(100),
    qty		        INT NOT NULL,
    unit_of_measure VARCHAR(10),      -- UOM like 'BOX', 'EA', 'KG'
    unit_price      DECIMAL(10,2),
    total_amount    DECIMAL(12,2) GENERATED ALWAYS AS (unit_price * qty) VIRTUAL,
    vendor_id       INT,
    po_date         DATE NOT NULL,
    due_date        DATE,
    status          ENUM('OPEN', 'PARTIAL', 'CLOSED', 'CANCELLED') DEFAULT 'OPEN',
	CONSTRAINT FK_po_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id)
);

INSERT INTO purchase_orders (
	po_number, part_number, description, qty, unit_of_measure, unit_price,
    vendor_ID, po_date, due_date, status
    ) VALUES 
	('PO-2025-0001',  '43LKJ-7', 'Incense, Lemon Grass', 2500, 'BOX', 4.76, 
    562, '2025-01-05', '2025-06-30','OPEN'),
	('PO-2025-0002', 'HK-234889', 'UDON, Yamasaki', 4000, 'BOX', 9.33, 
    310, '2025-02-15', '2025-07-30','OPEN'),
	('PO-2025-0003', '340597', 'Labubu, Funky Munkey', 1200, 'EA', 12.34, 
    714, '2025-03-04', '2025-11-02','OPEN');


/****************************************************************************************
								Sales Orders Table
****************************************************************************************/
DROP TABLE IF EXISTS sales_orders;
 CREATE TABLE sales_orders (
    sales_order_id   INT AUTO_INCREMENT PRIMARY KEY,
    so_number        VARCHAR(20) UNIQUE NOT NULL,
    customer_id      INT NOT NULL,
    po_id            INT,             
    shipment_id      INT,             -- Shipment that delivers it
    part_number      VARCHAR(20),
    description      VARCHAR(100),
    quantity         INT NOT NULL,
    unit_of_measure  VARCHAR(10),
    unit_price       DECIMAL(10,2),
    total_amount     DECIMAL(12,2) GENERATED ALWAYS AS (unit_price * quantity) VIRTUAL,
    order_date       DATE NOT NULL,
    requested_date   DATE,
    status           ENUM('OPEN', 'PARTIAL', 'CLOSED', 'CANCELLED') DEFAULT 'OPEN',
	CONSTRAINT FK_sales_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT FK_po_id FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id),
    CONSTRAINT FK_sales_shipment FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

INSERT INTO sales_orders (
    so_number, customer_id, po_id, shipment_id, part_number, description,
    quantity, unit_of_measure, unit_price, order_date, requested_date
) VALUES
-- Peachy Spa (customer 300) orders Incense; buy from Rama Wellness (vendor 714)
('SO-2025-0001', 300, 1, 1, '43LKJ-7', 'Incense, Lemon Grass', 
 2500, 'BOX', 7.50, '2025-01-03', '2025-06-15'),
 
-- Ranch 88 (customer 100) orders Udon; buy from Sakamoto Noodles (vendor 562)
('SO-2025-0002', 100, 2, 2, 'HK-234889', 'UDON, Yamasaki', 
 4000, 'BOX', 14.25, '2025-02-10', '2025-07-15'),

-- Shinjuku Stars (customer 200) orders Labubus; buy from Topok Express (vendor 310)  
('SO-2025-0003', 200, 3, NULL, '340597', 'Labubu, Funky Munkey', 
 1200, 'EA', 18.75, '2025-03-01', '2025-10-30');



/****************************************************************************************
									Payments Table
****************************************************************************************/
DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
	payment_id 		INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id 		INT NOT NULL,
    payment_method	ENUM('CHECK', 'ACH', 'WIRE', 'CREDIT_CARD', 'LC') DEFAULT 'CHECK',
    reference_num 		VARCHAR(30),		-- check, ACH, wire number
    date 			DATE NOT NULL,
    amount 			DECIMAL(10,2) NOT NULL,
    currency 		CHAR(3) DEFAULT 'USD',
    CONSTRAINT FK_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
);

INSERT INTO payments (
	invoice_id, payment_method, reference_num, date, amount, currency
    ) VALUES
	(1, 'CHECK', 'CHK-12048', '2025-02-10', 4820.50, 'USD'),
	(2, 'ACH', 'ACH-TRC-568853', '2025-01-25', 1950.75, 'USD'),
	(4, 'CHECK', 'CHK-12049', '2025-01-28', 1125.40, 'USD'),
	(3, 'WIRE', 'WIRE-REF-001', '2025-02-20', 1500.00, 'USD');


/****************************************************************************************
								Shipment Documents Table
****************************************************************************************/
DROP TABLE IF EXISTS shipment_documents;
CREATE TABLE shipment_documents (
    document_id     INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id     INT NOT NULL,
    document_type   ENUM('HBL', 'MBL', 'COMMERCIAL_INVOICE', 'PACKING_LIST', 'AWB'),
    document_number VARCHAR(50) UNIQUE NOT NULL,  -- HBL12345, MBL-SHA-LAX-001
    issuer          VARCHAR(100),                 -- Carrier name
    issue_date      DATE,
    status          ENUM('ISSUED', 'AMENDED', 'VOID') DEFAULT 'ISSUED',
    CONSTRAINT FK_ship_docs_shipments FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

INSERT INTO shipment_documents (
    shipment_id, document_type, document_number, issuer, issue_date, status
	) VALUES
	-- Shipment 1: Ocean FCL from Japan (Sakamoto Noodles → Ranch 88)
	(1, 'MBL', 'ONEU1234567890', 'Ocean Network Express', '2025-01-05', 'ISSUED'),
	(1, 'HBL', 'HBL-USA-2025-0001', 'PPM Logistics', '2025-01-05', 'ISSUED'),

	-- Shipment 2: Air from Korea (Topok Express → Shinjuku Stars)  
	(2, 'AWB', 'KE-123-45678901', 'Korean Air Cargo', '2025-01-09', 'ISSUED'),
	(2, 'HBL', 'HBL-USA-2025-0002', 'PPM Logistics', '2025-01-09', 'ISSUED'),

	-- Shipment 3: Ocean in transit
	(3, 'MBL', 'COSU9876543210', 'COSCO Shipping', '2025-01-11', 'ISSUED'),

	-- Shipment 5: Air (Ranch 88 second order)
	(5, 'AWB', 'CX-567-89012345', 'Cathay Pacific Cargo', '2025-01-15', 'ISSUED'),
	(5, 'HBL', 'HBL-USA-2025-0005', 'PPM Logistics', '2025-01-15', 'ISSUED'),

	-- Shipment 7: Ocean in transit  
	(7, 'MBL', 'MAEU1122334455', 'Maersk Line', '2025-01-21', 'ISSUED'),

	-- Shipment 8: Air DDP (final delivery)
	(8, 'AWB', 'CI-789-01234567', 'China Airlines', '2025-01-23', 'ISSUED'),
	(8, 'HBL', 'HBL-USA-2025-0008', 'PPM Logistics', '2025-01-23', 'ISSUED'),

	-- Shipment 9: Ocean in transit
	(9, 'MBL', 'HLXU9988776655', 'Hapag-Lloyd', '2025-01-26', 'ISSUED');


