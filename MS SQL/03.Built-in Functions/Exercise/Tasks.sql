--01. Find Names of All Employees by First Name
SELECT FirstName, LastName
FROM Employees
WHERE LEFT(FirstName, 2) = 'SA'

--02. Find Names of All Employees by Last Name
SELECT FirstName, LastName
FROM Employees
WHERE CHARINDEX('ei', LastName) > 0

--03. Find First Names of All Employess
SELECT FirstName 
FROM Employees
WHERE DepartmentID IN (3,10) AND YEAR(HireDate) BETWEEN 1995 AND 2005

--04. Find All Employees Except Engineers
SELECT FirstName, LastName
FROM Employees
WHERE CHARINDEX('engineer', JobTitle) = 0

--05. Find Towns with Name Length
SELECT Name FROM Towns
WHERE LEN(Name) IN (5,6)
ORDER BY Name

--06. Find Towns Starting With
SELECT * FROM Towns
WHERE LEFT(Name, 1) IN ('M', 'K', 'B', 'E')
ORDER BY Name

--07. Find Towns Not Starting With
SELECT * FROM Towns
WHERE LEFT(Name, 1) NOT IN ('R', 'B', 'D')
ORDER BY Name

--08. Create View Employees Hired After
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
FROM Employees
WHERE YEAR(HireDate) > 2000

--09. Length of Last Name
SELECT FirstName, LastName
FROM Employees 
WHERE LEN(LastName) = 5

--10. Rank Employees by Salary
SELECT i.EmployeeID,
        i.FirstName,
        i.LastName,i.Salary,DENSE_RANK() OVER   
        (PARTITION BY i.Salary ORDER BY i.EmployeeID) AS Rank  
FROM Employees AS i
WHERE Salary BETWEEN 10000 AND 50000 
ORDER BY Salary DESC

--11. Find All Employees with Rank 2 (not included in final score)
SELECT * FROM (
       SELECT EmployeeID,
              FirstName,
              LastName,
              Salary,
              DENSE_RANK() OVER(
			  PARTITION BY Salary ORDER BY EmployeeID
			  ) AS Rank
	   FROM Employees AS R  
	) Employees  
WHERE Rank = 2 AND Salary BETWEEN 10000 AND 50000 
ORDER BY Salary DESC

--12. Countries Holding 'A'
SELECT CountryName, IsoCode
FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode

--13. Mix of Peak and River Names
SELECT PeakName, RiverName,
LOWER(SUBSTRING(PeakName, 1, LEN(PeakName) - 1) + RiverName) AS MIX
FROM Peaks JOIN Rivers
ON RIGHT(Peaks.PeakName, 1) =  LEFT(Rivers.RiverName, 1)
ORDER BY Mix

--14. Games From 2011 and 2012 Year
SELECT TOP 50
	     [Name],
	     FORMAT([Start], 'yyyy-MM-dd') AS [Start]
    FROM Games
   WHERE DATEPART(YEAR, [Start]) IN (2011, 2012)
ORDER BY [Start],
		 [Name]

--15. User Email Providers
SELECT 
	Username, 
	RIGHT(Email, LEN(Email) - CHARINDEX('@', Email)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username

--16. Get Users with IPAddress Like Pattern
SELECT 
	Username, 
	IpAddress AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username

--17. Show All Games with Duration
SELECT 
	Name AS Game, 
	IIF(DATEPART(HH, Start) >= 18, 'Evening', 
		IIF(DATEPART(HH, Start) >= 12, 'Afternoon', 'Morning')) 
		AS [Part of the Day], 
	IIF(Duration IS NULL, 'Extra Long',
		IIF(Duration > 6, 'Long', 
			IIF(Duration >= 4, 'Short', 'Extra Short'))) 
		AS Duration
FROM Games
ORDER BY Game, Duration, [Part of the Day]

--18. Orders Table
SELECT 
	ProductName, OrderDate,
	DATEADD(DAY, 3, OrderDate) AS [Pay Due],
	DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
FROM Orders