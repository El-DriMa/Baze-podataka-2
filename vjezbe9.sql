--1. Kreirati bazu View_ i aktivirati je. 
CREATE DATABASE View_
GO 
USE View_
--2. U bazi View_ kreirati pogled v_Employee sljedeæe strukture: 
--- prezime i ime uposlenika kao polje ime i prezime, 
--- teritoriju i 
--- regiju koju pokrivaju 
--Uslov je da se dohvataju uposlenici koji su stariji od 60 godina. (Northwind) 
GO
CREATE VIEW v_Employee
AS 
SELECT CONCAT(e.FirstName,' ',e.LastName) AS 'Ime prezime',
t.TerritoryDescription AS 'Teritorija',r.RegionDescription AS 'Regija'
FROM Northwind.dbo.Employees AS e
JOIN Northwind.dbo.EmployeeTerritories AS et ON et.EmployeeID=e.EmployeeID
JOIN Northwind.dbo.Territories AS t on et.TerritoryID=t.TerritoryID
JOIN Northwind.dbo.Region AS r on t.RegionID=r.RegionID 
WHERE DATEDIFF(YEAR,e.BirthDate,GETDATE()) > 60
GO 
--kad bi trebali sortirat , jer order by ne radi u viewu
SELECT *
FROM v_Employee
ORDER BY 1

--3. Koristeæi pogled v_Employee prebrojati broj teritorija koje uposlenik pokriva po jednoj 
--regiji. Rezultate sortirati prema broju teritorija u opadajuæem redoslijedu, te prema 
--prezimenu i imenu u rastuæem redoslijedu. 
SELECT ve.[Ime prezime],ve.Regija, COUNT (*) 'Broj teritorija'
FROM v_Employee AS ve
GROUP BY ve.[Ime prezime],ve.Regija
ORDER BY 3 DESC,1

--4. Kreirati pogled v_Sales sljedeæe strukture: (Adventureworks2017) 
--- Id kupca 
--- Ime i prezime kupca 
--- Godinu narudžbe 
--- Vrijednost narudžbe bez troškova prevoza i takse 
GO
CREATE VIEW v_Sales
AS
SELECT c.CustomerID,CONCAT(p.FirstName,' ',p.LastName) AS 'Ime prezime',YEAR(soh.OrderDate) AS 'Godina narudzbe',
soh.SubTotal AS 'Bez troskova prevoza i takse'
FROM AdventureWorks2019.Sales.SalesOrderHeader AS soh
JOIN AdventureWorks2019.Sales.Customer AS c on soh.CustomerID=c.CustomerID
JOIN AdventureWorks2019.Person.Person AS p on c.CustomerID=p.BusinessEntityID
GO

--5. Koristeæi pogled v_Sales dati pregled sumarno ostvarenih prometa po osobi i godini. 
SELECT vs.[Ime prezime],vs.[Godina narudzbe],SUM(vs.[Bez troskova prevoza i takse]) AS 'Ukupno'
FROM v_Sales AS vs
GROUP BY vs.[Ime prezime],vs.[Godina narudzbe]

--6. Koristeæi pogled v_Sales dati pregled zapisa iz 2013. godine u kojima je vrijednost 
--narudžbe u intervalu 10% u odnosu na prosjeènu vrijednost narudžbe iz 2013 godine. 
--Pregled treba da sadrži ime i prezime kupca i vrijednost narudžbe, sortirano prema 
--vrijednosti nraudžbe obrnuto abecedno. 
GO
CREATE VIEW v_Sales2013
AS
SELECT *
FROM v_Sales AS vs
WHERE vs.[Godina narudzbe]=2013
GO

SELECT vs.[Ime prezime],vs.[Bez troskova prevoza i takse]
FROM v_Sales2013 AS vs
WHERE vs.[Bez troskova prevoza i takse] BETWEEN (
										SELECT AVG(vs.[Bez troskova prevoza i takse])
										FROM v_Sales2013 AS vs)*0.9  AND ( SELECT AVG(vs.[Bez troskova prevoza i takse])
																		FROM v_Sales2013 AS vs)*1.1
ORDER BY vs.[Bez troskova prevoza i takse] DESC


--7. Kreirati tabelu Zaposlenici te prilikom kreiranja uraditi insert podataka iz tabele 
--Employees baze Northwind. 
SELECT *
INTO Zaposlenici
FROM Northwind.dbo.Employees

--8. Kreirati pogled v_Zaposlenici koji æe dati pregled ID-a, imena, prezimena i 
--države zaposlenika. 

GO
CREATE VIEW v_Zaposlenici
AS
SELECT z.EmployeeID,z.FirstName,z.LastName,z.Country
FROM Zaposlenici AS z
GO

--9. Modificirati prethodno kreirani pogled te onemoguæiti unos podataka kroz pogled za 
--uposlenike koji ne dolaze iz Amerike ili Velike Britanije. 
CREATE OR ALTER VIEW v_Zaposlenici
AS
SELECT z.EmployeeID,z.FirstName,z.LastName,z.Country
FROM Zaposlenici AS z
WHERE z.Country IN ('USA','UK')
WITH CHECK OPTION
GO

--10. Testirati prethodno modificiran view unosom ispravnih i neispravnih podataka (napisati 
--2 testna sluèaja). 
INSERT INTO  v_Zaposlenici
VALUES ('Amna','LastName','BiH')

INSERT INTO  v_Zaposlenici
VALUES ('Amna','LastName','USA')

