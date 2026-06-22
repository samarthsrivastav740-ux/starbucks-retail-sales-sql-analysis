-- 2. Data Modeling

/*Defining primary keys for each tables*/

-->customer table
EXEC sp_help 'customers'

ALTER TABLE customers
ALTER COLUMN customer_id VARCHAR(50) NOT NULL;

ALTER TABLE customers
ADD CONSTRAINT PK_customers
PRIMARY KEY (customer_id);

-->items table
EXEC sp_help 'items'

ALTER TABLE items
ALTER COLUMN ID VARCHAR(50) NOT NULL;

ALTER TABLE items
ADD CONSTRAINT PK_items
PRIMARY KEY(ID);

-->sales table
EXEC sp_help 'sales'

ALTER TABLE sales
ALTER COLUMN transaction_id VARCHAR(50) NOT NULL;

ALTER TABLE sales
ALTER COLUMN customer_id VARCHAR(50) NOT NULL;

ALTER TABLE sales
ALTER COLUMN store_id VARCHAR(50) NOT NULL;

ALTER TABLE sales
ADD CONSTRAINT PK_sales
PRIMARY KEY (transaction_id,store_id,customer_id)

/*Defining foreign keys */

-- sales → customers
ALTER TABLE sales
ADD CONSTRAINT FK_Sales_Customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- sales -> items
ALTER TABLE sales
ADD CONSTRAINT FK_Sales_Items
FOREIGN KEY (item_id)
REFERENCES items(ID);

/* Observation:
Sales acts as the central fact table containing transactional
data, while Customers and Items serve as dimension tables
providing descriptive attributes. The resulting model follows
a star schema design suitable for reporting and business
analysis.
              customers          
                  |
                  |
    items----- sales                 
                      

Fact Table:
- sales

Dimension Tables:
- customers
- items

Relationships:
- sales.customer_id -> customers.customer_id
- sales.item_id -> items.ID

*/
