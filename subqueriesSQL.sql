USE AdventureWorks
GO




-- 1) Count all products
SELECT COUNT(*) AS TotalProducts
FROM Production.Product;


-- 2) Products with a subcategory
SELECT COUNT(*) AS total
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL;


-- 3) products per subcategory
SELECT ProductSubcategoryID, COUNT(*) AS quantity
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID;


-- 4) Products without a subcategory
SELECT COUNT(*) AS ProductsWithoutSubcategory
FROM Production.Product
WHERE ProductSubcategoryID IS NULL;


-- 5) Total sum of product quantities
SELECT SUM(Quantity) AS TotalQuantity
FROM Production.ProductInventory;


-- 6) Sum of product, LocationID = 40, totals < 100
SELECT ProductID, SUM(Quantity) AS quantites
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity) < 100;


-- 7) Sum of product by shelf + product, LocationID = 40, totals < 100
SELECT Shelf, ProductID, SUM(Quantity) AS quantties
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY Shelf, ProductID
HAVING SUM(Quantity) < 100;


-- 8) Average quantity where LocationID = 10
SELECT AVG(Quantity) AS AvgQuantity
FROM Production.ProductInventory
WHERE LocationID = 10;


-- 9) Average quantity by shelf
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf;


-- 10) Average quantity by shelf excluding 'N/A'
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE Shelf <> 'N/A'
GROUP BY ProductID, Shelf;


-- 11) Count and average list price grouped by Color and Class (exclude NULLs)
SELECT Color, Class, COUNT(*) AS Quantity, AVG(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class;


-- 12) Join: Country and province names
SELECT c.Name AS Country, s.Name AS Province
FROM Person.CountryRegion AS c
JOIN Person.StateProvince AS s
ON c.CountryRegionCode = s.CountryRegionCode;


-- 13) Join: Country and province names filtered by Germany and Canada
SELECT c.Name AS Country, s.Name AS Province
FROM Person.CountryRegion AS c
JOIN Person.StateProvince AS s
ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada');


-- Switch to Northwind
USE Northwind
GO


-- 14) Products sold at least once in last 27 years

SELECT DISTINCT p.product_name
FROM products AS p
JOIN order_details AS od USING(product_id)
JOIN Orders AS o USING(order_id)
WHERE EXTRACT(YEAR FROM AGE((SELECT MAX(order_date) FROM Orders), o.order_date)) <= 27;


-- 15) Top 5 zip codes where products sold most
SELECT c.postal_code, COUNT(*) AS totaL_shipped
FROM orders o
JOIN customers c USING(customer_id)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 16) Top 5 zip codes where products sold most in last 27 years
SELECT c.postal_code, COUNT(*) AS totaL_shipped
FROM orders o
JOIN customers c USING(customer_id)
WHERE EXTRACT(YEAR FROM AGE((SELECT MAX(order_date) FROM Orders), o.order_date)) <= 27
AND postal_code IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 17) City and number of customers
SELECT city, COUNT(*) AS CustomerCount
FROM customers
GROUP BY 1;


-- 18) Cities with > 2 customers
SELECT city, COUNT(*) AS CustomerCount
FROM customers
GROUP BY 1
HAVING COUNT(*) > 2;


-- 19) Customers who placed orders after 1/1/1998
SELECT DISTINCT c.contact_name, o.order_date
FROM customers AS c
JOIN orders AS o USING(customer_id)
WHERE o.order_date::date > '1998-01-01'::date;


-- 20) Customers with most recent order dates
SELECT c.contact_name, MAX(o.order_date) AS MostRecentOrder
FROM customers AS c
JOIN orders AS o USING(customer_id)
GROUP BY 1;


-- 21) Customers with count of products bought
SELECT c.contact_name, COUNT(od.product_id) AS ProductCount
FROM customers AS c
JOIN orders AS o USING(customer_id)
JOIN order_details AS od USING(order_id)
GROUP BY 1;


-- 22) Customers > 100 products
SELECT c.customer_id, COUNT(od.product_id) AS ProductCount
FROM customers AS c
JOIN orders AS o USING(customer_id)
JOIN order_details AS od USING(order_id)
GROUP BY 1
HAVING COUNT(od.product_id) > 100;


-- 23) Supplier–shipping company combinations
SELECT s.company_name AS "Supplier Company Name",
      sh.company_name AS "Shipping Company Name"
FROM Suppliers AS s
CROSS JOIN Shippers AS sh;


-- 24) Products ordered each day
SELECT o.order_date, p.product_name
FROM orders AS o
JOIN order_details AS od USING(order_id)
JOIN products AS p USING(product_id)
ORDER BY 1;


-- 25) Pairs of employees with same job title
SELECT 
    e1.first_name || ' ' || e1.last_name AS first_person,
    e2.first_name || ' ' || e2.last_name AS second_person,
    e1.title
FROM employees AS e1
JOIN employees AS e2 ON e1.title = e2.title AND e1.employee_id < e2.employee_id;


-- 26) Managers with more than 2 employees
SELECT e1.employee_id, 
       e1.first_name || ' ' || e1.last_name AS ManagerName,
       COUNT(e2.employee_id) AS EmployeeCount
FROM employees AS e1
JOIN employees AS e2 ON e1.employee_id = e2.reports_to
GROUP BY e1.employee_id, e1.first_name, e1.last_name
HAVING COUNT(e2.employee_id) > 2;


-- 27) Customers and suppliers by city
SELECT city, company_name AS Name, contact_name, 'Customer' AS Type
FROM customers
UNION ALL
SELECT city,company_name AS Name, contact_name, 'Supplier' AS Type
FROM Suppliers
ORDER BY City;



