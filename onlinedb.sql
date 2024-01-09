set serveroutput on;

--Drop table command will be helpful in avoiding already table exist error.
--Cascade constraints is invoked to loose any constraints associated with the table.
drop table recommendations cascade constraints;
drop table reviews cascade constraints;
drop table invoices cascade constraints;
drop table credit_cards cascade constraints;
drop table orders cascade constraints;
drop table products cascade constraints;
drop table product_categories cascade constraints;
drop table customers cascade constraints;

--Create table command will create the tables according to the given attributes.
CREATE table customers (
	cust_ID INT,
	cust_fname VARCHAR(100),
    cust_lname VARCHAR(100),
	cust_city VARCHAR(100),
	cust_email VARCHAR(100),
	cust_state VARCHAR(100),
	cust_zip NUMBER(5),
	PRIMARY KEY (cust_ID)
);

CREATE table credit_cards (
	creditcard_number VARCHAR(100) NOT NULL,
	cust_ID INT,
	creditcard_type VARCHAR(100),
	creditcard_expyear INT,
	creditcard_expmonth INT,
	PRIMARY KEY (creditcard_number),
	FOREIGN KEY (cust_ID) REFERENCES customers(cust_ID)	
);

CREATE table product_categories (
	category_ID INT,
	category_name VARCHAR(100),
	category_description VARCHAR(100),
	PRIMARY KEY (category_ID)
);

CREATE table products (
	prod_ID INT NOT NULL,
	prod_name VARCHAR(100),
	prod_quantity INT CONSTRAINT Valid_Quantity_Check CHECK (prod_quantity > 0), --Products with minimum availability will only be added
	prod_price FLOAT,
	category_ID INT NOT NULL,
	PRIMARY KEY (prod_ID),
	FOREIGN KEY (category_ID) REFERENCES product_categories (category_ID)
);

CREATE table orders (
	order_ID INT,
	cust_ID INT,
	prod_ID INT,
	order_quantity INT,
	order_date DATE,
	PRIMARY KEY (order_ID),
	FOREIGN KEY (cust_ID) REFERENCES customers(cust_ID),
	FOREIGN KEY (prod_ID) REFERENCES products(prod_ID)
);

CREATE table invoices (
	invoice_ID INT,
	order_ID INT,
	cust_ID INT,
	creditcard_number VARCHAR(100),
	invoice_amount INT,
	PRIMARY KEY (invoice_ID),
	FOREIGN KEY (order_ID) REFERENCES orders(order_ID),
	FOREIGN KEY (cust_ID) REFERENCES customers(cust_ID),
	FOREIGN KEY (creditcard_number) REFERENCES credit_cards(creditcard_number)
);

CREATE table reviews (
	review_ID INT NOT NULL,
	prod_ID INT,
	review_email VARCHAR(100),
	review_stars VARCHAR(5),
	review_text VARCHAR(100),
	PRIMARY KEY (review_ID),
	FOREIGN KEY (prod_ID) REFERENCES products(prod_ID)
);

CREATE table recommendations (
	rec_ID INT NOT NULL,
	cust_ID INT,
	rec_prodID INT,
	rec_date DATE,
	PRIMARY KEY (rec_ID),
	FOREIGN KEY (cust_ID) REFERENCES customers(cust_ID),
	FOREIGN KEY (rec_prodID) REFERENCES products(prod_ID)
);

--################# HELPER FUNCTIONS ############

--1) FIND_CUSTOMER_ID(email): It finds the customer ID based on the customer email
create or replace function find_customer_id(v_email in customers.cust_email%type) return
customers.cust_id%type as
v_id customers.cust_id%type;
begin
    --Implicit cursor to retirve value and store it in a variable
    select cust_id into v_id from customers where cust_email=v_email;
    --It returns the customer ID
    return v_id;
exception
    --When no rows returned, then this exception is executed
    when no_data_found then
    dbms_output.put_line('No customer found');
    return -1;
    when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--2) FIND_PRODUCT_CATEGORY_ID(category name): It finds the product category ID based on the category name.
create or replace function find_product_category_id(v_catname in product_categories.category_name%type) return
product_categories.category_id%type as
v_id product_categories.category_id%type;
begin
    --Implicit cursor to retirve value and store it in a variable
    select category_id into v_id from product_categories where category_name=v_catname;
    --It returns the product category ID
    return v_id;
exception
    --When no rows returned, then this exception is executed
    when no_data_found then
    dbms_output.put_line('No category found');
    return -1;
    when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--3) FIND_PRODUCT_ID(product name): It finds the product ID based on the product name
create or replace function find_product_id(v_pname in products.prod_name%type) return
products.prod_id%type as
v_id products.prod_id%type;
begin
    --Implicit cursor to retirve value and store it in a variable
    select prod_id into v_id from products where prod_name=v_pname;
    --It returns the product ID
    return v_id;
exception
    --When no rows returned, then this exception is executed
    when no_data_found then
    dbms_output.put_line('No product found');
    return -1;
    when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--4) FIND_CREDIT_CARD_ID(credit card #): It finds the customer ID based on the credit card number.
create or replace function find_credit_card(v_ccnumber in credit_cards.creditcard_number%type) return
credit_cards.cust_ID%type as
v_id credit_cards.cust_ID%type;
begin
    --Implicit cursor to retirve value and store it in a variable
    select cust_ID into v_id from credit_cards where creditcard_number=v_ccnumber;
    --It returns the customer ID
    return v_id;
exception
    --When no rows returned, then this exception is executed
    when no_data_found then
    dbms_output.put_line('No credit card found');
    return -1;
    when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--############## PROCEDURES #################

--1) Add_Customer: this procedures adds customer to the customer table.
--DROP SEQUENCE statement to drop existing codes
DROP SEQUENCE custID_seq_ID;

