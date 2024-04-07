GO
USE Northwind
GO
--1. Koriste�i bazu Northwind izdvojiti godinu, mjesec i dan datuma isporuke narud�be. 
SELECT YEAR(o.OrderDate) AS 'Godina',MONTH(o.OrderDate) AS 'Mjesec', DAY(o.OrderDate) AS 'Dan'
FROM Orders AS o

--2. Koriste�i bazu Northwind izra�unati koliko je godina pro�lo od datum narud�be do danas. 
SELECT DATEDIFF(YEAR,o.OrderDate,GETDATE()) AS 'Godina proslo'
FROM Orders AS o

--3. Koriste�i bazu Northwind dohvatiti sve zapise u kojima ime zaposlenika po�inje slovom A. 
SELECT *
FROM Employees AS e
WHERE LOWER(e.FirstName) LIKE 'A%'

--4. Koriste�i bazu Pubs dohvatiti sve zapise u kojima ime zaposlenika po�inje slovom A ili M. 
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

--5. Koriste�i bazu Northwind prikazati sve kupce koje u koloni ContactTitle sadr�e pojam "manager". 
GO
USE Northwind
GO

SELECT *
FROM Customers AS c
WHERE LOWER(c.ContactTitle) LIKE '%manager%'

--6. Koriste�i bazu Northwind dohvatiti sve kupce kod kojih se po�tanski broj sastoji samo od cifara. 
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

--7. Koriste�i bazu AdventureWorks2017 prikazati spojeno ime, srednje ime i prezime osobe. Uslov je 
--da se izme�u pojedinih segmenata nalazi space. Omogu�iti prikaz podataka i ako neki od podataka 
--nije unijet. Prikazati samo jedinstvene zapise (bez ponavljanja istih zapisa).

GO
USE AdventureWorks2019
GO

SELECT DISTINCT pp.FirstName+' '+ ISNULL(pp.MiddleName,' ')+' '+pp.LastName AS 'Ime srednje ime prezime' 
FROM Person.Person AS pp

--Prikazati podatke o narud�bama koje su napravljene prije 19.07.1996. godine. Izlaz treba da sadr�i 
--sljede�e kolone: Id narud�be, datum narud�be, ID kupca, te grad. 

GO
USE Northwind
GO

SELECT o.OrderID,o.OrderDate,o.CustomerID,o.ShipCity
FROM Orders AS o
WHERE o.OrderDate<'1996-07-19'

--Prikazati stavke narud�be gdje je koli�ina narud�be bila ve�a od 100 komada uz odobreni popust. 
SELECT *
FROM [Order Details] AS od
WHERE od.Quantity > 100 AND od.Discount > 0

--Prikazati ime kompanije kupca i kontakt telefon i to samo onih koji u svome imenu posjeduju rije� 
--�Restaurant�. Ukoliko naziv kompanije sadr�i karakter (-), kupce izbaciti iz rezultata upita. 

SELECT *
FROM Customers AS c
WHERE LOWER(c.CompanyName) LIKE '%restaurant%' AND c.CompanyName NOT LIKE '%-%'

--Prikazati proizvode �iji naziv po�inje slovima �C� ili �G�, drugo slovo mo�e biti bilo koje, a tre�e 
--slovo u nazivu je �A� ili �O�. 
SELECT * 
FROM Products AS p
WHERE LOWER(p.ProductName) LIKE '[CG]_[AO]%'


--Prikazati listu proizvoda �iji naziv po�inje slovima �L� ili �T�, ili je ID proizvoda = 46. Lista treba 
--da sadr�i samo one proizvode �ija se cijena po komadu kre�e izme�u 10 i 50 (uklju�uju�i grani�ne 
--vrijednosti). Upit napisati na dva na�ina. 

SELECT *
FROM Products AS p
WHERE (LOWER(p.ProductName) LIKE '[LT]%' OR p.ProductID=46) AND p.UnitPrice BETWEEN 10 AND 50 
--drugi nacin je sa <>

--Prikazati naziv proizvoda i cijenu, gdje je stanje na zalihama manje od naru�ene koli�ine. Tako�er, 
--u rezultate upita uklju�iti razliku izme�u stanja zaliha i naru�ene koli�ine. 

SELECT p.ProductName,p.UnitPrice,  p.UnitsOnOrder-p.UnitsInStock AS 'Razlika'
FROM Products AS p
WHERE p.UnitsInStock<p.UnitsOnOrder

--Prikazati sve podatke o dobavlja�ima koji dolaze iz �panije ili Njema�ke a nemaju unesen broj 
--faxa. Formatirati izlaz NULL vrijednosti na na�in da se prika�e umjesto NULL prikladno 
--obja�njenje. Upit napisati na dva na�ina.

SELECT s.SupplierID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region, s.PostalCode,s.Country, s.Phone, ISNULL(s.Fax,'nepoznata vrijednost') AS Fax, s.HomePage
FROM Suppliers AS s
WHERE s.Country LIKE 'Spain' OR s.Country LIKE 'Germany' AND s.Fax IS NULL 



