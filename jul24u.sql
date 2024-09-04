--1.Kreirati bazu podataka sa imenom vaseg broja indeksa

GO
CREATE DATABASE jul24

GO 
USE jul24 

--2.U kreiranoj bazi tabelu sa strukturom : 
--a) Uposlenici 
-- UposlenikID cjelobrojni tip i primarni kljuc autoinkrement,
-- Ime 10 UNICODE karaktera (obavezan unos)
-- Prezime 20 UNICODE karaktera (obaveznan unos),
-- DatumRodjenja polje za unos datuma i vremena (obavezan unos)
-- UkupanBrojTeritorija cjelobrojni tip

CREATE TABLE Uposlenici
(
UposlenikID INT CONSTRAINT PK_Uposlenici PRIMARY KEY IDENTITY(1,1),
Ime NVARCHAR(10) NOT NULL,
Prezime NVARCHAR(20) NOT NULL,
DatumRodjenja DATETIME NOT NULL,
UkupanBrojTeritorija INT
)


--b) Narudzbe
-- NarudzbaID cjelobrojni tip i primarni kljuc autoinkrement,
-- UposlenikID cjelobrojni tip i strani kljuc,
-- DatumNarudzbe polje za unos datuma i vremena,
-- ImeKompanijeKupca 40 UNICODE karaktera,
-- AdresaKupca 60 UNICODE karaktera,
-- UkupanBrojStavkiNarudzbe cjelobrojni tip

CREATE TABLE Narudzbe
(
NarudzbaID INT CONSTRAINT PK_Narudzbe PRIMARY KEY IDENTITY(1,1),
UposlenikID INT CONSTRAINT FK_NarudzbeUposlenici FOREIGN KEY REFERENCES Uposlenici(UposlenikID),
DatumNarudzbe DATETIME,
ImeKompanijeKupca NVARCHAR(40),
AdresaKupca NVARCHAR(60),
UkupanBrojStavkiNarudzbe INT
)


--c) Proizvodi
-- ProizvodID cjelobrojni tip i primarni kljuc autoinkrement,
-- NazivProizvoda 40 UNICODE karaktera (obaveznan unos),
-- NazivKompanijeDobavljaca 40 UNICODE karaktera,
-- NazivKategorije 15 UNICODE karaktera

CREATE TABLE Proizvodi
(
ProizvodID INT CONSTRAINT PK_Proizvodi PRIMARY KEY IDENTITY(1,1),
NazivProizvoda NVARCHAR(40) NOT NULL,
NazivKompanijeDobavljaca NVARCHAR(40),
NazivKategorije NVARCHAR(15)
)


--d) StavkeNarudzbe
-- NarudzbaID cjelobrojni tip strani i primarni kljuc,
-- ProizvodID cjelobrojni tip strani i primarni kljuc,
-- Cijena novcani tip (obavezan unos),
-- Kolicina kratki cjelobrojni tip (obavezan unos),
-- Popust real tip podataka (obavezno)

CREATE TABLE StavkeNarudzbe
(
NarudzbaID INT CONSTRAINT FK_StavkeNarudzbe_Narudzba FOREIGN KEY REFERENCES Narudzbe(NarudzbaID),
ProizvodID INT CONSTRAINT FK_StavkeNarudzbe_Proizvodi FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
Cijena MONEY NOT NULL,
Kolicina TINYINT NOT NULL,
Popust REAL NOT NULL
CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY (NarudzbaID,ProizvodID)
)

--(4 boda)


--3.Iz baze Northwind u svoju prebaciti sljedece podatke :
--a) U tabelu uposlenici sve uposlenike , Izracunata vrijednost za svakog uposlenika
-- na osnovnu EmployeeTerritories -> UkupanBrojTeritorija

SET IDENTITY_INSERT Uposlenici ON
INSERT INTO Uposlenici (UposlenikID,Ime,Prezime,DatumRodjenja,UkupanBrojTeritorija)
SELECT e.EmployeeID,e.FirstName,e.LastName,e.BirthDate,COUNT(et.TerritoryID)
FROM Northwind.dbo.Employees AS e JOIN Northwind.dbo.EmployeeTerritories AS et ON e.EmployeeID=et.EmployeeID
GROUP BY e.EmployeeID,e.FirstName,e.LastName,e.BirthDate

SELECT * FROM Uposlenici


SET IDENTITY_INSERT Uposlenici OFF

--b) U tabelu narudzbe sve narudzbe, Izracunata vrijensot za svaku narudzbu pojedinacno 
-- ->UkupanBrojStavkiNarudzbe