-- CREATE SEQUENCE statement to create a new sequence for generating unique customer IDs
CREATE SEQUENCE custID_seq_ID 
START with 1
INCREMENT BY 1;

-- CREATE OR REPLACE PROCEDURE statement to define the add_customer stored procedure
create or replace procedure add_customer(v_custFName IN VARCHAR, v_custLName IN VARCHAR, v_custCity IN VARCHAR, v_custEmail IN VARCHAR, v_custState IN VARCHAR, v_custZipcode IN NUMBER)
as
begin
    dbms_output.put_line('---------Add customer procedure called---------');
    -- Insert a new record into the 'customers' table using the sequence to generate a unique customer ID
    insert into customers values (custID_seq_ID.nextval, v_custFName, v_custLName, v_custCity, v_custEmail, v_custState, v_custZipcode);
    -- Output message indicating successful update of the 'customers' table
    dbms_output.put_line('Customer table updated with a new record');
exception
-- Exception handling block for managing any issues that may occur during execution
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--2) Show_all_customers_in_state
-- CREATE OR REPLACE PROCEDURE statement to define the show_all_customers_in_state stored procedure
create or replace procedure show_all_customers_in_state(v_state in customers.cust_state%type)
as
-- Declaration of variables to store customer and credit card detail
var_custId customers.cust_id%type;
var_custFName customers.cust_fname%type;
var_custLName customers.cust_lname%type;
var_custEmail customers.cust_email%type;
var_custAddress customers.cust_city%type;
var_ccNum credit_cards.creditcard_number%type;
var_ccType credit_cards.creditcard_type%type;
-- Cursor declaration to fetch customer and credit card details based on the provided state
cursor c1 is select c.cust_id, c.cust_fname, c.cust_lname, c.cust_email, c.cust_city, cc.creditcard_number, cc.creditcard_type
from customers c, credit_cards cc
where c.cust_id = cc.cust_id and c.cust_state=v_state;
begin
--Output message indicating that the procedure has been called
dbms_output.put_line('---------Show all customers in state procedure called---------');
open c1;
loop
-- Fetch data into variables
fetch c1 into var_custId, var_custFName, var_custLName, var_custEmail, var_custAddress, var_ccNum, var_ccType;
if (var_custId is null) then
    -- Check if there is no data (no customer from the provided state) 
    dbms_output.put_line('There is no customer from '||v_state);
    exit;
else
    -- Exit the loop if there is no more data to fetch
    exit when c1%notfound;
    dbms_output.put_line(v_state||': '||var_custFName || '  ' ||var_custLName || '  ' || var_custEmail || ' | '  || var_custAddress || ' | ' ||  var_ccNum || ' | ' ||  var_ccType);
end if;
end loop;
exception
--Exception handling block for managing any issues that may occur during execution
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--3) Add_CreditCard
-- CREATE OR REPLACE PROCEDURE statement to define the add_creditcard stored procedure
create or replace procedure add_creditcard(v_customeremail in customers.cust_email%type, v_creditcardnum in credit_cards.creditcard_number%type, v_customerid in customers.cust_id%type, v_cardtype in credit_cards.creditcard_type%type, v_expyear in credit_cards.creditcard_expyear%type, v_expmonth in credit_cards.creditcard_expmonth%type)
IS
-- Variable to store the customer ID
var_custid customers.cust_id%type;
-- Initialize variable with the input parameter
var_custemail customers.cust_email%type := v_customeremail;
begin
-- Output message indicating that the procedure has been called
dbms_output.put_line('---------Add Credit Card procedure called---------');
-- Call the find_customer_id function to get the customer ID based on the email
var_custid := find_customer_id(var_custemail);
-- Check if a valid customer ID is returned by the find_customer_id function
if var_custid != -1 then
    -- Insert a new record into the 'credit_cards' table
    insert into credit_cards values(v_creditcardnum,v_customerid,v_cardtype,v_expyear,v_expmonth);
    -- Output message indicating successful update of the 'credit_cards' table
    dbms_output.put_line('Credit card table updated with a new record');
else
    -- Output message indicating an invalid customer ID
    dbms_output.put_line('Invalid customer ID');
end if;
exception
-- Exception handling block for managing any issues that may occur during execution
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--4) Report_Cards_Expire
-- CREATE OR REPLACE PROCEDURE statement to define the report_cards_expire stored
create or replace procedure report_cards_expire(v_date in date)
is
begin
-- Output message indicating that the procedure has been called
dbms_output.put_line('---------Report cards expire procedure called---------');

