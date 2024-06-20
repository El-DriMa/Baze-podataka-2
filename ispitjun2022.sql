--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
CREATE DATABASE ispitJun2022
GO
USE ispitJun2022

--2. U kreiranoj bazi podataka kreirati tabele sa sljedeæom strukturom:
--a) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)
--• Tezina, decimalna vrijednost sa 2 znaka iza zareza
CREATE TABLE Proizvodi(
ProizvodID INT PRIMARY KEY IDENTITY (1,1),
Naziv NVARCHAR(50) NOT NULL,
SifraProizvoda NVARCHAR(25) NOT NULL,
Boja NVARCHAR(15),
NazivKategorije NVARCHAR(50) NOT NULL,
Tezina DECIMAL(10,2)
)
--b) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivTeritorije, 50 UNICODE (obavezan unos)
--• NazivRegije, 50 UNICODE (obavezan unos)
--• NacinIsporuke, 50 UNICODE (obavezan unos)
CREATE TABLE ZaglavljeNarudzbe (
NarudzbaID INT PRIMARY KEY IDENTITY (1,1),
DatumNarudzbe DATETIME NOT NULL,
DatumIsporuke DATETIME NOT NULL,
ImeKupca NVARCHAR(50) NOT NULL,
PrezimeKupca NVARCHAR(50) NOT NULL,
NazivTeritorije NVARCHAR(50) NOT NULL,
NazivRegije NVARCHAR(50) NOT NULL,
NacinIsporuke NVARCHAR(50) NOT NULL
)
--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani kljuè
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani kljuè
--• Cijena, novèani tip (obavezan unos),
--• Kolicina, skraæeni cjelobrojni tip (obavezan unos),
--• Popust, novèani tip (obavezan unos)
CREATE TABLE DetaljiNarudzbe(
NarudzbaID INT NOT NULL FOREIGN KEY REFERENCES ZaglavljeNarudzbe(NarudzbaID),
ProizvodID INT NOT NULL FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
Cijena MONEY NOT NULL,
Kolicina TINYINT NOT NULL,
Popust MONEY NOT NULL
)
--**Jedan proizvod se može više puta naruèiti, dok jedna narudžba može sadržavati više proizvoda. U okviru jedne
--narudžbe jedan proizvod se može naruèiti više puta.

--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeæe podatke:
--a) U tabelu Proizvodi dodati sve proizvode, na mjestima gdje nema pohranjenih podataka o težini
--zamijeniti vrijednost sa 0
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije
--• Weight -> Tezina

SET IDENTITY_INSERT Proizvodi ON;
INSERT INTO Proizvodi(ProizvodID,Naziv,SifraProizvoda,Boja,NazivKategorije,Tezina)
SELECT 
p.ProductID AS ProizvodID,
p.Name AS Naziv,
p.ProductNumber AS SifraProizvoda,
p.Color AS Boja,
pc.Name AS NazivKategorije,
ISNULL(p.Weight,0) AS Tezina
FROM AdventureWorks2019.Production.Product AS p
JOIN AdventureWorks2019.Production.ProductSubcategory psc ON p.ProductSubcategoryID=psc.ProductSubcategoryID
JOIN AdventureWorks2019.Production.ProductCategory AS pc ON psc.ProductCategoryID=pc.ProductCategoryID

SELECT * FROM Proizvodi

--b) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• Name (SalesTerritory) -> NazivTeritorije
--• Group (SalesTerritory) -> NazivRegije
--• Name (ShipMethod) -> NacinIsporuke

SET IDENTITY_INSERT Proizvodi OFF;
SET IDENTITY_INSERT ZaglavljeNarudzbe ON;

INSERT INTO ZaglavljeNarudzbe(NarudzbaID,DatumNarudzbe,DatumIsporuke,ImeKupca,PrezimeKupca,NazivTeritorije,NazivRegije,NacinIsporuke)
SELECT 
soh.SalesOrderID AS NarudzbaID,
soh.OrderDate AS DatumNarudzbe,
soh.ShipDate AS DatumIsporuke,
p.FirstName AS ImeKupca,
p.LastName AS PrezimeKupca,
t.Name AS NazivTeritorije,
t.[Group] AS NazivRegije,
sm.Name AS NacinIsporuke
FROM AdventureWorks2019.Sales.SalesOrderHeader AS soh
JOIN AdventureWorks2019.Sales.Customer AS c ON soh.CustomerID=c.CustomerID
JOIN AdventureWorks2019.Person.Person AS p ON c.PersonID=p.BusinessEntityID
JOIN AdventureWorks2019.Sales.SalesTerritory AS t ON soh.TerritoryID=t.TerritoryID
JOIN AdventureWorks2019.Purchasing.ShipMethod AS sm ON sm.ShipMethodID=soh.ShipMethodID

