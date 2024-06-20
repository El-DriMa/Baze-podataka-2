--14.07.2023.
--BAZE PODATAKA II – ISPIT
--***Prilikom izrade zadataka, OBAVEZNO iznad svakog zadatka napisati redni broj zadatka i tekst. Zadaci 
--koji ne budu oznaèeni na prethodno definisan naèin neæe biti evaluirani.
--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

GO
CREATE DATABASE ispitjul2023

USE ispitjul2023

--2. U kreiranoj bazi podataka kreirati tabele sa sljedeæom strukturom:
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• Ime, 50 UNICODE (obavezan unos)
--• Prezime, 50 UNICODE (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE karaktera 

CREATE TABLE Prodavaci
(
ProdavacID INT PRIMARY KEY IDENTITY (1,1),
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
ProizvodID INT PRIMARY KEY IDENTITY(1,1),
Naziv NVARCHAR(50) NOT NULL,
SifraProizvoda NVARCHAR(25) NOT NULL,
Boja NVARCHAR(15),
NazivPodkategorije NVARCHAR(50) NOT NULL,
)

--c) ZaglavljeNarudzbe 
--• NarudzbaID, cjelobrojna vrijednost i primarni kljuè, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• KreditnaKarticaID, cjelobrojna vrijednost
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivGradaIsporuke, 30 UNICODE (obavezan unos)
--• ProdavacID, cjelobrojna vrijednost, strani kljuè
--• NacinIsporuke, 50 UNICODE (obavezan unos)

CREATE TABLE ZaglavljeNarudzbe
(
NarudzbaID INT PRIMARY KEY IDENTITY(1,1),
DatumNarudzbe DATETIME NOT NULL,
DatumIsporuke DATETIME,
KreditnaKarticaID INT,
ImeKupca NVARCHAR(50) NOT NULL,
PrezimeKupca NVARCHAR(50) NOT NULL,
NazivGradaIsporuke NVARCHAR(30) NOT NULL,
ProdavacID INT FOREIGN KEY REFERENCES Prodavaci(ProdavacID),
NacinIsporuke NVARCHAR(50) NOT NULL
)


--d) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani kljuè
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani kljuè
--• Cijena, novèani tip (obavezan unos),
--• Kolicina, skraæeni cjelobrojni tip (obavezan unos),
--• Popust, novèani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)
--**Jedan proizvod se može više puta naruèiti, dok jedna narudžba može sadržavati više proizvoda. U okviru jedne 
--narudžbe jedan proizvod se može naruèiti više puta.

CREATE TABLE DetaljiNarudzbe
(
DetaljiNarudzbeID INT PRIMARY KEY IDENTITY(1,1),
NarudzbaID INT NOT NULL CONSTRAINT FK_Detalji_Zaglavlje FOREIGN KEY REFERENCES ZaglavljeNarudzbe(NarudzbaID),
ProizvodID INT NOT NULL CONSTRAINT FK_Detalji_Proizvod FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
Cijena MONEY NOT NULL,
Kolicina TINYINT NOT NULL,
Popust MONEY NOT NULL,
OpisSpecijalnePonude NVARCHAR(255) NOT NULL
)

--9 bodova

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
FROM AdventureWorks2019.Person.Person AS p
JOIN AdventureWorks2019.HumanResources.Employee AS e ON p.BusinessEntityID=e.BusinessEntityID
JOIN AdventureWorks2019.Sales.SalesPerson AS sp ON p.BusinessEntityID=sp.BusinessEntityID
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
INSERT INTO Proizvodi(ProizvodID,Naziv,SifraProizvoda,Boja,NazivPodkategorije)
SELECT p.ProductID,p.Name,p.ProductNumber,p.Color,pc.Name
FROM AdventureWorks2019.Production.Product AS p 
JOIN AdventureWorks2019.Production.ProductCategory AS pc ON p.ProductSubcategoryID=pc.ProductCategoryID
SET IDENTITY_INSERT Proizvodi OFF

