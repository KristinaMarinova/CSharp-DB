--Section 1. DDL 

CREATE DATABASE WMS

CREATE TABLE Clients
(
ClientId INT IDENTITY(1,1) NOT NULL,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Phone VARCHAR(12) NOT NULL,
CONSTRAINT PK_Clients PRIMARY KEY (ClientId),
CONSTRAINT CHK_Clients CHECK (LEN(Phone) = 12)
)

CREATE TABLE Mechanics
(
MechanicId INT IDENTITY(1,1) NOT NULL,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
[Address] VARCHAR(255) NOT NULL,
CONSTRAINT PK_Mechanics PRIMARY KEY (MechanicId)
)

CREATE TABLE Models
(
ModelId INT IDENTITY(1,1) NOT NULL,
[Name] VARCHAR(50) NOT NULL UNIQUE,
CONSTRAINT PK_Models PRIMARY KEY (ModelId)
)

CREATE TABLE Jobs
(
JobId INT IDENTITY(1,1) NOT NULL,
ModelId INT NOT NULL,
[Status] VARCHAR(11) NOT NULL DEFAULT 'Pending',
ClientId INT NOT NULL,
MechanicId INT,
IssueDate Date NOT NULL,
FinishDate Date,
CONSTRAINT PK_Jobs PRIMARY KEY (JobId),
CONSTRAINT FK_Jobs_Models FOREIGN KEY (ModelId) REFERENCES Models(ModelId),
CONSTRAINT FK_Jobs_Clients FOREIGN KEY (ClientId) REFERENCES Clients(ClientId),
CONSTRAINT FK_Jobs_Mechanics FOREIGN KEY (MechanicId) REFERENCES Mechanics(MechanicId),
CONSTRAINT CHK_Jobs CHECK (Status in ('Pending','In Progress','Finished'))
)

CREATE TABLE Orders
(
OrderId INT IDENTITY (1,1) NOT NULL,
JobId INT NOT NULL,
IssueDate DATE,
Delivered BIT DEFAULT 0
CONSTRAINT PK_Orders PRIMARY KEY (OrderId),
CONSTRAINT FK_Orders_Jobs FOREIGN KEY (JobId) REFERENCES Jobs(JobId)
)

CREATE TABLE Vendors
(
VendorId INT IDENTITY (1,1) NOT NULL,
[Name] VARCHAR(50) NOT NULL UNIQUE,
CONSTRAINT PK_Vendors PRIMARY KEY (VendorId)
)

CREATE TABLE Parts
(
PartId INT IDENTITY (1,1) NOT NULL,
SerialNumber VARCHAR(50) NOT NULL UNIQUE,
[Description] VARCHAR(255),
Price MONEY NOT NULL,
VendorId INT NOT NULL,
StockQty INT NOT NULL DEFAULT 0,
CONSTRAINT PK_Parts PRIMARY KEY (PartId),
CONSTRAINT CHK_Parts_Price CHECK (Price > 0),
CONSTRAINT CHK_Parts_StockQty CHECK (StockQty >= 0),
CONSTRAINT FK_Parts_Vendors FOREIGN KEY (VendorId) REFERENCES Vendors(VendorId)
)

CREATE TABLE OrderParts
(
OrderId INT NOT NULL,
PartId INT NOT NULL,
Quantity INT NOT NULL DEFAULT 1,
CONSTRAINT PK_OrderParts PRIMARY KEY (OrderId,PartId),
CONSTRAINT FK_OrderParts_Orders FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
CONSTRAINT FK_OrderParts_Parts FOREIGN KEY (PartId) REFERENCES Parts(PartId),
CONSTRAINT CHK_OrderParts_Quantity CHECK (Quantity > 0)
)

CREATE TABLE PartsNeeded
(
JobId INT NOT NULL,
PartId INT NOT NULL,
Quantity INT NOT NULL DEFAULT 1,
CONSTRAINT PK_PartsNeeded PRIMARY KEY (JobId,PartId),
CONSTRAINT FK_PartsNeeded_Jobs FOREIGN KEY (JobId) REFERENCES Jobs(JobId),
CONSTRAINT FK_PartsNeeded_Parts FOREIGN KEY (PartId) REFERENCES Parts(PartId),
CONSTRAINT CHK_PartsNeeded_Quantity CHECK (Quantity > 0)
)

