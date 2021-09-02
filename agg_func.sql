USE AdventureWorks2019
GO 
-- Understood the task incorrectly
SELECT GroupName,
       COUNT(*) as CountGroups
FROM HumanResources.Department
GROUP BY GroupName
GO
-- Added JobTitle for readability and named column for agg function
SELECT hre.BusinessEntityID,
       hre.JobTitle
       MAX(Rate) AS MaxRate
FROM HumanResources.Employee AS hre
JOIN HumanResources.EmployeePayHistory AS hrp
ON hre.BusinessEntityID = hrp.BusinessEntityID
GROUP BY hre.BusinessEntityID
GO
-- Added Name for readability
SELECT pps.Name,
       MIN(ListPrice) AS 'Min price'
FROM Production.Product AS pp
JOIN Production.ProductSubcategory AS pps
ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
JOIN Sales.SalesOrderDetail as sso
ON pp.ProductID = sso.ProductID
JOIN Sales.SalesOrderHeader AS ssoh
ON sso.SalesOrderID = ssoh.SalesOrderID
GROUP BY pps.Name;
GO
-- Changed Name to ID in COUNT
SELECT ppc.Name,
       COUNT(DISTINCT pps.ProductSubcategoryID) AS 'Amount subcategories'
FROM Production.ProductSubcategory AS pps
JOIN Production.ProductCategory AS ppc
ON pps.ProductCategoryID = ppc.ProductCategoryID
GROUP BY ppc.Name
GO
SELECT pps.Name,
       AVG(LineTotal) AS 'Average order'
FROM Sales.SalesOrderHeader AS ssoh
JOIN Sales.SalesOrderDetail AS ssod
ON ssoh.SalesOrderID = ssod.SalesOrderID
JOIN Production.Product AS pp
ON ssod.ProductID = pp.ProductID
JOIN Production.ProductSubcategory AS pps
ON pps.ProductSubcategoryID = pp.ProductSubcategoryID
GROUP BY pps.Name
GO
-- Added Rate for readability
SELECT BusinessEntityID,
       Rate,
       MIN(RateChangeDate) AS 'Date of hiring'
FROM HumanResources.EmployeePayHistory
WHERE Rate IN (SELECT MAX(Rate)
	       FROM HumanResources.EmployeePayHistory)
GROUP BY BusinessEntityID, Rate
