USE AdventureWorks2019
GO 
-- 1.1 Убираем выбросы. Найти продукты за январь-2013 по сумме продаж без первых и последних 10%, используя таблицы
-- Sales.SalesOrderHeader
-- Sales.SalesOrderDetail
-- Production.Product
SELECT *
FROM (
    SELECT DISTINCT sod.ProductID,
           SUM(LineTotal) OVER(ORDER BY sod.ProductID) Total,
		   NTILE(10) OVER(ORDER BY sod.ProductID) AS Parts
    FROM Production.Product AS pp
	JOIN Sales.SalesOrderDetail AS sod
    ON pp.ProductID = sod.ProductID
    JOIN Sales.SalesOrderHeader AS soh
    ON sod.SalesOrderID = soh.SalesOrderID
    WHERE OrderDate >= '2013-01-01'
       AND OrderDate < '2013-02-01'
    GROUP BY LineTotal, sod.ProductID, OrderDate
	) AS t
WHERE Parts BETWEEN '2' AND '9'
ORDER BY Parts

GO
-- 1.2 Найти самые дешёвые (цена по прайсу) продукты в каждой из субкатегорий продуктов 
-- (для тех продуктов, у которых субкатегория задана), 
-- используя таблицу Production.Product
SELECT ProductSubcategoryID,
	   ProductID,
       MIN(ListPrice) OVER(PARTITION BY ProductSubcategoryID ORDER BY ProductSubcategoryID) AS CheapestPrice
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GO
-- 1.3 Найти вторую по величине цену для горных велосипедов, используя таблицу Production.Product
SELECT ProductID,
       ProductSubcategoryID,
	   MAX(MaxPrice) AS SndMaxPrice
FROM (SELECT ProductID,
       ProductSubcategoryID,
       MAX(ListPrice) OVER(ORDER BY ListPrice) AS MaxPrice,
	   DENSE_RANK() OVER(ORDER BY ListPrice DESC) AS CountRank
	   FROM Production.Product
	   WHERE ProductSubcategoryID = 1
	   GROUP BY ListPrice, ProductID, ProductSubcategoryID) AS MaxPrices
WHERE CountRank = 2
GROUP BY ProductID, ProductSubcategoryID, MaxPrice
GO
IF OBJECT_ID (N'Production.ufnFindTotalSalesByCategoryInYear', N'FN') IS NOT NULL  
    DROP FUNCTION Production.ufnFindTotalSalesByCategoryInYear; 
GO
-- 1.4 Посчитать продажи за 2013 год в разрезе Категорий, посчитать YoY метрику ((продажи-продажи_за_прошлый_год)\продажи), используя таблицы
-- Sales.SalesOrderHeader
-- Sales.SalesOrderDetail
-- Production.Product
-- Production.ProductSubcategory
-- Production.ProductCategory
WITH CategoryTotalBeYears_CTE
AS
(
    SELECT DISTINCT pc.ProductCategoryID,
           pc.Name as Category,
		   YEAR(OrderDate) AS Years,
	       SUM(LineTotal) OVER(Partition BY pc.ProductCategoryID ORDER BY pc.ProductCategoryID, YEAR(OrderDate)) AS TotalByCatInYear
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
	GROUP BY pc.ProductCategoryID, pc.Name, YEAR(OrderDate), LineTotal
)
SELECT *,
       ((TotalByCatInYear - (LAG(TotalByCatInYear) OVER(PARTITION BY ProductCategoryID ORDER BY ProductCategoryID)))/TotalByCatInYear) AS YoY
FROM CategoryTotalBeYears_CTE
ORDER BY ProductCategoryID
GO
-- 1.5 Найти сумму максимальную заказа за каждый день января 2013, используя таблицы
-- Sales.SalesOrderHeader
-- Sales.SalesOrderDetail
SELECT DISTINCT OrderDate,
       MAX(LineTotal) OVER(PARTITION BY DAY(OrderDate) ORDER BY OrderDate
	   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS MaxTotalForDay
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE YEAR(OrderDate) = '2013' AND MONTH(OrderDate) = '01'
GROUP BY OrderDate, LineTotal
ORDER BY OrderDate
GO
-- 1.6 Найти товар, который чаще всего продавался в каждой из субкатегорий в январе 2013, используя таблицы
-- Sales.SalesOrderHeader
-- Sales.SalesOrderDetail
-- Production.Product
-- Production.ProductSubcategory
SELECT DISTINCT MAX(COUNT(pp.ProductID)) OVER(PARTITION BY pp.ProductSubcategoryID ORDER BY pp.ProductSubcategoryID) AS MaxTotalCount, 
       pp.ProductSubcategoryID
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS pp
ON sod.ProductID = pp.ProductID
JOIN Production.ProductSubcategory AS pps
ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
WHERE YEAR(OrderDate) = '2013' AND MONTH(OrderDate) = '01'
GROUP BY pp.ProductSubcategoryID, pp.ProductID, pp.Name