--1.Iz tabele HumanResources.Employee baze AdventureWorks2017 iz kolone LoginID izvuæi  ime uposlenika. 
GO
USE AdventureWorks2019
GO 

SELECT e.LoginID,
SUBSTRING(e.LoginID,CHARINDEX('\',e.LoginID)+1,LEN(e.LoginID)-CHARINDEX('\',e.LoginID)-1) AS 'Ime uposlenika'
FROM HumanResources.Employee AS e


--2. Kreirati upit koji prikazuje podatke o zaposlenicima. Lista treba da sadrži sljedeæe kolone: ID uposlenika, korisnièko ime i novu lozinku:
 --Uslovi su sljedeæi: 
-- Za korisnièko ime potrebno je koristiti kolonu LoginID (tabela Employees). Npr. 
--LoginID zaposlenika sa identifikacijskim brojem 23 je adventureworks\mary0. 
--Korisnièko ime zaposlenika je sve što se nalazi iza znaka \ (backslash) što je u ovom 
--primjeru mary0, 
--Nova lozinka se formira koristeæi Rowguid zaposlenika na sljedeæi naèin: Rowguid je 
--potrebno okrenuti obrnuto (npr. dbms2015 -> 5102smbd) i nakon toga preskaèemo 
--prvih 5 i uzimamo narednih 7 karaktera. Sljedeæi korak jeste da iz dobijenog stringa 
--poèevši od drugog karaktera naredna dva zamijenimo sa X# (npr. ako je dobiveni 
--string dbms2015 izlaz æe biti dX#s2015) 

SELECT e.BusinessEntityID,
SUBSTRING(e.LoginID,CHARINDEX('\',e.LoginID)+1,LEN(e.LoginID)-CHARINDEX('\',e.LoginID)) AS 'Ime uposlenika',
STUFF(SUBSTRING(REVERSE(e.rowguid),6,7),2,2,'X#') AS 'Lozinka'
FROM HumanResources.Employee AS e


--3. Iz tabele Sales.Customer baze AdventureWorks2017 iz kolone AccountNumber izvuæi broj pri èemu je potrebno broj prikazati bez vodeæih nula. 
--a) dohvatiti sve zapise 
--b) dohvatiti one zapise kojima je unijet podatak u kolonu PersonID

SELECT c.AccountNumber, CAST(RIGHT(c.AccountNumber,PATINDEX('%[A-Z]%',REVERSE(c.AccountNumber))-1) AS INT)
FROM Sales.Customer AS c

SELECT c.AccountNumber, CAST(RIGHT(c.AccountNumber,PATINDEX('%[A-Z]%',REVERSE(c.AccountNumber))-1) AS INT)
FROM Sales.Customer AS c
WHERE c.PersonID IS NOT NULL


--4. Iz tabele Purchasing.Vendor baze AdventureWorks2017 dohvatiti zapise u kojima se podatak 
--u koloni AccountNumber formirao iz prve rijeèi kolone Name. Npr. dostavljaè koji ima id 
--1492 ne ispunjava definisani uslov, dok dostavljaè koji ima id 1494 ispunjava. U rezultatima 
--upita prikazati samo one kolone koje se nalaze u definiciji tabele.

SELECT v.AccountNumber,v.Name
FROM Purchasing.Vendor AS v


SELECT v.AccountNumber,v.Name, 
LEFT(v.AccountNumber, PATINDEX('%[0-9]%',v.AccountNumber)-1),
LEFT(v.Name +' ', CHARINDEX(' ', v.Name+' ')-1)
FROM Purchasing.Vendor AS v
WHERE LEFT(v.AccountNumber, PATINDEX('%[0-9]%',v.AccountNumber)-1) LIKE LEFT(v.Name +' ', CHARINDEX(' ', v.Name+' ')-1)

SELECT *
FROM Purchasing.Vendor AS v
WHERE LEFT(v.AccountNumber,PATINDEX('%[0-9]%',v.AccountNumber)-1) LIKE IIF(CHARINDEX(' ',v.Name)=0,v.Name,LEFT(v.Name,CHARINDEX(' ',v.Name+' ')-1))

SELECT LEFT(v.AccountNumber,PATINDEX('%[0-9]%',v.AccountNumber)-1)
FROM Purchasing.Vendor AS v

SELECT LEFT(v.Name,CHARINDEX(' ',v.Name+' ')-1)
FROM Purchasing.Vendor AS v


--5. Koristeæi bazu Northwind kreirati upit koji æe prikazati odvojeno ime i prezime (dobijeno iz kolone ContactName), naziv firme te državu i grad kupca ali samo onih èija zadnja rijeè adrese
--se sastoji od 2 ili 3 cifre. Takoðer, uzeti u obzir samo one kupce koji u polju ContactName
--imaju dvije rijeèi. 

GO 
USE Northwind
GO

SELECT c.ContactName,
LEFT(c.ContactName,CHARINDEX(' ',c.ContactName)-1) AS 'Ime',
RIGHT(c.ContactName,CHARINDEX(' ',REVERSE(c.ContactName))-1) AS 'Prezime',
c.CompanyName,c.Country,c.City,c.Address
FROM  Customers AS c

SELECT c.ContactName,
LEFT(c.ContactName,CHARINDEX(' ',c.ContactName)-1) AS 'Ime',
RIGHT(c.ContactName,CHARINDEX(' ',REVERSE(c.ContactName))-1) AS 'Prezime',
c.CompanyName,c.Country,c.City,c.Address
FROM  Customers AS c
WHERE LEN(RIGHT(c.Address,CHARINDEX(' ',REVERSE(c.Address))-1)) IN (2,3)

SELECT c.ContactName,
LEFT(c.ContactName,CHARINDEX(' ',c.ContactName)-1) AS 'Ime',
RIGHT(c.ContactName,CHARINDEX(' ',REVERSE(c.ContactName))-1) AS 'Prezime',
c.CompanyName,c.Country,c.City,c.Address
FROM  Customers AS c
WHERE LEN(RIGHT(c.Address,CHARINDEX(' ',REVERSE(c.Address))-1)) IN (2,3) AND ISNUMERIC(RIGHT(c.Address,CHARINDEX(' ',REVERSE(c.Address))-1))=1

SELECT c.ContactName,
LEFT(c.ContactName,CHARINDEX(' ',c.ContactName)-1) AS 'Ime',
RIGHT(c.ContactName,CHARINDEX(' ',REVERSE(c.ContactName))-1) AS 'Prezime',
c.CompanyName,c.Country,c.City,c.Address
FROM  Customers AS c
WHERE LEN(RIGHT(c.Address,CHARINDEX(' ',REVERSE(c.Address))-1)) IN (2,3) AND ISNUMERIC(RIGHT(c.Address,CHARINDEX(' ',REVERSE(c.Address))-1))=1 AND
LEN(c.ContactName)-LEN(REPLACE(c.ContactName,' ',''))=1


--6. Koristeæi bazu Northwind u tabeli Customers dodati izraèunato polje Spol u koji æe se upitom pohraniti vrijednost da li se radi o muškarcu ili ženi (M ili F). Vrijednost na osnovu koje se 
--odreðuje to o kojem se spolu radi nalazi se u koloni ContactName gdje zadnje slovo prve rijeèi 
--odreðuje spol (rijeèi koje se završavaju slovom a predstavljaju osobe ženskog spola). Nakon
--testiranja ispravnosti izraèunato polje izbrisati iz pomenute tabele


SELECT c.ContactName,RIGHT(LEFT(c.ContactName,CHARINDEX(' ',c.ContactName)-1),1)
FROM Customers AS c

SELECT c.ContactName,IIF(RIGHT(LEFT(c.ContactName,CHARINDEX(' ',c.ContactName)-1),1) LIKE 'a','F','M')
FROM Customers AS c

ALTER TABLE Customers
ADD Spol AS IIF(RIGHT(LEFT(ContactName,CHARINDEX(' ',ContactName)-1),1) LIKE 'a','F','M')

SELECT *
FROM Customers AS c

ALTER TABLE Customers
DROP COLUMN Spol
