--1.Kroz SQL kod kreirati bazu podataka Vjezba2
CREATE DATABASE db2v2
USE db2v2

--2.U pomenutoj bazi kreirati šemu Prodaja
GO
CREATE SCHEMA Prodaja
GO

--3.U šemi Prodaja kreirati tabele sa sljedećom strukturom:
CREATE TABLE Prodaja.Autori(
AutorID NVARCHAR(11) CONSTRAINT PK_Autori PRIMARY KEY,
Prezime NVARCHAR(40) NOT NULL,
Ime NVARCHAR(20) NOT NULL,
Telefon CHAR(12) DEFAULT 'nepoznato',
Adresa NVARCHAR(40),
SaveznaDrzava CHAR(2),
PostanskiBroj CHAR(5),
Ugovor BIT NOT NULL
)



CREATE TABLE Prodaja.Knjige(
KnjigaID VARCHAR(6) CONSTRAINT PK_Knjige PRIMARY KEY,
Naziv VARCHAR(80) NOT NULL,
Vrsta CHAR(12) NOT NULL,
IzdavacID CHAR(4), 
Cijena MONEY,
Biljeska VARCHAR(200),
Datum DATETIME
)

--4.Upotrebom insert naredbe iz tabele Publishers baze Pubs izvršiti kreiranje i insertovanje podataka u tabelu --Izdavaci šeme Prodaja (Nazivi kolona trebaju biti na bosanskom jeziku)SELECT p.pub_id AS IzadavacID,p.pub_name AS NazivIzdavaca,p.city AS Grad,p.state AS SaveznaDrzava,p.country AS DrzavaINTO Prodaja.IzdavaciFROM pubs.dbo.publishers AS p--5.U kreiranoj tabeli Izdavaci provjeriti koje polje je primarni ključ, ukoliko ga nema, prikladno polje proglasiti primarnim ključem ALTER TABLE Prodaja.IzdavaciADD CONSTRAINT PK_Izdavaci PRIMARY KEY(IzadavacID)--6.Povezati tabelu Izdavaci sa tabelom Knjige, po uzoru na istoimene tabele baze PubsALTER TABLE Prodaja.KnjigeADD CONSTRAINT FK_Knjige_Izdavaci FOREIGN KEY(IzdavacID) REFERENCES Prodaja.Izdavaci(IzadavacID)--7.U šemu Prodaja dodati tabelu sa sljedećom strukturomCREATE TABLE Prodaja.AutoriKnjige(AutorID NVARCHAR(11) CONSTRAINT FK_AutoriKnjige_Autori FOREIGN KEY REFERENCES Prodaja.Autori(AutorID),
KnjigaID VARCHAR(6) CONSTRAINT FK_AutoriKnjige_Knjige FOREIGN KEY REFERENCES Prodaja.Knjige(KnjigaID),
AuOrd TINYINT,
CONSTRAINT PK_AutoriKnjige PRIMARY KEY(AutorID,KnjigaID)
)

--8.U kreirane tabele izvršiti insert podataka iz baze Pubs 
--(Za polje biljeska tabele Knjige na mjestima gdje je vrijednost NULL pohraniti „nepoznata vrijednost“)

INSERT INTO Prodaja.Autori
SELECT a.au_id,a.au_lname,a.au_fname,a.phone,a.address,a.state,a.zip,a.contract 
FROM pubs.dbo.Authors AS a

INSERT INTO Prodaja.Knjige
SELECT t.title_id,t.title,t.type,t.pub_id,t.price,ISNULL(t.notes,'nepoznata vrijednost'),t.pubdate
FROM pubs.dbo.titles AS t

INSERT INTO Prodaja.AutoriKnjige
SELECT ta.au_id,ta.title_id,ta.au_ord
FROM pubs.dbo.titleauthor AS ta

--9.U tabeli Autori nad kolonom Adresa promijeniti tip podatka na nvarchar (40) 
ALTER TABLE Prodaja.Autori
ALTER COLUMN Adresa NVARCHAR(40)


--10.Prikazati sve autore čije ime počinje sa slovom A ili S
SELECT *
FROM Prodaja.Autori AS a
WHERE a.Ime LIKE 'A%' OR a.Ime LIKE 'S%'

--11.Prikazati knjige gdje cijena nije unesena 
SELECT *
FROM Prodaja.Knjige AS k
WHERE k.Cijena IS NULL

--12.U tabeli Izdavaci nad poljem NazivIzdavaca postaviti ograničenje kojim se onemogućuje unos duplikata

ALTER TABLE Prodaja.Izdavaci
ADD CONSTRAINT UQ_Izdavaci_Naziv UNIQUE(NazivIzdavaca)  

--13.Prikladnim primjerima testirati postavljeno ograničenje na polju NazivIzdavaca

SELECT *
FROM Prodaja.Izdavaci

INSERT INTO Prodaja.Izdavaci(IzadavacID, NazivIzdavaca)
VALUES('AAAA', 'GGG&G1')

INSERT INTO Prodaja.Izdavaci(IzadavacID, NazivIzdavaca)
VALUES('AAA2', 'GGG&G1')


--14.U bazi Vjezba2 kreirati šemu Narudzbe
GO
CREATE SCHEMA Narudzbe
GO

--15.Upotrebom insert naredbe iz tabele Region baze Northwind izvršiti kreiranje i insertovanje podataka u tabelu Regije šeme Narudžbe
SELECT *
INTO Narudzbe.Regije
FROM Northwind.dbo.Region

--16.Upotrebom insert naredbe iz tabele OrderDetails baze Northwind izvršiti kreiranje i insertovanje podataka u tabelu StavkeNarudzbe šeme NarudzbeSELECT *INTO Narudzbe.StavkeNarudzbeFROM Northwind.dbo.[Order Details]
--17.U tabeli StavkeNarudzbe dodati standardnu kolonu ukupno tipa decimalni broj (8,2).
ALTER TABLE Narudzbe.StavkeNarudzbe
ADD Ukupno DECIMAL(8,2)

--18.Izvršiti update kreirane kolone kao umnožak kolona Quantity i UnitPrice.
UPDATE Narudzbe.StavkeNarudzbe
SET Ukupno=UnitPrice*Quantity

--19.U tabeli StavkeNarduzbe kreirati ograničenje na koloni Discount kojim će se onemogućiti unos vrijednosti manjih od 0. 
ALTER TABLE Narudzbe.StavkeNarudzbe
ADD CONSTRAINT CK_StavkeNarudzbe_Discount CHECK(Discount>=0)

--20.U tabeli stavke narudzbe dodati novu kolonu, ako je UnitPrice <100 potrebno je pohraniti vrijednost „DA“ a u suptornom „NE“.
ALTER TABLE Narudzbe.StavkeNarudzbe
ADD novaKolona AS CASE WHEN(UnitPrice<100) THEN 'DA' ELSE 'NE' END

SELECT *
FROM Narudzbe.StavkeNarudzbe