for i in (
    --Loop through the result set of customers with expiring credit cards within the specified date range
    select c.cust_lname, c.cust_fname, cc.creditcard_number, cc.creditcard_type, cc.creditcard_expyear, cc.creditcard_expmonth
    from customers c, credit_cards cc
    where c.cust_id=cc.cust_id and add_months(trunc(to_date(cc.creditcard_expyear || '-' || cc.creditcard_expmonth, 'YYYY-MM')), -2) <= v_date
    and trunc(to_date(cc.creditcard_expyear || '-' || cc.creditcard_expmonth, 'YYYY-MM')) <= v_date
    order by c.cust_lname, c.cust_fname
) loop
    -- Output details for each customer with their expiring credit cards
    dbms_output.put_line('Customer Last Name: ' || i.cust_lname||', Customer First Name: ' || i.cust_fname || ', Card Number: ' || i.creditcard_number || ', Card Type: ' || i.creditcard_type || ', Expiration Year: ' || i.creditcard_expyear || ', Expiration Month: ' || i.creditcard_expmonth);
end loop;
exception
-- Exception handling block for managing any issues that may occur during execution
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--5) Add_Category
--Drop sequence for category ID
drop sequence cat_seq_id;

--creating a sequence 'cat_seq_id' to get unique values for category ID
create sequence cat_seq_id
start with 1
increment by 1;

--Creating a procedure to add a new category
create or replace procedure add_category(v_catName in product_categories.category_name%type, v_catDesc in product_categories.category_description%type)
is
begin
    dbms_output.put_line('---------Add category procedure called---------');
    -- Insert a new record into the 'product_categories' table with the specified category ID, Name, and Description
    insert into product_categories values(cat_seq_id.nextval, v_catName, v_catDesc);
    dbms_output.put_line('Product categories table updated with a new record');
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--6) Add_Product
--Drop sequence for product ID
drop sequence prod_seq_id;

--Creating a sequence 'prod_seq_id' to generate unique values for product ID
create sequence prod_seq_id
start with 1
increment by 1;

--Creating a procedure to add new product
create or replace procedure add_product(v_pname in products.prod_name%type,
v_pquantity in products.prod_quantity%type, v_pprice in products.prod_price%type,
v_catid in product_categories.category_ID%type, v_catname in product_categories.category_name%type)
is
--Use the function created earlier to get category ID based on category name
var_catid product_categories.category_ID%type;
begin
dbms_output.put_line('---------Add product procedure called---------');
--Use the function created earlier to get category ID based on category name.
var_catID := find_product_category_id(v_catname);
if var_catID != -1 then
    -- Insert a new record into the 'products' table with the provided values
    insert into products values(prod_seq_id.nextval, v_pname, v_pquantity, v_pprice, v_catid);
    dbms_output.put_line('Products table updated with a new record');
else
    dbms_output.put_line('Product category not found');
end if;
exception
when others then
 dbms_output.put_line ('SQLCODE: ' || SQLCODE);
 dbms_output.put_line ('SQLERRM: ' || SQLERRM);
end;

--7) Update_Inventory
--Creating a procedure to update product inventory
create or replace procedure update_inventory(v_pid in products.prod_id%type, v_pquant in INT)
is
var_availableQuantity int;
begin
dbms_output.put_line('---------Update Inventory procedure called---------');
--getting the current quantity for the given product ID
select prod_quantity into var_availableQuantity
from products where prod_ID=v_pid;
--Update the product quantity based on the input parameter
update products
set prod_quantity = var_availableQuantity-v_pquant
where prod_ID=v_pid;
commit;
dbms_output.put_line('Inventory Updated');
exception
when no_data_found then
    dbms_output.put_line('Product not found');
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--8) Report_Inventory
--creating a procedure to generate a report on product inventory by category
create or replace procedure report_inventory
as
cursor c1 is select pc.category_name, sum(prod_quantity) as Total_Quantity
from product_categories pc, products p
where pc.category_id=p.category_id
group by pc.category_name;
rec1 c1%rowtype;
begin
dbms_output.put_line('---------Report inventory procedure called---------');
open c1;
loop
-- Fetch data into the record
fetch c1 into rec1;
exit when c1%notfound;
dbms_output.put_line('Category: '||rec1.category_name||', Quantity: '||rec1.Total_Quantity);
end loop;
close c1;
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--9) Invoice_Customer
-- Drop the existing sequence inv_seq_id if it exists
drop sequence inv_seq_id;

-- Create a new sequence inv_seq_id
create sequence inv_seq_id
start with 1
increment by 1;

-- A stored procedure named invoice_customer
create or replace procedure invoice_customer(v_oId in invoices.order_ID%type,
v_cEmail in customers.cust_email%type,v_ccNum in invoices.creditcard_number%type,
v_invAmount in invoices.invoice_amount%type)
as
var_custId customers.cust_ID%type;
begin
dbms_output.put_line('---------Invoice customer procedure called---------');
-- Call a function find_customer_id to get the customer ID based on the provided email
var_custId:=find_customer_id(v_cEmail);
-- Check if the customer ID is not equal to -1 (indicating the customer is found)
if var_custId != -1 then
    -- Insert a new record into the invoices table using the provided values and the next value from the sequence
    insert into invoices values(inv_seq_id.nextval, v_oId, var_custId, v_ccNum, v_invAmount);
    dbms_output.put_line('Invoices created');
    -- Commit the transaction to make the changes permanent
    commit;
else
    dbms_output.put_line('Customer not found');
end if;
-- Exception handling: Catch any errors that might occur during the execution of the procedure
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--10) Place_Order
--Sequence is used for automatically incrementing the Order ID value.
--Sequence is dropped initially and then created. It starts with value 1 and increments by 1.
drop sequence ord_seq_id;