--c) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID (SalesOrderHeader) -> NarudzbaID
--• OrderDate (SalesOrderHeader)-> DatumNarudzbe
--• ShipDate (SalesOrderHeader)-> DatumIsporuke
--• CreditCardID(SalesOrderID)-> KreditnaKarticaID
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• City (Address) -> NazivGradaIsporuke
--• SalesPersonID (SalesOrderHeader)-> ProdavacID
--• Name (ShipMethod)-> NacinIsporuke

SET IDENTITY_INSERT ZaglavljeNarudzbe ON
INSERT INTO ZaglavljeNarudzbe(NarudzbaID,DatumNarudzbe,DatumIsporuke,KreditnaKarticaID,ImeKupca,PrezimeKupca,NazivGradaIsporuke,ProdavacID,NacinIsporuke)
SELECT 
soh.SalesOrderID,
soh.OrderDate,
soh.ShipDate,
soh.CreditCardID,
p.ModifiedDate,
p.LastName,
ad.City,
soh.SalesPersonID,
sm.Name
FROM AdventureWorks2019.Sales.SalesOrderHeader AS soh 
JOIN AdventureWorks2019.Sales.Customer AS c ON c.CustomerID=soh.CustomerID
JOIN AdventureWorks2019.Person.Person AS p ON p.BusinessEntityID=c.CustomerID
JOIN AdventureWorks2019.Person.EmailAddress AS ea ON p.BusinessEntityID=ea.BusinessEntityID
JOIN AdventureWorks2019.Purchasing.ShipMethod AS sm ON sm.ShipMethodID=soh.ShipMethodID
JOIN AdventureWorks2019.Person.Address AS ad ON ad.AddressID=soh.ShipToAddressID

SET IDENTITY_INSERT ZaglavljeNarudzbe OFF



--d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID (SalesOrderDetail)-> NarudzbaID
--• ProductID (SalesOrderDetail)-> ProizvodID
--• UnitPrice (SalesOrderDetail)-> Cijena
--• OrderQty (SalesOrderDetail)-> Kolicina
--• UnitPriceDiscount (SalesOrderDetail)-> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude

SET IDENTITY_INSERT DetaljiNarudzbe ON

INSERT INTO DetaljiNarudzbe (NarudzbaID,ProizvodID, Cijena, Kolicina, Popust, OpisSpecijalnePonude)
SELECT 
sod.SalesOrderID,
sod.ProductID,
sod.UnitPrice,
sod.OrderQty,
sod.UnitPriceDiscount,
so.Description
FROM AdventureWorks2019.Sales.SalesOrderDetail AS sod
JOIN AdventureWorks2019.Sales.SpecialOfferProduct AS sop ON sod.SpecialOfferID=sop.SpecialOfferID AND sod.ProductID=sop.ProductID
JOIN AdventureWorks2019.Sales.SpecialOffer AS so ON so.SpecialOfferID=sop.SpecialOfferID


SET IDENTITY_INSERT DetaljiNarudzbe OFF

--10 bodova
--4.
--a) (6 bodova) Kreirati funkciju f_detalji u formi tabele gdje korisniku slanjem parametra identifikacijski 
--broj narudžbe æe biti ispisano spojeno ime i prezime kupca, grad isporuke, ukupna vrijednost narudžbe 
--sa popustom, te poruka da li je narudžba plaæena karticom ili ne. Korisnik može dobiti 2 poruke „Plaæeno 
--karticom“ ili „Nije plaæeno karticom“. 
--OBAVEZNO kreirati testni sluèaj. (Novokreirana baza)

GO 
CREATE OR ALTER FUNCTION f_detalji
(
	@ID INT
)
RETURNS TABLE
AS RETURN
SELECT CONCAT(zn.ImeKupca,' ',zn.PrezimeKupca) AS 'Ime i prezime',zn.NazivGradaIsporuke,SUM((dn.Cijena*dn.Kolicina)*(1-dn.Popust)) AS 'Ukupno',IIF(zn.KreditnaKarticaID IS NOT NULL,'Placeno karticom','Nije placeno karticom') AS 'Poruka'
FROM ispitjul2023.dbo.ZaglavljeNarudzbe AS zn
JOIN ispitjul2023.dbo.DetaljiNarudzbe AS dn ON dn.NarudzbaID=zn.NarudzbaID
WHERE @ID=zn.NarudzbaID
GROUP BY CONCAT(zn.ImeKupca,' ',zn.PrezimeKupca),zn.NazivGradaIsporuke,IIF(zn.KreditnaKarticaID IS NOT NULL,'Placeno karticom','Nije placeno karticom')
GO

