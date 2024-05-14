--1.Prikazati ukupnu vrijednost troška prevoza po državama ali samo ukoliko je veæa od  4000 za robu koja se isporuèila u Francusku, Njemaèku ili Švicarsku. (Northwind)
GO
USE Northwind
GO

SELECT o.ShipCountry,SUM(o.Freight)
FROM Orders AS o
WHERE o.ShipCountry IN ('France','Germany','Switzerland')
GROUP BY o.ShipCountry
HAVING SUM(o.Freight)>4000


--2. Prikazati 10 najprodavanijih proizvoda. Za proizvod je dovoljno prikazati njegov identifikacijski broj. Ulogu najprodavanijeg ima onaj koji je u najveæim kolièinama prodat. (Northwind)

SELECT TOP 10 od.ProductID,SUM(od.Quantity) AS 'Ukupan br prodanih proizvoda'
FROM [Order Details] AS od
GROUP BY od.ProductID
ORDER BY 2 DESC

--3.Prikazati spojeno ime i prezime uposlenika, teritorije i regije koje pokriva. Uslov je da su zaposlenici mlaði od 65 godina. (Northwind)

SELECT CONCAT(e.FirstName,' ',e.LastName) AS 'Ime i prezime',t.TerritoryDescription,r.RegionDescription
FROM Employees AS e 
JOIN EmployeeTerritories AS et ON e.EmployeeID=et.EmployeeID
JOIN Territories AS t ON et.TerritoryID=t.TerritoryID
JOIN Region AS r ON r.RegionID=t.RegionID
WHERE DATEDIFF(YEAR,e.BirthDate,GETDATE())<65


--4.Prikazati ukupnu vrijednost obraðenih narudžbi sa popustom za svakog uposlenika pojedinaèno. Uslov je da su narudžbe kreirane u 1996. godini, te u obzir uzeti samo one 
--uposlenike èija je ukupna ukupna obraðena vrijednost veæa od 20000. Podatke sortirati prema ukupnoj vrijednosti (zaokruženoj na dvije decimale) u rastuæem redoslijedu. (Northwind) 

SELECT CONCAT(e.FirstName,' ',e.LastName) AS 'Zaposlenik',ROUND(SUM(od.UnitPrice*Quantity*(1-od.Discount)),2) AS 'Ukupna vrijednost'
FROM Orders AS o 
JOIN [Order Details] AS od ON o.OrderID=od.OrderID
JOIN Employees AS e ON o.EmployeeID=e.EmployeeID
WHERE YEAR(o.OrderDate)=1996 
GROUP BY CONCAT(e.FirstName,' ',e.LastName)
HAVING SUM(od.UnitPrice*Quantity*(1-od.Discount))>20000
ORDER BY 2 ASC

--5.Prikazati naziv dobavljaèa, adresu i državu dobavljaèa, te nazive proizvoda koji pripadaju kategoriji piæa a ima ih na stanju više od 30 komada. 
--Rezultate upita sortirati po državama u abedecnom redoslijedu. (Northwind)

SELECT s.ContactName,s.Address,s.Country,p.ProductName
FROM Suppliers AS s 
JOIN Products AS p ON p.SupplierID=s.SupplierID
JOIN Categories AS c ON p.CategoryID=c.CategoryID
WHERE c.CategoryName LIKE 'Beverages' AND p.UnitsInStock>30
ORDER BY 3 

--6.Prikazati kontakt ime kupca, njegov id, id narudžbe, datum kreiranja narudžbe (prikazan u formatu dan.mjesec.godina, npr. 24.07.2021) te ukupnu vrijednost 
--narudžbe sa i bez popusta. Prikazati samo one narudžbe koje su kreirane u 1997. godini. 
--Izraèunate vrijednosti zaokružiti na dvije decimale, te podatke sortirati prema ukupnoj vrijednosti narudžbe sa popustom u opadajuæem redoslijedu. (Northwind) 

