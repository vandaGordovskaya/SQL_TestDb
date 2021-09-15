USE TestDb
GO
1.1
CREATE TABLE dbo.Customer(
	CustomerID int NOT NULL PRIMARY KEY ,
	FirstName varchar(50),
	LastName varchar(50),
	Email varchar(100),
	ModifiedDate date
)
GO
1.2
CREATE NONCLUSTERED INDEX [NCIX_FirstName_LastName_Email] ON dbo.Customer
(
	[FirstName] ASC,
	[LastName] ASC,
	[Email] ASC
);
GO
1.3
CREATE INDEX [IX_Customer_ModifiedDate] ON dbo.Customer (ModifiedDate) INCLUDE
(FirstName, LastName);
GO
1.4
CREATE TABLE dbo.Customer2(
	CustomerID int NOT NULL,
	AccountNumber varchar(10),
	FirstName varchar(50),
	LastName varchar(50),
	Email varchar(100),
	ModifiedDate date
)
GO
CREATE CLUSTERED INDEX [IX_AccountNumber] ON dbo.Customer2 (AccountNumber ASC);
GO
ALTER TABLE dbo.Customer2
ADD PRIMARY KEY (CustomerID);
GO
1.5
EXEC sp_rename N'dbo.Customer2.IX_AccountNumber', N'CIX_AccountNumber', N'INDEX';  
GO
1.6
DROP INDEX CIX_AccountNumber ON dbo.Customer2;  
GO
1.7
CREATE UNIQUE NONCLUSTERED INDEX [AK_Customer_Email] ON dbo.Customer2 (Email ASC);
GO
1.8
CREATE NONCLUSTERED INDEX [NCIX_Customer2_ModifiedDate] 
ON dbo.Customer2 (ModifiedDate)
WITH (FILLFACTOR=70)
GO
SELECT fill_factor
FROM sys.indexes
WHERE object_id = object_id('dbo.Customer2')
    AND name = 'NCIX_Customer2_ModifiedDate';