--Section 2. DML
--Insert

INSERT INTO Clients(FirstName, LastName, Phone) VALUES 
('Teri' ,'Ennaco','570-889-5187'),
('Merlyn','Lawler','201-588-7810'),
('Georgene','Montezuma','925-615-5185'),
('Jettie','Mconnell','908-802-3564'),
('Lemuel','Latzke','631-748-6479'),
('Melodie','Knipp','805-690-1682'),
('Candida','Corbley','908-275-8357')

INSERT INTO Parts(SerialNumber, [Description], Price, VendorId) VALUES
('WP8182119', 'Door Boot Seal', 117.86, 2),
('W10780048', 'Suspension Rod',	42.81, 1),
('W10841140', 'Silicone Adhesive', 6.77, 4),
('WPY055980', 'High Temperature Adhesive', 13.94, 3)


--UPDATE
UPDATE Jobs
SET Status = 'In Progress', MechanicId = 3
WHERE Status='Pending'


--DELETE
DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
WHERE OrderId = 19


--Section 3. Querying 

--Mechanic Assignments
--Select all mechanics with their jobs. Include job status and issue date. 
--Order by mechanic Id, issue date, job Id (all ascending).

SELECT CONCAT(FirstName,' ',LastName) AS Mechanic, [Status], IssueDate
FROM Mechanics
JOIN Jobs ON Jobs.MechanicId = Mechanics.MechanicId
ORDER BY Jobs.MechanicId, Jobs.IssueDate, Jobs.JobId


--Current Clients
--Select the names of all clients with active jobs (not Finished). 
--Include the status of the job and how many days it’s been since it was submitted. 
--Assume the current date is 24 April 2017. 
--Order results by time length (descending) and by client ID (ascending).

SELECT CONCAT(FirstName,' ',LastName) as Client,
DATEDIFF(day,issuedate,'2017-04-24')as [Days going],
[Status]
FROM Clients
JOIN Jobs ON Clients.ClientId = Jobs.ClientId
WHERE Jobs.Status<>'Finished'


--Mechanic Performance
--Select all mechanics and the average time they take to finish their assigned jobs. 
--Calculate the average as an integer. Order results by mechanic ID (ascending).

SELECT 
CONCAT(FirstName, ' ', LastName) AS Mechanic,
AVG(DATEDIFF(DAY,IssueDate,FinishDate)) AS [Average days]
FROM JOBS
JOIN Mechanics ON Jobs.MechanicId = Mechanics.MechanicId
WHERE Status='Finished'
GROUP BY Jobs.MechanicId, FirstName, LastName


--Available Mechanics
--Select all mechanics without active jobs (include mechanics which don’t have any job 
--assigned or all of their jobs are finished). Order by ID (ascending).

SELECT CONCAT(FirstName, ' ', LastName) AS Available
FROM Mechanics
WHERE Mechanics.MechanicId NOT IN
(
    SELECT DISTINCT
           Mechanics.MechanicId
    FROM Mechanics
         LEFT JOIN Jobs ON Jobs.MechanicId = Mechanics.MechanicId
    WHERE Status <> 'Finished'
)
ORDER BY Mechanics.MechanicId;


--Past Expenses
--Select all finished jobs and the total cost of all parts that were ordered for them. 
--Sort by total cost of parts ordered (descending) and by job ID (ascending).

SELECT Jobs.JobId, SUM(Price) AS Total
FROM Jobs
JOIN PartsNeeded ON Jobs.JobId = PartsNeeded.JobId
JOIN Parts ON Parts.PartId = PartsNeeded.PartId
WHERE Jobs.Status = 'Finished'
GROUP BY Jobs.JobId
ORDER BY Total DESC,  Jobs.JobId


--Missing Parts
--List all parts that are needed for active jobs (not Finished) 
--without sufficient quantity in stock and in pending orders 
--(the sum of parts in stock and parts ordered is less than the required quantity). 
--Order them by part ID (ascending).

SELECT P.PartId,
       P.Description,
       SUM(PN.Quantity) AS Required,
       AVG(p.StockQty) AS [In Stock],
       ISNULL(SUM(op.Quantity), 0) AS [Ordered]