SELECT * FROM f_detalji(43660)

--b) (4 bodova) U kreiranoj bazi kreirati proceduru sp_insert_DetaljiNarudzbe kojom æe se omoguæiti insert
--nove stavke narudžbe. OBAVEZNO kreirati testni sluèaj. (Novokreirana baza)


--c) (6 bodova) Kreirati upit kojim æe se prikazati ukupan broj proizvoda po kategorijama. Korisnicima se 
--treba ispisati o kojoj kategoriji se radi. Uslov je da se prikažu samo one kategorije kojima pripada više 
--od 30 proizvoda, te da nazivi proizvoda se sastoje od 3 rijeèi, a sadrže broj u bilo kojoj od rijeèi i još 
--uvijek se nalaze u prodaji. Takoðer, ukupan broj proizvoda po kategorijama mora biti veæi od 50. 
--(AdventureWorks2017)

GO
USE AdventureWorks2019

SELECT c.Name, COUNT(*) AS 'Ukupno'
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS sc ON p.ProductSubcategoryID=sc.ProductSubcategoryID
JOIN Production.ProductCategory AS c ON c.ProductCategoryID=sc.ProductCategoryID
WHERE LEN(p.Name)-LEN(REPLACE(p.Name,' ',''))=2 AND p.Name LIKE '%[0-9]%' AND p.SellEndDate IS NULL
GROUP BY c.Name
HAVING COUNT(c.ProductCategoryID)>30 


--d) (7 bodova) Za potrebe menadžmenta kompanije potrebno je kreirati upit kojim æe se prikazati proizvodi
--koji trenutno nisu u prodaji i ne pripada kategoriji bicikala, kako bi ih ponovno vratili u prodaju.
--Proizvodu se poèetkom i po prestanku prodaje zabilježi datum. Osnovni uslov za ponovno povlaèenje u 
--prodaju je to da je ukupna prodana kolièina za svaki proizvod pojedinaèno bila veæa od 200 komada.
--Kao rezultat upita oèekuju se podaci u formatu npr. Laptop 300kom itd. (AdventureWorks2017)

SELECT p.Name,SUM(sod.OrderQty) AS 'Uupno prodano'
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS sc ON p.ProductSubcategoryID=sc.ProductSubcategoryID
JOIN Production.ProductCategory AS c ON c.ProductCategoryID=sc.ProductCategoryID
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID=sod.ProductID
WHERE p.SellEndDate IS NOT NULL AND LOWER(c.Name) NOT LIKE 'bikes'
GROUP BY p.Name
HAVING SUM(sod.OrderQty)>200

--e) (7 bodova) Kreirati upit kojim æe se prikazati identifikacijski broj narudžbe, spojeno ime i prezime kupca, 
--te ukupna vrijednost narudžbe koju je kupac platio. Uslov je da je od datuma narudžbe do datuma 
--isporuke proteklo manje dana od prosjeènog broja dana koji je bio potreban za isporuku svih narudžbi. 
--(AdventureWorks2017)

SELECT soh.SalesOrderID,CONCAT(p.FirstName,' ',p.LastName) AS 'Ime prezime kupca',soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Customer AS c ON c.CustomerID=soh.CustomerID
JOIN Person.Person AS p ON c.PersonID=p.BusinessEntityID
WHERE DATEDIFF(DAY,soh.OrderDate,soh.ShipDate)<(SELECT AVG(DATEDIFF(DAY,soh.OrderDate,soh.ShipDate))
												FROM Sales.SalesOrderHeader AS soh)										



--30 bodova
--5.
--a) (9 bodova) Kreirati upit koji æe prikazati one naslove kojih je ukupno prodano više od 30 komada a 
--napisani su od strane autora koji su napisali 2 ili više djela/romana. U rezultatima upita prikazati naslov 
--i ukupnu prodanu kolièinu. (Pubs) 

GO
USE pubs

