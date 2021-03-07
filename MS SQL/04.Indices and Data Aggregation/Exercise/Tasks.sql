--01. Records’ Count
SELECT COUNT(Id) AS Count 
FROM WizzardDeposits

--02. Longest Magic Wand
SELECT MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits

--03. Longest Magic Wand per Deposit Groups
SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup

--04. Smallest Deposit Group per Magic Wand Size (not included in final score)
SELECT TOP 1 WITH TIES DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

--05. Deposits Sum
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup

--06. Deposits Sum for Ollivander Family
SELECT 
  DepositGroup, 
  SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup

--07. Deposits Filter
SELECT 
  DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

--08. Deposit Charge
SELECT 
  DepositGroup, 
  MagicWandCreator, 
  MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup ASC

--09. Age Groups
SELECT
  IIF(Age >= 61, '[61+]', 
    IIF(Age = 0, '[0-10]', 
	  CONCAT('[',(Age-1)/10 * 10 + 1,'-', (Age-1)/10 * 10 + 10, ']'))) AS AgeGroup,
  COUNT(Age) AS WizardCount
FROM WizzardDeposits
GROUP BY 
  IIF(Age >= 61, '[61+]', 
    IIF(Age = 0, '[0-10]', 
	  CONCAT('[',(Age-1)/10 * 10 + 1,'-', (Age-1)/10 * 10 + 10, ']')))
HAVING COUNT(Age) > 0

ORDER BY AgeGroup
--10. First Letter
SELECT DISTINCT
  LEFT(FirstName, 1) AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
ORDER BY FirstLetter

--11. Average Interest
SELECT
  DepositGroup, IsDepositExpired,
  AVG(DepositInterest) AS AverageInterest
FROM WizzardDeposits
WHERE DepositStartDate > '1985/01/01'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

--12. Rich Wizard, Poor Wizard (not included in final score)
SELECT TOP 1
  (SELECT DepositAmount FROM WizzardDeposits WHERE Id = (SELECT MIN(Id) FROM WizzardDeposits)) - 
  (SELECT DepositAmount FROM WizzardDeposits WHERE Id = (SELECT MAX(Id) FROM WizzardDeposits)) 
  AS SumDifference
FROM WizzardDeposits

--13. Departments Total Salaries
SELECT 
  DepartmentID, 
  SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--14. Employees Minimum Salaries
SELECT
  DepartmentID, MIN(Salary) AS MinimumSalary
FROM Employees
WHERE DepartmentID IN (2,5,7) AND HireDate > '2000/01/01'
GROUP BY DepartmentID

--15. Employees Average Salaries
SELECT * 
INTO NewTable
FROM Employees
WHERE Salary > 30000

DELETE FROM NewTable
WHERE ManagerId = 42

UPDATE NewTable
SET Salary += 5000
WHERE DepartmentID = 1

SELECT
  DepartmentID, AVG(Salary) AS AverageSalary
FROM NewTable
GROUP BY DepartmentID

--16. Employees Maximum Salaries
SELECT
  DepartmentID, MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--17. Employees Count Salaries
SELECT COUNT(Salary) AS Count
FROM Employees
WHERE ManagerID IS NULL

--18. 3rd Highest Salary (not included in final score)
SELECT 
  DepartmentID,
  (SELECT DISTINCT Salary FROM Employees
   WHERE DepartmentID = e.DepartmentID
   ORDER BY Salary DESC 
   OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY) AS ThirdHighestSalary
FROM Employees e
WHERE 
  (SELECT DISTINCT Salary FROM Employees
   WHERE DepartmentID = e.DepartmentID
   ORDER BY Salary DESC 
   OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY) IS NOT NULL
GROUP BY DepartmentID

--19. Salary Challenge (not included in final score)
SELECT TOP 10
  FirstName, LastName, e.DepartmentID 
FROM Employees AS e
INNER JOIN (
  SELECT DepartmentID, AVG(Salary) AS AverageSalary
  FROM Employees 
  GROUP BY DepartmentID) AS av
ON e.DepartmentID = av.DepartmentID
WHERE Salary > AverageSalary
ORDER BY e.DepartmentID

