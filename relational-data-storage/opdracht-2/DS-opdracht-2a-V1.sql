-- Analyseer de data kwaliteit
-- Maak een rapport van je bevindingen
-- Beschrijf de stappen die je moet zetten om de data integriteit op een acceptabel niveau te krijgen
-- Hanteer de bekende Naming Conventions voor je rapport
-- Maak een SQL script dat foreign key constraint die bij deze database horen verwijderd en vervolgens weer aanmaakt
-- Noem de file: 'DS-opdracht-2a-VN.sql' waarbij N staat staat voor de versie van je scriptCommit en push je werk naar Github

---------------------------------------------
----------- W3SCHOOLS INFORMATION ----------- 

-- SQL NULL Values

A field with a NULL value is a field with no value.
If a field in a table is optional, it is possible to insert a new record or update a record without adding a value to this field.
Then, the field will be saved with a NULL value.

-- How to Test for NULL Values?
It is not possible to test for NULL values with comparison operators, such as =, <, or <>.

We will have to use the IS NULL and IS NOT NULL operators instead.
The IS NULL operator is used to test for empty values (NULL values).
The IS NOT NULL operator is used to test for non-empty values (NOT NULL values).

-- IS NULL Syntax
SELECT column_names
FROM table_name
WHERE column_name IS NULL;

-- IS NOT NULL Syntax
SELECT column_names
FROM table_name
WHERE column_name IS NOT NULL;

-- ALTER TABLE - RENAME COLUMN

To rename a column in a table, use the following syntax:

ALTER TABLE table_name
RENAME COLUMN old_name to new_name;

-- ALTER TABLE - ADD FOREIGN KEY
https://www.w3schools.com/sql/sql_foreignkey.asp

ALTER TABLE table1_name
ADD CONSTRAINT foreignkey_table1
FOREIGN KEY (designated foreignkey column table1)
REFERENCES table2_name (primarykey table2);

----------------------------------------------
-------------- ADD FOREIGN KEYS --------------

---------------- OPDRACHT 2 ------------------

-- In table mhl_districts missing FK country_ID (mhl_countries):
ALTER TABLE mhl_districts ADD CONSTRAINT country_ID FOREIGN KEY (country_ID) REFERENCES mhl_countries (id);
SUCCESS! 
-----------------------

-- In table mhl_communes missing FK district_ID (mhl_districts):
ALTER TABLE mhl_communes ADD CONSTRAINT district_ID FOREIGN KEY (district_ID) REFERENCES mhl_districts (id);
SUCCESS! 
-----------------------

-- In table mhl_cities missing FK commune_ID (mhl_communes):
ALTER TABLE mhl_cities ADD CONSTRAINT commune_ID FOREIGN KEY (commune_ID) REFERENCES mhl_communes (id);
FAILED 
#1452 - Cannot add or update a child row: a foreign key constraint fails (`mhl`.`#sql-6ac_559`, CONSTRAINT `commune_ID` FOREIGN KEY (`commune_ID`) REFERENCES `mhl_communes` (`id`))

-- Thoughts to find false data
SELECT commune_ID FROM mhl_cities WHERE commune_ID IS NULL; --empty result set (zero rows)
SELECT id FROM mhl_communes WHERE id IS NULL; --empty result set (zero rows)

-- This selects all rows with the same data, that's not what I need.
SELECT mhl_cities.*, mhl_communes.* FROM mhl_cities INNER JOIN mhl_communes ON mhl_cities.commune_ID = mhl_communes.id;

-- TRY:
-- This selects all rows where the commune_id from mhl_cities is not present in the mhl_communes ID row:
SELECT commune_ID FROM mhl_cities WHERE commune_ID NOT IN (SELECT ID FROM mhl_communes);
SUCCESS! results: 755 and 0

-- Create a new table with false data from mhl_cities
CREATE TABLE data_cities_communes
SELECT * FROM mhl_cities 
WHERE commune_ID = 755 OR commune_ID = 0;

-- Delete false data from mhl_cities
DELETE FROM mhl_cities
WHERE commune_ID = 755 OR commune_ID = 0; 
(215 rows affected)

-- Try FK again
ALTER TABLE mhl_cities ADD CONSTRAINT commune_ID FOREIGN KEY (commune_ID) REFERENCES mhl_communes (id);
SUCCESS!
-----------------------

-- in table mhl_detaildefs missing FK group_id (mhl_detailgroups):
ALTER TABLE mhl_detaildefs ADD CONSTRAINT group_id FOREIGN KEY (group_ID) REFERENCES mhl_detailgroups (id);
SUCCESS!
-----------------------

-- in table mhl_detaildefs missing FK propertytype_id (mhl_propertytypes):
ALTER TABLE mhl_detaildefs ADD CONSTRAINT propertytype_ID FOREIGN KEY (propertytype_ID) REFERENCES mhl_propertytypes (id);
FAILED
#1452 - Cannot add or update a child row: a foreign key constraint fails (`mhl`.`#sql-6ac_5e9`, CONSTRAINT `propertytype_ID` FOREIGN KEY (`propertytype_ID`) REFERENCES `mhl_propertytypes` (`id`))

-- geplaatste foreign key in mhl_detaildefs komt niet overeen met de propertytype_ID
Data is incompleet, vandaar dat foreign key niet werkt. 

-- Foreign key verwijderen:
ALTER TABLE mhl_detaildefs
DROP FOREIGN KEY propertytype_ID;
FAILED
#1091 - Cant DROP propertytype_ID; check that column/key exists

