--22.09.2023.
--BAZE PODATAKA II – ISPIT
--***Prilikom izrade zadataka, OBAVEZNO iznad svakog zadatka napisati redni broj zadatka i tekst. Zadaci 
--koji ne budu oznaèeni na prethodno definisan naèin neæe biti evaluirani.
--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

GO
CREATE DATABASE ispitsep2023

USE ispitsep2023
--2. U kreiranoj bazi podataka kreirati tabele sa sljedeæom strukturom:
--a) Uposlenici
--• UposlenikID, 9 karaktera fiksne dužine i primarni kljuè,
--• Ime, 20 karaktera (obavezan unos),
--• Prezime, 20 karaktera (obavezan unos),
--• DatumZaposlenja, polje za unos datuma i vremena (obavezan unos),
--• OpisPosla, 50 karaktera (obavezan unos)

CREATE TABLE Uposlenici 
(
UposlenikID CHAR(9) CONSTRAINT PK_Uposlenik  PRIMARY KEY,
Ime NVARCHAR(20) NOT NULL,
Prezime NVARCHAR(20) NOT NULL,
DatumZaposlenja DATETIME NOT NULL,
OpisPosla NVARCHAR(50) NOT NULL
)

--b) Naslovi
--• NaslovID, 6 karaktera i primarni kljuè,
--• Naslov, 80 karaktera (obavezan unos),
--• Tip, 12 karaktera fiksne dužine (obavezan unos),
--• Cijena, novèani tip podataka,
--• NazivIzdavaca, 40 karaktera,
--• GradIzadavaca, 20 karaktera,
--• DrzavaIzdavaca, 30 karaktera

CREATE TABLE Naslovi
(
NaslovID NVARCHAR(6) CONSTRAINT PK_Naslovi PRIMARY KEY,
Naslov NVARCHAR(80) NOT NULL,
Tip CHAR(12) NOT NULL,
Cijena MONEY,
NazivIzdavaca NVARCHAR(40),
GradIzadavaca NVARCHAR(20),
DrzavaIzdavaca NVARCHAR(30)
)


--d) Prodavnice
--• ProdavnicaID, 4 karaktera fiksne dužine i primarni kljuè,
--• NazivProdavnice, 40 karaktera,
--• Grad, 40 karaktera

CREATE TABLE Prodavnice
(
ProdavnicaID CHAR(4) CONSTRAINT PK_Prodavnica PRIMARY KEY,
NazivProdavnice NVARCHAR(40),
Grad NVARCHAR(40)
)

--c) Prodaja
--• ProdavnicaID, 4 karaktera fiksne dužine, strani i primarni kljuè,
--• BrojNarudzbe, 20 karaktera, primarni kljuè,
--• NaslovID, 6 karaktera, strani i primarni kljuè,
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos),
--• Kolicina, skraæeni cjelobrojni tip (obavezan unos)

CREATE TABLE Prodaja
(
ProdavnicaID CHAR(4) CONSTRAINT FK_Prodaja_Prodavnica FOREIGN KEY REFERENCES Prodavnice(ProdavnicaID),
BrojNarudzbe NVARCHAR(20),
NaslovID NVARCHAR(6) CONSTRAINT FK_Prodaja_Naslovi FOREIGN KEY REFERENCES Naslovi(NaslovID),
DatumNarudzbe DATETIME NOT NULL,
Kolicina TINYINT NOT NULL
CONSTRAINT PK_Prodaja PRIMARY KEY(ProdavnicaID,BrojNarudzbe,NaslovID)
)
--6 bodova
--3. Iz baze podataka Pubs u svoju bazu podataka prebaciti sljedeæe podatke:
--a) U tabelu Uposlenici dodati sve uposlenike
--• emp_id -> UposlenikID
--• fname -> Ime
--• lname -> Prezime
--• hire_date -> DatumZaposlenja
--• job_desc -> OpisPosla

INSERT INTO Uposlenici
SELECT e.emp_id,e.fname,e.lname,e.hire_date,j.job_desc
FROM pubs.dbo.employee AS e
JOIN pubs.dbo.jobs AS j ON e.job_id=j.job_id

--b) U tabelu Naslovi dodati sve naslove, na mjestima gdje nema pohranjenih podataka o nazivima izdavaèa
--zamijeniti vrijednost sa nepoznat izdavac
--• title_id -> NaslovID
--• title -> Naslov
--• type -> Tip
--• price -> Cijena
--• pub_name -> NazivIzdavaca
--• city -> GradIzdavaca
--• country -> DrzavaIzdavaca

INSERT INTO Naslovi
SELECT t.title_id,t.title,t.type,t.price,ISNULL(p.pub_name,'nepoznat izdavac'),p.city,p.country
FROM pubs.dbo.titles AS t
JOIN pubs.dbo.publishers AS p ON t.pub_id=p.pub_id

--c) U tabelu Prodaja dodati sve stavke iz tabele prodaja
--• stor_id -> ProdavnicaID
--• order_num -> BrojNarudzbe
--• title_id -> NaslovID
--• ord_date -> DatumNarudzbe
--• qty -> Kolicina