SELECT c.ContactName,c.CustomerID,o.OrderID,FORMAT(o.OrderDate,'dd.MM.yyyy') AS 'Datum narudzbe',
ROUND(SUM(od.UnitPrice*od.Quantity*(1-od.Discount)),2) AS 'Sa popustom',
SUM(od.UnitPrice*od.Quantity) AS 'Bez popusta'
FROM Customers AS c
JOIN Orders AS o ON o.CustomerID=c.CustomerID
JOIN [Order Details] AS od ON od.OrderID=o.OrderID
WHERE YEAR(o.OrderDate)=1997
GROUP BY c.ContactName,c.CustomerID,o.OrderID,FORMAT(o.OrderDate,'dd.MM.yyyy')
ORDER BY 5 DESC

--7.U tabeli Customers baze Northwind ID kupca je primarni kljuè. U tabeli Orders baze Northwind ID kupca je vanjski kljuè. 
--Koristeæi set operatore prikazati: 
--a) kupce koji su obavili narudžbu 
--b) one kupce koji nisu obavili narudžbu (ukoliko ima takvih) 

SELECT c.CustomerID
FROM Customers AS c
INTERSECT
SELECT o.CustomerID
FROM Orders AS o



--8.Kreirati upit koji prikazuje zaradu od prodaje proizvoda. Lista treba da sadrži identifikacijski broj proizvoda, ukupnu vrijednost bez popusta, ukupnu vrijednost sa popustom. 
--Vrijednost zarade zaokružiti na dvije decimale. Uslov je da se prikaže zarada samo za stavke gdje je bilo popusta. Listu sortirati prema ukupnoj zaradi sa popustom u opadajuæem redoslijedu. (AdventureWorks2017)

USE AdventureWorks2019

SELECT sod.ProductID,
ROUND(SUM(sod.OrderQty*sod.UnitPrice),2) AS 'Bez popusta',
CAST(ROUND(SUM(sod.LineTotal),2) AS DECIMAL(18,2)) AS 'Sa popustom'
FROM Sales.SalesOrderDetail AS sod
WHERE sod.UnitPriceDiscount>0
GROUP BY sod.ProductID
ORDER BY 3 DESC

--9.Prikazati 10 najskupljih stavki narudžbi. Upit treba da sadrži id stavke, naziv proizvoda,kolièinu, cijenu i vrijednost stavke narudžbe. 
--Cijenu i vrijednost stavke narudžbe zaokružiti na dvije decimale. 
--Izlaz formatirati na naèin da uz kolièinu stoji “kom” (npr.50 kom) a uz cijenu i vrijednost stavke narudžbe “KM” (npr. 50 KM). (AdventureWorks2017) 


SELECT TOP 10 sod.SalesOrderDetailID,p.Name,
CONCAT(sod.OrderQty,' kom') AS Kolicina,
CONCAT(ROUND(sod.UnitPrice,2),' KM') AS 'Cijena',
ROUND(sod.OrderQty*sod.UnitPrice,2) AS 'Ukupna vrijednost'
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p ON sod.ProductID=p.ProductID
ORDER BY ROUND(sod.OrderQty*sod.UnitPrice,2) DESC

--10.Kreirati upit koji prikazuje ukupan broj narudžbi po teritoriji na kojoj je kreirana narudžba. 
--Lista treba da sadrži sljedeæe kolone: naziv teritorije, ukupan broj narudžbi. 
--Uzeti u obzir samo teritorije na kojima je kreirano više od 1000 narudžbi. (AdventureWorks2017) 

SELECT st.Name, COUNT(*)
FROM Sales.SalesTerritory AS st
JOIN Sales.SalesOrderHeader AS soh ON soh.TerritoryID=st.TerritoryID
GROUP BY st.Name
HAVING COUNT(*)>1000



--11.Kreirati upit koji prikazuje zaradu od prodaje proizvoda. Lista treba da sadrži naziv proizvoda, ukupnu zaradu bez uraèunatog popusta
--i ukupnu zaradu sa uraèunatim popustom. Iznos zarade zaokružiti na dvije decimale. Uslov je da se prikaže zarada 
--samo za stavke gdje je bilo popusta. Listu sortirati po zaradi opadajuæim redoslijedom. (AdventureWorks2017)

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




