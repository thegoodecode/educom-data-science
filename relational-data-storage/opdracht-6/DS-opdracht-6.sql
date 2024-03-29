-- 6.1.1 Selecteer uit de hitcount-tabel het aantal leveranciers en totale hitcount per maand (display de nederlandse naam van de maand), gesorteerd per jaar en maand.

-- mhl_hitcount: [supplier_ID, year, month, hitcount]

SELECT
mhl_hitcount.year AS jaar,

CASE
WHEN mhl_hitcount.month = '1'
THEN 'januari'
WHEN mhl_hitcount.month = '2'
THEN 'februari'
WHEN mhl_hitcount.month = '3'
THEN 'maart'
WHEN mhl_hitcount.month = '4'
THEN 'april'
WHEN mhl_hitcount.month = '5'
THEN 'mei'
WHEN mhl_hitcount.month = '6'
THEN 'juni'
WHEN mhl_hitcount.month = '7'
THEN 'juli'
WHEN mhl_hitcount.month = '8'
THEN 'augustus'
WHEN mhl_hitcount.month = '9'
THEN 'september'
WHEN mhl_hitcount.month = '10'
THEN 'oktober'
WHEN mhl_hitcount.month = '11'
THEN 'november'
WHEN mhl_hitcount.month = '12'
THEN 'december'
END AS maand,

COUNT(supplier_ID) AS aantal_leveranciers,
SUM(mhl_hitcount.hitcount) AS totaal_hitcounts

FROM
mhl_hitcount

GROUP BY year, month
ORDER BY year, month


---------------------------------------------------------------------------------------------------------------------------------------


-- 6.1.2 Selecteer alle Nederlandse gemeentes, de leveranciersnaam, de totale hitcount en de gemiddelde hitcount van de betreffende gemeente, van die leveranciers die een hogere hitcount hebben dan dat gemiddelde, gesorteerd op het verschil (totaal ten opzichte van gemiddelde) in aflopende volgorde.

-- Gemeentes: mhl_communes: [id, district_ID, name]
-- NEDERLANDSE gemeentes: mhl_districts [ID, country_ID, name, display_order]
-- Landen: mhl_countries [ID, code, name, display]
-- Leveranciersnaam: mhl_suppliers: [ID, membertype, company, name, straat, huisnr, postcode, city_ID, p_address, p_postcode, p_city_ID]
-- Totale hitcount: mhl_hitcount: [supplier_ID, year, month, hitcount]
-- Gemiddelde hitcount: mhl_hitcount: [supplier_ID, year, month, hitcount]
-- Per gemeente
-- Van leveranciers die een hogere hitcount hebben dan gemiddeld
-- Gesorteerd op het verschil (total ten opzichte van gemiddelde) 
--in aflopende volgorde


SELECT
mhl_communes.name AS gemeente,
mhl_suppliers.name AS leverancier,
SUM(mhl_hitcount.hitcount) AS total_hitcount,
AVG(mhl_hitcount.hitcount) AS average_hitcount

FROM
mhl_suppliers

INNER JOIN
mhl_cities 
ON mhl_cities.ID = mhl_suppliers.city_ID

INNER JOIN
mhl_communes
ON mhl_communes.ID = mhl_cities.commune_ID

INNER JOIN
mhl_districts
ON mhl_districts.ID = mhl_communes.district_ID

INNER JOIN
mhl_countries
ON mhl_countries.ID = mhl_districts.country_ID

INNER JOIN
mhl_hitcount
ON mhl_hitcount.supplier_ID = mhl_suppliers.ID

WHERE mhl_countries.name = 'Nederland'

GROUP BY gemeente, leverancier

HAVING SUM(mhl_hitcount.hitcount) > AVG(mhl_hitcount.hitcount)

ORDER BY gemeente ASC, (SUM(mhl_hitcount.hitcount)-AVG(mhl_hitcount.hitcount))
DESC;

