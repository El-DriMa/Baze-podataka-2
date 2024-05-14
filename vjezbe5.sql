--1.Prikazati ukupnu vrijednost tro�ka prevoza po dr�avama ali samo ukoliko je ve�a od  4000 za robu koja se isporu�ila u Francusku, Njema�ku ili �vicarsku. (Northwind)
GO
USE Northwind
GO

SELECT o.ShipCountry,SUM(o.Freight)
FROM Orders AS o
WHERE o.ShipCountry IN ('France','Germany','Switzerland')
GROUP BY o.ShipCountry
HAVING SUM(o.Freight)>4000


--2. Prikazati 10 najprodavanijih proizvoda. Za proizvod je dovoljno prikazati njegov identifikacijski broj. Ulogu najprodavanijeg ima onaj koji je u najve�im koli�inama prodat. (Northwind)

SELECT TOP 10 od.ProductID,SUM(od.Quantity) AS 'Ukupan br prodanih proizvoda'
FROM [Order Details] AS od
GROUP BY od.ProductID
ORDER BY 2 DESC

--3.Prikazati spojeno ime i prezime uposlenika, teritorije i regije koje pokriva. Uslov je da su zaposlenici mla�i od 65 godina. (Northwind)

SELECT CONCAT(e.FirstName,' ',e.LastName) AS 'Ime i prezime',t.TerritoryDescription,r.RegionDescription
FROM Employees AS e 
JOIN EmployeeTerritories AS et ON e.EmployeeID=et.EmployeeID
JOIN Territories AS t ON et.TerritoryID=t.TerritoryID
JOIN Region AS r ON r.RegionID=t.RegionID
WHERE DATEDIFF(YEAR,e.BirthDate,GETDATE())<65


--4.Prikazati ukupnu vrijednost obra�enih narud�bi sa popustom za svakog uposlenika pojedina�no. Uslov je da su narud�be kreirane u 1996. godini, te u obzir uzeti samo one 
--uposlenike �ija je ukupna ukupna obra�ena vrijednost ve�a od 20000. Podatke sortirati prema ukupnoj vrijednosti (zaokru�enoj na dvije decimale) u rastu�em redoslijedu. (Northwind) 

SELECT CONCAT(e.FirstName,' ',e.LastName) AS 'Zaposlenik',ROUND(SUM(od.UnitPrice*Quantity*(1-od.Discount)),2) AS 'Ukupna vrijednost'
FROM Orders AS o 
JOIN [Order Details] AS od ON o.OrderID=od.OrderID
JOIN Employees AS e ON o.EmployeeID=e.EmployeeID
WHERE YEAR(o.OrderDate)=1996 
GROUP BY CONCAT(e.FirstName,' ',e.LastName)
HAVING SUM(od.UnitPrice*Quantity*(1-od.Discount))>20000
ORDER BY 2 ASC

--5.Prikazati naziv dobavlja�a, adresu i dr�avu dobavlja�a, te nazive proizvoda koji pripadaju kategoriji pi�a a ima ih na stanju vi�e od 30 komada. 
--Rezultate upita sortirati po dr�avama u abedecnom redoslijedu. (Northwind)

SELECT s.ContactName,s.Address,s.Country,p.ProductName
FROM Suppliers AS s 
JOIN Products AS p ON p.SupplierID=s.SupplierID
JOIN Categories AS c ON p.CategoryID=c.CategoryID
WHERE c.CategoryName LIKE 'Beverages' AND p.UnitsInStock>30
ORDER BY 3 

--6.Prikazati kontakt ime kupca, njegov id, id narud�be, datum kreiranja narud�be (prikazan u formatu dan.mjesec.godina, npr. 24.07.2021) te ukupnu vrijednost 
--narud�be sa i bez popusta. Prikazati samo one narud�be koje su kreirane u 1997. godini. 
--Izra�unate vrijednosti zaokru�iti na dvije decimale, te podatke sortirati prema ukupnoj vrijednosti narud�be sa popustom u opadaju�em redoslijedu. (Northwind) 

SELECT c.ContactName,c.CustomerID,o.OrderID,FORMAT(o.OrderDate,'dd.MM.yyyy') AS 'Datum narudzbe',
ROUND(SUM(od.UnitPrice*od.Quantity*(1-od.Discount)),2) AS 'Sa popustom',
SUM(od.UnitPrice*od.Quantity) AS 'Bez popusta'
FROM Customers AS c
JOIN Orders AS o ON o.CustomerID=c.CustomerID
JOIN [Order Details] AS od ON od.OrderID=o.OrderID
WHERE YEAR(o.OrderDate)=1997
GROUP BY c.ContactName,c.CustomerID,o.OrderID,FORMAT(o.OrderDate,'dd.MM.yyyy')
ORDER BY 5 DESC

--7.U tabeli Customers baze Northwind ID kupca je primarni klju�. U tabeli Orders baze Northwind ID kupca je vanjski klju�. 
--Koriste�i set operatore prikazati: 
--a) kupce koji su obavili narud�bu 
--b) one kupce koji nisu obavili narud�bu (ukoliko ima takvih) 

SELECT c.CustomerID
FROM Customers AS c
INTERSECT
SELECT o.CustomerID
FROM Orders AS o



