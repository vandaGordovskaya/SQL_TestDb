CREATE DATABASE TestDb
GO
CREATE SCHEMA TestSchema
    CREATE TABLE TestTable (
	Id           INT NOT NULL,
	Name         VARCHAR(20),
    	IsSold       BIT,
	InvoiceDate  DATE           
    )
GO
USE TestDb
GO
INSERT INTO TestSchema.TestTable
VALUES
(1,'Boat', 1, '2020-11-08'),
(2,'Auto', 0, '2020-11-09'),
(3,'Plane', null, '2020-12-09')
GO
USE TestDb
GO
EXEC sp_configure 'CONTAINED DATABASE AUTHENTICATION', 1;
GO
RECONFIGURE;
GO
USE [master]
GO
ALTER DATABASE TestDb SET CONTAINMENT = PARTIAL;
GO
USE TestDb
GO
CREATE USER TestUser WITH PASSWORD = 'pass4TU!@#';
GO
GRANT CONNECT TO TestUser;
GO
USE TestDb
GO
EXECUTE AS USER = 'TestUser'
GO
SELECT * FROM TestDb.TestSchema.TestTable
GO
REVERT;
GO
GRANT SELECT ON OBJECT::TestDb.TestSchema.TestTable TO TestUser;
GO
USE TestDb
GO
EXECUTE AS USER = 'TestUser'
GO
SELECT * FROM TestDb.TestSchema.TestTable
GO
SELECT CURRENT_USER
GO
REVERT;
GO
DROP USER IF EXISTS TestUser;