-- different results in average_hitcount in comparison to the given solution :
-- SELECT a.gemeente, b.leverancier, b.total_hitcount, a.average_hitcount
-- FROM (
--     SELECT g.id, l.name AS leverancier, SUM(h.hitcount) AS total_hitcount
--   FROM mhl_suppliers l
--   INNER JOIN mhl_cities p ON l.city_ID=p.id
--   INNER JOIN mhl_communes g ON p.commune_ID=g.id
--   INNER JOIN mhl_districts d ON g.district_ID=d.id
--   INNER JOIN mhl_hitcount h ON h.supplier_ID=l.id
--   WHERE d.country_ID= (
--         SELECT id
--         FROM mhl_countries
--         WHERE name='Nederland')
--         GROUP BY g.id, l.name 
--     ) AS b
-- INNER JOIN (
--     SELECT g.id, AVG(h.hitcount) AS average_hitcount, g.name AS gemeente
--     FROM mhl_hitcount h
--     INNER JOIN mhl_suppliers l ON h.supplier_ID=l.id
--     INNER JOIN mhl_cities p ON l.city_ID=p.id
--     INNER JOIN mhl_communes g ON p.commune_ID=g.id
--     INNER JOIN mhl_districts d ON g.district_ID=d.id
--     WHERE d.country_ID = (
--         SELECT id
--         FROM mhl_countries
--         WHERE name='Nederland'
--     ) 
--     GROUP BY g.id
--     ) AS a ON a.id=b.id
-- GROUP BY a.id, b.leverancier
-- HAVING b.total_hitcount > a.average_hitcount
-- ORDER BY a.gemeente, (b.total_hitcount-a.average_hitcount) DESC


---------------------------------------------------------------------------------------------------------------------------------------


-- 6.1.3 Selecteer alle rubrieknamen en het aantal leveranciers in die rubriek

hitcount: mhl_hitcount: [supplier_ID, year, month, hitcount]
rubrieken: mhl_rubrieken: [ID, parent, display_order, name]
mhl_suppliers_mhl_rubriek_view: [ID, mhl_suppliers_id, mhl_rubriek_view_id]
mhl_suppliers: [ID, membertype, company, name, straat, huisnr, postcode, city_ID, p_address, p_postcode, p_city_ID]


SELECT 
mhl_rubrieken.name
SUM(DISTINCT mhl_suppliers.ID)

FROM 


CREATE OR REPLACE VIEW rubrieken AS
    SELECT
        IFNULL(rc.id, rp.id) as id,
        IF(ISNULL(rp.name), rc.name, CONCAT(rp.name, ' - ', rc.name)) AS rubriek,
        IFNULL(rp.name, rc.name) AS hoofdrubriek,
        IF(ISNULL(rp.name), ' ', rc.name) AS subrubriek
    FROM mhl_rubrieken rp
    RIGHT OUTER JOIN mhl_rubrieken rc ON rc.parent = rp.id
    ORDER BY Rubriek

SELECT
    rubrieken.rubriek,
    (SELECT COUNT(mhl_suppliers_ID)
     FROM mhl_suppliers_mhl_rubriek_view
     WHERE mhl_rubriek_view_ID = rubrieken.id) AS numsup
FROM rubrieken
ORDER BY rubriek


---------------------------------------------------------------------------------------------------------------------------------------


-- 6.1.4 Selecteer de totale hitcount per rubriek met 'Geen hits' als een rubriek geen hitcount kent.


---------------------------------------------------------------------------------------------------------------------------------------


-- 6.2.1 Selecteer het ID en de joindate (in 'EUR' datumformaat) van de leveranciers die in de laatste 7 dagen van de maand lid zijn geworden.

-- mhl_suppliers.ID
-- mhl_suppliers.joindate (in europese datum notering) DATE_FORMAT(CURDATE(), '%m/%d/%Y')
-- van de leveranciers die in de laatste 7 dagen van de maand lid zijn geworden

SELECT 
DATE_FORMAT(CURDATE(), '%d/%m/%Y'),
mhl_suppliers.ID

FROM mhl_suppliers

ORDER BY mhl_suppliers.joindate DESC
OFFSET 0 ROWS
FETCH NEXT 7 ROWS ONLY;

----- fail

SELECT 
mhl_suppliers.ID,

DATE_FORMAT(mhl_suppliers.joindate, '%m/%d/%Y') AS joindate

