USE AdventureWorks2014
GO

CREATE VIEW dbo.vSalesPerformance
AS
SELECT 
	--Individual Items sold in each order
	SOD.SalesOrderID, SOD.ProductID, SOD.OrderQty
	, SOD.UnitPrice,
	SOD.LineTotal, SOD.UnitPriceDiscount,
	--Information about the sales order (Header Items)
	CAST(SOH.OrderDate AS date) AS OrderDate
	, CAST(SOH.DueDate AS date) AS DueDate,
	CAST(SOH.ShipDate AS date) AS ShipDate
	,SOH.SubTotal, SOH.TaxAmt, SOH.TotalDue
	-- Product information
	,ProdDrv.Name
	,ProdDrv.Name AS Subcategory
	,ProdDrv.Name AS Category
	,ProdDrv.Color, ProdDrv.ListPrice
	,ProdDrv.StandardCost
	, HistStartDate
	-- Detailed information about the customer 
	,Customer.AccountNumber, Customer.FullName
	-- Sales Territory Information
	,TerritoryName,Terr.CountryRegionCode
	, Terr.SalesYTD, Terr.SalesLastYear
FROM Sales.SalesOrderDetail AS SOD
LEFT JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID = SOH.SalesOrderID
-- Derived Table For Product Information
LEFT JOIN (
	SELECT 
	PROD.ProductID, PROD.ProductSubcategoryID,PROD.Name
	,PSC.Name AS Subcategory
	,PC.Name AS Category
	,PROD.Color, PROD.ListPrice
	,PCH.StandardCost
	, CAST(PCH.StartDate AS date) AS HistStartDate
FROM Production.Product AS PROD
LEFT JOIN Production.ProductSubcategory AS PSC
ON PROD.ProductSubcategoryID = PSC.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS PC
ON PSC.ProductCategoryID = PC.ProductCategoryID
LEFT JOIN Production.ProductCostHistory AS PCH
ON PROD.ProductID = PCH.ProductID
) ProdDrv
ON ProdDrv.ProductID = SOD.ProductID
-- Derived Table For Customers Information
LEFT JOIN (
	SELECT 
	CU.CustomerID, CU.AccountNumber,
	CONCAT(PP.FirstName, ' ', PP.MiddleName, ' ' ,PP.LastName) AS FullName
FROM Sales.Customer AS CU
INNER JOIN Person.Person AS PP
ON PP.BusinessEntityID = CU.CustomerID
) Customer
ON SOH.CustomerID = Customer.CustomerID
-- Sales Territory Information
INNER JOIN (
	SELECT 
	ST.TerritoryID, ST.Name AS TerritoryName,
	ST.CountryRegionCode, ST.SalesYTD, ST.SalesLastYear
FROM Sales.SalesTerritory AS ST
) Terr
ON SOH.TerritoryID = Terr.TerritoryID
GO