INSERT INTO Prodaja
SELECT s.stor_id,s.ord_num,s.title_id,s.ord_date,s.qty
FROM pubs.dbo.sales AS s

--22.09.2023.
--d) U tabelu Prodavnice dodati sve prodavnice
--• stor_id -> ProdavnicaID
--• store_name -> NazivProdavnice
--• city -> Grad

INSERT INTO Prodavnice
SELECT s.stor_id,s.stor_name,s.city
FROM pubs.dbo.stores AS s

--6 bodova
--4.
--a) (6 bodova) Kreirati proceduru sp_update_naslov kojom æe se uraditi update podataka u tabelu Naslovi.
--Korisnik može da pošalje jedan ili više parametara i pri tome voditi raèuna da se ne desi gubitak/brisanje 
--zapisa. OBAVEZNO kreirati testni sluèaj za kreiranu proceduru. (Novokreirana baza)

GO
CREATE PROCEDURE sp_update_naslov
(
@NaslovID NVARCHAR(6),
@Naslov NVARCHAR(80)=NULL,
@Tip CHAR(12)=NULL,
@Cijena MONEY=NULL,
@NazivIzdavaca NVARCHAR(40)=NULL,
@GradIzadavaca NVARCHAR(20)=NULL,
@DrzavaIzdavaca NVARCHAR(30)=NULL
)
AS BEGIN
UPDATE Naslovi
SET Naslov=ISNULL(@Naslov,Naslov),
Tip=ISNULL(@Tip,Tip),
Cijena=ISNULL(@Cijena,Cijena),
NazivIzdavaca=ISNULL(@NazivIzdavaca,NazivIzdavaca),
GradIzadavaca=ISNULL(@GradIzadavaca,GradIzadavaca),
DrzavaIzdavaca=ISNULL(@DrzavaIzdavaca,DrzavaIzdavaca)
WHERE NaslovID=@NaslovID
END
GO

exec sp_update_naslov @NaslovID=BU1032,@Naslov='amnaaaaaa'

SELECT * FROM Naslovi


--b) (7 bodova) Kreirati upit kojim æe se prikazati ukupna prodana kolièina i ukupna zarada bez popusta za 
--svaku kategoriju proizvoda pojedinaèno. Uslov je da proizvodi ne pripadaju kategoriji bicikala, da im je 
--boja bijela ili crna te da ukupna prodana kolièina nije veæa od 20000. Rezultate sortirati prema ukupnoj 
--zaradi u opadajuæem redoslijedu. (AdventureWorks2017)

GO
USE AdventureWorks2019

SELECT c.Name,SUM(sod.OrderQty) AS 'Ukuppno prodana kolicina',SUM(sod.OrderQty*sod.UnitPrice) AS 'Ukupna zarada bez popusta'
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS sc ON p.ProductSubcategoryID=sc.ProductSubcategoryID
JOIN Production.ProductCategory AS c ON c.ProductCategoryID=sc.ProductCategoryID
JOIN Sales.SalesOrderDetail AS sod ON sod.ProductID=p.ProductID
WHERE c.Name NOT LIKE 'Bikes'  AND p.Color IN ('Black','White')
GROUP BY c.Name
HAVING SUM(sod.OrderQty)<20000
ORDER BY 3 DESC

--c) (8 bodova) Kreirati upit koji prikazuje kupce koji su u maju mjesecu 2013 ili 2014 godine naruèili 
--proizvod „Front Brakes“ u kolièini veæoj od 5. Upitom prikazati spojeno ime i prezime kupca, email, 
--naruèenu kolièinu i datum narudžbe formatiran na naèin dan.mjesec.godina (AdventureWorks2017)

SELECT CONCAT(p.FirstName,' ',p.LastName) AS 'Ime i prezime',ea.EmailAddress,sod.OrderQty,FORMAT(soh.OrderDate,'dd.MM.yyyy'),pr.Name
FROM Sales.Customer AS c 
JOIN Person.Person AS p ON c.PersonID=p.BusinessEntityID
JOIN Person.BusinessEntity AS be ON p.BusinessEntityID=be.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON soh.CustomerID=c.CustomerID
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID=soh.SalesOrderID
JOIN Person.EmailAddress AS ea ON ea.BusinessEntityID=be.BusinessEntityID
JOIN Production.Product AS pr ON pr.ProductID=sod.ProductID
WHERE YEAR(soh.OrderDate) IN (2014,2013) AND MONTH(soh.OrderDate)=5 AND pr.Name='Front Brakes' AND sod.OrderQty>5

--d) (10 bodova) Kreirati upit koji æe prikazati naziv kompanije dobavljaèa koja je dobavila proizvode, koji 
--se u najveæoj kolièini prodaju (najprodavaniji). Uslov je da proizvod pripada kategoriji morske hrane i 
--da je dostavljen/isporuèen kupcu. Takoðer uzeti u obzir samo one proizvode na kojima je popust odobren.
--U rezultatima upita prikazati naziv kompanije dobavljaèa i ukupnu prodanu kolièinu proizvoda.
--(Northwind)

GO 
USE Northwind