FROM 
mhl_suppliers

WHERE joindate >= 7DAYSBEFORELASTDAYOFTHEMONTH AND joindate <= LASTDAYOFTHEMONTH

----->

SELECT mhl_suppliers.ID,
DATE_FORMAT(mhl_suppliers.joindate, '%d/%m/%Y') AS joindate 

FROM mhl_suppliers 

WHERE DAY(LAST_DAY(mhl_suppliers.joindate)) - DAY(mhl_suppliers.joindate) <= 7 

ORDER BY 
YEAR(mhl_suppliers.joindate), 
MONTH(mhl_suppliers.joindate), 
DAY(mhl_suppliers.joindate);


---------------------------------------------------------------------------------------------------------------------------------------


-- 6.2.2 Selecteer het ID, de joindate en het aantal dagen dat ze vandaag lid zijn, oplopend gesorteerd naar het aantal dagen lid.

SELECT
mhl_suppliers.ID AS ID,
mhl_suppliers.joindate AS joindate,
DATEDIFF(NOW(), joindate) AS aantal_dagen_lid

FROM
mhl_suppliers

ORDER BY
aantal_dagen_lid ASC;


---------------------------------------------------------------------------------------------------------------------------------------


-- 6.2.3. Selecteer de naam van de dag en het aantal leveranciers dat op die dag lid geworden is.


SELECT

COUNT(DISTINCT mhl_suppliers.ID) AS aantal_leveranciers,
DAYNAME(mhl_suppliers.joindate)AS day_of_the_week

FROM 
mhl_suppliers

