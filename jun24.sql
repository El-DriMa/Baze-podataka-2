--1.
CREATE DATABASE jun24

GO
USE jun24


--2.
CREATE TABLE Uposlenici
(
UposlenikID INT CONSTRAINT PK_Uposlenici PRIMARY KEY IDENTITY(1,1),
Ime NVARCHAR(10) NOT NULL,
Prezime NVARCHAR(20) NOT NULL,
DatumRodjenja DATETIME NOT NULL,
UkupanBrojTeritorija INT
)

CREATE TABLE Narudzbe
(
NarudzbaID INT CONSTRAINT PK_Narudzbe PRIMARY KEY IDENTITY(1,1),
UposlenikID INT CONSTRAINT FK_Uposlenik_Narudzba FOREIGN KEY REFERENCES Uposlenici(UposlenikID),
DatumNarudzbe DATETIME,
ImeKompanijeKupca NVARCHAR(40),
AdresaKupca NVARCHAR(60)
)

CREATE TABLE Proizvodi
(
ProizvodID INT CONSTRAINT PK_Proizvodi PRIMARY KEY IDENTITY(1,1),
NazivProizvoda NVARCHAR(40) NOT NULL,
NazivKompanijeDobavljaca NVARCHAR(40),
NazivKategorije NVARCHAR(15)
)

CREATE TABLE StavkeNarudzbe
(
NarudzbaID INT CONSTRAINT FK_StavkeNarudzbe_Narudzba FOREIGN KEY REFERENCES Narudzbe(NarudzbaID),
ProizvodID INT CONSTRAINT FK_StavkeNarudzbe_Proizvod FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
Cijena MONEY NOT NULL,
Kolicina TINYINT NOT NULL,
Popoust REAL NOT NULL
CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY(NarudzbaID,ProizvodID)
)

	
--3.
SET IDENTITY_INSERT Uposlenici ON
INSERT INTO Uposlenici(UposlenikID,Ime,Prezime,DatumRodjenja,UkupanBrojTeritorija)
SELECT e.EmployeeID,e.FirstName,e.LastName,e.BirthDate,
(SELECT COUNT(*) FROM Northwind.dbo.EmployeeTerritories AS et WHERE et.EmployeeID=e.EmployeeID)
FROM Northwind.dbo.Employees AS e
SET IDENTITY_INSERT Uposlenici OFF

SELECT * FROM Uposlenici

SET IDENTITY_INSERT Narudzbe ON
INSERT INTO Narudzbe(NarudzbaID,UposlenikID,DatumNarudzbe,ImeKompanijeKupca,AdresaKupca)
SELECT o.OrderID,o.EmployeeID,o.OrderDate,c.CompanyName,c.Address
FROM Northwind.dbo.Orders AS o 
JOIN Northwind.dbo.Customers AS c ON o.CustomerID=c.CustomerID
SET IDENTITY_INSERT Narudzbe OFF

SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID,NazivProizvoda,NazivKompanijeDobavljaca,NazivKategorije)
SELECT p.ProductID,p.ProductName,s.CompanyName,c.CategoryName
FROM Northwind.dbo.Products AS p
JOIN Northwind.dbo.Suppliers AS s ON p.SupplierID=s.SupplierID
JOIN Northwind.dbo.Categories AS c ON p.CategoryID=c.CategoryID
SET IDENTITY_INSERT Proizvodi OFF

INSERT INTO StavkeNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popoust)
SELECT od.OrderID,od.ProductID,od.UnitPrice,od.Quantity,od.Discount
FROM Northwind.dbo.[Order Details] AS od

--4.
--a) U stavkeNarudzbe dodati 2 nove izracunate kolone : VrijednostNarudzbeSaPopustom
-- i vrijednostNarudzbeBezPoputsa. Izracunate kolone vec cuvaju podatke na psnpvu podataka iz kolona!

ALTER TABLE StavkeNarudzbe
ADD CijenaBezPopusta AS Cijena*Kolicina PERSISTED --calc

SELECT * FROM StavkeNarudzbe
WHERE NarudzbaID=11071

INSERT INTO StavkeNarudzbe
VALUES (11071,23,4,2,0)

--b) Kreirati pogled v_select_orders kojim ce se prikazati ukupna zarada po uposlenicima od narudzbi kreiranih
--u zadnjem kvartalu 1996.god. Pogledom je potrebno prikazati spojeno ime i prezime uposlenika, ukupna zadara sa popustom na 2 dec,
--i zarada bez popusta. OBAVEZNO koristiti izracunate kolone iz 4a

GO
CREATE VIEW v_selecct_orders
AS
SELECT CONCAT(u.Ime,' ',u.Prezime) AS 'Uposlenik',
ROUND(SUM(sn.VrijednostNarudzbeSaPopustom),2) AS 'Sa popustom',
ROUND(SUM(sn.VrijednostNarudzbeBezPopusta),2) AS 'Bez popusta'
FROM Uposlenici AS u 
JOIN Narudzbe AS n ON n.UposlenikID=u.UposlenikID
JOIN StavkeNarudzbe AS sn ON n.NarudzbaID=sn.NarudzbaID
WHERE MONTH(n.DatumNarudzbe) IN (12,11,10,9)
GROUP BY CONCAT(u.Ime,' ',u.Prezime)
GO