create sequence ord_seq_id
start with 1
increment by 1;

--This procedure places the order as directed by the customer.
create or replace procedure place_order(v_cemail in customers.cust_email%type,
v_pname in products.prod_name%type,v_pquant in products.prod_quantity%type,
v_ccnum in credit_cards.creditcard_number%type,v_odate orders.order_date%type)
as
var_cId customers.cust_ID%type;
var_pId products.prod_ID%type;
var_invAmount invoices.invoice_amount%type;
var_quant products.prod_quantity%type;
begin
dbms_output.put_line('---------Place order procedure called---------');
--Condition to check if the given input quantity is valid or not.
if v_pquant<=0 then
    dbms_output.put_line('Invalid input quantity. Quantity should be greater than 0');
    return;
end if;
--Calling respective helper functions to retrieve associated values
var_cId := find_customer_id(v_cemail);
var_pId := find_product_id(v_pname);
--Condition to check if both customer and products exists to place the order
if var_cId!=-1 and var_pId!=-1 then
    --Inventory is updated with new quantity of associated product based on product ID.
    select prod_quantity into var_quant from products where prod_id=var_pId;
    --Condition to check if the inventory has atleast 1 quantity for selected product or not.
    if var_quant=0 then
        dbms_output.put_line('Out of Stock for choosen product');
        return;
    --Condition to check if the available quantity is more than required quantity.
    elsif var_quant>=v_pquant then
        dbms_output.put_line('-----');
        --Update inventory procedure called
        update_inventory(var_pId,v_pquant);
        select prod_price*v_pquant into var_invAmount from products where prod_ID=var_pId;
        insert into orders values(ord_seq_id.nextval,var_cId,var_pId,v_pquant,v_odate);
        --Invoice generated under customer who is associated with the purchase
        invoice_customer(ord_seq_id.currval,v_cemail,v_ccnum,var_invAmount);
        --To save the database stage
        commit;
        dbms_output.put_line('Order placed');
        dbms_output.put_line('-----');
    else
        dbms_output.put_line('Insufficient Inventory. Please reduce the input quantity');
        return;
    end if;
else
    dbms_output.put_line('Customer or Product doesnot exist');
end if;
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--11) Show_Orders:
--This procedure is called to display the list of orders placed.
create or replace procedure show_orders
is
var_ordersCount int;
begin
dbms_output.put_line('---------Show orders procedure called---------');
var_ordersCount := 0;
--This loop will iterate all the orders individually and then correspondingly print.
for i in (
    select c.cust_fname, p.prod_name, o.order_quantity, i.invoice_amount
    from customers c, products p, orders o, invoices i
    where c.cust_id=o.cust_id and o.order_id=i.order_id and p.prod_id=o.prod_id
) loop
    dbms_output.put_line('Customer Name: '||i.cust_fname||', Product Name: '||i.prod_name||
    ', Quantity Ordered: '||i.order_quantity||', Amount Charged: '||i.invoice_amount);
var_ordersCount := var_ordersCount + 1;
end loop;
dbms_output.put_line('Total Orders: ' || var_ordersCount);
--Condition to check if there are no orders.
if var_ordersCount=0 then
    dbms_output.put_line('There are no orders placed');
end if;
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line ('SQLERRM: ' || SQLERRM);
end;

--12) Report_Orders_by_State:
--This procedure is called to display the orders by grouping the state
create or replace procedure report_orders_by_state(v_state in customers.cust_state%type)
is
var_grandTotal number;
var_custCount number := 0;
--User defined exception
no_customer_exists exception;
begin
dbms_output.put_line('---------Report orders by state procedure called---------');
var_grandTotal := 0;
select distinct count(cust_id) into var_custCount from customers where cust_state=v_state;
--Condition to check if there is a customer who belongs to given input state
if var_custCount=0 then
    --Raising user defined exception
    raise no_customer_exists;
end if;
--This loop iterates by identifying and then grouping the customer uniquely
--It then finds the orders count and the total invoice amount for a state
dbms_output.put_line(v_state ||':-');
for i in (
    select c.cust_fname, c.cust_email, count(o.order_id) as Total_Orders, sum(i.invoice_amount) as Total_Amount
    from customers c, orders o, invoices i
    where c.cust_id=o.cust_id and o.order_id=i.order_id and c.cust_state=v_state
    group by c.cust_fname, c.cust_email
) loop
    dbms_output.put_line('Customer Name: '||i.cust_fname||', Customer email: '||i.cust_email||
    ', Total Number of Orders Placed : '||i.Total_Orders||', Total Amount Spent: '||i.Total_Amount);
    var_grandTotal := var_grandTotal + i.Total_Amount;
end loop;
if var_grandTotal >0 then
    dbms_output.put_line('Grand Total Amount Spent: '||var_grandTotal);
else
    dbms_output.put_line('No customer from '||v_state||' has an order placed');
end if;
exception
when no_customer_exists then
    dbms_output.put_line('There is no customer from '||v_state);
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line ('SQLERRM: ' || SQLERRM);
end;