-- Dan eerst data controleren:
SELECT propertytype_ID FROM mhl_detaildefs WHERE propertytype_ID NOT IN (SELECT ID FROM mhl_propertytypes);
(18 rows)

-- Nieuwe tabel met false data:
CREATE TABLE data_detaildefs_propertytypes
SELECT * FROM mhl_detaildefs 
WHERE propertytype_ID NOT IN (SELECT ID FROM mhl_propertytypes);

-- Delete false data from mhl_detaildefs:
DELETE FROM mhl_detaildefs
WHERE propertytype_ID NOT IN (SELECT ID FROM mhl_propertytypes);
(18 rows affected)

-- Checking relations in table mhl_detaildefs:
Only shows group_id as a FK, not the propertytype_ID. Although it shows in the structure that propertytype_ID should be a FK.

-- Had to drop propertytype_ID INDEX (table structures -> go below first table -> INDEXES) to be able to create a new FK

---!!! TIP: use FK_ before constraints to show the constraint is about a foreign key.
-----------------------

-- in table mhl_suppliers missing FK city_ID (mhl_cities):
ALTER TABLE mhl_suppliers ADD CONSTRAINT city_ID FOREIGN KEY (city_ID) REFERENCES mhl_cities (id);
FAILED
#1452 - Cannot add or update a child row: a foreign key constraint fails (`mhl`.`#sql-32c_47`, CONSTRAINT `city_ID` FOREIGN KEY (`city_ID`) REFERENCES `mhl_cities` (`id`))

-- This selects all rows where the city_id from mhl_suppliers is not present in the mhl_cities ID row:
SELECT city_ID FROM mhl_suppliers WHERE city_ID NOT IN (SELECT ID FROM mhl_cities);
SUCCES! 241 rows with different IDS

-- Create a new table with false data from mhl_suppliers
CREATE TABLE data_suppliers_cities
SELECT * FROM mhl_suppliers
WHERE city_id NOT IN (SELECT ID FROM mhl_cities);

-- Delete false data from mhl_suppliers
DELETE FROM mhl_suppliers
WHERE city_id NOT IN (SELECT ID FROM mhl_cities);
(241 rows affected)

-- Try FK again:
ALTER TABLE mhl_suppliers ADD CONSTRAINT city_ID FOREIGN KEY (city_ID) REFERENCES mhl_cities (id);
SUCCESS!
-----------------------

-- in table mhl_suppliers missing FK p_city_ID (mhl_cities):
ALTER TABLE mhl_suppliers ADD CONSTRAINT p_city_ID FOREIGN KEY (p_city_ID) REFERENCES mhl_cities (id);
FAILED
#1452 - Cannot add or update a child row: a foreign key constraint fails (`mhl`.`#sql-32c_4f`, CONSTRAINT `p_city_ID` FOREIGN KEY (`p_city_ID`) REFERENCES `mhl_cities` (`id`))

-- select rows of p_city_ID
SELECT p_city_ID FROM mhl_suppliers WHERE p_city_ID NOT IN (SELECT ID FROM mhl_cities);

-- selects the distinct rows of p_city_id
SELECT DISTINCT p_city_ID FROM mhl_suppliers WHERE p_city_ID NOT IN (SELECT ID FROM mhl_cities);

-- create a new table with false data from mhl_suppliers
CREATE TABLE data_suppliers_pcityid
SELECT * FROM mhl_suppliers
WHERE p_city_ID NOT IN (SELECT ID FROM mhl_cities);
6908

-- delete false data from mhl_suppliers
DELETE FROM mhl_suppliers
WHERE p_city_ID NOT IN (SELECT ID FROM mhl_cities);
6908 rows affected

-- did not see the new table. Had to delete table mhl_suppliers and create table anew along with inserting the data from mhl.sql (opened in mysql workbench)

-- Try FK again:
ALTER TABLE mhl_suppliers ADD CONSTRAINT p_city_ID FOREIGN KEY (p_city_ID) REFERENCES mhl_cities (id);
SUCCESS!
-----------------------

-- in table mhl_suppliers missing FK membertypes (mhl_membertypes):
ALTER TABLE mhl_suppliers ADD CONSTRAINT membertype FOREIGN KEY (membertype) REFERENCES mhl_membertypes (id);
FAILED
#1452 - Cannot add or update a child row: a foreign key constraint fails (`mhl`.`#sql-32c_591`, CONSTRAINT `membertype` FOREIGN KEY (`membertype`) REFERENCES `mhl_membertypes` (`id`))

-- select rows in mhl_suppliers which do not occur in mhl_membertypes:
SELECT membertype FROM mhl_suppliers WHERE membertype NOT IN (SELECT ID FROM mhl_membertypes);
returns: membertype = 0

-- create table to refer false data to:
CREATE TABLE data_suppliers_membertypes
SELECT * FROM mhl_suppliers
WHERE membertype NOT IN (SELECT ID FROM mhl_membertypes);

-- delete false data from table mhl_suppliers:
DELETE FROM mhl_suppliers
WHERE membertype NOT IN (SELECT ID FROM mhl_membertypes);
3 rows affected.

-- try FK again:
ALTER TABLE mhl_suppliers ADD CONSTRAINT membertype FOREIGN KEY (membertype) REFERENCES mhl_membertypes (id);
SUCCESS
-----------------------