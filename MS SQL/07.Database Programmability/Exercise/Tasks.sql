--01. Employees with Salary Above 35000
CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
		SELECT FirstName, LastName
		FROM Employees
		WHERE Salary > 35000

--02. Employees with Salary Above Number
CREATE PROC usp_GetEmployeesSalaryAboveNumber(@Number DECIMAL(18,4))
AS
		SELECT FirstName,LastName
		FROM Employees
		WHERE Salary >= @Number

--03. Town Names Starting With
CREATE PROC usp_GetTownsStartingWith(@InputString VARCHAR(20))
AS
		SELECT [Name]
		FROM Towns
		WHERE [Name] LIKE @InputString + '%'

--04. Employees from Town
CREATE PROC usp_GetEmployeesFromTown(@InputString VARCHAR(20))
AS 
		SELECT e.FirstName, e.LastName 
		FROM Employees AS e
		JOIN Addresses AS a ON e.AddressID = a.AddressID
		JOIN Towns AS t ON a.TownID = t.TownID
		WHERE t.Name = @InputString 

--05. Salary Level Function
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
RETURNS NVARCHAR(10)
AS
BEGIN
		DECLARE @salaryLevel NVARCHAR(10)

		IF(@salary < 30000)
		BEGIN
				SET @salaryLevel = 'Low'
		END
		ELSE IF(@salary <= 50000)
		BEGIN
				SET @salaryLevel = 'Average'
		END
		ELSE 
		BEGIN
				SET @salaryLevel = 'High'
		END
		RETURN @salaryLevel 
END

--06. Employees by Salary Level
CREATE PROC usp_EmployeesBySalaryLevel @LevelOfSalary VARCHAR(15)
AS
SELECT FirstName, LastName 
FROM Employees
WHERE dbo.ufn_GetSalaryLevel(Salary) = @LevelOfSalary

--07. Define Function
REATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(MAX), @word VARCHAR(MAX))
RETURNS BIT
BEGIN
	DECLARE @count INT = 1
	WHILE(@count <= LEN(@word))
	BEGIN
		DECLARE @currentLetter CHAR(1) = SUBSTRING(@word, @count, 1)
		DECLARE @charIdex INT = CHARINDEX(@currentLetter, @setOfLetters)

		IF(@charIdex = 0)
		BEGIN
			RETURN 0
		END
		SET @count += 1
	END
	RETURN 1
END

--08. Delete Employees and Departments
CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
ALTER TABLE Departments
ALTER COLUMN ManagerID INT

UPDATE Departments
SET ManagerID = NULL
WHERE DepartmentID = @departmentId

UPDATE Employees
SET ManagerID = NULL
WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

DELETE FROM EmployeesProjects
WHERE EmployeeID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

DELETE FROM Employees
WHERE DepartmentID = @departmentId

DELETE FROM Departments
WHERE DepartmentID = @departmentId

SELECT COUNT(*)
FROM Employees
WHERE DepartmentID = @departmentId

--09. Find Full Name
CREATE PROC usp_GetHoldersFullName 
AS
		SELECT CONCAT(FirstName, ' ', LastName)
		FROM AccountHolders

--10. People with Balance Higher Than
CREATE PROC usp_GetHoldersWithBalanceHigherThan (@InputMoney MONEY)
AS
SELECT 
		t.FirstName AS [First Name],
		t.LastName AS [Last Name]
FROM (
SELECT ah.Id, ah.FirstName, ah.LastName, SUM(a.Balance) AS TotalBalanc
FROM AccountHolders AS ah
JOIN Accounts AS a ON ah.Id = a.AccountHolderId
GROUP BY ah.Id, ah.FirstName, ah.LastName
HAVING SUM(a.Balance) > @InputMoney) 
AS t
ORDER BY t.FirstName, t.LastName

--11. Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue (@InitialSum DECIMAL(18, 4), @YearlyInterestRate FLOAT, @NumberOfYears INT)
RETURNS DECIMAL(18,4)
BEGIN
			DECLARE @FutureValue DECIMAL(18,4)
			SET @FutureValue = @InitialSum * POWER ((1+@YearlyInterestRate) , @NumberOfYears)
			RETURN @FutureValue
END

--12. Calculating Interest
CREATE PROC usp_CalculateFutureValueForAccount (@AccountID INT, @InterestRate FLOAT)
AS
SELECT 
t.Id AS [Account id], 
t.FirstName AS [First Name], 
t.LastName AS [Last Name], 
t.TotalBalance AS [Current Balance], 
dbo.ufn_CalculateFutureValue(t.TotalBalance, @InterestRate, 5) AS [Balance in 5 years]
FROM(
	   SELECT a.Id, ah.FirstName, ah.LastName, SUM(a.Balance) AS TotalBalance
		  FROM AccountHolders AS ah
			JOIN Accounts AS a ON ah.Id = a.AccountHolderId
      WHERE a.Id = @AccountID
GROUP BY a.Id, ah.FirstName, ah.LastName) AS t

--13. *Cash in User Games Odd Rows
CREATE FUNCTION ufn_CashInUsersGames
(@gameName NVARCHAR(50)
)
RETURNS TABLE
AS
     RETURN
     WITH prices
          AS (
          SELECT Cash,
                 (ROW_NUMBER() OVER(ORDER BY ug.Cash DESC)) AS RowNum
          FROM UsersGames ug
               JOIN Games g ON ug.GameId = g.Id
          WHERE g.Name = @gameName)
          SELECT SUM(Cash) [SumCash]
          FROM prices
          WHERE RowNum % 2 = 1;