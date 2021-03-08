--01. Number of Users for Email Provider
SELECT 
	RIGHT([Email], LEN([Email]) - CHARINDEX('@',[Email])) AS [Email Provider],
	COUNT(*) AS [Number Of Users]
FROM Users
GROUP BY RIGHT([Email], LEN([Email]) - CHARINDEX('@',[Email]))
	ORDER BY 
		[Number Of Users] DESC,
		[Email Provider] ASC

--02. All Users in Games
SELECT 
	g.Name AS Game,
	gt.Name as [Game Type],
	u.Username,
	ug.Level,
	ug.Cash,
	c.Name
FROM UsersGames ug
	JOIN Characters c ON ug.CharacterId = c.Id
	JOIN Games g ON ug.GameId = g.Id
	JOIN GameTypes gt ON g.GameTypeId = gt.Id
	JOIN Users u ON ug.UserId = u.Id
ORDER BY 
	Level DESC,
	Username ASC,
	g.Name ASC

--03. Users in Games with Their Items
SELECT 
	u.Username,
	g.Name,
	COUNT(ugi.ItemId) AS [Items Count],
	SUM(i.Price) AS[Items Price]
FROM UsersGames ug
	JOIN Users u ON ug.UserId = u.Id
	JOIN Games g ON ug.GameId = g.Id
	JOIN UserGameItems ugi ON ug.Id = ugi.UserGameId
	JOIN Items i ON ugi.ItemId = i.Id
GROUP BY u.Username, g.Name
HAVING COUNT(i.Name) >= 10
ORDER BY 
	[Items Count] DESC,
	[Items Price] DESC,
	u.Username ASC

--04. * User in Games with Their Statistics
SELECT u.Username,
       g.Name AS Game,
       MAX(c.Name) AS Character,
       SUM(iStat.Strength) + MAX(gtStat.Strength) + MAX(cStat.Strength) AS Strength,
       SUM(iStat.Defence) + MAX(gtStat.Defence) + MAX(cStat.Defence) AS Defence,
       SUM(iStat.Speed) + MAX(gtStat.Speed) + MAX(cStat.Speed) AS Speed,
       SUM(iStat.Mind) + MAX(gtStat.Mind) + MAX(cStat.Mind) AS Mind,
       SUM(iStat.Luck) + MAX(gtStat.Luck) + MAX(cStat.Luck) AS Luck
FROM Users AS u
     JOIN UsersGames AS ug ON ug.UserId = u.Id
     JOIN Games AS g ON g.Id = ug.GameId
     JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
     JOIN Items AS i ON i.Id = ugi.ItemId
     JOIN [Statistics] AS iStat ON iStat.Id = i.StatisticId
     JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
     JOIN [Statistics] AS gtStat ON gtstat.Id = gt.BonusStatsId
     JOIN Characters AS c ON c.Id = ug.CharacterId
     JOIN [Statistics] AS cStat ON cStat.Id = c.StatisticId
GROUP BY g.Name,
         Username
ORDER BY Strength DESC,
         Defence DESC,
         Speed DESC,
         Mind DESC,
         Luck DESC

--05. All Items with Greater than Average Statistics
select
i.Name, 
i.Price, 
i.MinLevel, 
s.Strength, 
s.Defence, 
s.Speed, 
s.Luck, 
s.Mind 
from Items as i
inner join [dbo].[Statistics] as s
on i.StatisticId = s.Id
left join (select avg(Speed) as avgSpeed, avg(Luck) as avgLuck, avg(Mind) as avgMind from [dbo].[Statistics]) as avgStats
on s.Speed > avgStats.avgSpeed and s.Luck > avgStats.avgLuck and s.Mind > avgStats.avgMind
where avgStats.avgSpeed is not null
order by i.Name

--06. Display All Items about Forbidden Game Type
select i.Name as Item, i.Price, i.MinLevel, gt.Name as 'Forbidden Game Type' from Items as i
inner join GameTypeForbiddenItems as gtf
on i.Id = gtf.ItemId
inner join GameTypes as gt
on gtf.GameTypeId = gt.Id
order by gt.Name desc, i.Name

--07. Buy Items for User in Game
declare @userId int = (select Id from Users where Username = 'Alex');
declare @userGameId int = (select Id from UsersGames where GameId = (select Id from Games where Name = 'Edinburgh'));
declare @blackguardId int = (select Id from Items where Name = 'Blackguard');
declare @bottomlessPotionofAmplificationId int = (select Id from Items where Name = 'Bottomless Potion of Amplification');
declare @eyeofEtlichDiabloIIIId int = (select Id from Items where Name = 'Eye of Etlich (Diablo III)');
declare @gemofEfficaciousToxinId int = (select Id from Items where Name = 'Gem of Efficacious Toxin');
declare @goldenGorgetofLeoricId int = (select Id from Items where Name = 'Golden Gorget of Leoric');
declare @hellfireAmuletId int = (select Id from Items where Name = 'Hellfire Amulet');

