USE AdventureWorks2019
GO
SELECT PP.FirstName, 
       PP.LastName,
       HE.JobTitle,
       HE.BirthDate
FROM Person.Person PP
INNER JOIN HumanResources.Employee HE
ON PP.BusinessEntityID = HE.BusinessEntityID 
GO
SELECT PP.FirstName, 
       PP.LastName,
       (SELECT JobTitle
       FROM HumanResources.Employee HE
       WHERE PP.BusinessEntityID = HE.BusinessEntityID) JobTitle
FROM Person.Person PP
GO
SELECT PP.FirstName, 
       PP.LastName,
       (SELECT JobTitle
       FROM HumanResources.Employee HE
       WHERE PP.BusinessEntityID = HE.BusinessEntityID) JobTitle
FROM Person.Person PP
WHERE EXISTS (SELECT BusinessEntityID FROM HumanResources.Employee AS HE WHERE PP.BusinessEntityID = HE.BusinessEntityID)
GO
SELECT PP.FirstName, 
       PP.LastName,
       HE.JobTitle
FROM Person.Person PP CROSS JOIN HumanResources.Employee HE
GO
SELECT COUNT(*) ResultRows
FROM (SELECT PP.FirstName, 
       PP.LastName,
       HE.JobTitle
FROM Person.Person PP CROSS JOIN HumanResources.Employee HE) AS Result



5 875 980