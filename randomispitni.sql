--neki random zadaci sa proslih ispita
--1.(6 bodova) Kreirati upit koji æe prikazati ukupan broj uposlenika po odjelima. Potrebno je prebrojati 
--samo one uposlenike koji su trenutno aktivni, odnosno rade na datom odjelu. Takoðer, samo uzeti u obzir 
--one uposlenike koji imaju više od 10 godina radnog staža (ne ukljuèujuæi graniènu vrijednost). Rezultate 
--sortirati preba broju uposlenika u opadajuæem redoslijedu. (AdventureWorks2017)

GO
USE AdventureWorks2019

SELECT d.Name,COUNT(*) AS 'Broj uposlenika'
FROM HumanResources.EmployeeDepartmentHistory AS ed
JOIN HumanResources.Employee AS e ON ed.BusinessEntityID=e.BusinessEntityID
JOIN HumanResources.Department AS d ON ed.DepartmentID=d.DepartmentID
WHERE ED.EndDate IS NULL AND DATEDIFF(YEAR,e.HireDate,GETDATE())>10
GROUP BY d.Name
ORDER BY 2 DESC

--2.a) (3 boda) U kreiranoj bazi kreirati index kojim æe se ubrzati pretraga prema šifri i nazivu proizvoda.
--Napisati upit za potpuno iskorištenje indexa.1

USE View_

CREATE INDEX IX_pretraga_ime
ON Osoba(Ime)

--(7 bodova) U kreiranoj bazi kreirati proceduru sp_search_products kojom æe se vratiti podaci o 
--proizvodima na osnovu bilo kojeg parametra Korisnici ne moraju unijeti niti jedan od 
--parametara ali u tom sluèaju procedura ne vraæa niti jedan od zapisa. Korisnicima unosom veæ prvog 
--slova kategorije se trebaju osvježiti zapisi.

USE ispitJun2022

GO
CREATE PROCEDURE sp_pretraga_proizvoda
(
	@Naziv NVARCHAR(50)=NULL,
	@SifraProizvoda NVARCHAR(25)=NULL,
	@Boja NVARCHAR(15)=NULL,
	@NazivKategorije NVARCHAR(50)=NULL,
	@Tezina DECIMAL(10,2)=NULL
)
AS BEGIN
SELECT *
FROM Proizvodi
WHERE Naziv LIKE @Naziv +'%' OR SifraProizvoda LIKE @SifraProizvoda +'%' OR Boja LIKE @Boja +'%' OR NazivKategorije LIKE @NazivKategorije +'%' OR Tezina=@Tezina
END

--drop procedure sp_pretraga_proizvoda
EXEC sp_pretraga_proizvoda @Naziv='H'

--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

GO
CREATE DATABASE randomIspit

USE randomIspit
--2. U kreiranoj bazi podataka kreirati tabele sa sljedeæom strukturom:
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• Ime, 50 UNICODE (obavezan unos)
--• Prezime, 50 UNICODE (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE karaktera 

CREATE TABLE Prodavaci
(
ProdavacID INT CONSTRAINT PK_Prodavaci PRIMARY KEY IDENTITY(1,1),
Ime NVARCHAR(50) NOT NULL,
Prezime NVARCHAR(50) NOT NULL,
OpisPosla NVARCHAR(50) NOT NULL,
EmailAdresa NVARCHAR(50)
)

--b) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera 
--• NazivPodkategorije, 50 UNICODE (obavezan unos)

CREATE TABLE Proizvodi 
(
ProizvodID INT CONSTRAINT PK_Proizvodi PRIMARY KEY IDENTITY(1,1),
Naziv NVARCHAR(50) NOT NULL,
SifraProizvoda NVARCHAR(25) NOT NULL,
Boja NVARCHAR(15),
NazivPodaktegorije NVARCHAR(50) NOT NULL
)

--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeæe podatke:
--a) U tabelu Prodavaci dodati sve prodavaèe
--• BusinessEntityID (SalesPerson) -> ProdavacID
--• FirstName (Person) -> Ime
--• LastName (Person) -> Prezime
--• JobTitle (Employee) -> OpisPosla
--• EmailAddress (EmailAddress) -> EmailAdresa