SELECT t.title_id,t.title,SUM(s.qty) AS 'Kolicin'
FROM titles AS t
JOIN sales AS s ON t.title_id=s.title_id
WHERE t.title_id IN (SELECT ta.title_id
					FROM titleauthor AS ta
					WHERE ta.au_id IN 
						(SELECT ta.au_id
						FROM titleauthor AS ta
						GROUP BY ta.au_id 
						HAVING COUNT(*)>=2))
GROUP BY t.title_id,t.title
HAVING SUM(s.qty)>30



--b) (10 bodova) Kreirati upit koji æe u % prikazati koliko je narudžbi (od ukupnog broja kreiranih) 
--isporuèeno na svaku od teritorija pojedinaèno. Npr Australia 20.2%, Canada 12.01% itd. Vrijednosti 
--dobijenih postotaka zaokružiti na dvije decimale i dodati znak %. (AdventureWorks2017)

GO
USE AdventureWorks2019


SELECT PODQ.Name,PODQ.[Ukupno narudzbi],ROUND(
(PODQ.[Ukupno narudzbi]*1.0/(SELECT COUNT(*) FROM Sales.SalesOrderHeader ))*100,2) AS 'Ukuno %'
FROM (SELECT st.Name,COUNT(*) AS 'Ukupno narudzbi'
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesTerritory AS st ON st.TerritoryID=soh.TerritoryID
GROUP BY st.Name) AS PODQ

SELECT * FROM Production.Product

--c) (12 bodova) Kreirati upit koji æe prikazati osobe koje imaju redovne prihode a nemaju vanredne, i one 
--koje imaju vanredne a nemaju redovne. Lista treba da sadrži spojeno ime i prezime osobe, grad i adresu 
--stanovanja i ukupnu vrijednost ostvarenih prihoda (za redovne koristiti neto). Pored navedenih podataka 
--potrebno je razgranièiti kategorije u novom polju pod nazivom Opis na naèin "ISKLJUÈIVO 
--VANREDNI" za one koji imaju samo vanredne prihode, ili "ISKLJUÈIVO REDOVNI" za one koji 
--imaju samo redovne prihode. Konaène rezultate sortirati prema opisu abecedno i po ukupnoj vrijednosti 
--ostvarenih prihoda u opadajuæem redoslijedu. (prihodi)

GO 
USE prihodi

SELECT CONCAT(o.Ime,' ',o.PrezIme) AS 'Ime i prezime',g.Grad,o.Adresa,SUM(rp.Neto) AS 'Iznos','Iskljucivo redovni' AS 'Opis'
FROM Osoba AS o 
JOIN Grad AS g ON o.GradID=g.GradID
JOIN RedovniPrihodi AS rp ON rp.OsobaID=o.OsobaID
WHERE o.OsobaID NOT IN (SELECT vp.OsobaID FROM VanredniPrihodi AS vp WHERE vp.OsobaID IS NOT NULL)
GROUP BY CONCAT(o.Ime,' ',o.PrezIme),g.Grad,o.Adresa
UNION
SELECT CONCAT(o.Ime,' ',o.PrezIme) AS 'Ime i prezime',g.Grad,o.Adresa,SUM(vp.IznosVanrednogPrihoda) AS 'Iznos','Iskljucivo vanredni' AS 'Opis'
FROM Osoba AS o 
JOIN Grad AS g ON o.GradID=g.GradID
JOIN VanredniPrihodi AS vp ON vp.OsobaID=o.OsobaID
WHERE o.OsobaID NOT IN (SELECT rp.OsobaID FROM RedovniPrihodi AS rp WHERE rp.OsobaID IS NOT NULL)
GROUP BY CONCAT(o.Ime,' ',o.PrezIme),g.Grad,o.Adresa
ORDER BY 4,5 DESC


--31 bod
--6. Dokument teorijski_ispit 14JUL23, preimenovati vašim brojem indeksa, te u tom dokumentu izraditi pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem indeksa npr IB210001.sql, teorijski dokument imenovan 
--Vašim brojem indexa npr IB210001.docx upload-ovati ODVOJEDNO na ftp u folder Upload.
--Maksimalan broj bodova:100 
--Prag prolaznosti: 55
