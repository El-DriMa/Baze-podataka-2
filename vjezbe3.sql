--1.Koristeæi bazu Northwind izdvojiti godinu, mjesec i dan datuma isporuke narudžbe. 

USE Northwind

SELECT YEAR(o.OrderDate) AS 'Godina',
MONTH(o.OrderDate) AS 'Mjesec',
DAY(o.OrderDate) AS 'Dan'
FROM Orders AS o

--2.. Prikazati 10 kolièinski najveæih stavki prodaje. Lista treba da sadrži broj narudžbe, datum narudžbe i kolièinu.
--Provjeriti da li ima više stavki sa kolièinom kao posljednja u listi, te ukljuèiti ih u rezultate upita ukoliko postoje. 

USE pubs

SELECT TOP 10 WITH TIES s.stor_id,s.ord_date,s.qty
FROM sales AS s
ORDER BY 3 DESC

--3.. Prikazati listu knjiga sa sljedeæim kolonama: naslov, tip djela i cijena. 
--Kao novu kolonu dodati 20% od prikazane cijene (npr. Ako je cijena 19.99 u novoj koloni treba da piše 3,998). 
--Naziv kolone se treba zvati „20% od cijene“. Listu sortirati abecedno po tipu djela i po cijeni opadajuæim redoslijedom. 
--Sa liste eliminisati one knjige koje nemeju pohranjenu vrijednost cijene. 
--Modifikovati upit tako da uz veæ prikazane kolone se prikaže i cijena umanjena za 20 %. Naziv kolone treba da se zove „Cijena umanjena za 20%“. 

SELECT t.title,t.type,t.price,
t.price*0.2 AS '20% od cijene',
t.price*(1-0.2) AS 'Umanjeno za 20%'
FROM titles AS t
WHERE t.price IS NOT NULL
ORDER BY t.title, t.price DESC

--4.. Prikazati listu prodaje knjiga sa sljedeæim kolonama: Id prodavnice, broj narudžbe i kolièinu, 
--ali samo gdje je kolièina izmeðu 10 i 50, ukljuèujuæi i graniène vrijednosti.
--Rezultat upita sortirati po kolièini opadajuæim redoslijedom. Upit napisati na dva naèina.

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


--6.. Prikazati listu autora sa sljedeæim kolonama: Id, ime i prezime (spojeno), grad i to samo one autore èiji Id poèinje brojem 8 
--ili dolaze iz grada „Salt Lake City“.
--Takoðer autorima status ugovora treba biti 1. Koristiti aliase nad kolonama. 

SELECT a.au_id AS 'ID',CONCAT(a.au_fname,' ',a.au_lname) AS 'Ime i prezime',a.city AS 'Grad'
FROM authors AS a
WHERE (LEFT(a.au_id,1)=8 OR LOWER(a.city) LIKE 'Salt Lake City') AND a.contract=1

--7. Prikazati sve podatke o dobavljaèima koji dolaze iz Španije ili Njemaèke a nemaju unesen broj faxa.
--Formatirati izlaz NULL vrijednosti na naèin da se prikaže umjesto NULL prikladno objašnjenje. Upit napisati na dva naèina.
GO
USE Northwind
GO

SELECT * --ISNULL(s.Fax,'nepoznata vrijednost')
FROM Suppliers AS s
WHERE (UPPER(s.Country) LIKE 'GERMANY' OR UPPER(s.Country) LIKE 'SPAIN') AND s.Fax IS NULL


SELECT * --ISNULL(s.Fax,'nepoznata vrijednost')
FROM Suppliers AS s
WHERE UPPER(s.Country) IN ('SPAIN','GERMANY') AND s.Fax IS NULL

--8. Prikazati naziv proizvoda i cijenu, gdje je stanje na zalihama manje od naruèene kolièine.
--Takoðer, u rezultate upita ukljuèiti razliku izmeðu stanja zaliha i naruèene kolièine. 

SELECT p.ProductName,p.UnitPrice,p.UnitsOnOrder-p.UnitsInStock AS 'Razlika'
FROM Products AS p
WHERE p.UnitsInStock<p.UnitsOnOrder

--9.. Prikazati proizvode èiji naziv poèinje slovima „C“ ili „G“, drugo slovo može biti bilo koje, a treæe slovo u nazivu je „A“ ili „O“.

SELECT *
FROM Products AS p
WHERE UPPER(p.ProductName) LIKE '[CG]_[AO]%'

