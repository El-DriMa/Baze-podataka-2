--1.Kreirati bazu podataka pod nazivom ZadaciZaVjezbu.

CREATE DATABASE zzv1

--2.U pomenutoj bazi kreirati tabelu Aplikanti koja �e sadr�avati sljede�e kolone: Ime, Prezime i Mjesto_ro�enja. 
--Sva navedena polja trebaju da budu tekstualnog tipa, te prilikom kreiranja istih paziti da se ne zauzimaju bespotrebno memorijski resursi.

USE zzv1

CREATE TABLE Aplikanti(
Ime NVARCHAR(20),
Prezime NVARCHAR(35),
Mjesto_rodjenja NVARCHAR(40)
)

--3.U tabelu Aplikanti dodati kolonu AplikantID, te je proglasiti primarnim klju�em tabele (kolona mora biti autonkrement)
ALTER TABLE Aplikanti
ADD AplikantID INT PRIMARY KEY IDENTITY(1,1)

--4.U bazi ZadaciZaVjezbu kreirati tabelu Projekti koji �e sadr�avati sljede�e kolone: Naziv projekta, Akronim projekta, Svrha projekta i Cilj projekta. 
--Sva polja u tabeli su tekstualnog tipa, te prilikom kreiranja istih paziti da se ne zauzimaju bespotrebno memorijski resursi. 
--Sva navedena polja osim cilja projekta moraju imati vrijednost.

CREATE TABLE Projekti(
Naziv NVARCHAR(20) NOT NULL,
Akronim NVARCHAR(5) NOT NULL,
Svrha NVARCHAR(50) NOT NULL,
Cilj NVARCHAR(50) NULL
)

--5.U tabelu Projekti dodati kolonu Sifra projekta, te je proglasiti primarnim klju�em tabele.
ALTER TABLE Projekti
ADD Sifra INT NOT NULL

ALTER TABLE Projekti
ADD CONSTRAINT PK_Projekti PRIMARY KEY(Sifra)

--6.U tabelu Aplikanti dodati kolonu projekatID koje �e biti spoljni klju� na tabelu projekat. 
ALTER TABLE Aplikanti
ADD projekatID INT CONSTRAINT FK_Aplikanti_Projekti FOREIGN KEY REFERENCES Projekti(Sifra)

--7.U bazi podataka ZadaciZaVjezbu kreirati tabelu TematskeOblasti koja �e sadr�avati sljede�a polja 
--tematskaOblastID, naziv i opseg. 
--TematskaOblastID predstavlja primarni klju� tabele, te se automatski uve�ava. 
--Sva definisana polja moraju imati vrijednost. Prilikom definisanja du�ine polja potrebno je obratiti pa�nju da se ne zauzimaju bespotrebno memorijski resursi. 
--Projekti pripadaju jednoj tematskoj oblasti

CREATE TABLE TematskeOblasti(
TematskaOblastID INT CONSTRAINT PK_TematskeOblasti PRIMARY KEY,
Naziv NVARCHAR(20) NOT NULL,
Opseg NVARCHAR(20) NOT NULL
)

ALTER TABLE Projekti
ADD TemaskaOblastID INT CONSTRAINT FK_Projekti_TematskeOblasti FOREIGN KEY REFERENCES TematskeOblasti(TematskaOblastID)

--8.U tabeli Aplikanti dodati polje email koje je tekstualnog tipa i mo�e ostati prazno. 
ALTER TABLE Aplikanti 
ADD Email NVARCHAR(50) NULL

--9.U tabeli Aplikanti obrisati mjesto ro�enja i dodati polja telefon i mati�ni broj. Oba novokreirana polja su tekstualnog tipa i moraju sadr�avati vrijednost.
ALTER TABLE Aplikanti 
DROP COLUMN Mjesto_rodjenja

ALTER TABLE Aplikanti
ADD Telefon NVARCHAR(15) NOT NULL,
    Maticni_broj NVARCHAR(13) NOT NULL

--10.Obrisati tabele kreirane u prethodnim zadacima
DROP TABLE Aplikanti,TematskeOblasti,Projekti

--11.
USE master
DROP DATABASE zzv1