USE Northwind

--1.KREIRATI UPIT KOJI PRIKAZUJE ONE UPOSLENIKE (IME I PREZIME) KOJI IMAJU MANJE GODINA OD PROSJEKA STAROSTI SVIH UPOSLENIKA U KOLEKTIVU


--PRVO
SELECT CONCAT(e.FirstName,' ',e.LastName) AS 'Ime prezime', DATEDIFF(YEAR,e.BirthDate,GETDATE()) AS 'Godine'
FROM Employees AS e
--DRUGO
SELECT AVG(DATEDIFF(YEAR,e.BirthDate,GETDATE()))
FROM Employees AS e
--TRECE
SELECT CONCAT(e.FirstName,' ',e.LastName) AS 'Ime prezime', DATEDIFF(YEAR,e.BirthDate,GETDATE()) AS 'Godine'
FROM Employees AS e
WHERE DATEDIFF(YEAR,e.BirthDate,GETDATE()) <
		(SELECT AVG(DATEDIFF(YEAR,e.BirthDate,GETDATE()))
		FROM Employees AS e)

--2. EXIST OPERATOR. KREIRATI UPIT KOJIM ÆE SE PRIKAZATI SAMO ONI kupci KOJI NISU KREIRALI NITI JEDNU NARUDŽBU

SELECT c.ContactName
FROM Customers AS c
WHERE NOT EXISTS (
	SELECT *
	FROM Orders AS o 
	WHERE o.CustomerID=c.CustomerID
)

--3.KREIRATI UPIT KOJI ÆE PRIKAZATI PO 2 NAJSTARIJIH UPOSLENIKA IZ AMERIKE I VELIKE BRITANIJE. 
--UPITOM JE POTREBNO PRIKAZATI IME, PREZIME, STAROST I DRŽAVU IZ KOJE DOLAZI (NORTHWIND)

SELECT *
FROM (SELECT TOP 2 e.FirstName,e.LastName,e.Country,DATEDIFF(YEAR,e.BirthDate,GETDATE()) AS 'Starost'
FROM Employees AS e
WHERE e.Country LIKE 'USA'
ORDER BY 4 DESC ) AS A
UNION 
SELECT *
FROM (
SELECT TOP 2 e.FirstName,e.LastName,e.Country,DATEDIFF(YEAR,e.BirthDate,GETDATE()) AS 'Starost'
FROM Employees AS e
WHERE e.Country LIKE 'UK'
ORDER BY 4 DESC ) AS B

--pravi zadaci

--1.Prikazati ID narudžbe, ID proizvoda i prodajnu cijenu, te razliku podajne cijene u odnosu na prosjeènu vrijednost prodajne cijene za sve stavke.
--Rezultat sortirati prema vrijednosti razlike u rastuæem redoslijedu.  (Northwind) 

SELECT od.OrderID,od.ProductID,od.UnitPrice,
ABS(od.UnitPrice - ( SELECT AVG(od.UnitPrice)
				FROM [Order Details] AS od )) AS 'Razlika'
FROM [Order Details] AS od
ORDER BY 4 ASC

--2.Za sve proizvode kojih ima na stanju dati prikaz njihovog id-a, naziva, stanja zaliha, te razliku stanja zaliha proizvoda u odnosu na
--prosjeènu vrijednost stanja za sve proizvode u tabeli. Rezultat sortirati prema vrijednosti razlike u opadajuæem redoslijedu. (Northwind) 

SELECT p.ProductID,p.ProductName,p.UnitsInStock,
		(SELECT AVG(p.UnitsInStock)
		FROM Products AS p) AS 'Prosjek',
ABS(p.UnitsInStock - (SELECT AVG(p.UnitsInStock)
					  FROM Products AS p )) AS 'Razlika'
FROM Products AS p 
WHERE p.UnitsInStock > 0
ORDER BY 4 DESC


--3.Prikazati po 5 najstarijih zaposlenika muškog, i ženskog spola uz navoðenje sljedeæih podataka: spojeno ime i prezime, datum roðenja, godine starosti, 
--opis posla koji obavlja, spol. Konaène rezultate sortirati prema spolu rastuæim, a zatim prema godinama starosti opadajuæim redoslijedom. (AdventureWorks2017) 

USE AdventureWorks2019

SELECT *
FROM(
SELECT TOP 5 CONCAT(p.FirstName,' ',p.LastName) AS 'Ime prezime',e.BirthDate,DATEDIFF(YEAR,e.BirthDate,GETDATE()) AS 'Godine starosti',
e.JobTitle,e.Gender
FROM HumanResources.Employee AS e 
JOIN Person.Person AS p ON e.BusinessEntityID=p.BusinessEntityID
WHERE e.Gender LIKE 'M'
ORDER BY 3 DESC ) AS A
UNION
SELECT *
FROM (
SELECT TOP 5 CONCAT(p.FirstName,' ',p.LastName) AS 'Ime prezime',e.BirthDate,DATEDIFF(YEAR,e.BirthDate,GETDATE()) AS 'Godine starosti',
e.JobTitle,e.Gender
FROM HumanResources.Employee AS e 
JOIN Person.Person AS p ON e.BusinessEntityID=p.BusinessEntityID
WHERE e.Gender LIKE 'F'
ORDER BY 3 DESC ) AS B
ORDER BY A.Gender ASC ,A.[Godine starosti] DESC


