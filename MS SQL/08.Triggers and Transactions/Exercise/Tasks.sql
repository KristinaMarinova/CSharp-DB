--14. Create Table Logs
CREATE TABLE Logs
(
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT NOT NULL REFERENCES Accounts(Id),
	OldSum MONEY,
	NewSum MONEY
)

GO
CREATE TRIGGER tr_AccountSumLog
ON Accounts
AFTER UPDATE
AS
BEGIN
	INSERT Logs(AccountId, OldSum, NewSum)
	SELECT inserted.Id, deleted.Balance, inserted.Balance
	FROM deleted, inserted
END
GO

--15. Create Table Emails
CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT REFERENCES Accounts(Id),
	Subject VARCHAR(MAX),
	Body VARCHAR(MAX)
)

GO
CREATE TRIGGER tr_CreateEmailAfterLogTrigger
ON Logs
AFTER INSERT
AS
BEGIN
	INSERT NotificationEmails(Recipient, Subject, Body)
		SELECT inserted.AccountId,
			CONCAT('Balance change for account: ', CAST(inserted.AccountId AS VARCHAR(255))), 
			CONCAT('On ', GETDATE(), ' your balance was changed from ', inserted.OldSum, ' to ', inserted.NewSum)
		FROM inserted
END
GO

--16. Deposit MoneyGO
CREATE PROC usp_DepositMoney (@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN
	BEGIN TRAN
	UPDATE Accounts
		SET Balance += @MoneyAmount
		WHERE Accounts.Id = @AccountId
	COMMIT
END
GO

--17. Withdraw Money Procedure
GO
CREATE PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN
	BEGIN TRAN
	DECLARE @CurrentAccountBalance MONEY
		UPDATE Accounts
		SET Balance -= @MoneyAmount
		WHERE Accounts.Id = @AccountId
		
		SET @CurrentAccountBalance = (SELECT Balance FROM Accounts AS a WHERE a.Id = @AccountId)
		
		IF (@CurrentAccountBalance < 0)
			ROLLBACK
		ELSE
	COMMIT
END
GO

--18. Money Transfer
GO
CREATE PROC usp_TransferMoney (@SenderId INT, @ReceiverId INT, @Amount MONEY)
AS
BEGIN
	DECLARE @SenderBalance MONEY = (SELECT Balance FROM Accounts WHERE Id = @SenderId)
	BEGIN TRAN
		IF(@Amount < 0)
			ROLLBACK
		ELSE
		BEGIN
			IF(@SenderBalance - @amount >= 0)
			BEGIN
				EXEC usp_WithdrawMoney @senderId, @amount
				EXEC usp_DepositMoney @receiverId, @amount
				COMMIT
			END
			ELSE
			BEGIN
				ROLLBACK
			END
		END
END
GO

--20. *Massive Shopping
DECLARE @User VARCHAR(MAX) = 'Stamat'
DECLARE @GameName VARCHAR(MAX) = 'Safflower'
DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = @User)
DECLARE @GameId INT = (SELECT Id FROM Games WHERE Name = @GameName)
DECLARE @UserMoney MONEY = (SELECT Cash FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
DECLARE @ItemsBulkPrice MONEY
DECLARE @UserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)

BEGIN TRAN 
		SET @ItemsBulkPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12) --11 to 12
		IF (@UserMoney - @ItemsBulkPrice >= 0)
		BEGIN
			INSERT INTO UserGameItems(ItemId,UserGameId) -- no values?
			(SELECT i.Id, @UserGameId FROM Items AS i
			WHERE i.id IN (Select Id FROM Items WHERE MinLevel BETWEEN 11 AND 12))
			UPDATE UsersGames
			SET Cash -= @ItemsBulkPrice
			WHERE GameId = @GameId AND UserId = @UserId
			COMMIT
		END
		ELSE
		BEGIN
			ROLLBACK
		END
			

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
BEGIN TRAN  
		SET @ItemsBulkPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21) --19 to 21
		IF (@UserMoney - @ItemsBulkPrice >= 0)
		BEGIN
			INSERT UserGameItems(ItemId,UserGameId)
			SELECT i.Id, @UserGameId FROM Items AS i
			WHERE i.id IN (Select Id FROM Items WHERE MinLevel BETWEEN 19 AND 21)
			UPDATE UsersGames
			SET Cash -= @ItemsBulkPrice
			WHERE GameId = @GameId AND UserId = @UserId
			COMMIT
		END
		ELSE
		BEGIN
			ROLLBACK
		END

 SELECT Name AS 'Item Name' FROM Items
 WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @UserGameId)
 ORDER BY [Item Name]

--21. Employees with Three Projects
GO
CREATE PROC usp_AssignProject (@EmloyeeId INT, @ProjectID INT)
AS
BEGIN
	BEGIN TRAN
		IF ((SELECT Count(*) FROM Employees e 
			JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
			JOIN Projects p ON ep.ProjectID = p.ProjectID
			WHERE e.EmployeeID = @EmloyeeId)
			>= 3)
			BEGIN
				ROLLBACK
				RAISERROR('The employee has too many projects!', 16,1)
				RETURN
			END
		ELSE
		INSERT INTO EmployeesProjects VALUES -- columns not specified
		(@EmloyeeId, @ProjectID)
	COMMIT
END
GO

--22. Delete Employees
CREATE TABLE Deleted_Employees
(
 EmployeeId INT PRIMARY KEY IDENTITY,
 FirstName VARCHAR(50), 
 LastName VARCHAR(50), 
 MiddleName VARCHAR(50), 
 JobTitle VARCHAR(50), 
 DepartmentId INT, 
 Salary MONEY
)

GO
CREATE TRIGGER tr_DeleteEmployee ON Employees AFTER DELETE
AS
INSERT INTO Deleted_Employees(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
SELECT d.FirstName, d.LastName, d.MiddleName, d.JobTitle, d.DepartmentID, d.Salary 
FROM deleted AS d
GO

SELECT * FROM Deleted_Employees
DELETE FROM Employees
WHERE EmployeeID = 1