FROM Parts AS P
     JOIN PartsNeeded PN ON PN.PartId = P.PartId
     JOIN Jobs AS J ON J.JobId = PN.JobId
     LEFT JOIN Orders AS O ON O.JobId = J.JobId
     LEFT JOIN OrderParts AS OP ON OP.OrderId = O.OrderId
WHERE J.Status <> 'Finished'
GROUP BY p.PartId,
         P.Description
HAVING AVG(P.StockQty) + ISNULL(SUM(OP.Quantity), 0) < SUM(PN.Quantity)
ORDER BY P.PartId


--Place Order
--Your task is to create a user defined procedure (usp_PlaceOrder) which 
--accepts job ID, part serial number and   quantity and creates an order with the specified 
--parameters. If an order already exists for the given job that and the order is not issued 
--(order’s issue date is NULL), add the new product to it. If the part is already listed in 
--the order, add the quantity to the existing one.
GO

CREATE PROC usp_PlaceOrder
(@jobId         INT,
 @partSerialNum VARCHAR(50),
 @quantity      INT
)
AS
     BEGIN
	--check quantity
         IF(@quantity <= 0)
            BEGIN
                 RAISERROR('Part quantity must be more than zero!', 16, 1);
                 RETURN;
		  END;

	 --declare and check jobId
	    DECLARE @jobIdSelected INT=
         (
             SELECT JobId
             FROM Jobs
             WHERE JobId = @jobId
         );
         IF(@jobIdSelected IS NULL)
            BEGIN
                 RAISERROR('Job not found!', 16, 1);
                 RETURN;
		  END;

	  --declare and check job status
         DECLARE @JobStatus VARCHAR(11)=
         (
             SELECT Status
             FROM JOBS
             WHERE JobId = @jobId
         );
	             
         IF(@JobStatus = 'Finished')
            BEGIN
                 RAISERROR('This job is not active!', 16, 1);
                 RETURN;
		  END;

	   --declare and check serial number
         DECLARE @partId INT=
         (
             SELECT PartId
             FROM Parts
             WHERE SerialNumber = @partSerialNum
         );
         IF(@partId IS NULL)
            BEGIN
                 RAISERROR('Part not found!', 16, 1);
                 RETURN;
		  END;

	   -- check if order for partId exist
         DECLARE @OrderId INT=
         (
             SELECT o.OrderId
             FROM Orders o
             WHERE JobId = @jobId AND IssueDate IS NULL
	    )
	    --if order for part does not exist create new one
         IF(@OrderId IS NULL)
            BEGIN
                 INSERT INTO Orders(JobId, IssueDate)
                 VALUES (@jobId, NULL );

                 INSERT INTO OrderParts(OrderId,PartId,Quantity)
                 VALUES (IDENT_CURRENT('Orders'),@partId,@quantity);
		  END;
		--if order exist
         ELSE
          BEGIN
		   DECLARE @PartExistInOrder INT =(SELECT @@ROWCOUNT FROM OrderParts WHERE OrderId=@OrderId AND PartId=@partId)

		   IF  (@PartExistInOrder IS NULL)
		   BEGIN
				 -- if part not exist in order =>add part
				 INSERT INTO OrderParts(OrderId,PartId,Quantity)
				 VALUES (@OrderId,@partId,@quantity);
		   END
		   ELSE
		   BEGIN
				--if part exist add only quantity
				UPDATE OrderParts
				SET Quantity+=@quantity
				WHERE OrderId=@OrderId AND PartId=@partId
		   END
        END;
     END;


--Cost Of Order
--Create a user defined function (udf_GetCost) that receives a job’s ID and 
--returns the total cost of all parts that were ordered for it. 
--Return 0 if there are no orders.
GO

CREATE FUNCTION udf_GetCost(@jobId INT)
RETURNS DECIMAL(10, 2)
AS
     BEGIN
         DECLARE @result DECIMAL(10, 2);
         SET @result =
         (
             SELECT ISNULL(SUM(P.Price * OP.Quantity), 0.00)
             FROM Orders AS O
                  JOIN OrderParts AS OP ON O.OrderId = OP.OrderId
                  JOIN Parts AS P ON P.PartId = OP.PartId
             WHERE JobId = @jobId
         );
         RETURN @result;
     END;