SELECT *
FROM v_selecct_orders
ORDER BY 2,3

--c) Kreirati funckiju f_starijiUposlenici koja ce vracati podatke u formi tabele na osnovu prosljedjenog parametra
--godineStarosti, cijelobrojni tip.Funkcija vraca one zaise u kojima su godine starosti kod uposlenika
--vece od unesene vrijednosti parametra.Potrebno je da se prilikom kreiranja funkcije u rezultatu
--nalaze sve kolone uposnici zajedno sa godinama starosti. Provjeriti ispravnost .

GO
CREATE FUNCTION f_stariji
(
@godineStarosti INT
)
RETURNS TABLE
AS RETURN 
SELECT u.UposlenikID,u.Ime,u.Prezime,u.UkupanBrojTeritorija,u.DatumRodjenja,
DATEDIFF(YEAR,u.DatumRodjenja,GETDATE()) AS 'Starost'
FROM Uposlenici AS u
WHERE DATEDIFF(YEAR,u.DatumRodjenja,GETDATE())>@godineStarosti

SELECT * FROM f_stariji(60)


--d) Pronaci najprodavaniji proizvod u 2011 godini.Ulogu najprodavanijeg ima onaj kojeg je najveci broj komada prodat.
--(AV19)

USE AdventureWorks2019

SELECT TOP 1 p.Name,SUM(sod.OrderQty) AS 'Kolicina'
FROM Production.Product AS p 
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID=Sod.ProductID
JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID=sod.SalesOrderID
WHERE YEAR(soh.OrderDate)=2011
GROUP BY p.Name
ORDER BY 2 DESC

--e) Prikazati ukupan broj porizvoda prema specijalnim ponudama.
--Potrebno je proebrojati samo one koji pripadaju kategoriji odjece

SELECT so.Type, COUNT(*) AS 'Kolicina'
FROM Sales.SpecialOffer AS so
JOIN Sales.SpecialOfferProduct AS sop ON so.SpecialOfferID=sop.SpecialOfferID
JOIN Production.Product AS p ON sop.ProductID=p.ProductID
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON pc.ProductCategoryID=ps.ProductCategoryID
WHERE pc.Name LIKE 'Clothing'
GROUP BY so.Type

--f) Prikazati najskuplji proizvod (ListPrice) u svakoj kategoriji

SELECT pc.Name AS 'Kategorija',MAX(p.Name) AS 'Najskuplji proizvod',MAX(p.ListPrice) AS 'Cijena'
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON pc.ProductCategoryID=ps.ProductCategoryID
GROUP BY pc.Name

--g) Prikazati proizvode cija mpc(ListPrice) manje od prosjecne mpc kategorije proizvoda kojoj pripada

SELECT p.Name,p.ListPrice,pc.Name AS 'Kategorija'
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON pc.ProductCategoryID=ps.ProductCategoryID
WHERE p.ListPrice<(SELECT AVG(p2.ListPrice)
				   FROM Production.Product AS p2
				   JOIN Production.ProductSubcategory AS ps2 ON ps2.ProductSubcategoryID=p2.ProductSubcategoryID
				   WHERE ps2.ProductCategoryID=pc.ProductCategoryID)
ORDER BY pc.Name,p.Name

--5.

--a) Pronaci najprodavanije proizvode koji nisu na listi top 10 najrpodavanijih proizvoda u zadnjih 11 godina


SELECT p.Name
FROM Production.Product AS p
WHERE p.ProductID NOT IN (SELECT TOP 10 p2.ProductID
						  FROM Production.Product AS p2
						  JOIN Sales.SalesOrderDetail AS sod ON p2.ProductID=sod.ProductID
						  JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID=sod.SalesOrderID
						  WHERE soh.OrderDate>=DATEADD(YEAR,-11,GETDATE())
						  GROUP BY p2.ProductID
						  ORDER BY SUM(sod.OrderQty) DESC)


 --b) Prikazati ime i prezime kupca,id narudzbe te ukupnu vrijednost narudzbe sa popustom (na 2 dec), uz uslov
 --da su na nivou pojedine narudzbe naruceni proizvodi iz svih kategorija

 SELECT pe.FirstName,pe.LastName,soh.SalesOrderID,ROUND(SUM(soh.SubTotal),2) AS 'Ukupno'
 FROM Sales.SalesOrderHeader AS soh 
 JOIN Sales.Customer AS c ON soh.CustomerID=c.CustomerID
 JOIN Person.Person AS pe ON c.PersonID=pe.BusinessEntityID
 JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID=sod.SalesOrderID
 JOIN  Production.Product AS p ON sod.ProductID=p.ProductID
 JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
 JOIN Production.ProductCategory AS pc ON pc.ProductCategoryID=ps.ProductCategoryID
 GROUP BY pe.FirstName,pe.LastName,soh.SalesOrderID
 HAVING COUNT(DISTINCT pc.ProductCategoryID)=(SELECT COUNT(*) FROM Production.ProductCategory)
 ORDER BY 4 DESC


