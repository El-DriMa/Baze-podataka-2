--1.Iz tabele HumanResources.Employee baze AdventureWorks2017 iz kolone LoginID izvu�i  ime uposlenika. 
GO
USE AdventureWorks2019
GO 

SELECT e.LoginID,
SUBSTRING(e.LoginID,CHARINDEX('\',e.LoginID)+1,LEN(e.LoginID)-CHARINDEX('\',e.LoginID)-1) AS 'Ime uposlenika'
FROM HumanResources.Employee AS e


--2. Kreirati upit koji prikazuje podatke o zaposlenicima. Lista treba da sadr�i sljede�e kolone: ID uposlenika, korisni�ko ime i novu lozinku:
 --Uslovi su sljede�i: 
-- Za korisni�ko ime potrebno je koristiti kolonu LoginID (tabela Employees). Npr. 
--LoginID zaposlenika sa identifikacijskim brojem 23 je adventureworks\mary0. 
--Korisni�ko ime zaposlenika je sve �to se nalazi iza znaka \ (backslash) �to je u ovom 
--primjeru mary0, 
--Nova lozinka se formira koriste�i Rowguid zaposlenika na sljede�i na�in: Rowguid je 
--potrebno okrenuti obrnuto (npr. dbms2015 -> 5102smbd) i nakon toga preska�emo 
--prvih 5 i uzimamo narednih 7 karaktera. Sljede�i korak jeste da iz dobijenog stringa 
--po�ev�i od drugog karaktera naredna dva zamijenimo sa X# (npr. ako je dobiveni 
--string dbms2015 izlaz �e biti dX#s2015) 

SELECT e.BusinessEntityID,
SUBSTRING(e.LoginID,CHARINDEX('\',e.LoginID)+1,LEN(e.LoginID)-CHARINDEX('\',e.LoginID)) AS 'Ime uposlenika',
STUFF(SUBSTRING(REVERSE(e.rowguid),6,7),2,2,'X#') AS 'Lozinka'
FROM HumanResources.Employee AS e


--3. Iz tabele Sales.Customer baze AdventureWorks2017 iz kolone AccountNumber izvu�i broj pri �emu je potrebno broj prikazati bez vode�ih nula. 
--a) dohvatiti sve zapise 
--b) dohvatiti one zapise kojima je unijet podatak u kolonu PersonID

SELECT c.AccountNumber, CAST(RIGHT(c.AccountNumber,PATINDEX('%[A-Z]%',REVERSE(c.AccountNumber))-1) AS INT)
FROM Sales.Customer AS c

SELECT c.AccountNumber, CAST(RIGHT(c.AccountNumber,PATINDEX('%[A-Z]%',REVERSE(c.AccountNumber))-1) AS INT)
FROM Sales.Customer AS c
WHERE c.PersonID IS NOT NULL


--4. Iz tabele Purchasing.Vendor baze AdventureWorks2017 dohvatiti zapise u kojima se podatak 
--u koloni AccountNumber formirao iz prve rije�i kolone Name. Npr. dostavlja� koji ima id 
--1492 ne ispunjava definisani uslov, dok dostavlja� koji ima id 1494 ispunjava. U rezultatima 
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


--5. Koriste�i bazu Northwind kreirati upit koji �e prikazati odvojeno ime i prezime (dobijeno iz kolone ContactName), naziv firme te dr�avu i grad kupca ali samo onih �ija zadnja rije� adrese
--se sastoji od 2 ili 3 cifre. Tako�er, uzeti u obzir samo one kupce koji u polju ContactName
--imaju dvije rije�i. 

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


--6. Koriste�i bazu Northwind u tabeli Customers dodati izra�unato polje Spol u koji �e se upitom pohraniti vrijednost da li se radi o mu�karcu ili �eni (M ili F). Vrijednost na osnovu koje se 
--odre�uje to o kojem se spolu radi nalazi se u koloni ContactName gdje zadnje slovo prve rije�i 
--odre�uje spol (rije�i koje se zavr�avaju slovom a predstavljaju osobe �enskog spola). Nakon
--testiranja ispravnosti izra�unato polje izbrisati iz pomenute tabele


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