--11. Koristeæi tabele Purchasing.Vendor i Purchasing.PurchaseOrderDetail kreirati 
--v_Purchasing pogled sljedeæe strukture: 
--- Name iz tabele Vendor 
--- PurchaseOrderID iz tabele Purchasing.PurchaseOrderDetail 
--- DueDate iz tabele Purchasing.PurchaseOrderDetail 
--- OrderQty iz tabele Purchasing.PurchaseOrderDetail 
--- UnitPrice iz tabele Purchasing.PurchaseOrderDetail 
--- ukupno kao proizvod OrderQty i UnitPrice 
--Uslov je da se dohvate samo oni zapisi kod kojih DueDate pripada 1. ili 3. kvartalu. 
--(AdventureWorks2017) 
GO
CREATE VIEW v_Purchasing
AS
SELECT v.Name,pod.PurchaseOrderID,pod.DueDate,pod.OrderQty,pod.UnitPrice,pod.UnitPrice*pod.OrderQty AS 'Ukupno'
FROM AdventureWorks2019.Purchasing.Vendor AS v
JOIN AdventureWorks2019.Purchasing.PurchaseOrderHeader AS poh ON poh.VendorID=v.BusinessEntityID
JOIN AdventureWorks2019.Purchasing.PurchaseOrderDetail AS pod ON poh.PurchaseOrderID=pod.PurchaseOrderID
WHERE DATEPART(QUARTER,pod.DueDate) IN (1,3)
GO


--12. Koristeæi pogled v_Purchasing dati pregled svih dobavljaèa èiji je ukupan broj stavki u 
--okviru jedne narudžbe jednak minimumu, odnosno maksimumu ukupnog broja stavki 
--po dostavljaèima i purchaseOrderID.
--Pregled treba imati sljedeæu strukturu: 
--- Name 
--- PurchaseOrderID 
--- Ukupan broj stavki

GO
CREATE VIEW v_Purchasing_Count
AS
SELECT vp.Name,vp.PurchaseOrderID,COUNT(*) AS 'Ukupno stavki'
FROM v_Purchasing AS vp
GROUP BY vp.Name,vp.PurchaseOrderID
GO

SELECT vpc.Name,vpc.PurchaseOrderID,vpc.[Ukupno stavki]
FROM v_Purchasing_Count AS vpc
WHERE vpc.[Ukupno stavki]=(SELECT MIN(vpc.[Ukupno stavki]) FROM v_Purchasing_Count AS vpc)
OR    vpc.[Ukupno stavki]=(SELECT MIN(vpc.[Ukupno stavki]) FROM v_Purchasing_Count AS vpc)
ORDER BY 3 DESC

--13. U bazi radna kreirati tabele Osoba i Uposlenik. 
--Strukture tabela su sljedeæe: 
--- Osoba 
--OsobaID cjelobrojna varijabla, primarni kljuè 
--VrstaOsobe 2 unicode karaktera, obavezan unos 
--Prezime 50 unicode karaktera, obavezan unos 
--Ime 
--- Uposlenik 
--50 unicode karaktera, obavezan unos 
--UposlenikID cjelobrojna varijabla, primarni kljuè 
--NacionalniID 15 unicode karaktera, obavezan unos 
--LoginID 256 unicode karaktera, obavezan unos 
--RadnoMjesto 50 unicode karaktera, obavezan unos 
--DtmZapos datumska varijabla 
--Spoj tabela napraviti prema spoju izmeðu tabela 
--Person.Person i HumanResources.Employee baze AdventureWorks2017. 
CREATE TABLE Osoba
(
	OsobaID			INT CONSTRAINT PK_Osoba PRIMARY KEY,
	VrstaOsobe		NVARCHAR (2) NOT NULL,
	Prezime			NVARCHAR (50) NOT NULL,
	Ime				NVARCHAR (50) NOT NULL
)

CREATE TABLE Uposlenik
(
	UposlenikID		INT CONSTRAINT PK_Uposlenik PRIMARY KEY,
	NacionalniID	NVARCHAR (15) NOT NULL,
	LoginID			NVARCHAR (256) NOT NULL,
	RadnoMjesto		NVARCHAR (50) NOT NULL,
	DtmZapos		DATE,
	CONSTRAINT FK_Uposlenik_Osoba FOREIGN KEY (UposlenikID) REFERENCES Osoba (OsobaID)
)

--14. Nakon kreiranja tabela u tabelu Osoba kopirati odgovarajuæe podatke iz tabele Person.Person, 
--a u tabelu Uposlenik kopirati odgovarajuæe zapise iz tabele 
--HumanResources.Employee.
INSERT INTO Osoba
SELECT p.BusinessEntityID,p.PersonType,p.LastName,p.FirstName
FROM AdventureWorks2019.Person.Person AS p

INSERT INTO Uposlenik
SELECT e.BusinessEntityID,e.NationalIDNumber,e.LoginID,e.JobTitle,e.HireDate
FROM AdventureWorks2019.HumanResources.Employee AS e


--15. Kreirati pogled (view) v_Osoba_Uposlenik nad tabelama Uposlenik i Osoba koji æe 
--sadržavati sva polja obje tabele. 
GO
CREATE VIEW v_Osoba_Uposlenik 
AS
SELECT *
FROM Uposlenik AS u JOIN Osoba AS o ON o.OsobaID=u.UposlenikID
GO

--16. Koristeæi pogled v_Osoba_Uposlenik prebrojati koliko se osoba zaposlilo po 
--godinama.

SELECT YEAR(vou.DtmZapos) AS 'Godina',COUNT (*) AS 'Broj osoba'
FROM v_Osoba_Uposlenik AS vou
GROUP BY YEAR(vou.DtmZapos)
ORDER BY COUNT(*)