SELECT TOP 1  s.CompanyName,SUM(od.Quantity) AS 'Kolicina'
FROM dbo.Suppliers AS s
JOIN dbo.Products AS p ON p.SupplierID=s.SupplierID
JOIN dbo.Categories AS c ON c.CategoryID=p.CategoryID
JOIN dbo.[Order Details] AS od ON od.ProductID=p.ProductID
JOIN dbo.Orders AS o ON o.OrderID=od.OrderID
WHERE c.CategoryName LIKE 'Sea%' AND o.ShippedDate IS NOT NULL AND od.Discount>0
GROUP BY s.CompanyName
ORDER BY 2 DESC


--e) (11 bodova) Kreirati upit kojim æe se prikazati narudžbe u kojima je na osnovu popusta kupac uštedio 
--2000KM i više. Upit treba da sadrži identifikacijski broj narudžbe, spojeno ime i prezime kupca, te 
--stvarnu ukupnu vrijednost narudžbe zaokruženu na 2 decimale. Rezultate sortirati po ukupnoj vrijednosti 
--narudžbe u opadajuæem redoslijedu.

GO
USE AdventureWorks2019

SELECT soh.SalesOrderID,CONCAT(p.FirstName,' ',p.LastName) AS 'Ime i prezime',CAST(SUM(sod.LineTotal) AS DECIMAL(18,2)) AS 'Ukupna vrijednost'
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Customer AS c ON c.CustomerID=soh.CustomerID
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID=soh.SalesOrderID
JOIN Person.Person AS p ON p.BusinessEntityID=c.PersonID
GROUP BY soh.SalesOrderID,CONCAT(p.FirstName,' ',p.LastName)
HAVING SUM(sod.OrderQty*sod.UnitPrice)-SUM(sod.LineTotal)>=2000
ORDER BY 3 DESC

-- 43 boda
--5.
--a) (13 bodova) Kreirati upit koji æe prikazati kojom kompanijom (ShipMethod(Name)) je isporuèen najveæi 
--broj narudžbi, a kojom najveæa ukupna kolièina proizvoda. (AdventureWorks2017)

GO
USE AdventureWorks2019

SELECT * FROM
(SELECT TOP 1 sm.Name,SUM(sod.OrderQty) AS 'Ukupna kolicina proizvoda'
FROM Purchasing.ShipMethod AS sm
JOIN Sales.SalesOrderHeader AS soh ON soh.ShipMethodID=sm.ShipMethodID
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID=sod.SalesOrderID
GROUP BY sm.Name
ORDER BY 2 DESC) AS PODQ1
UNION
SELECT * FROM
(SELECT TOP 1 sm.Name,COUNT(soh.SalesOrderID) AS 'Ukupan broj narudzbi'
FROM Purchasing.ShipMethod AS sm
JOIN Sales.SalesOrderHeader AS soh ON soh.ShipMethodID=sm.ShipMethodID
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID=sod.SalesOrderID
GROUP BY sm.Name
ORDER BY 2 DESC) AS PODQ2




--b) (8 bodova) Modificirati prethodno kreirani upit na naèin ukoliko je jednom kompanijom istovremeno 
--isporuèen najveæi broj narudžbi i najveæa ukupna kolièina proizvoda upitom prikazati poruku „Jedna 
--kompanija“, u suprotnom „Više kompanija“ (AdventureWorks2017)

SELECT IIF(COUNT(DISTINCT PODQ.Name)<2,'Jedna kompanija','Vise kompanija')
FROM
(SELECT * FROM
	(SELECT TOP 1 sm.Name,SUM(sod.OrderQty) AS 'Ukupna kolicina proizvoda'
	FROM Purchasing.ShipMethod AS sm
	JOIN Sales.SalesOrderHeader AS soh ON soh.ShipMethodID=sm.ShipMethodID
	JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID=sod.SalesOrderID
	GROUP BY sm.Name
	ORDER BY 2 DESC) AS PODQ1
UNION
	SELECT * FROM
	(SELECT TOP 1 sm.Name,COUNT(soh.SalesOrderID) AS 'Ukupan broj narudzbi'
	FROM Purchasing.ShipMethod AS sm
	JOIN Sales.SalesOrderHeader AS soh ON soh.ShipMethodID=sm.ShipMethodID
	JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID=sod.SalesOrderID
	GROUP BY sm.Name
	ORDER BY 2 DESC) AS PODQ2 )AS PODQ


--c) (4 boda) Kreirati indeks IX_Naslovi_Naslov kojim æe se ubrzati pretraga prema naslovu. OBAVEZNO 
--kreirati testni sluèaj. (NovokreiranaBaza)

USE ispitsep2023

CREATE INDEX IX_Naslovi_Naslov
ON Naslovi(Naslov)

SELECT n.Naslov
FROM Naslovi AS n

--25 bodova
--6. Dokument teorijski_ispit 22SEP23, preimenovati vašim brojem indeksa, te u tom dokumentu izraditi pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem indeksa npr IB210001.sql, teorijski dokument imenovan 
--Vašim brojem indexa npr IB210001.docx upload-ovati ODVOJEDNO na ftp u folder Upload.
--Maksimalan broj bodova:100 
--Prag prolaznosti: 55