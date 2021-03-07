--01. One-To-One Relationship
CREATE TABLE Persons (
	PersonID INT NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	Salary MONEY NOT NULL,
	PassportID INT NOT NULL
)

CREATE TABLE Passports (
	PassportID INT NOT NULL,
	PassportNumber CHAR(8) NOT NULL
)

ALTER TABLE Persons
ADD CONSTRAINT PK_Person PRIMARY KEY(PersonID)

ALTER TABLE Passports
ADD CONSTRAINT PK_Passport PRIMARY KEY(PassportID)

ALTER TABLE Persons
ADD CONSTRAINT FK_Persons_Passports FOREIGN KEY(PassportID) REFERENCES Passports(PassportID)

ALTER TABLE Persons
ADD CONSTRAINT UQ_Persons UNIQUE(PassportID)

ALTER TABLE Passports
ADD CONSTRAINT UQ_Passports UNIQUE(PassportNumber) 

INSERT INTO Passports (PassportID, PassportNumber)
VALUES (101, 'N34FG21B'),
		(102, 'K65LO4R7'),
		(103, 'ZE657QP2')

INSERT INTO Persons (PersonID, FirstName, Salary, PassportID)
VALUES (1, 'Roberto', 43300.00, 102),
		(2, 'Tom', 56100.00, 103),
		(3, 'Yana', 60200.00, 101)

--02. One-To-Many Relationship
CREATE TABLE Manufacturers (
	ManufacturerID INT PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	EstablishedOn DATE NOT NULL
)

CREATE TABLE Models (
	ModelID INT PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	ManufacturerID INT,
	CONSTRAINT FK_Models_Manufacturers FOREIGN KEY(ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
)

INSERT INTO Manufacturers (ManufacturerID, [Name], EstablishedOn)
VALUES (1, 'BMW', '07/03/1916'),
		(2, 'Tesla', '01/01/2003'),
		(3, 'Lada', '01/05/1966')

INSERT INTO Models (ModelID, [Name], ManufacturerID)
VALUES (101, 'X1', 1),
		(102, 'i6', 1),
		(103, 'Model S', 2),
		(104, 'Model X', 2),
		(105, 'Model 3', 2),
		(106, 'Nova', 3)

--03. Many-To-Many Relationship
CREATE TABLE Students (
	StudentID INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Exams (
	ExamID INT PRIMARY KEY IDENTITY(101, 1),
	[Name] NVARCHAR(30) NOT NULL
)


CREATE TABLE StudentsExams (
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID) NOT NULL,
	ExamID INT FOREIGN KEY REFERENCES Exams(ExamID) NOT NULL,
	CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentID, ExamID)
)

INSERT INTO Students
VALUES ('Mila'),
		('Toni'),
		('Ron')

INSERT INTO Exams
VALUES ('SpringMVC'),
		('Neo4j'),
		('Oracle 11g')

INSERT INTO StudentsExams
VALUES (1, 101),
		(1, 102),
		(2, 101),
		(3, 103),
		(2, 102),
		(2, 103)

--04. Self-Referencing
CREATE TABLE Teachers (
	TeacherID INT PRIMARY KEY IDENTITY(101, 1),
	[Name] NVARCHAR(30) NOT NULL,
	ManagerID INT FOREIGN KEY REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers
VALUES ('John', NULL),
		('Maya', 106),
		('Silvia', 106),
		('Ted', 105),
		('Mark', 101),
		('Greta', 101)

--05. Online Store Database
CREATE TABLE Cities(
  CityID int NOT NULL,
  Name varchar(50) NOT NULL,
  CONSTRAINT PK_Cities PRIMARY KEY (CityID)
)

CREATE TABLE Customers(
  CustomerID int NOT NULL,
  Name varchar(50) NOT NULL,
  Birthday date,
  CityID int,
  CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
  CONSTRAINT FK_Customers_Cities FOREIGN KEY (CityID) REFERENCES Cities(CityID)
)

CREATE TABLE Orders(
  OrderID int NOT NULL,
  CustomerID int NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY (OrderID),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
)

CREATE TABLE ItemTypes(
  ItemTypeID int NOT NULL,
  Name varchar(50) NOT NULL,
  CONSTRAINT PK_ItemTypes PRIMARY KEY (ItemTypeID)
)

CREATE TABLE Items(
  ItemID int NOT NULL,
  Name varchar(50) NOT NULL,
  ItemTypeID int NOT NULL,
  CONSTRAINT PK_Items PRIMARY KEY (ItemID),
  CONSTRAINT FK_Items_ItemTypes FOREIGN KEY (ItemTypeID) REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems(
  OrderID int NOT NULL,
  ItemID int NOT NULL,
  CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, ItemID),
  CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  CONSTRAINT FK_OrderItems_Items FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
)

--06. University Database
CREATE TABLE Majors(
  MajorID int NOT NULL,
  Name nvarchar(50) NOT NULL,
  CONSTRAINT PK_Majors PRIMARY KEY (MajorID)
)

CREATE TABLE Students(
  StudentID int NOT NULL,
  StudentNumber int NOT NULL UNIQUE,
  StudentName nvarchar(200) NOT NULL,
  MajorID int,
  CONSTRAINT PK_Students PRIMARY KEY (StudentID),
  CONSTRAINT FK_Students_Majors FOREIGN KEY (MajorID) REFERENCES Majors(MajorID)
)

CREATE TABLE Payments(
  PaymentID int NOT NULL,
  PaymentDate date NOT NULL,
  PaymentAmount money NOT NULL,
  StudentID int NOT NULL,
  CONSTRAINT PK_Payments PRIMARY KEY (PaymentID),
  CONSTRAINT FK_Payments_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
)

CREATE TABLE Subjects(
  SubjectID int NOT NULL,
  SubjectName nvarchar(50) NOT NULL,
  CONSTRAINT PK_Subjects PRIMARY KEY (SubjectID)
)

CREATE TABLE Agenda(
  StudentID int NOT NULL,
  SubjectID int NOT NULL,
  CONSTRAINT PK_Agenda PRIMARY KEY (StudentID, SubjectID),
  CONSTRAINT FK_Agenda_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
  CONSTRAINT FK_Agenda_Subjects FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
)

--09. *Peaks in Rila
SELECT M.MountainRange, P.PeakName, P.Elevation FROM Mountains AS m
JOIN Peaks AS p
ON M.Id = P.MountainId
WHERE M.MountainRange = 'Rila'
ORDER BY P.Elevation DESC