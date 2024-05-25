######### PROJENÝN AMACI ##########

Ýstanbuldaki bazý spor tesisleri, tesislerde bulunan spor dallarý, tesislerde çalýþan eðitmenler ve spor yapan kiþileri içermektedir.


######### VERÝTABANI TASARIMI #############

CREATE DATABASE SporVT
use SporVT
create table TESISLER(
TesisID int identity(1,1) primary key,
TesisAdi nvarchar(100)
)

create table SPORDALLARI(
SporID int identity(1,1) primary key,
SporAdi nvarchar(100),
TesisID int foreign key (TesisID) references TESISLER(TesisID)
)

create table EGITMENLER(
EgitmenID int identity(1,1) primary key,
EgitmenAdi nvarchar(50),
SporID int foreign key (SporID) references SPORDALLARI(SporID),
TesisID int foreign key (TesisID) references TESISLER(TesisID)
)

create table KISILER(
KisilerID int identity(1,1) primary key,
AdSoyad nvarchar(50),
Telno nvarchar(20),
Email nvarchar(50),
DogumTarihi date,
KayitTarihi date,
TesisID int foreign key (TesisID) references TESISLER(TesisID),
SporID int foreign key (SporID) references SPORDALLARI(SporID),
EgitmenID int foreign key (EgitmenID) references EGITMENLER(EgitmenID)
)


##############  100.000 VERÝ ATAMA  ###############

declare @counter int = 0

while @counter < 100000
begin
    declare @AdSoyad nvarchar(100) = (select top 1 Adsoyad from KISILER order by NEWID())
	declare @Telno nvarchar(100) = (select top 1 Telno from KISILER order by NEWID())
	declare @Email nvarchar(100) = (select top 1 Email from KISILER order by NEWID())
	declare @DogumTarihi date = (select top 1 DogumTarihi from KISILER order by NEWID())
	declare @KayitTarihi date = (select top 1 KayitTarihi from KISILER order by NEWID())
	declare @TesisID int = (select top 1 TesisID from TESISLER order by NEWID())
	declare @SporID int = (select top 1 SporID from SPORDALLARI order by NEWID())
	declare @EgitmenID int = (select top 1 EgitmenID from EGITMENLER order by NEWID())

	insert into KISILER(AdSoyad, Telno, Email, DogumTarihi, KayitTarihi, TesisID, SporID, EgitmenID)
    values (@AdSoyad, @Telno, @Email, @DogumTarihi, @KayitTarihi, @TesisID, @SporID, @EgitmenID)

    set @counter = @counter + 1
end

select * from KISILER where KisilerID >= 100000

############# STORED PROCEDUR #############

create procedure sp_Update
    @AdSoyad nvarchar(50),
	@Telno nvarchar(50),
	@Email nvarchar(50),
	@DogumTarihi date,
    @SporID int,
	@TesisID int,
	@EgitmenID int
	
as
	begin
	set nocount on

	insert into KISILER(AdSoyad, Telno, Email, DogumTarihi, KayitTarihi, TesisID, SporID, EgitmenID)
	values (@AdSoyad, @Telno, @Email, @DogumTarihi, GETDATE(), @TesisID, @SporID, @EgitmenID)

	select COUNT(*) from KISILER where TesisID =  @TesisID and SporID = @SporID
end


exec sp_Update
    @AdSoyad = 'ÖMER DEMÝR',
	@Telno = '534 594 78 42',
	@Email = 'omer@hotmail.com',
	@DogumTarihi = '1997-02-18',
    @SporID = 57,
	@TesisID = 19,
	@EgitmenID =5



############# TRIGGER #############



create table AUDIT_LOG(
	ID int identity(1,1),
	KULLANICI_ID int,
	ADSOYAD varchar(50),
	TELNO VARCHAR(50),
	ISLEM_TIPI varchar(10),
	ISLEM_ZAMANI datetime,
	DETAY varchar(500),
	constraint [PK_AUDIT_LOG] primary key CLUSTERED ([ID] asc)
)

create trigger trgAfterInsertOnKisiler
on KISILER
after insert
as
begin
declare
    @KisilerID int, 
	@AdSoyad varchar(50), 
	@Telefon varchar(100),
	@Tesis int,
	@Spor int,
	@Egitmen int

    select @KisilerID = KisilerID, @AdSoyad = AdSoyad, @Telefon = Telno, @Tesis=TesisID, @Spor=SporID, @Egitmen=EgitmenID from inserted

    insert into AUDIT_LOG (KULLANICI_ID, ADSOYAD, TELNO, ISLEM_TIPI, ISLEM_ZAMANI, DETAY)
    values (@KisilerID, @AdSoyad, @Telefon, 'INSERT', GETDATE(), 'Yeni Kullanýcý eklendi.' )
    end


insert into KISILER(AdSoyad, Telno, Email, DogumTarihi, KayitTarihi, TesisID, SporID, EgitmenID) 
values('Özge Asan', '532 423 75 12', 'ozge@hotmail.com', '2002-11-22', '2024-05-24', 5, 50, 19)


############## VIEW ###############

create view Tablolar as 
select
K.AdSoyad, 
E.EgitmenAdi, 
S.SporAdi, 
T.TesisAdi
from KISILER K
inner join EGITMENLER E on  K.EgitmenID = E.EgitmenID
inner join SPORDALLARI S on  K.SporID = S.SporID
inner join TESISLER T on K.TesisID = T.TesisID

select * from Tablolar


########### SORGULAR ############

select top 5 * from KISILER where KayitTarihi = '2021-06-23'
select Count(*) from KISILER where TesisID = 17 and SporID = 25 
Update KISILER set SporID = 10 where KisilerID = 100
update KISILER set Telno ='534 789 45 23' where = KisilerID = 23
delete from EGITMENLER where EgitmenAdi = 'MUSTAFA ÖZ'
select * from TESISLER order by TesisAdi
select top 10 * from KISILER where DogumTarihi >= '2005-01-01' order by KisilerID
select AdSoyad from KISILER where EgitmenID = (select EgitmenID from EGITMENLER where EgitmenAdi = 'ONUR KARA')
select * from SPORDALLARI where SporAdi like '%mna%'
select TesisID, Count(*) as OgrenciSayisi from KISILER group by TesisID having Count(*) > 4000
select top 10 K.AdSoyad, K.Telno, E.EgitmenAdi from KISILER K left outer join EGITMENLER E on K.EgitmenID = E.EgitmenID where EgitmenAdi = 'ADEM GÜL'









