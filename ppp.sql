drop table Shipment_order;
drop table transport_agency;
drop table customers;

--creation of transport_agency table
create table transport_agency(
Agency_id number(5) NOT NULL,
Agency_name varchar(30),
Other_details varchar(20)
);

alter table transport_agency add constraint transport_pk primary key(Agency_id);

--creation of customers table
create table customers(
customer_id number(6),
customer_name varchar(30),
penalty_charge number(20),
shipmentfrom_add varchar(70)
);
alter table customers add constraint customers_pk primary key(customer_id,shipmentfrom_add);

--creation of Shipment_order table
create table Shipment_order(
Order_id number(7),
shipmentto_add varchar(70),
Agency_id number(5),
customer_id number(6),
shipmentfrom_add varchar(70),
dates date
);
alter table Shipment_order add constraint shipment_pk primary key(Order_id);
alter table Shipment_order add constraint shipment_fkA foreign key(Agency_id) references transport_agency(Agency_id);
alter table Shipment_order add constraint ship_fkB foreign key(customer_id,shipmentfrom_add) references customers(customer_id,shipmentfrom_add);


--insertion into transport_agency table
insert into transport_agency values(11034,'BOGRA','Uposhohor');
insert into transport_agency values(11035,'KHULNA','Teligati');
insert into transport_agency values(11036,'DHAKA','Gulshan');
insert into transport_agency values(11037,'BOGRA','Fulbari');
insert into transport_agency values(11038,'PONCHOGOR','Uttara');
insert into transport_agency values(11039,'PONCHOGORa','Uttaraa');

--insertion into customers table
insert into customers values(223345,'Toufiq',2000,'Chittagong');
insert into customers values(223346,'Rahim',1000,'Dhaka');
insert into customers values(223347,'Karim',900,'Rangpur');
insert into customers values(223348,'Nura',700,'Rahimganj');
insert into customers values(223349,'Imtiaz',100,'Rohomotpur');
insert into customers values(223350,'Imtiazs',100,'Rohomotpura');

insertion into Shipment_order table
insert into Shipment_order values(5566778,'Dhaka',11034,223345,'Chittagong','19-JUN-2015');
insert into Shipment_order values(5566779,'Chadpur',11035,223346,'Dhaka','19-JUN-2016');
insert into Shipment_order values(5566780,'Rosulpur',11036,223347,'Rangpur','29-JUN-2016');
insert into Shipment_order values(5566781,'Rahamatgonj',11037,223348,'Rahimganj','30-JUN-2016');
insert into Shipment_order values(5566782,'Rosulpur',11038,223349,'Rohomotpur','29-JUL-2016');

savepoint cont1;


describe transport_agency;
describe customers;
describe Shipment_order;



-- Aggregate functions section starts here
select count(customer_id) from customers;
select count(Order_id) from Shipment_order where Order_id>5566778;
select count(Order_id) as TotalOrders from Shipment_order;
select avg(penalty_charge) from customers;
select max(penalty_charge) from customers;
select min(penalty_charge) from customers;



--sub query section starts here
select t.Agency_id,t.Agency_name 
from transport_agency t
where t.Agency_id in
(select s.Agency_id 
from Shipment_order s,customers c 
where s.customer_id=c.customer_id
AND c.penalty_charge >50);

select Agency_id,Agency_name 
from transport_agency
UNION ALL 
select t.Agency_id,t.Agency_name 
from transport_agency t
where t.Agency_id in
(select s.Agency_id 
from Shipment_order s,customers c 
where s.customer_id=c.customer_id
AND c.penalty_charge >50);







--set operation starts here
select c.customer_id,c.shipmentfrom_add from customers c 
union all select s.customer_id,s.shipmentfrom_add from Shipment_order s where s.Agency_id in(select Agency_id from transport_agency where Agency_id>11034);

select c.customer_id,c.shipmentfrom_add from customers c 
union select s.customer_id,s.shipmentfrom_add from Shipment_order s where s.Agency_id in(select Agency_id from transport_agency where Agency_id>11034);

select c.customer_id,c.shipmentfrom_add from customers c 
intersect select s.customer_id,s.shipmentfrom_add from Shipment_order s where s.Agency_id in(select Agency_id from transport_agency where Agency_id>11034);

select c.customer_id,c.shipmentfrom_add from customers c 
minus select s.customer_id,s.shipmentfrom_add from Shipment_order s where s.Agency_id in(select Agency_id from transport_agency where Agency_id>11034);



--join operation starts here
select c.customer_name,s.order_id from customers c join Shipment_order s on c.customer_id=s.customer_id;
select c.customer_name,s.order_id from customers c natural join Shipment_order s;
select c.customer_name,s.order_id from customers c join Shipment_order s using(customer_id);
select c.customer_name,s.order_id from customers c cross join Shipment_order s ;
select c.customer_name,s.order_id from 
customers c left outer join Shipment_order s on c.customer_id=s.customer_id;



rollback to cont1;



--the pl/sql section satrts here

set serveroutput on;
declare
c_name customers.customer_name%type:='Rahim';
c_id1 customers.customer_id%type:='223346';
c_id2 customers.customer_id%type;
begin 
select customer_id into c_id2 from customers where customer_name=c_name;
if c_id1=c_id2 then
             dbms_output.put_line('User found in database');
