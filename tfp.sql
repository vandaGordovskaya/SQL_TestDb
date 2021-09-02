USE AdventureWorks2019
GO 
IF OBJECT_ID(N'notifier', N'TR') IS NOT NULL  
   DROP TRIGGER notifier 
GO 
CREATE TRIGGER notifier 
ON HumanResources.Department
FOR INSERT, UPDATE 
AS 
THROW 50001, 'The table cannot be updated via adding or changing data', 1;
ROLLBACK TRANSACTION; 
RETURN; 
GO
IF OBJECT_ID(N'notifier2', N'TR') IS NOT NULL  
   DROP TRIGGER notifier2
GO
CREATE TRIGGER notifier2 
ON DATABASE
FOR ALTER_TABLE
AS 
THROW 50002, 'No tables can be changed in the DB', 1;
ROLLBACK TRANSACTION; 
RETURN; 
GO
IF OBJECT_ID (N'dbo.ufnConcatStrings', N'FN') IS NOT NULL  
    DROP FUNCTION dbo.ufnConcatStrings; 
GO
CREATE FUNCTION dbo.ufnConcatStrings(@Col1 varchar(255), @Col2 varchar(255))
RETURNS varchar(255)
AS
BEGIN
    RETURN CONCAT_WS(' - ',@Col1,@Col2) 
END;
GO
IF OBJECT_ID (N'HumanResources.ufnEmployeeByDepartment', N'FN') IS NOT NULL  
    DROP FUNCTION HumanResources.ufnEmployeeByDepartment; 
	GO
CREATE FUNCTION HumanResources.ufnEmployeeByDepartment(@DepartmentN smallint)
RETURNS TABLE
AS
RETURN
(
    SELECT hre.*,
           hredp.DepartmentID
    FROM HumanResources.Employee AS hre
    JOIN HumanResources.EmployeeDepartmentHistory AS hredp
        ON hredp.BusinessEntityID = hre.BusinessEntityID
    WHERE hredp.DepartmentID = @DepartmentN
);
-- Did not add '%' at the beginning of the mask
-- Forgot to add searching by Last Name
GO
CREATE PROCEDURE Person.uspSearchByName
    @SearchName varchar(255)
-- 2021.29.08 created by Vanda Gordovskaya
-- search approximate name
-- This procedure searches name in FirstName column of Person.Person table
-- and returns table with BusinessEntityId, FirstName, LastName

AS
    SELECT @SearchName = '%' RTRIM(@SearchName) + '%';
    SELECT BusinessEntityId, 
	   FirstName, 
	   LastName
    FROM Person.Person
    WHERE FirstName LIKE @SearchName OR LastName LIKE @SearchName;
GO
EXEC Person.uspSearchByName @SearchName = 'John';
