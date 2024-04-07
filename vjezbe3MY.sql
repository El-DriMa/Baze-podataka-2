GO
USE Northwind
GO
--1. Koristeæi bazu Northwind izdvojiti godinu, mjesec i dan datuma isporuke narudžbe. 
SELECT YEAR(o.OrderDate) AS 'Godina',MONTH(o.OrderDate) AS 'Mjesec', DAY(o.OrderDate) AS 'Dan'
FROM Orders AS o

--2. Koristeæi bazu Northwind izraèunati koliko je godina prošlo od datum narudžbe do danas. 
SELECT DATEDIFF(YEAR,o.OrderDate,GETDATE()) AS 'Godina proslo'
FROM Orders AS o

--3. Koristeæi bazu Northwind dohvatiti sve zapise u kojima ime zaposlenika poèinje slovom A. 
SELECT *
FROM Employees AS e
WHERE LOWER(e.FirstName) LIKE 'A%'

--4. Koristeæi bazu Pubs dohvatiti sve zapise u kojima ime zaposlenika poèinje slovom A ili M. 
GO
USE pubs
GO

SELECT *
FROM employee AS e
WHERE LOWER(e.fname) LIKE 'A%' OR LOWER(e.fname) LIKE  'M%'

--ili
SELECT *
FROM employee AS e
WHERE LOWER(e.fname) LIKE '[AM]%'

--5. Koristeæi bazu Northwind prikazati sve kupce koje u koloni ContactTitle sadrže pojam "manager". 
GO
USE Northwind
GO

SELECT *
FROM Customers AS c
WHERE LOWER(c.ContactTitle) LIKE '%manager%'

--6. Koristeæi bazu Northwind dohvatiti sve kupce kod kojih se poštanski broj sastoji samo od cifara. 
SELECT *
FROM Customers AS c
WHERE c.PostalCode LIKE '[0-9]%' AND c.PostalCode NOT LIKE '%-%'

--ili
SELECT *
FROM Customers AS c
WHERE c.PostalCode NOT LIKE '%[^0-9]%' 

--ili
SELECT *
FROM Customers AS c
WHERE ISNUMERIC(c.PostalCode)=1

--7. Koristeæi bazu AdventureWorks2017 prikazati spojeno ime, srednje ime i prezime osobe. Uslov je 
--da se izmeðu pojedinih segmenata nalazi space. Omoguæiti prikaz podataka i ako neki od podataka 
--nije unijet. Prikazati samo jedinstvene zapise (bez ponavljanja istih zapisa).

GO
USE AdventureWorks2019
GO

SELECT DISTINCT pp.FirstName+' '+ ISNULL(pp.MiddleName,' ')+' '+pp.LastName AS 'Ime srednje ime prezime' 
FROM Person.Person AS pp

--Prikazati podatke o narudžbama koje su napravljene prije 19.07.1996. godine. Izlaz treba da sadrži 
--sljedeæe kolone: Id narudžbe, datum narudžbe, ID kupca, te grad. 

GO
USE Northwind
GO

SELECT o.OrderID,o.OrderDate,o.CustomerID,o.ShipCity
FROM Orders AS o
WHERE o.OrderDate<'1996-07-19'

--Prikazati stavke narudžbe gdje je kolièina narudžbe bila veæa od 100 komada uz odobreni popust. 
SELECT *
FROM [Order Details] AS od
WHERE od.Quantity > 100 AND od.Discount > 0

--Prikazati ime kompanije kupca i kontakt telefon i to samo onih koji u svome imenu posjeduju rijeè 
--„Restaurant“. Ukoliko naziv kompanije sadrži karakter (-), kupce izbaciti iz rezultata upita. 

SELECT *
FROM Customers AS c
WHERE LOWER(c.CompanyName) LIKE '%restaurant%' AND c.CompanyName NOT LIKE '%-%'

--Prikazati proizvode èiji naziv poèinje slovima „C“ ili „G“, drugo slovo može biti bilo koje, a treæe 
--slovo u nazivu je „A“ ili „O“. 
SELECT * 
FROM Products AS p
WHERE LOWER(p.ProductName) LIKE '[CG]_[AO]%'


--Prikazati listu proizvoda èiji naziv poèinje slovima „L“ ili „T“, ili je ID proizvoda = 46. Lista treba 
--da sadrži samo one proizvode èija se cijena po komadu kreæe izmeðu 10 i 50 (ukljuèujuæi graniène 
--vrijednosti). Upit napisati na dva naèina. 

SELECT *
FROM Products AS p
WHERE (LOWER(p.ProductName) LIKE '[LT]%' OR p.ProductID=46) AND p.UnitPrice BETWEEN 10 AND 50 
--drugi nacin je sa <>

--Prikazati naziv proizvoda i cijenu, gdje je stanje na zalihama manje od naruèene kolièine. Takoðer, 
--u rezultate upita ukljuèiti razliku izmeðu stanja zaliha i naruèene kolièine. 

SELECT p.ProductName,p.UnitPrice,  p.UnitsOnOrder-p.UnitsInStock AS 'Razlika'
FROM Products AS p
WHERE p.UnitsInStock<p.UnitsOnOrder

--Prikazati sve podatke o dobavljaèima koji dolaze iz Španije ili Njemaèke a nemaju unesen broj 
--faxa. Formatirati izlaz NULL vrijednosti na naèin da se prikaže umjesto NULL prikladno 
--objašnjenje. Upit napisati na dva naèina.

SELECT s.SupplierID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region, s.PostalCode,s.Country, s.Phone, ISNULL(s.Fax,'nepoznata vrijednost') AS Fax, s.HomePage
FROM Suppliers AS s
WHERE s.Country LIKE 'Spain' OR s.Country LIKE 'Germany' AND s.Fax IS NULL 