SELECT * FROM ZaglavljeNarudzbe

--c) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust


INSERT INTO DetaljiNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
SELECT 
sod.SalesOrderID AS NarudzbaID,
sod.ProductID AS ProizvodID,
sod.UnitPrice AS Cijena,
sod.OrderQty AS Kolicina,
sod.UnitPriceDiscount AS Popust
FROM AdventureWorks2019.Sales.SalesOrderDetail AS sod

SELECT * FROM DetaljiNarudzbe

--4.
--a) (6 bodova) Kreirati upit koji æe prikazati ukupan broj uposlenika po odjelima. Potrebno je prebrojati 
--samo one uposlenike koji su trenutno aktivni, odnosno rade na datom odjelu. Takoðer, samo uzeti u obzir 
--one uposlenike koji imaju više od 10 godina radnog staža (ne ukljuèujuæi graniènu vrijednost). Rezultate 
--sortirati preba broju uposlenika u opadajuæem redoslijedu. (AdventureWorks2017)

USE AdventureWorks2019
GO

SELECT d.Name,COUNT(*) AS 'Ukupno uposlenika'
FROM HumanResources.Department AS d
JOIN HumanResources.EmployeeDepartmentHistory AS edh ON d.DepartmentID=edh.DepartmentID
JOIN HumanResources.Employee AS e ON e.BusinessEntityID=edh.BusinessEntityID
WHERE DATEDIFF(YEAR,e.BirthDate,e.HireDate)>10 AND edh.EndDate IS NULL
GROUP BY d.Name
ORDER BY 2 DESC

--b) (10 bodova) Kreirati upit koji prikazuje po mjesecima ukupnu vrijednost poruèene robe za skladište, te 
--ukupnu kolièinu primljene robe, iskljuèivo u 2012 godini. Uslov je da su troškovi prevoza bili izmeðu 
--500 i 2500, a da je dostava izvršena CARGO transportom. Takoðer u rezultatima upita je potrebno 
--prebrojati stavke narudžbe na kojima je odbijena kolièina veæa od 100. (AdventureWorks2017)

SELECT MONTH(poh.OrderDate) AS 'Mjesec',SUM(pod.LineTotal) AS 'Ukupna vrijednost robe', SUM(pod.ReceivedQty) AS 'Ukupna kolicina robe',
SUM(IIF(pod.RejectedQty>100,1,0)) AS 'Broj stavki s odbijenom kolicinom > 100'
FROM Purchasing.PurchaseOrderDetail AS pod
JOIN Purchasing.PurchaseOrderHeader AS poh ON pod.PurchaseOrderID=poh.PurchaseOrderID
JOIN Purchasing.ShipMethod AS sm ON poh.ShipMethodID=sm.ShipMethodID
WHERE YEAR(poh.OrderDate)=2012
AND poh.Freight BETWEEN 500 AND 2500 
AND sm.Name LIKE '%CARGO%'
GROUP BY MONTH(poh.OrderDate)


--c) (10 bodova) Prikazati ukupan broj narudžbi koje su obradili uposlenici, za svakog uposlenika 
--pojedinaèno. Uslov je da su narudžbe kreirane u 2011 ili 2012 godini, te da je u okviru jedne narudžbe 
--odobren popust na dvije ili više stavki. Takoðer uzeti u obzir samo one narudžbe koje su isporuèene u 
--Veliku Britaniju, Kanadu ili Francusku. (AdventureWorks2017)

SELECT CONCAT(p.FirstName,' ',p.LastName) AS 'Ime prezime',COUNT(DISTINCT soh.SalesOrderID) AS 'Ukupno narudzbi'
FROM Person.Person AS p
JOIN Sales.SalesOrderHeader AS soh ON p.BusinessEntityID=soh.SalesPersonID
JOIN Sales.SalesTerritory AS t ON soh.TerritoryID=t.TerritoryID
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID=soh.SalesOrderID
WHERE YEAR(soh.OrderDate) IN (2011,2012) AND t.Name IN ('UK','Canada','France')
GROUP BY CONCAT(p.FirstName,' ',p.LastName) 
HAVING COUNT(DISTINCT CASE WHEN sod.UnitPriceDiscount > 0 THEN soh.SalesOrderID END) >= 2