SET IDENTITY_INSERT Prodavaci ON
INSERT INTO Prodavaci(ProdavacID,Ime,Prezime,OpisPosla,EmailAdresa)
SELECT 
sp.BusinessEntityID,
p.FirstName,
p.LastName,
e.JobTitle,
ea.EmailAddress
FROM AdventureWorks2019.Sales.SalesPerson AS sp
JOIN AdventureWorks2019.Person.Person AS p ON sp.BusinessEntityID=p.BusinessEntityID
JOIN AdventureWorks2019.HumanResources.Employee AS e ON e.BusinessEntityID=p.BusinessEntityID
JOIN AdventureWorks2019.Person.EmailAddress AS ea ON ea.BusinessEntityID=p.BusinessEntityID

SET IDENTITY_INSERT Prodavaci OFF

SELECT * FROM Prodavaci


--b) U tabelu Proizvodi dodati sve proizvode
--• ProductID (Product)-> ProizvodID
--• Name (Product)-> Naziv
--• ProductNumber (Product)-> SifraProizvoda
--• Color (Product)-> Boja 
--• Name (ProductSubategory) -> NazivPodkategorije

SET IDENTITY_INSERT Proizvodi ON 
INSERT INTO Proizvodi(ProizvodID,Naziv,SifraProizvoda,Boja,NazivPodaktegorije)
SELECT 
p.ProductID,
p.Name,
p.ProductNumber,
p.Color,
ps.Name
FROM AdventureWorks2019.Production.Product AS p
JOIN AdventureWorks2019.Production.ProductSubcategory AS ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID

SET IDENTITY_INSERT Proizvodi OFF

SELECT * FROM Proizvodi

--a)(6 bodova) kreirati pogled v_detalji gdje je korisniku potrebno prikazati identifikacijski broj narudzbe,
--spojeno ime i prezime kupca, grad isporuke, ukupna vrijednost narudzbe sa popustom i bez popusta, te u dodatnom polju informacija da li je narudzba placena karticom ("Placeno karticom" ili "Nije placeno karticom").
--Rezultate sortirati prema vrijednosti narudzbe sa popustom u opadajucem redoslijedu.
--OBAVEZNO kreirati testni slucaj.(Novokreirana baza)


USE ispitJun2022

GO
CREATE VIEW v_detaljiOpet
AS
SELECT CONCAT(zn.ImeKupca,' ',zn.PrezimeKupca) AS 'Ime prezime',zn.NazivRegije,SUM(dn.Cijena*dn.Kolicina) AS 'Bez popusta',
SUM(dn.Cijena*dn.Kolicina*(1-dn.Popust)) AS 'Sa popustom',IIF(zn.NacinIsporuke IS NULL,'Bez kartice','Sa karticom') AS 'Placanje'
FROM ZaglavljeNarudzbe AS zn
JOIN DetaljiNarudzbe AS dn ON dn.NarudzbaID=zn.NarudzbaID
GROUP BY CONCAT(zn.ImeKupca,' ',zn.PrezimeKupca),zn.NazivRegije,zn.NacinIsporuke
GO

SELECT * FROM v_detaljiOpet ORDER BY 4 DESC

--b)( 4 bodova) U kreiranoj bazi kreirati wproceduru sp_insert_ZaglavljeNarudzbe kojom ce se omoguciti kreiranje nove narudzbe.
--OBAVEZNO kreirati testni slucaj.(Novokreirana baza).

GO
CREATE PROCEDURE sp_Insert_ZN
(
@DatumNarudzbe DATETIME,
@DatumIsporuke DATETIME,
@ImeKupca NVARCHAR(50),
@PrezimeKupca NVARCHAR(50),
@NazivTeritorije NVARCHAR(50),
@NazivRegije NVARCHAR(50),
@NacinIsporuke NVARCHAR(50)
)
AS BEGIN
INSERT INTO ZaglavljeNarudzbe
VALUES (@DatumNarudzbe,@DatumIsporuke,@ImeKupca,@PrezimeKupca,@NazivTeritorije,@NazivRegije,@NacinIsporuke)
END
GO


--c)(6 bodova) Kreirati upit kojim ce se prikazati ukupan broj proizvoda po kategorijama. 
--Uslov je da se prikazu samo one kategorije kojima ne pripada vise od 30 proizvoda, 
--a sadrze broj u bilo kojoj od rijeci imena proizvoda (AdventureWorks2017)

GO
USE AdventureWorks2019

SELECT pc.Name,COUNT(*) AS 'Ukupan br proizvoda' 
FROM Production.Product AS p 
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID=pc.ProductCategoryID
WHERE  p.Name LIKE '%[0-9]%'
GROUP BY pc.Name
HAVING COUNT(*)<30



