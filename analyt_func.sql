USE AdventureWorks2019
GO 
-- 1.1 Remove ejection. Find Products in JAN-2013 by sales amount without the first and last 10%.
-- Sales.SalesOrderHeader
-- Sales.SalesOrderDetail
-- Production.Product
SELECT Product,
	   Total
FROM (
    SELECT pp.Name AS Product,
           SUM(sod.LineTotal) AS Total,
		   NTILE(10) OVER(ORDER BY SUM(sod.LineTotal)) AS Parts
    FROM Production.Product AS pp
	JOIN Sales.SalesOrderDetail AS sod
    ON pp.ProductID = sod.ProductID
    JOIN Sales.SalesOrderHeader AS soh
    ON sod.SalesOrderID = soh.SalesOrderID
    WHERE OrderDate >= '2013-01-01'
       AND OrderDate < '2013-02-01'
    GROUP BY pp.Name
	) AS t
WHERE Parts BETWEEN '2' AND '9'
ORDER BY Parts
GO
-- 1.2 Find the cheapest Products in each Subcategory of Products where Subcategory exists using Production.Product
SELECT Name,
       ListPrice 
FROM(SELECT Name,
		   RANK() OVER(PARTITION BY ProductSubcategoryID ORDER BY ListPrice) AS Level,
	       ListPrice
	FROM Production.Product
	WHERE ProductSubcategoryID IS NOT NULL) AS temp
WHERE Level=1
GO
-- 1.3 Find the second max value price of Mountain Bicycles using Production.Product
SELECT DISTINCT ListPrice AS SndMaxPrice
FROM (SELECT ListPrice,
	   DENSE_RANK() OVER(PARTITION BY ProductSubcategoryID ORDER BY ListPrice DESC) AS CountRank
	   FROM Production.Product
	   WHERE ProductSubcategoryID = 1) AS RangePrices
WHERE CountRank = 2
GO
-- 1.4 Count YoY (sales-previous_year_sales)/sales
-- Sales.SalesOrderHeader
-- Sales.SalesOrderDetail
-- Production.Product
-- Production.ProductSubcategory
-- Production.ProductCategory
WITH CategoryTotalBeYears_CTE
AS
(
    SELECT pc.Name as Category,
           YEAR(OrderDate) AS Years,
	   SUM(LineTotal) AS CurrentTotal,
           LAG(sum(sod.LineTotal)) OVER (ORDER BY pc.Name ,YEAR(soh.OrderDate)) PrevSales
	FROM Production.ProductSubcategory as ps
	JOIN Production.ProductCategory as pc 
	ON ps.ProductCategoryID = pc.ProductCategoryID
	JOIN Production.Product AS pp
	ON ps.ProductSubcategoryID = pp.ProductSubcategoryID
	JOIN Sales.SalesOrderDetail AS sod
	ON pp.ProductID = sod.ProductID
	JOIN Sales.SalesOrderHeader AS soh
	ON sod.SalesOrderID = soh.SalesOrderID
	WHERE YEAR(OrderDate) IN ('2012', '2013')
	GROUP BY YEAR(OrderDate), pc.Name
)
SELECT *,
       (CurrentTotal - PrevSales)/CurrentTotal AS YoY
FROM CategoryTotalBeYears_CTE
WHERE Years='2013'
GO
-- 1.5 Select the max sum of order for each day of JAN-2013
-- Sales.SalesOrderHeader
-- Sales.SalesOrderDetail
SELECT DISTINCT OrderDate,
       MAX(LineTotal) OVER(PARTITION BY DAY(OrderDate)) AS MaxTotalForDay
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE YEAR(OrderDate) = '2013' 
    AND MONTH(OrderDate) = '01'
GROUP BY OrderDate, LineTotal
ORDER BY OrderDate
GO
-- 1.6 Find the most sold good in JAN-2013
-- Sales.SalesOrderHeader
-- Sales.SalesOrderDetail
-- Production.Product
-- Production.ProductSubcategory
SELECT DISTINCT pps.Name, 
       FIRST_VALUE(pp.Name) OVER(PARTITION BY pp.ProductSubcategoryID ORDER BY Count(*) DESC) PopularGood     
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS pp
ON sod.ProductID = pp.ProductID
JOIN Production.ProductSubcategory AS pps
ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
WHERE YEAR(OrderDate) = '2013' AND MONTH(OrderDate) = '01'
GROUP BY pp.ProductSubcategoryID, pp.ProductID, pp.Name, pps.Name
