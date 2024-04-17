--1.Koriste�i bazu Northwind izdvojiti godinu, mjesec i dan datuma isporuke narud�be. 

USE Northwind

SELECT YEAR(o.OrderDate) AS 'Godina',
MONTH(o.OrderDate) AS 'Mjesec',
DAY(o.OrderDate) AS 'Dan'
FROM Orders AS o

--2.. Prikazati 10 koli�inski najve�ih stavki prodaje. Lista treba da sadr�i broj narud�be, datum narud�be i koli�inu.
--Provjeriti da li ima vi�e stavki sa koli�inom kao posljednja u listi, te uklju�iti ih u rezultate upita ukoliko postoje. 

USE pubs

SELECT TOP 10 WITH TIES s.stor_id,s.ord_date,s.qty
FROM sales AS s
ORDER BY 3 DESC

--3.. Prikazati listu knjiga sa sljede�im kolonama: naslov, tip djela i cijena. 
--Kao novu kolonu dodati 20% od prikazane cijene (npr. Ako je cijena 19.99 u novoj koloni treba da pi�e 3,998). 
--Naziv kolone se treba zvati �20% od cijene�. Listu sortirati abecedno po tipu djela i po cijeni opadaju�im redoslijedom. 
--Sa liste eliminisati one knjige koje nemeju pohranjenu vrijednost cijene. 
--Modifikovati upit tako da uz ve� prikazane kolone se prika�e i cijena umanjena za 20 %. Naziv kolone treba da se zove �Cijena umanjena za 20%�. 

SELECT t.title,t.type,t.price,
t.price*0.2 AS '20% od cijene',
t.price*(1-0.2) AS 'Umanjeno za 20%'
FROM titles AS t
WHERE t.price IS NOT NULL
ORDER BY t.title, t.price DESC

--4.. Prikazati listu prodaje knjiga sa sljede�im kolonama: Id prodavnice, broj narud�be i koli�inu, 
--ali samo gdje je koli�ina izme�u 10 i 50, uklju�uju�i i grani�ne vrijednosti.
--Rezultat upita sortirati po koli�ini opadaju�im redoslijedom. Upit napisati na dva na�ina.

SELECT s.stor_id,s.ord_num,s.qty
FROM sales AS s
WHERE s.qty BETWEEN 10 AND 50
ORDER BY s.qty DESC

SELECT s.stor_id,s.ord_num,s.qty
FROM sales AS s
WHERE s.qty>=10 AND s.qty<=50
ORDER BY s.qty DESC

--5.Prikazati sve tipove knjiga bez duplikata. Listu sortirati u abecednom redoslijedu.
SELECT DISTINCT t.type 
FROM titles AS t
ORDER BY t.type ASC


--6.. Prikazati listu autora sa sljede�im kolonama: Id, ime i prezime (spojeno), grad i to samo one autore �iji Id po�inje brojem 8 
--ili dolaze iz grada �Salt Lake City�.
--Tako�er autorima status ugovora treba biti 1. Koristiti aliase nad kolonama. 

SELECT a.au_id AS 'ID',CONCAT(a.au_fname,' ',a.au_lname) AS 'Ime i prezime',a.city AS 'Grad'
FROM authors AS a
WHERE (LEFT(a.au_id,1)=8 OR LOWER(a.city) LIKE 'Salt Lake City') AND a.contract=1

--7. Prikazati sve podatke o dobavlja�ima koji dolaze iz �panije ili Njema�ke a nemaju unesen broj faxa.
--Formatirati izlaz NULL vrijednosti na na�in da se prika�e umjesto NULL prikladno obja�njenje. Upit napisati na dva na�ina.
GO
USE Northwind
GO

SELECT * --ISNULL(s.Fax,'nepoznata vrijednost')
FROM Suppliers AS s
WHERE (UPPER(s.Country) LIKE 'GERMANY' OR UPPER(s.Country) LIKE 'SPAIN') AND s.Fax IS NULL


SELECT * --ISNULL(s.Fax,'nepoznata vrijednost')
FROM Suppliers AS s
WHERE UPPER(s.Country) IN ('SPAIN','GERMANY') AND s.Fax IS NULL

--8. Prikazati naziv proizvoda i cijenu, gdje je stanje na zalihama manje od naru�ene koli�ine.
--Tako�er, u rezultate upita uklju�iti razliku izme�u stanja zaliha i naru�ene koli�ine. 

SELECT p.ProductName,p.UnitPrice,p.UnitsOnOrder-p.UnitsInStock AS 'Razlika'
FROM Products AS p
WHERE p.UnitsInStock<p.UnitsOnOrder

--9.. Prikazati proizvode �iji naziv po�inje slovima �C� ili �G�, drugo slovo mo�e biti bilo koje, a tre�e slovo u nazivu je �A� ili �O�.

SELECT *
FROM Products AS p
WHERE UPPER(p.ProductName) LIKE '[CG]_[AO]%'