--13) Report_Low_Inventory:
--This trigger tracks the products table to stay updated with the inventory/stock.
create or replace trigger report_low_inventory after insert or update on products
declare
cursor c1 is select prod_id,prod_name,prod_quantity
from products where prod_quantity<50;
--All the cursor values are stored as a record with rowtype
rec1 c1%rowtype;
begin
dbms_output.put_line('---------Report low inventory trigger fired---------');
open c1;
--It fetches all the products that are less than 50 units
loop
fetch c1 into rec1;
exit when c1%notfound;
dbms_output.put_line('Stock less than 50 units --> Product Id: '||rec1.prod_id||', Product Name: '||rec1.prod_name||
', Quantity: '||rec1.prod_quantity);
end loop;
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line ('SQLERRM: ' || SQLERRM);
end;

--To restock the inventory, below procedure is used.
create or replace procedure restock_inventory(v_pName in products.prod_name%type, v_quant in products.prod_quantity%type)
is
var_pid products.prod_id%type;
var_availableQuant products.prod_quantity%type;
begin
dbms_output.put_line('---------Restock inventory procedure called---------');
var_pid := find_product_id(v_pName);
if var_pid != -1 then
    select prod_quantity into var_availableQuant from products where prod_id=var_pid;
    update products set prod_quantity=var_availableQuant+v_quant where prod_id=var_pid;
    dbms_output.put_line('Product "'||v_pName||'" is restocked with '||v_quant||' more units');
else
    dbms_output.put_line('Product not found to Restock');
end if;
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line ('SQLERRM: ' || SQLERRM);
end;

--14) Report_Best_Customers
-- Creating or replacing a stored procedure named report_best_customers
create or replace procedure report_best_customers(v_minAmount in number)
as
var_customer boolean;
begin
dbms_output.put_line('---------Report best customers procedure called---------');
var_customer := false;
-- Looping through the result set of a query that retrieves customer names and their total amount spent
for i in (
    select c.cust_fname, sum(i.invoice_amount) as Total_Amount
    from customers c, invoices i
    where c.cust_id=i.cust_id
    group by c.cust_fname
    having sum(i.invoice_amount)>v_minAmount
) loop
dbms_output.put_line('Customer Name: '||i.cust_fname||', Total Amount Spent: '||i.Total_Amount);
-- Set the boolean variable to true to indicate the presence of best customers
var_customer := true;
end loop;
if not var_customer then
    dbms_output.put_line('There is no best customer');
end if;
-- Exception handling: To catch any errors that might occur during the execution of the procedure
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--15) Payments_to_CC
-- Create or replace a stored procedure named payments_to_cc
create or replace procedure payments_to_cc
as
var_visaFee number := 0.03;
var_mcFee number := 0.03;
var_amexFee number := 0.05;
var_discFee number := 0.02;
var_fee number;
begin
dbms_output.put_line('---------Payments to cc procedure called---------');
-- Loop through distinct credit card types in the credit_cards table
for rec_ccType in (
    select distinct creditcard_type
    from credit_cards
) loop
    -- Initialize the fee variable to 0 for each credit card type
    var_fee := 0;
    -- Calculate the total fee based on the order quantity and the associated transaction fee for each credit card type
    select sum(case
                    when rec_ccType.creditcard_type = 'VISA' then o.order_quantity * var_visaFee
                    when rec_ccType.creditcard_type = 'MASTERCARD' then o.order_quantity * var_mcFee
                    when rec_ccType.creditcard_type = 'AMEX' then o.order_quantity * var_amexFee
                    when rec_ccType.creditcard_type = 'DISCOVER' then o.order_quantity * var_discFee
                    else 0
                end)
    into var_fee
    from orders o, credit_cards cc
    where o.cust_id=cc.cust_id;
    dbms_output.put_line('Credit Card Type: '||rec_ccType.creditcard_type||', Total Fee: '||var_fee);
end loop;
-- Exception handling: Catch any errors that might occur during the execution of the procedure
exception
when others then
    -- Display the SQLCODE (error code) and the error message
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--16) Thrifty_Customer
-- Create or replace a stored procedure named thrifty_customer
create or replace procedure thrifty_customer(v_num in number)
is
-- Declare a cursor to select customer information with total amount spent
cursor c1 is select c.cust_id, c.cust_fname, nvl(sum(i.invoice_amount), 0) AS total_spent
from customers c
left join invoices i on c.cust_id = i.cust_id
group by c.cust_id, c.cust_fname
order by total_spent desc;
-- Declare a record variable to store the fetched data from the cursor
rec1 c1%rowtype;
-- Declare a variable to count the number of fetched records
var_count number;
begin
-- Display a message indicating the start of the procedure
dbms_output.put_line('---------Thrifty customer procedure called---------');
-- Initialize the count variable to 0
var_count := 0;
-- Open the cursor
open c1;
-- Loop through the cursor and fetch customer data
loop
fetch c1 into rec1;
-- Exit the loop if there are no more records or if the desired count is reached
exit when c1%notfound or var_count>=v_num;
dbms_output.put_line('Customer ID: ' ||rec1.cust_id || ', Customer Name: ' ||
rec1.cust_fname || ', Total Spent: ' || rec1.total_spent);
-- Increment the count variable
var_count := var_count + 1;
end loop;
-- Exception handling: Catch any errors that might occur during the execution of the procedure
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--17) Add_Review
--This procedure adds the review given by a person to the reviews table, takes the email of the person and adds the review to the corresponding product.

--dropping old sequence id
drop sequence rev_seq_id;