GROUP BY DAYNAME(mhl_suppliers.joindate)
ORDER BY
FIELD(day_of_the_week,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday' )
;


---------------------------------------------------------------------------------------------------------------------------------------

--6.2.4 Selecteer het aantal leveranciers dat lid is geworden per jaar en per maandnaam.

SELECT

COUNT(DISTINCT mhl_suppliers.ID) AS aantal_leveranciers,
MONTHNAME(mhl_suppliers.joindate) AS maand,
YEAR(mhl_suppliers.joindate) AS jaar

FROM 
mhl_suppliers

GROUP BY  
YEAR(mhl_suppliers.joindate),
MONTH(mhl_suppliers.joindate),
maand

ORDER BY
YEAR(mhl_suppliers.joindate),
MONTH(mhl_suppliers.joindate)
;


---------------------------------------------------------------------------------------------------------------------------------------


-- 6.3.1 Selecteer alle plaatsnamen met uppercase van de eerste letter.

SELECT

mhl_cities.name AS plaatsnaam,
CONCAT(UPPER(LEFT(mhl_cities.name,1)), LOWER(RIGHT(mhl_cities.name,LENGTH(mhl_cities.name)-1))) AS nette_plaatsnaam

FROM mhl_cities

ORDER BY plaatsnaam

---- de plaatsnamen met een ' vooraan kregen geen hoofdletter. In search bar zoeken naar name LIKE ' krijgt geen resultaten, ook niet op 't of 's. 

-- SELECT * FROM mhl_cities WHERE mhl_cities.name LIKE '\'%'; (CHATGPT answer after trial and error)

SELECT 
    mhl_cities.name AS plaatsnaam,
    CASE
        WHEN mhl_cities.name LIKE ''\''%'' THEN CONCAT(LOWER(SUBSTRING(mhl_cities.name, 1, 2)), UPPER(SUBSTRING(mhl_cities.name, 4, 1)))
        ELSE CONCAT(UPPER(LEFT(mhl_cities.name,1)), LOWER(RIGHT(mhl_cities.name,LENGTH(mhl_cities.name)-1)))
    END AS nette_plaatsnaam
FROM mhl_cities
ORDER BY plaatsnaam;
---- IN VSCODE " '\'%'  " Cannot be shown properly to add comments like this after the code so I had to do '' instead of '
---- This line of code shows 's en 't in Lowercase letters, the 4 character in uppercase but the _ in between is gone. 

SELECT 
    mhl_cities.name AS plaatsnaam,
    CASE
        WHEN mhl_cities.name LIKE ''\''%'' THEN CONCAT(LOWER(SUBSTRING(mhl_cities.name, 1, 2)), UPPER(SUBSTRING(mhl_cities.name, 3, 2)))
        ELSE CONCAT(UPPER(LEFT(mhl_cities.name,1)), LOWER(RIGHT(mhl_cities.name,LENGTH(mhl_cities.name)-1)))
    END AS nette_plaatsnaam
FROM mhl_cities
ORDER BY plaatsnaam;

----Shows the 's and 't in Lowercase, the _ and the fourth character in Uppercase

SELECT 
mhl_cities.name AS plaatsnaam,
CASE
WHEN mhl_cities.name LIKE ''\''%'' THEN CONCAT(LOWER(SUBSTRING(mhl_cities.name, 1, 2)), UPPER(SUBSTRING(mhl_cities.name, 3, 2)), LOWER(SUBSTRING(mhl_cities.name, 5)))
ELSE CONCAT(UPPER(LEFT(mhl_cities.name,1)), LOWER(RIGHT(mhl_cities.name,LENGTH(mhl_cities.name)-1)))
END AS nette_plaatsnaam
FROM mhl_cities
ORDER BY plaatsnaam;
                                                                                    
---- For the sake of being able to write comments, '\'%' is written like ''\''%'' 


---------------------------------------------------------------------------------------------------------------------------------------


-- 6.3.2. Selecteer de namen van de eerste 25 leveranciers met HTML-teken in hun naam, met de vervanging van deze tekens door het juiste speciale teken.

-- vervangen van tekens: REPLACE

SELECT mhl_suppliers.name AS leveranciersnaam, 
CASE 

WHEN mhl_suppliers.name LIKE '%&Auml;%' 
THEN REPLACE(mhl_suppliers.name, '&Auml;', 'Ä')

WHEN mhl_suppliers.name LIKE '%&auml;%' 
THEN REPLACE(mhl_suppliers.name, '&auml;', 'ä')

WHEN mhl_suppliers.name LIKE '%&aacute;%' 
THEN REPLACE(mhl_suppliers.name, '&aacute;', 'á') 

WHEN mhl_suppliers.name LIKE '%&Ouml;%' 
THEN REPLACE(mhl_suppliers.name, '&Ouml;', 'Ö') 

WHEN mhl_suppliers.name LIKE '%&ouml;%' 
THEN REPLACE(mhl_suppliers.name, '&ouml;', 'ö') 

WHEN mhl_suppliers.name LIKE '%&oacute;%' 
THEN REPLACE(mhl_suppliers.name, '&oacute;', 'ó') 

WHEN mhl_suppliers.name LIKE '%&Euml;%' 
THEN REPLACE(mhl_suppliers.name, '&Euml;', 'Ë')

WHEN mhl_suppliers.name LIKE '%&euml;%' 
THEN REPLACE(mhl_suppliers.name, '&euml;', 'ë') 

WHEN mhl_suppliers.name LIKE '%&eacute;%' 
THEN REPLACE(mhl_suppliers.name, '&eacute;', 'é') 

WHEN mhl_suppliers.name LIKE '%&Iuml;%' 
THEN REPLACE(mhl_suppliers.name, '&Iuml;', 'Ï')

WHEN mhl_suppliers.name LIKE '%&iuml;%' 
THEN REPLACE(mhl_suppliers.name, '&iuml;', 'ï')

WHEN mhl_suppliers.name LIKE '%&iacute;%' 
THEN REPLACE(mhl_suppliers.name, '&iacute;', 'í') 

WHEN mhl_suppliers.name LIKE '%&Uuml;%' 
THEN REPLACE(mhl_suppliers.name, '&Uuml;', 'Ü') 

WHEN mhl_suppliers.name LIKE '%&uuml;%' 
THEN REPLACE(mhl_suppliers.name, '&uuml;', 'ü')

WHEN mhl_suppliers.name LIKE '%&uacute;%' 
THEN REPLACE(mhl_suppliers.name, '%uacute;', 'ú') 

ELSE mhl_suppliers.name

END AS nette_plaatsnaam

FROM mhl_suppliers;

---- &Uuml;lkem d&ouml;nerfabriek WORDT &Uuml;lkem d&ouml;nerfabriek

SELECT 
    mhl_suppliers.name AS leveranciersnaam, 
    CASE 
        WHEN mhl_suppliers.name LIKE '%Ü%' THEN REPLACE(mhl_suppliers.name, '&Uuml;', 'Ü')
        WHEN mhl_suppliers.name LIKE '%Ö%' THEN REPLACE(mhl_suppliers.name, '&Ouml;', 'Ö')
        WHEN mhl_suppliers.name LIKE '%Ä%' THEN REPLACE(mhl_suppliers.name, '&Auml;', 'Ä')
        WHEN mhl_suppliers.name LIKE '%ü%' THEN REPLACE(mhl_suppliers.name, '&uuml;', 'ü')
        WHEN mhl_suppliers.name LIKE '%ö%' THEN REPLACE(mhl_suppliers.name, '&ouml;', 'ö')
        WHEN mhl_suppliers.name LIKE '%ä%' THEN REPLACE(mhl_suppliers.name, '&auml;', 'ä')
        WHEN mhl_suppliers.name LIKE '%á%' THEN REPLACE(mhl_suppliers.name, '&aacute;', 'á') 
        WHEN mhl_suppliers.name LIKE '%ó%' THEN REPLACE(mhl_suppliers.name, '&oacute;', 'ó') 
        WHEN mhl_suppliers.name LIKE '%Ë%' THEN REPLACE(mhl_suppliers.name, '&Euml;', 'Ë')
        WHEN mhl_suppliers.name LIKE '%ë%' THEN REPLACE(mhl_suppliers.name, '&euml;', 'ë') 
        WHEN mhl_suppliers.name LIKE '%é%' THEN REPLACE(mhl_suppliers.name, '&eacute;', 'é') 
        WHEN mhl_suppliers.name LIKE '%Ï%' THEN REPLACE(mhl_suppliers.name, '&Iuml;', 'Ï')
        WHEN mhl_suppliers.name LIKE '%ï%' THEN REPLACE(mhl_suppliers.name, '&iuml;', 'ï')
        WHEN mhl_suppliers.name LIKE '%í%' THEN REPLACE(mhl_suppliers.name, '&iacute;', 'í') 
        WHEN mhl_suppliers.name LIKE '%x%' THEN REPLACE(mhl_suppliers.name, '&times;', 'x') 
        WHEN mhl_suppliers.name LIKE '%÷%' THEN REPLACE(mhl_suppliers.name, '&divide;', '÷') 
        ELSE mhl_suppliers.name
    END AS nette_plaatsnaam
FROM 
    mhl_suppliers;

----&Uuml;lkem d&ouml;nerfabriek WORDT Ülkem d&ouml;nerfabriek, replaces only the first html character it encounters

SELECT 
    mhl_suppliers.name AS leveranciersnaam,
    REPLACE(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE(
                                        REPLACE(
                                            REPLACE(
                                                REPLACE(
                                                    REPLACE(
                                                        REPLACE(
                                                            REPLACE(
                                                                REPLACE(
                                                                    mhl_suppliers.name,
                                                                    '&Uuml;', 'Ü'),
                                                                '&Ouml;', 'Ö'),
                                                            '&Auml;', 'Ä'),
                                                        '&uuml;', 'ü'),
                                                    '&ouml;', 'ö'),
                                                '&auml;', 'ä'),
                                            '&aacute;', 'á'),
                                        '&oacute;', 'ó'),
                                    '&Euml;', 'Ë'),
                                '&euml;', 'ë'),
                            '&eacute;', 'é'),
                        '&Iuml;', 'Ï'),
                    '&iuml;', 'ï'),
                '&iacute;', 'í'),
            '&times;', 'x'),
        '&divide;', '÷'
    ) AS nette_plaatsnaam
FROM 
    mhl_suppliers;

---- &Uuml;lkem d&ouml;nerfabriek WORDT Ülkem dönerfabriek
---- still has to be filtered by only names with HTML signs  