SET IDENTITY_INSERT Narudzbe ON
INSERT INTO Narudzbe(NarudzbaID,UposlenikID,DatumNarudzbe,ImeKompanijeKupca,AdresaKupca,UkupanBrojStavkiNarudzbe)
SELECT o.OrderID,o.EmployeeID,o.OrderDate,c.CompanyName,c.Address,SUM(od.Quantity)
FROM Northwind.dbo.Orders AS o JOIN Northwind.dbo.Customers AS c ON o.CustomerID=c.CustomerID JOIN 
Northwind.dbo.[Order Details] AS od ON o.OrderID=od.OrderID
GROUP BY o.OrderID, o.EmployeeID, o.OrderDate, c.CompanyName, c.Address

SELECT * FROM Narudzbe

SET IDENTITY_INSERT Narudzbe OFF

--c) U tabelu porizvodi sve porizvode

SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID,NazivProizvoda,NazivKompanijeDobavljaca,NazivKategorije)
SELECT p.ProductID,p.ProductName,s.CompanyName,c.CategoryName
FROM Northwind.dbo.Products AS p JOIN Northwind.dbo.Suppliers AS s ON p.SupplierID=s.SupplierID
JOIN Northwind.dbo.Categories AS c ON p.CategoryID=c.CategoryID

SET IDENTITY_INSERT Proizvodi OFF

--d) U tabelu StavkeNrudzbe sve narudzbe

INSERT INTO StavkeNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
SELECT od.OrderID,od.ProductID,od.UnitPrice,od.Quantity,od.Discount
FROM Northwind.dbo.[Order Details] AS od


--(5 bodova)

--4. 
--a) (4 boda) Kreirati indeks kojim ce se ubrzati pretraga po nazivu proizvoda, OBEVAZENO kreirati testni slucaj (Nova baza)

CREATE INDEX ix_Pretraga 
ON Proizvodi(NazivProizvoda)

--b) (4 boda) Kreirati proceduru sp_update_proizvodi kojom ce se izmjeniti podaci o prpoizvodima u tabeli.
     --Korisnici mogu poslati jedan ili vise parametara te voditi raucna da ne dodje do gubitka podataka.(Nova baza)

GO 
CREATE PROCEDURE sp_update_proizvodi 
(
@ProizvodID INT,
@NazivProizvoda NVARCHAR(40)=NULL,
@NazivKompanijeDobavljaca NVARCHAR(40)=NULL,
@NazivKategorije NVARCHAR(15)=NULL
)
AS BEGIN
UPDATE Proizvodi
SET
NazivProizvoda=ISNULL(@NazivProizvoda,NazivProizvoda),
NazivKompanijeDobavljaca=ISNULL(@NazivKompanijeDobavljaca,NazivKompanijeDobavljaca),
NazivKategorije=ISNULL(@NazivKategorije,NazivKategorije)
WHERE ProizvodID=@ProizvodID
END

--c) (5 bodova) Kreirati funckiju f_4c koja ce vratiti podatke u tabelarnom obliku na osnovnu prosljedjenog parametra idNarudzbe
	--cjelobrojni tip. Funckija ce vratiti one narudzbe ciji id odgovara poslanom parametru.
	--Potrebno je da se prilikom kreiranja funkcije u rezultatu nalazi id narudzbe,ukupna vrijednost bez popustva. OBAVEZNO testni sluc (Nova baza)

GO
CREATE FUNCTION f_4c 
(
@idNarudzbe INT 
)
RETURNS TABLE
AS RETURN
SELECT sn.NarudzbaID,sn.Cijena*sn.Kolicina AS 'Ukupno bez popusta'
FROM StavkeNarudzbe AS sn
WHERE sn.NarudzbaID=@idNarudzbe

SELECT * FROM f_4c(10248)


--d) (6 bodova) Pronaci najmanju narudzbu placenu karticom i isporuceno na porducje Europe,uz id narudzbe prikazati i spojeno ime i prezime
	--kupca te grad u koji je isporucena narudzbe (AdventureWorks)

USE AdventureWorks2019

SELECT TOP 1 soh.SalesOrderID,CONCAT(p.FirstName,' ',p.LastName) AS 'Kupac',pa.City,soh.SubTotal
FROM Sales.SalesOrderHeader AS soh JOIN Sales.Customer AS c on soh.CustomerID=c.CustomerID
JOIN Person.Person AS p ON c.PersonID=p.BusinessEntityID
JOIN Sales.SalesTerritory AS st ON soh.TerritoryID=st.TerritoryID
JOIN Person.Address AS pa ON soh.ShipToAddressID=pa.AddressID
WHERE soh.CreditCardID IS NOT NULL AND st.[Group] LIKE 'Europe'
ORDER BY soh.SubTotal ASC 


--e) (6 bodova) Prikazati ukupan broj porizvoda prema specijalnim ponudama.Potrebno je prebrojati samo one proizvode
	--koji pripadaju kategoriji odjece ili imaju zabiljezen model (AdventureWorks)