--4.Prikazati 3 zaposlenika koji su u braku i 3 koja nisu a obavljaju poslove menadžera uz navoðenje sljedeæih podataka:
--opis posla koji obavlja, datum zaposlenja, braèni status i staž. Ako osoba nije u braku plaæa dodatni porez (upitom naglasiti to), inaèe ne plaæa. 
--Konaène rezultate sortirati prema braènom statusu rastuæim, a zatim prema stažu opadajuæim redoslijedom. (AdventureWorks2017)

SELECT *
FROM (
SELECT TOP 3 e.JobTitle,e.HireDate,e.MaritalStatus,DATEDIFF(YEAR,e.HireDate,GETDATE()) AS 'Staz', 'Placa' AS 'Porez'
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID=p.BusinessEntityID
WHERE e.JobTitle LIKE '%manager%' AND e.MaritalStatus='S' ) AS A
UNION 
SELECT *
FROM (
SELECT TOP 3 e.JobTitle,e.HireDate,e.MaritalStatus,DATEDIFF(YEAR,e.HireDate,GETDATE()) AS 'Staz', 'NE placa' AS 'Porez'
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID=p.BusinessEntityID
WHERE e.JobTitle LIKE '%manager%' AND e.MaritalStatus='M' ) AS B
ORDER BY A.MaritalStatus ASC,A.Staz DESC

--5.Prikazati po 5 najstarijih zaposlenika koje se nalaze na prvom ili èetvrtom organizacionom nivou. Grupe se prave u zavisnosti od polja EmailPromotion.
--Prvu grupu æe èiniti oni èija vrijednost u pomenutom polju je 0, zatim drugu æe èiniti oni sa vrijednosti 1, dok treæu sa vrijednosti 2. 
--Za svakog zaposlenika potrebno je prikazati spojeno ime i prezime, organizacijski nivo na kojem se nalazi, te da li prima email promocije.
--Pored ovih polja potrebno je uvesti i polje pod nazivom „Prima“ koje æe sadržavati poruke: Ne prima (ukoliko je EmailPromotion = 0), Prima selektirane 
--(ukoliko je EmailPromotion = 1) i Prima (ukoliko je EmailPromotion = 2). Konaène rezultate sortirati prema organizacijskom nivou i dodatno uvedenom polju. 

SELECT *
FROM (
SELECT CONCAT(p.FirstName,' ',p.LastName) AS 'Ime prezime',e.OrganizationLevel,'Ne prima' AS 'Prima',DATEDIFF(YEAR,e.BirthDate,GETDATE()) AS 'Starost'
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID=p.BusinessEntityID
WHERE (e.OrganizationLevel=1 OR e.OrganizationLevel=4) AND p.EmailPromotion=0 ) AS A
UNION 
SELECT *
FROM (
SELECT CONCAT(p.FirstName,' ',p.LastName) AS 'Ime prezime',e.OrganizationLevel,'Prima selektirane' AS 'Prima',DATEDIFF(YEAR,e.BirthDate,GETDATE()) AS 'Starost'
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID=p.BusinessEntityID
WHERE (e.OrganizationLevel=1 OR e.OrganizationLevel=4) AND p.EmailPromotion=1 ) AS B
SELECT *
FROM (
SELECT CONCAT(p.FirstName,' ',p.LastName) AS 'Ime prezime',e.OrganizationLevel,'Prima' AS 'Prima',DATEDIFF(YEAR,e.BirthDate,GETDATE()) AS 'Starost'
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID=p.BusinessEntityID
WHERE (e.OrganizationLevel=1 OR e.OrganizationLevel=4) AND p.EmailPromotion=2 ) AS C
ORDER BY 2,4


--6.Prikazati id narudžbe, datum narudžbe i datum isporuke za narudžbe koje su isporuèenena podruèje Kanade u 7. mjesecu 2014. godine. 
--Uzeti u obzir samo narudžbe koje nisu plaæene kreditnom karticom. Datume formatirati na naèin (dd.mm.yyyy).

SELECT soh.SalesOrderID,FORMAT(soh.OrderDate,'dd.MM.yyyy') AS 'Datum narudzbe',FORMAT(soh.ShipDate,'dd.MM.yyyy') AS 'Datum isporuke'
FROM Sales.SalesOrderHeader AS soh 
JOIN Sales.SalesTerritory AS st ON soh.TerritoryID=st.TerritoryID
WHERE st.Name LIKE 'Canada' AND soh.CreditCardID IS NULL AND YEAR(soh.ShipDate)=2014 AND MONTH(soh.ShipDate)=7