create sequence rev_seq_id
start with 1
increment by 1;
--initialising a new sequence id
--creating a procedure to add review
create or replace procedure add_review(v_email in reviews.review_email%type,
v_stars in reviews.review_stars%type, v_pname in products.prod_name%type,
v_text in reviews.review_text%type)
as
var_pid products.prod_id%type;
begin
--Printing a message to indicate procedure is called
dbms_output.put_line('---------Add review procedure called---------');
--find product ID corresponding to the given product name
var_pid := find_product_id(v_pname);
--check if a valid product ID is found
if var_pid != -1 then
    --inserting mail id, product id, rating, comments for a product ID
    insert into reviews values(rev_seq_id.nextval,var_pid,v_email,v_stars,v_text);
    --print message to indicate review table updated with new record
    dbms_output.put_line('Review table updated with a new record');
else
    --print a message indicating product does not exist
    dbms_output.put_line('Selected product does not exist');
end if;
exception
--Handle any exception
when others then
    --print SQL code and error message associated with it
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--18) Buy_Or_Beware
--This procedure prints the best and worst-rated products based on the given input 
--creating a procedure buy or beware
create or replace procedure buy_or_beware(v_num in number)
as
--Defining a cursor c1 to select products with the highest average rating
cursor c1 is select avg(r.review_stars) as Average_Rating, p.prod_id, p.prod_name,
stddev(r.review_stars) as StdDev_Stars
from products p right join reviews r on p.prod_id=r.prod_id
group by p.prod_id, p.prod_name
order by Average_Rating desc;
--Defining a cursor c2 to select products with the lowest average rating
cursor c2 is select avg(r.review_stars) as Average_Rating, p.prod_id, p.prod_name,
stddev(r.review_stars) as StdDev_Stars
from products p right join reviews r on p.prod_id=r.prod_id
group by p.prod_id, p.prod_name
order by Average_Rating asc;
--Variables to count number of worst and best rated products
var_bestCount number;
var_worstCount number;
begin
dbms_output.put_line('---------Buy or beware procedure called---------');
var_bestCount := 0;
var_worstCount := 0;
--print a message top rated products
dbms_output.put_line('Top rated products:');
--Looping through cursor c1
for i in c1 
loop
    --exit loop when we have required number of best rated products
    exit when var_bestCount>=v_num or i.Average_Rating is null;
    --print the product information
    dbms_output.put_line('Average Stars: ' || i.Average_Rating||', Product ID: ' ||
    i.prod_ID||', Product Name: ' || i.prod_name ||', Standard Deviation: ' ||
    i.StdDev_Stars);
    --increasing counter for best rated products
    var_bestCount:=var_bestCount+1;
end loop;
--printing message for worst rated products
dbms_output.put_line('Buyer Beware: Stay Away from...:');
--looping through cursor c2
for i in c2 
loop
    -- exit loop when we have required number of worst rated products
    exit when var_worstCount>=v_num or i.Average_Rating is null;
    --print information about the product
    dbms_output.put_line('Average Stars: ' || i.Average_Rating||', Product ID: ' ||
    i.prod_ID||', Product Name: ' || i.prod_name ||', Standard Deviation: ' ||
    i.StdDev_Stars);
    --increasing counter for worst rated products
    var_worstCount:=var_worstCount+1;
end loop;
exception
--handle any exception
when others then
    --print SQL code and error message associated with it
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--19) Recommend_To_Customer
--This procedure takes Customer ID as the input and recommends the highest-rated product the customer has not bought, 
--in the same category the customer has bought a product before and insert it into the table.
drop sequence rec_seq_id;

create sequence rec_seq_id
start with 1
increment by 1;

--creating a new sequence ID
--create a procedure recommend to customer

create or replace procedure recommend_to_customer(v_cid in customers.cust_id%type)
as
begin
--print a message to indicate procedure is called
dbms_output.put_line('---------Recommend to customer procedure called---------');
--loop through the different categories of products customer brought
for category_record in (
    select distinct p.category_ID
    from orders o, products p 
    where o.prod_ID = p.prod_ID and o.cust_ID = v_cid
) loop
    --loop through the products in same category that the customer has not brought 
    for product_record in (
        select p.prod_ID, p.prod_name, avg(nvl(r.review_stars, 0)) AS avg_rating
        from products p, reviews r 
        where p.prod_ID = r.prod_ID and p.category_ID = category_record.category_ID
        and p.prod_ID not in (
            select prod_ID
            from orders
            where cust_ID = v_cid)
        group by p.prod_ID, p.prod_name
        order by avg(nvl(r.review_stars, 0)) desc
    ) loop
        --inserting a new recommendation into recommendation table 
        insert into recommendations values(rec_seq_id.nextval,v_cid,product_record.prod_ID,sysdate);
        --print a message that the table is updated
        dbms_output.put_line('Recommendations table updated with a new record');
        --exit the loop after recommending highest rated product in the category
        exit;
        end loop;
    end loop;