SELECT so.SpecialOfferID,COUNT(sop.ProductID) AS 'Broj proizvoda'
FROM Sales.SpecialOffer AS so
JOIN Sales.SpecialOfferProduct AS sop ON so.SpecialOfferID=sop.SpecialOfferID
JOIN Production.Product AS p ON sop.ProductID=p.ProductID
JOIN Production.ProductSubcategory AS ps ON ps.ProductSubcategoryID=p.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID=pc.ProductCategoryID
WHERE pc.Name LIKE 'Clothing' OR p.ProductModelID IS NOT NULL
GROUP BY so.SpecialOfferID

--f) (9 bodova) Prikazatu 5 kupaca koji su napravili najveci broj narudzbi u zadnjih 30% narudzbi iz 2011 ili 2012 god. (AdventureWorks)


SELECT TOP 5 c.CustomerID,pe.FirstName,pe.LastName,COUNT(soh.SalesOrderID) AS 'Broj narudzbi'
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Customer AS c ON soh.CustomerID=c.CustomerID
JOIN Person.Person AS pe ON c.PersonID=pe.BusinessEntityID
WHERE YEAR(soh.OrderDate) IN (2011,2012) AND soh.SalesOrderID IN 
																  (SELECT TOP 30 PERCENT soh2.SalesOrderID
																  FROM Sales.SalesOrderHeader AS soh2
																  WHERE YEAR(soh2.OrderDate) IN (2011,2012)
																  ORDER BY soh2.OrderDate DESC)
GROUP BY c.CustomerID,pe.FirstName,pe.LastName
ORDER BY COUNT(soh.SalesOrderID) DESC


						
--g) (10 bodova) Menadzmentu kompanije potrebne su informacije o najmanje prodavanim porizvodima. ...kako bi ih eliminisali iz ponude.
	--Obavezno prikazati naziv o kojem se proizvodu radi i kvartal i godinu i adekvatnu poruku. (AdventureWorks)

--5.
--a) (11 bodova) Prikazati kupce koji su kreirali narudzbe u minimalno 5 razlicitih mjeseci u 2012 godini.

SELECT sq.CustomerID,COUNT(DISTINCT MONTH(sq.Mjesec)) AS 'Broj mjeseci'
FROM(
	SELECT soh.CustomerID,MONTH(soh.OrderDate) AS 'Mjesec'
	FROM Sales.SalesOrderHeader AS soh
	WHERE YEAR(soh.OrderDate)=2012
	GROUP BY soh.CustomerID,MONTH(soh.OrderDate)
) AS sq
GROUP BY sq.CustomerID
HAVING COUNT(DISTINCT MONTH(sq.Mjesec))>=5

--b) (16 bodova) Prikazati 5 narudzbi sa najvise narucenih razlicitih proizvoda i 5 narudzbi sa najvise porizvoda koji pripadaju razlicitim potkategorijama.
	--Upitom prikazati ime i prezime kupca,id narudzbe te ukupnu vrijednost narudzbe sa popoustom zaokruzenu na 2 decimale (AdventureWorks)

SELECT PODQ1.Kupac,PODQ1.SalesOrderID,PODQ1.Ukupno
FROM (
SELECT TOP 5 sod.SalesOrderID,COUNT(DISTINCT sod.ProductID) AS 'Proizvoda',CONCAT(pe.FirstName,' ',pe.LastName) AS 'Kupac',ROUND(SUM(soh.TotalDue),2) AS 'Ukupno'
FROM Sales.SalesOrderDetail AS sod
JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID=soh.SalesOrderID
JOIN Sales.Customer AS c ON soh.CustomerID=c.CustomerID
JOIN Person.Person AS pe ON c.PersonID=pe.BusinessEntityID
GROUP BY sod.SalesOrderID,CONCAT(pe.FirstName,' ',pe.LastName)
ORDER BY 2 DESC 
) AS PODQ1
UNION ALL
SELECT PODQ2.Kupac,PODQ2.SalesOrderID,PODQ2.Ukupno
FROM(
SELECT TOP 5 sod.SalesOrderID,COUNT(DISTINCT p.ProductSubcategoryID) AS 'Kategorije',CONCAT(pe.FirstName,' ',pe.LastName) AS 'Kupac',ROUND(SUM(soh.TotalDue),2) AS 'Ukupno'
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p ON sod.ProductID=p.ProductID
JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID=soh.SalesOrderID
JOIN Sales.Customer AS c ON soh.CustomerID=c.CustomerID
JOIN Person.Person AS pe ON c.PersonID=pe.BusinessEntityID
GROUP BY sod.SalesOrderID,CONCAT(pe.FirstName,' ',pe.LastName)
ORDER BY 2 DESC 
) AS PODQ2