--8.Kreirati upit koji prikazuje zaradu od prodaje proizvoda. Lista treba da sadr�i identifikacijski broj proizvoda, ukupnu vrijednost bez popusta, ukupnu vrijednost sa popustom. 
--Vrijednost zarade zaokru�iti na dvije decimale. Uslov je da se prika�e zarada samo za stavke gdje je bilo popusta. Listu sortirati prema ukupnoj zaradi sa popustom u opadaju�em redoslijedu. (AdventureWorks2017)

USE AdventureWorks2019

SELECT sod.ProductID,
ROUND(SUM(sod.OrderQty*sod.UnitPrice),2) AS 'Bez popusta',
CAST(ROUND(SUM(sod.LineTotal),2) AS DECIMAL(18,2)) AS 'Sa popustom'
FROM Sales.SalesOrderDetail AS sod
WHERE sod.UnitPriceDiscount>0
GROUP BY sod.ProductID
ORDER BY 3 DESC

--9.Prikazati 10 najskupljih stavki narud�bi. Upit treba da sadr�i id stavke, naziv proizvoda,koli�inu, cijenu i vrijednost stavke narud�be. 
--Cijenu i vrijednost stavke narud�be zaokru�iti na dvije decimale. 
--Izlaz formatirati na na�in da uz koli�inu stoji �kom� (npr.50 kom) a uz cijenu i vrijednost stavke narud�be �KM� (npr. 50 KM). (AdventureWorks2017) 


SELECT TOP 10 sod.SalesOrderDetailID,p.Name,
CONCAT(sod.OrderQty,' kom') AS Kolicina,
CONCAT(ROUND(sod.UnitPrice,2),' KM') AS 'Cijena',
ROUND(sod.OrderQty*sod.UnitPrice,2) AS 'Ukupna vrijednost'
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p ON sod.ProductID=p.ProductID
ORDER BY ROUND(sod.OrderQty*sod.UnitPrice,2) DESC

--10.Kreirati upit koji prikazuje ukupan broj narud�bi po teritoriji na kojoj je kreirana narud�ba. 
--Lista treba da sadr�i sljede�e kolone: naziv teritorije, ukupan broj narud�bi. 
--Uzeti u obzir samo teritorije na kojima je kreirano vi�e od 1000 narud�bi. (AdventureWorks2017) 

SELECT st.Name, COUNT(*)
FROM Sales.SalesTerritory AS st
JOIN Sales.SalesOrderHeader AS soh ON soh.TerritoryID=st.TerritoryID
GROUP BY st.Name
HAVING COUNT(*)>1000



--11.Kreirati upit koji prikazuje zaradu od prodaje proizvoda. Lista treba da sadr�i naziv proizvoda, ukupnu zaradu bez ura�unatog popusta
--i ukupnu zaradu sa ura�unatim popustom. Iznos zarade zaokru�iti na dvije decimale. Uslov je da se prika�e zarada 
--samo za stavke gdje je bilo popusta. Listu sortirati po zaradi opadaju�im redoslijedom. (AdventureWorks2017)

USE AdventureWorks2019

SELECT p.Name,ROUND(SUM(sod.OrderQty*sod.UnitPrice),2) AS 'Bez popusta',
CAST(ROUND(SUM(sod.OrderQty*sod.UnitPrice*(1-sod.UnitPriceDiscount)),2) AS DECIMAL(18,2)) AS 'Sa popustom'
--ROUND(SUM(sod.LineTotal),2) AS 'Sa popustom'-- svejedno
FROM Production.Product AS p JOIN Sales.SalesOrderDetail AS sod ON sod.ProductID=p.ProductID
WHERE sod.UnitPriceDiscount>0
GROUP BY p.Name
ORDER BY SUM(sod.OrderQty*sod.UnitPrice*(1-sod.UnitPriceDiscount)) DESC


--12.Prikazati tip popusta, naziv prodavnice i njen id. (Pubs) 

USE pubs

SELECT d.discounttype,s.stor_name,s.stor_id
FROM stores AS s JOIN discounts AS d ON d.stor_id=s.stor_id

--13.Prikazati id uposlenika, ime i prezime, te naziv posla koji obavlja. (Pubs)

SELECT *
FROM employee AS e JOIN jobs AS j ON e.job_id=j.job_id

--14.Odrediti da li je svaki autor napisao bar po jedan naslov. (Pubs) 

SELECT a.au_id
FROM authors AS a
INTERSECT 
SELECT ta.au_id
FROM titleauthor AS ta

SELECT *
FROM authors

--a) ako ima autora koji nisu napisali niti jedan naslov navesti njihov ID. 
SELECT a.au_id AS 'Autori bez naslova'
FROM authors AS a LEFT JOIN titleauthor AS ta ON a.au_id=ta.au_id
WHERE ta.title_id IS NULL

--ili
SELECT a.au_id
FROM authors AS a
EXCEPT
SELECT ta.au_id
FROM titleauthor AS ta

--b) dati pregled autora koji su napisali bar po jedan naslov. 
SELECT DISTINCT a.au_id AS 'Autori sa bar jednim naslovom'
FROM authors AS a JOIN titleauthor AS ta ON a.au_id=ta.au_id