exception
--handle any exception
when others then
    --print SQL code and error message associated with it
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--20) List_Recommendations
--Provide a list of all the recommended products to the customer and its average rating.
--creating procedure list recommendations
create or replace procedure list_recommendations
as
--defining a cursor c1 to select customer names, recommend product names and average ratings
cursor c1 is select c.cust_fname, p.prod_name, avg(nvl(r.review_stars,0)) as avg_rating
from recommendations rec join customers c on rec.cust_id=c.cust_id
join products p on rec.rec_prodid=p.prod_id
left join reviews r on rec.rec_prodid=r.prod_id
group by c.cust_fname, p.prod_name;
--declaring record variable to store results from the cursor
rec1 c1%rowtype;
begin
--print a message toindicate recommendations is called
dbms_output.put_line('---------List recommendations procedure called---------');
--open the cursor c1
open c1;
--looping through the cursor c1
loop
--fetch a record from cursor c1 into record variable
fetch c1 into rec1;
exit when c1%notfound;
--print the customer name and recommended product
dbms_output.put_line('Customer Name: '||rec1.cust_fname||', Product Name: '||rec1.prod_name||
', Average Rating: '||rec1.avg_rating);
end loop;
--close the cursor the c1
close c1;
exception
--handle any exceptions 
when others then
    --print SQL code and error message associated with it
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--21) Income_By_state
-- Procedure to calculate and print the total income by state from sales.
-- It selects states with a total invoice amount greater than zero.
create or replace procedure income_by_state
as
cursor c1 is select c.cust_state, sum(i.invoice_amount)
from customers c, invoices i
where c.cust_id=i.cust_id
group by c.cust_state
having sum(i.invoice_amount)>0;
var_state customers.cust_state%type;
var_amount invoices.invoice_amount%type;
begin
dbms_output.put_line('---------Income by state procedure called---------');
open c1;
loop
fetch c1 into var_state, var_amount;
exit when c1%notfound;
dbms_output.put_line('State: '||var_state||', Total Amount of Purchases(in $): '||var_amount);
end loop;
close c1;
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--22) Best_Selling_Products
-- Procedure to list the best-selling products up to a specified number (v_num).
-- It sorts products by the total units sold in descending order.
create or replace procedure best_selling_products(v_num in number)
is
cursor c1 is select p.prod_name, pc.category_name, sum(o.order_quantity) as total_units_sold,
sum(i.invoice_amount) as total_amount_collected
from product_categories pc, products p, orders o, invoices i
where pc.category_id=p.category_id and p.prod_id=o.prod_id and o.order_id=i.order_id
group by p.prod_name, pc.category_name
order by total_units_sold desc;
rec1 c1%rowtype;
var_ordercount number;
begin
dbms_output.put_line('---------Best selling products procedure called---------');
var_orderCount := 0;
open c1;
loop
fetch c1 into rec1;
exit when c1%notfound or var_orderCount>v_num;
dbms_output.put_line('Product Name: '||rec1.prod_name||', Product Category: '||
rec1.category_name||', Total Number of Units Sold: '||rec1.total_units_sold||
', Total amount collected (in dollars): '||rec1.total_amount_collected);
var_orderCount:=var_orderCount+1;
end loop;
close c1;
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--23) Recommendation_Follow_Up:
-- Procedure to track and print the status of product recommendations for each customer.
-- It checks if the recommended products have been purchased.
create or replace procedure recommendations_follow_up
as
cursor c1 is select c.cust_fname, p.prod_name,
case
    when o.order_ID is not null then 'RECOMMENDATION FOLLOWED'
    else 'RECOMMENDATION NOT FOLLOWED YET'
end as rec_status
from recommendations rec join customers c on rec.cust_id =c.cust_id
join products p on rec.rec_prodid=p.prod_id
left join orders o on rec.rec_prodid=o.prod_id
and rec.cust_id=o.cust_id;
rec1 c1%rowtype;
begin
dbms_output.put_line('---------Recommendations follow up procedure called---------');
open c1;
loop
fetch c1 into rec1;
exit when c1%notfound;
dbms_output.put_line('Customer Name: '||rec1.cust_fname||', Product Name: '||rec1.prod_name||
', Recommendation Status: '||rec1.rec_status);
end loop;
close c1;
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--24) Products_Ordered_By_Time_Interval:
-- Procedure to report the number of units ordered and number of customers by product
-- within a given time interval (v_startDt to v_endDt).
create or replace procedure prod_ordered_by_time_interval(v_startDt in date, v_endDt in date)
as
cursor c1 is select p.prod_name, sum(o.order_quantity) as total_units_ordered,
count(distinct o.cust_id) as number_of_customers
from products p join orders o on p.prod_id=o.prod_id
where o.order_date between v_startDt and v_endDt
group by p.prod_name;
rec1 c1%rowtype;
begin
dbms_output.put_line('---------Products ordered by time interval procedure called---------');
open c1;
loop
fetch c1 into rec1;
exit when c1%notfound;
dbms_output.put_line('Product Name: '||rec1.prod_name||', Total Number of units ordered: '
||rec1.total_units_ordered||', Toal Number of customers ordered: '||rec1.number_of_customers);
end loop;
close c1;
exception
when others then
    dbms_output.put_line ('SQLCODE: ' || SQLCODE);
    dbms_output.put_line('Error: '||SQLERRM);
end;

--#################### TABLE STATUS BEFORE RUNNING ANONYMOUS BLOCK ##############################
select * from customers;
select * from product_categories;
select * from products;
select * from credit_cards;
select * from invoices;
select * from orders;
select * from reviews;
select * from recommendations;

--#################### ANONYMOUS BLOCK ##############################
begin

dbms_output.put_line('---------ANONYMOUS BLOCK called---------');