else
    dbms_output.put_line('User not found in database');
end if;
end;
/
show errors;




set serveroutput on;
declare   
customer_no customers.customer_id%type;
begin
	SELECT count(customer_id) INTO customer_no FROM customers;
	DBMS_OUTPUT.PUT_LINE('The number of customer is : ' || customer_no);
end;
/
show errors;


-- Example of simple loop operation using cursor
set serveroutput on
declare
	cursor customers_cur is select customer_name, customer_id from customers;
	customers_record customers_cur%ROWTYPE;
begin
	OPEN customers_cur;
	LOOP
		FETCH customers_cur INTO customers_record;
		EXIT WHEN customers_cur%ROWCOUNT > 2;
		DBMS_OUTPUT.PUT_LINE('Customer name : ' || customers_record.customer_name || ' & ' || 'customer id : ' || customers_record.customer_id);
	END LOOP;
	CLOSE customers_cur;
end;
/	
show errors;


drop table cus_audit;

CREATE TABLE cus_audit(
	new_cid number(6),
	new_c_name varchar2(30),
	old_c_name varchar2(30),
	entry_date varchar2(30),
	action varchar2(30)
);


-- Trigger for customers table

set serveroutput on
CREATE OR REPLACE TRIGGER CustomerAudit
BEFORE INSERT OR DELETE OR UPDATE ON customers
FOR EACH ROW  

BEGIN

  IF INSERTING THEN
  INSERT INTO cus_audit(new_c_name, old_c_name, new_cid, entry_date, action) VALUES(:NEW.customer_name, Null, :NEW.customer_id, TO_CHAR(sysdate, 'DD/MON/YYYY HH24:MI:SS'), 'Insert');
  ELSIF DELETING THEN
  INSERT INTO cus_audit(new_c_name, old_c_name, new_cid, entry_date, action) VALUES(NULL, :OLD.customer_name, :OLD.customer_id, TO_CHAR(sysdate, 'DD/MON/YYYY HH24:MI:SS'), 'Delete');
  ELSIF UPDATING THEN
  INSERT INTO cus_audit(new_c_name, old_c_name, new_cid, entry_date, action) VALUES(:NEW.customer_name, :OLD.customer_name, :NEW.customer_id, TO_CHAR(sysdate, 'DD/MON/YYYY HH24:MI:SS'), 'Update');
  END IF;
END;
/


--another trigger on customers table

set serveroutput on 
CREATE OR REPLACE TRIGGER check_due BEFORE INSERT OR UPDATE ON customers
FOR EACH ROW
DECLARE
   c_min constant number(8,2) := 100.0;
   c_max constant number(8,2) := 2000.0;
BEGIN
  IF :new.penalty_charge < c_min THEN
  RAISE_APPLICATION_ERROR(-20000,'due is too small');
  ELSIF :new.penalty_charge > c_max THEN
  RAISE_APPLICATION_ERROR(-20000,'due is too big');
END IF;
END;
/


-- Example of PL/SQL FUNCTION

CREATE OR REPLACE FUNCTION max_due RETURN NUMBER IS
   max_due customers.penalty_charge%TYPE;
BEGIN
  SELECT MAX(penalty_charge) INTO max_due FROM customers;
  RETURN max_due;
END;
/

SET SERVEROUTPUT ON
BEGIN
dbms_output.put_line('customers Max due: ' || max_due);
END;
/


-- Example of PL/SQL PROCEDURES with parameter
set serveroutput on
CREATE OR REPLACE PROCEDURE add_customer (
  cid customers.customer_id%TYPE,
  cname customers.customer_name%TYPE,
  ccharge customers.penalty_charge%TYPE,
  cshipment customers.shipmentfrom_add%TYPE ) IS
BEGIN
  INSERT INTO customers(customer_id, customer_name, penalty_charge, shipmentfrom_add) VALUES(cid, cname, ccharge, cshipment);
  COMMIT;
END add_customer;
/
SHOW ERRORS

BEGIN
   add_customer(223350,'Sakib',560,'Sirajgonj');
END;
/

--using sequence for auditing on transport_agency table
DROP SEQUENCE a;
CREATE SEQUENCE a
MINVALUE 0
START WITH 1
INCREMENT BY 1;


drop table transporta;
create table transporta(
num number(4),
Agency_id number(5) NOT NULL,
Agency_name varchar(30),
Other_details varchar(20),
datees DATE DEFAULT SYSDATE
);


CREATE OR REPLACE TRIGGER transport_agency_audit
AFTER INSERT OR DELETE ON transport_agency
FOR EACH ROW
DECLARE

BEGIN
	IF INSERTING THEN
		INSERT INTO transporta (num,Agency_id, Agency_name, Other_details) 
		VALUES (a.nextval,:NEW.Agency_id, :NEW.Agency_name, :NEW.Other_details);
	ELSIF UPDATING THEN
		INSERT INTO transporta (Agency_id, Agency_name, Other_details,datees)
		VALUES (:NEW.Agency_id, :NEW.Agency_name, :NEW.Other_details,sysdate);
	
	END IF;
	
END;
/