begin tran 
update UsersGames
set Cash -= ((select Price from Items where Id = @blackguardId) + 
(select Price from Items where Id = @bottomlessPotionofAmplificationId) + 
(select Price from Items where Id = @eyeofEtlichDiabloIIIId) +
(select Price from Items where Id = @gemofEfficaciousToxinId) +
(select Price from Items where Id = @goldenGorgetofLeoricId) +
(select Price from Items where Id = @hellfireAmuletId)) where UserId = @userId;

insert into UserGameItems
values(@userGameId, @blackguardId),
(@userGameId, @bottomlessPotionofAmplificationId),
(@userGameId, @eyeofEtlichDiabloIIIId),
(@userGameId, @gemofEfficaciousToxinId),
(@userGameId, @goldenGorgetofLeoricId),
(@userGameId, @hellfireAmuletId);
commit
go

select u.Username, g.Name, ug.Cash, i.Name as 'Item Name' from Games as g
inner join UsersGames as ug
on g.Id = ug.GameId
inner join Users as u
on ug.UserId = u.Id
inner join UserGameItems as ugi
on ug.Id = ugi.UserGameId
inner join Items as i
on ugi.ItemId = i.Id
where g.Name = 'Edinburgh'
order by i.Name
go

--08. Peaks and Mountains
select p.PeakName, m.MountainRange as Mountain, p.Elevation from Peaks as p
inner join Mountains as m
on p.MountainId = m.Id
order by p.Elevation desc

--09. Peaks with Mountain, Country and Continent
select p.PeakName, m.MountainRange as Mountain, c.CountryName, con.ContinentName from Peaks as p
inner join Mountains as m
on p.MountainId = m.Id
inner join MountainsCountries as mc
on m.Id = mc.MountainId
inner join Countries as c
on mc.CountryCode = c.CountryCode
inner join Continents as con
on c.ContinentCode = con.ContinentCode
order by p.PeakName, c.CountryName

--10. Rivers by Country
select CountriesByContinent.CountryName, 
CountriesByContinent.ContinentName,
RiversCountAndTotalLenghtByCountry.RiversCount,
RiversCountAndTotalLenghtByCountry.TotalLength
from 
(select c.CountryName, con.ContinentName from Countries as c
inner join Continents as con
on c.ContinentCode = con.ContinentCode) as CountriesByContinent
inner join 
(select c.CountryName, count(r.Id) as RiversCount, sum(r.Length) as TotalLength from Countries as c
left join CountriesRivers as cr
on c.CountryCode = cr.CountryCode
left join Rivers as r
on cr.RiverId = r.Id
group by c.CountryName) as RiversCountAndTotalLenghtByCountry
on CountriesByContinent.CountryName = RiversCountAndTotalLenghtByCountry.CountryName
order by RiversCount desc, TotalLength desc, CountryName

--11. Count of Countries by Currency
select c.CurrencyCode, c.Description as Currency, CurrencyUsageCountByCountries.NumberOfCountries from
(select CurrencyCode, count(*) as NumberOfCountries from Countries
group by CurrencyCode) as CurrencyUsageCountByCountries
inner join Currencies as c
on CurrencyUsageCountByCountries.CurrencyCode = c.CurrencyCode
order by NumberOfCountries desc, Currency

--12. Population and Area by Continent
select con.ContinentName, 
sum(cast(c.AreaInSqKm as bigint)) as CountriesArea, 
sum(cast(c.Population as bigint)) as CountriesPopulation 
from Countries as c
inner join Continents as con
on c.ContinentCode = con.ContinentCode
group by con.ContinentName
order by CountriesPopulation desc

--13. Monasteries by Country
create table Monasteries
(
Id int identity primary key, 
Name varchar(50), 
CountryCode char(2) foreign key references Countries(CountryCode)
)
go

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')
go

update Countries
set IsDeleted = 1
where CountryCode in ('BR', 'CA', 'CN', 'RU', 'US')
go

select m.Name, c.CountryName from Monasteries as m
inner join Countries as c
on m.CountryCode = c.CountryCode
where IsDeleted = 0
order by m.Name
go

--14. Monasteries by Continents and Countries
update Countries
set CountryName = 'Burma'
where CountryName = 'Myanmar'
go

insert into Monasteries
values ('Hanga Abbey', (select CountryCode from Countries where CountryName = 'Tanzania'))
go

insert into Monasteries
values ('Myin-Tin-Daik', (select CountryCode from Countries where CountryName = 'Myanmar'))
go

select CountriesAndContinents.ContinentName, 
CountriesAndContinents.CountryName,
MonasteriesCountByCountry.MonasteriesCount
from (select c.CountryName, count(*) as MonasteriesCount from Countries as c
left join Monasteries as m
on c.CountryCode = m.CountryCode
where c.IsDeleted = 0
group by c.CountryName) as MonasteriesCountByCountry
inner join (select c.CountryName, con.ContinentName from Countries as c
inner join Continents as con
on c.ContinentCode = con.ContinentCode) as CountriesAndContinents
on MonasteriesCountByCountry.CountryName = CountriesAndContinents.CountryName
order by MonasteriesCountByCountry.MonasteriesCount desc, CountriesAndContinents.CountryName
go