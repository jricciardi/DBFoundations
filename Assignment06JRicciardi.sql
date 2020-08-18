--*************************************************************************--
-- Title: Assignment06
-- Author: JayRicciardi
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2020-08-17,JayRicciardi,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JayRicciardi')
	 Begin 
	  Alter Database [Assignment06DB_JayRicciardi] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JayRicciardi;
	 End
	Create Database Assignment06DB_JayRicciardi;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JayRicciardi;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
CREATE VIEW vCategories WITH SCHEMABINDING
AS 
    SELECT CategoryID, CategoryName
    FROM dbo.Categories
GO

CREATE VIEW vEmployees WITH SCHEMABINDING
AS
    SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
    FROM dbo.Employees
GO

CREATE VIEW vInventories WITH SCHEMABINDING
AS
    SELECT InventoryID, InventoryDate, EmployeeID, ProductID, (Count)
    FROM dbo.Inventories
GO

CREATE VIEW vProducts WITH SCHEMABINDING
AS
    SELECT ProductID, ProductName, CategoryID, UnitPrice
    FROM dbo.Products
GO



-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON Categories TO PUBLIC
DENY SELECT ON Employees TO PUBLIC
DENY SELECT ON Inventories TO PUBLIC
DENY SELECT ON Products TO PUBLIC

GRANT SELECT ON vCategories TO PUBLIC
GRANT SELECT ON vEmployees TO PUBLIC
GRANT SELECT ON vInventories TO PUBLIC
GRANT SELECT ON vProducts TO PUBLIC
GO

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
CREATE VIEW vProductsbyCategories 
AS
    SELECT TOP 100 Percent
    CategoryName
    , ProductName
    , UnitPrice
    FROM vCategories AS c 
    JOIN vProducts AS p 
        ON c.CategoryID = p.CategoryID
    ORDER BY CategoryName, ProductName
GO
SELECT * FROM vProductsbyCategories


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
CREATE VIEW vInventoryLogWithProducts
AS
    SELECT TOP 100 percent 
    ProductName
    , [Count]
    , InventoryDate
    FROM vInventories AS i 
    JOIN vProducts AS p 
        ON i.ProductID = p.ProductID
    ORDER BY ProductName, InventoryDate, [Count]
GO
SELECT * FROM vInventoryLogWithProducts
GO

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
CREATE VIEW vEmployeeInventoryCheck
AS
SELECT TOP 100 Percent
    InventoryDate
    , [EmployeeName] = e.EmployeeFirstName + ' ' +  e.EmployeeLastName
    FROM vInventories AS i 
    JOIN vEmployees AS e 
        ON i.EmployeeID = e.EmployeeID
    GROUP BY InventoryDate, EmployeeFirstName, EmployeeLastName
    GO
SELECT * FROM vEmployeeInventoryCheck
GO


-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
CREATE VIEW vProductCategoryInventory
AS 
    SELECT TOP 100 PERCENT
    CategoryName
    , ProductName
    , InventoryDate
    , [Count]
    FROM vCategories AS c
    JOIN vProducts as p
        ON c.CategoryID = p.CategoryID
    JOIN Inventories AS i
        ON i.ProductID = p.ProductID
    ORDER BY CategoryName, ProductName, InventoryDate, [Count]
    GO

SELECT * FROM vProductCategoryInventory
GO

-- Select for results from the example below:
SELECT * FROM vProductCategoryInventory WHERE ProductName = 'Chai'
GO
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
CREATE VIEW vEmployeeInventoryEvents
AS 
    SELECT TOP 100 Percent
    CategoryName
    , ProductName
    , InventoryDate
    , [Count]
    , [EmployeeName] = e.EmployeeFirstName + ' ' +  e.EmployeeLastName
    FROM vCategories AS c
    JOIN vProducts as p
        ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
        ON i.ProductID = p.ProductID
    JOIN vEmployees as e
        ON e.EmployeeID = i.EmployeeID
    ORDER BY InventoryDate, CategoryName, ProductName, EmployeeFirstName, EmployeeLastName
GO

SELECT * FROM vEmployeeInventoryEvents
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
CREATE VIEW vExploreChaiChangInventory
AS
    SELECT TOP 100 Percent 
    CategoryName
    , ProductName
    , InventoryDate
    , [Count]
    , [EmployeeName] = e.EmployeeFirstName + ' ' +  e.EmployeeLastName
    FROM vCategories AS c
    JOIN vProducts AS p
        ON c.CategoryID = p.CategoryID
    JOIN vInventories as i
        ON i.ProductID = p.ProductID
    JOIN vEmployees AS e
        ON e.EmployeeID = i.EmployeeID
    WHERE ProductName IN (SELECT ProductName FROM Products WHERE ProductName = 'Chai' OR ProductName = 'Chang')
    ORDER BY InventoryDate, CategoryName, ProductName
GO

SELECT * FROM vExploreChaiChangInventory
GO


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
CREATE VIEW vManagerEmployeeLookup
AS 
    SELECT TOP 100 Percent 
    [Manager] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
    , [Employee] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	FROM vEmployees AS e
	JOIN vEmployees AS m
	  ON e.ManagerID = m.EmployeeID 
ORDER BY 1, 2; 
GO

Select * From vManagerEmployeeLookup
GO

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS 
    SELECT TOP 100 Percent
    c.CategoryID
    , c.CategoryName
    , p.ProductID
    , p.ProductName
    , p.UnitPrice
    , i.InventoryID
    , i.InventoryDate
    , i.[Count]
    , e.EmployeeID,
    [Employee] = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
    [Manager] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
        FROM vCategories as c INNER JOIN vProducts as p
            ON c.CategoryID = p.CategoryID
        JOIN vInventories as i
            ON p.ProductID = i.ProductID
        JOIN vEmployees as e
            ON i.EmployeeID = e.EmployeeID
        JOIN vEmployees AS m
            ON e.ManagerID = m.EmployeeID 
    GO

Select * From vInventoriesByProductsByCategoriesByEmployees
GO


-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoryLogWithProducts]
Select * From [dbo].[vEmployeeInventoryCheck]
Select * From [dbo].[vProductCategoryInventory]
Select * From [dbo].[vEmployeeInventoryEvents]
Select * From [dbo].[vExploreChaiChangInventory]
Select * From [dbo].[vManagerEmployeeLookup]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/