--d) (11 bodova) Napisati upit koji æe prikazati sljedeæe podatke o proizvodima: naziv proizvoda, naziv 
--kompanije dobavljaèa, kolièinu na skladištu, te kreiranu šifru proizvoda. Šifra se sastoji od sljedeæih 
--vrijednosti: (Northwind)
--1) Prva dva slova naziva proizvoda
--2) Karakter /
--3) Prva dva slova druge rijeèi naziva kompanije dobavljaèa, uzeti u obzir one kompanije koje u 
--nazivu imaju 2 ili 3 rijeèi
--4) ID proizvoda, po pravilu ukoliko se radi o jednocifrenom broju na njega dodati slovo 'a', u 
--suprotnom uzeti obrnutu vrijednost broja
--Npr. Za proizvod sa nazivom Chai i sa dobavljaèem naziva Exotic Liquids, šifra æe btiti Ch/Li1a.

USE Northwind
GO

SELECT p.ProductName,s.CompanyName,p.UnitsInStock,
LEFT(p.ProductName, 2) + '/' + 
    LEFT(
        CASE 
            WHEN LEN(s.CompanyName) - LEN(REPLACE(s.CompanyName, ' ', '')) >= 1 
            THEN SUBSTRING(s.CompanyName, CHARINDEX(' ', s.CompanyName) + 1, LEN(s.CompanyName))
            ELSE ''
        END, 2) + 
    CASE 
        WHEN p.ProductID < 10 THEN CAST(p.ProductID AS VARCHAR(10)) + 'a'
        ELSE REVERSE(CAST(p.ProductID AS VARCHAR(10)))
    END AS 'ProductCode'
FROM Products AS p
JOIN Suppliers AS s ON p.SupplierID=s.SupplierID
WHERE LEN(s.CompanyName)-LEN(REPLACE(s.CompanyName,' ',''))>=1


--5.
--a) (3 boda) U kreiranoj bazi kreirati index kojim æe se ubrzati pretraga prema šifri i nazivu proizvoda.
--Napisati upit za potpuno iskorištenje indexa.
CREATE INDEX IX_Proizvodi_Ime_Sifra
ON Proizvodi(SifraProizvoda,Naziv)

--b) (7 bodova) U kreiranoj bazi kreirati proceduru sp_search_products kojom æe se vratiti podaci o 
--proizvodima na osnovu kategorije kojoj pripadaju ili težini. Korisnici ne moraju unijeti niti jedan od 
--parametara ali u tom sluèaju procedura ne vraæa niti jedan od zapisa. Korisnicima unosom veæ prvog 
--slova kategorije se trebaju osvježiti zapisi, a vrijednost unesenog parametra težina æe vratiti one 
--proizvode èija težina je veæa od unesene vrijednosti.

USE ispitJun2022

GO
CREATE PROCEDURE sp_search_products
(	
    @Kategorija NVARCHAR(50)=NULL,
	@Tezina DECIMAL(10,2)=NULL
)
AS BEGIN
SELECT *
FROM Proizvodi AS p
WHERE p.NazivKategorije LIKE @Kategorija+'%' OR p.Tezina>@Tezina
END

EXEC sp_search_products @Kategorija='b'
GO

--c) (18 bodova) Zbog proglašenja dobitnika nagradne igre održane u prva dva mjeseca drugog kvartala 2013 
--godine potrebno je kreirati upit. Upitom æe se prikazati treæa najveæa narudžba (vrijednost bez popusta)
--za svaki mjesec pojedinaèno. Obzirom da je u pravilima nagradne igre potrebno nagraditi 2 osobe 
--(muškarca i ženu) za svaki mjesec, potrebno je u rezultatima upita prikazati pored navedenih stavki i o 
--kojem se kupcu radi odnosno ime i prezime, te koju je nagradu osvojio. Nagrade se dodjeljuju po 
--sljedeæem pravilu:
--• za žene u prvom mjesecu drugog kvartala je stoni mikser, dok je za muškarce usisivaè
--• za žene u drugom mjesecu drugog kvartala je pegla, dok je za muškarc multicooker
--Obzirom da za kupce nije eksplicitno naveden spol, odreðivat æe se po pravilu: Ako je zadnje slovo imena 
--a, smatra se da je osoba ženskog spola u suprotnom radi se o osobi muškog spola. Rezultate u formiranoj 
--tabeli dobitnika sortirati prema vrijednosti narudžbe u opadajuæem redoslijedu. (AdventureWorks2017)

USE AdventureWorks2019
--MRSKO MI RAZMISLJAT O OVOM A NE GA RADIT 