--Adding customers
add_customer('John','Heldom', 'Charloette','john@gmail.com', 'NC', '21338');
add_customer('Pranahith Babu','Yarra', 'Baltimore','pranahithbabu@gmail.com', 'MD', '21227');
add_customer('Jack','Luke', 'New York','jack@gmail.com', 'NY', '20904');
add_customer('Henry','Sih', 'Phoenix', 'henry@gmail.com','AZ', '20850');
add_customer('Buhen','Rov', 'Ellicott City','buhen@gmail.com', 'MD', '21043');
add_customer('Kevin','Jume', 'Columbia', 'kevin@gmail.com','SC', '21044');

--Adding credit cards
add_creditcard('john@gmail.com', '6564 6232 2313 1333', 1, 'DISCOVER', 2028, 10);
add_creditcard('pranahithbabu@gmail.com', '4954 5654 5465 4545', 2, 'VISA', 2029, 08);
add_creditcard('jack@gmail.com', '4265 6898 9656 5563', 3, 'VISA', 2030, 12);
add_creditcard('henry@gmail.com', '5438 2187 5453 4554', 4, 'MASTERCARD', 2028, 10);
add_creditcard('buhen@gmail.com', '3465 6665 6663 2313', 5, 'AMEX', 2031, 10);
add_creditcard('kevin@gmail.com', '3746 9847 4646 4979', 6, 'AMEX', 2028, 10);

--Displays list of customers in MD(Maryland).
show_all_customers_in_state('MD');

--Displays the cards that expire within 2 months window of below fiven date.
report_cards_expire(to_date('2028-10-01','YYYY-MM-DD'));

--Adding product categories
add_category('Clothing', 'Wide range of appareal suitable for daily wear');
add_category('Electronics','Smartphone,tablets,Computers and laptops');
add_category('Grocery', 'One step destination for essential food supplies');
add_category('Furniture', 'Transform your living space with our furniture collection');

--Adding products
Add_Product('40inchTV', 30, 250, 2, 'Electronics');
Add_Product('T-shirt', 100, 20, 1, 'Clothing');
Add_Product('Sofa', 20, 2000, 4, 'Furniture');
Add_Product('Milk', 100, 5, 3, 'Grocery');
Add_Product('Hoodie', 50, 30, 1, 'Clothing');
Add_Product('Chocolates', 200, 10, 3, 'Grocery');
Add_Product('Laptop', 100, 800, 2, 'Electronics');
Add_Product('Table', 70, 60, 4, 'Furniture');

--Updates inventory after removal of 5units.
update_inventory(1, 5);

--Displays the list of inventory.
report_inventory;

--Places the order based on given input.
place_order('pranahithbabu@gmail.com','Sofa',1,'4954 5654 5465 4545',sysdate);
place_order('kevin@gmail.com','Chocolates',50,'3746 9847 4646 4979',sysdate);
place_order('henry@gmail.com','Table',3,'5438 2187 5453 4554',sysdate);
place_order('john@gmail.com','40inchTV',2,'6564 6232 2313 1333',sysdate);
place_order('jack@gmail.com','Milk',2,'4265 6898 9656 5563',sysdate);
place_order('buhen@gmail.com','Hoodie',2,'3465 6665 6663 2313',sysdate);

--Displays the list of orders placed.
show_orders;

--Show the order based on the given state.
report_orders_by_state('NC');

--Displays the list of customers who placed order worth more than below given amount.
report_best_customers(1500);

--Displays the values of charges incured towards each credit card type.
payments_to_cc;

--Shows the least spent customers.
thrifty_customer(4);

--Adding reviews
add_review('john@gmail.com',2, '40inchTV','Not a great product. Look out for required features before purchasing');
add_review('pranahithbabu@gmail.com',5,'Sofa', 'Excellent. A great reliable product');
add_review('kevin@gmail.com',5 ,'Chocolates', 'Best for gifting');
add_review('henry@gmail.com',4,'Table', 'Good and sturdy, useful for office setup');
add_review('jack@gmail.com',1,'Milk', 'Do not buy, this product is most of the time near to expiry date');
add_review('buhen@gmail.com',5,'Hoodie', 'Very comfortable and affordable price, worth buying');

--Lists the top and bottom number of people based on their orders.
buy_or_beware(7);

--Adding recommendations.
recommend_to_customer(2);
recommend_to_customer(5);
recommend_to_customer(3);
recommend_to_customer(1);
recommend_to_customer(4);

--Lists the recommendations given.
list_recommendations;

--Displays the income generated through orders by each state.
income_by_state;

--Lists the best selling products based on their reviews.
best_selling_products(3);

--Placing an order again to show whether the given recommendation is followed or not.
place_order('pranahithbabu@gmail.com','Table',2,'4954 5654 5465 4545',sysdate);

--Checks whether customer followed the recommendation or not.
recommendations_follow_up;

--Displays the list of orders placed in a given time interval.
prod_ordered_by_time_interval(to_date('2023-12-12', 'YYYY-MM-DD'), to_date('2023-12-20', 'YYYY-MM-DD')); --Change the dates based on your execution time

--Restocks the inventory.(It is different from update inventory by incrementing the quantity).
restock_inventory('Laptop',10);

dbms_output.put_line('---------ANONYMOUS BLOCK ends---------');

end;

--#################### TABLE STATUS AFTER RUNNING ANONYMOUS BLOCK ##############################
select * from customers;
select * from product_categories;
select * from products;
select * from credit_cards;
select * from invoices;
select * from orders;
select * from reviews;
select * from recommendations;
--#################### THE END ##############################