--d)(7 bodova) Kreirati upit koji ce prikazati uposlenike koji imaju iskustva(radilli su na jednom odjelu)
--a trenutno rade na marketing ili odjelu za nabavku. 
--Osobama po prestanku rada na odjelu se upise podatak datuma prestanka rada.
--Rezultat upita treba prikazati ime i prezime uposlenika, odjel na kojem rade.
--(AdventureWorks2017)

SELECT CONCAT(p.FirstName,' ',p.LastName) AS 'Ime prezime',d.Name
FROM HumanResources.Employee AS e
JOIN HumanResources.EmployeeDepartmentHistory AS edh ON e.BusinessEntityID=edh.BusinessEntityID
JOIN HumanResources.Department AS d ON edh.DepartmentID=d.DepartmentID
JOIN Person.Person AS p ON e.BusinessEntityID=p.BusinessEntityID
WHERE (d.Name LIKE 'Marketing' OR d.Name LIKE 'Purchasing')  AND edh.EndDate IS NULL
AND edh.BusinessEntityID IN (SELECT edh2.BusinessEntityID 
		FROM HumanResources.EmployeeDepartmentHistory AS edh2 
		GROUP BY edh2.BusinessEntityID 
		HAVING COUNT(edh2.BusinessEntityID)>=2)



--e)(7 bodova) Kreirati upit kojim ce se prikazati proizvod koji je najvise dana bio u prodaji( njegova prodaja je prestala) 
--a pripada kategoriji bicikala. Proizvodu se pocetkom i po prestanku prodaje biljezi datum.
--Ukoliko postoji vise proizvoda sa istim vremenskim periodom kao i prvi prikazati ih u rezultatima upita.
--(AdventureWorks2017)


USE AdventureWorks2019

SELECT TOP 1 WITH TIES p.Name,pc.Name,DATEDIFF(DAY,p.SellStartDate,p.SellEndDate) AS 'Br dana'
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON pc.ProductCategoryID=ps.ProductCategoryID
WHERE p.SellEndDate IS NOT NULL AND pc.Name LIKE 'Bikes'
ORDER BY 3 DESC

--a) (9 bodova) Prikazati nazive odjela na kojima TRENUTNO radi najmanje , odnosno najvise uposlenika(AdventureWorks2017)

SELECT *
FROM(
SELECT TOP 1 d.Name,COUNT (*) AS 'Br uposlenika'
FROM HumanResources.EmployeeDepartmentHistory AS edh
JOIN HumanResources.Employee AS e ON edh.BusinessEntityID=e.BusinessEntityID
JOIN HumanResources.Department AS d ON edh.DepartmentID=d.DepartmentID
GROUP BY d.Name
ORDER BY COUNT (*)  DESC) AS A
UNION
SELECT * 
FROM (
SELECT TOP 1 d.Name,COUNT (*) AS 'Br uposlenika'
FROM HumanResources.EmployeeDepartmentHistory AS edh
JOIN HumanResources.Employee AS e ON edh.BusinessEntityID=e.BusinessEntityID
JOIN HumanResources.Department AS d ON edh.DepartmentID=d.DepartmentID
GROUP BY d.Name
ORDER BY COUNT (*) ASC) AS B


--b)(10 bodova) Kreirati upit kojim ce se prikazati ukupan broj obradjenih narudzbi i ukupnu vrijednost narudzbi sa popustom za svakog 
--uposlenika pojedinacno, i to od zadnje 30% kreiranih datumski kreiranih narudzbi. 
--Rezultate sortirati prema ukupnoj vrijednosti u opadajucem redoslijedu.
--(AdventureWorks2017)

SELECT CONCAT(p.FirstName,' ',p.LastName) AS 'Uposlenik', COUNT(*) AS 'Ukupan br narudzbi', SUM(soh.TotalDue) AS 'Ukupna vrijednost'
FROM Sales.SalesOrderDetail AS sod 
JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID=soh.SalesOrderID
JOIN Sales.SalesPerson AS sp ON soh.SalesPersonID=sp.BusinessEntityID
JOIN HumanResources.Employee AS e ON sp.BusinessEntityID=e.BusinessEntityID
JOIN Person.Person AS p ON p.BusinessEntityID=e.BusinessEntityID
WHERE soh.SalesOrderID IN(SELECT TOP 30 PERCENT soh1.SalesOrderID
			  FROM Sales.SalesOrderHeader AS soh1
			  ORDER BY soh1.OrderDate DESC)
GROUP BY CONCAT(p.FirstName,' ',p.LastName)
ORDER BY 2 DESC




