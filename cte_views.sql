USE AdventureWorks2019
GO  
CREATE VIEW Person.vPerson
AS
SELECT pp.Title,
       pp.FirstName,
       pp.LastName,
       pe.EmailAddress
FROM Person.Person AS pp JOIN Person.EmailAddress AS pe
ON pp.BusinessEntityID = pe.BusinessEntityID; 
GO
SELECT Title, 
       FirstName, 
       LastName, 
       EmailAddress
FROM Person.vPerson
ORDER BY LastName;
GO
WITH EmployeeData_CTE(BusinessEntityId, NationalIdNumber, JobTitle, FirstName, LastName)
AS
(
	SELECT hre.BusinessEntityId,
	       NationalIdNumber, 
	       JobTitle, 
	       FirstName,
	       LastName
	FROM HumanResources.Employee AS hre
	     INNER JOIN Person.Person AS pp
	     ON hre.BusinessEntityId = pp.BusinessEntityId
)
,

EmployeePhone_CTE(BusinessEntityId, NationalIdNumber, JobTitle, PhoneNumber)
AS
(
	SELECT hre.BusinessEntityId,
	       NationalIdNumber, 
	       JobTitle, 
	       PhoneNumber
	FROM HumanResources.Employee AS hre
	     INNER JOIN Person.PersonPhone AS ppp
	     ON hre.BusinessEntityId = ppp.BusinessEntityId
)
SELECT ed.BusinessEntityId,
       ed.NationalIdNumber, 
       ed.JobTitle, 
       ed.FirstName,
       ed.LastName,
       ep.PhoneNumber
FROM EmployeeData_CTE AS ed INNER JOIN EmployeePhone_CTE AS ep
ON ed.BusinessEntityId = ep.BusinessEntityId
ORDER BY ed.BusinessEntityId;