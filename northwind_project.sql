--To obtain a list of all tables and views in the db
SELECT table_name AS name,
       table_type AS type
  FROM information_schema.tables
 WHERE table_schema = 'public' AND table_type IN ('BASE TABLE', 'VIEW');

--Removing unwanted column
ALTER TABLE employees
DROP COLUMN photo;

--Combining orders and employees tables to see who is responsible for each other:
SELECT 
    e.first_name || ' ' || e.last_name as employee_name,
    o.order_id,
    o.order_date
FROM orders o
JOIN employees e ON o.employee_id = e.employee_id
Limit 10;

--Combining orders and customers table to get more detailed info about each customer
SELECT 
    o.order_id,
    c.company_name,
    c.contact_name,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LIMIT 10;

--Combining order_details,products and orders tables to get detailed order info including the product name and quantity
SELECT 
    o.order_id,
    p.product_name,
    od.quantity,
    o.order_date
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN orders o ON od.order_id = o.order_id
LIMIT 10;

--Ranking employees by sales performance
WITH EmployeeSales AS (
    SELECT Employees.Employee_ID, Employees.First_Name, Employees.Last_Name,
           SUM(Unit_Price * Quantity * (1 - Discount)) AS "Total Sales"
    FROM Orders 
    JOIN Order_Details ON Orders.Order_ID = Order_Details.Order_ID
    JOIN Employees ON Orders.Employee_ID = Employees.Employee_ID

    GROUP BY Employees.Employee_ID
)
SELECT Employee_ID, First_Name, Last_Name,
       RANK() OVER (ORDER BY "Total Sales" DESC) AS "Sales Rank"
FROM EmployeeSales;

--We can see that Margeret Peacock is the top-selling employee 
--and Steven Buchanan is the lowest-selling employee.

-------------------------------------------

--Calculating running total sales for each month
WITH MonthlySales AS (
    SELECT DATE_TRUNC('month', Order_Date)::DATE AS "Month", 
           SUM(Unit_Price * Quantity * (1 - Discount)) AS "Total Sales"
    FROM Orders 
    JOIN Order_Details ON Orders.Order_ID = Order_Details.Order_ID
    GROUP BY DATE_TRUNC('month', Order_Date)
)
SELECT "Month", 
       SUM("Total Sales") OVER (ORDER BY "Month") AS "Running Total"
FROM MonthlySales
ORDER BY "Month";

--Calculating the month-over-month sales growth rate
WITH MonthlySales AS (
    SELECT EXTRACT('month' from Order_Date) AS Month, 
           EXTRACT('year' from Order_Date) AS Year, 
           SUM(Unit_Price * Quantity * (1 - Discount)) AS TotalSales
    FROM Orders 
    JOIN Order_Details ON Orders.Order_ID = Order_Details.Order_ID
    GROUP BY EXTRACT('month' from Order_Date),  EXTRACT('year' from Order_Date)
),
LaggedSales AS (
    SELECT Month, Year, 
           TotalSales, 
           LAG(TotalSales) OVER (ORDER BY Year, Month) AS PreviousMonthSales
    FROM MonthlySales
)
SELECT Year, Month,
       ((TotalSales - PreviousMonthSales) / PreviousMonthSales) * 100 AS "Growth Rate"
FROM LaggedSales;

------------------------------------------

--Identifying customers with above-average order values
WITH OrderValues AS (
    SELECT Orders.Customer_ID, 
           Orders.Order_ID, 
           SUM(Unit_Price * Quantity * (1 - Discount)) AS "Order Value"
    FROM Orders 
    JOIN Order_Details ON Orders.Order_ID = Order_Details.Order_ID
    GROUP BY Orders.Customer_ID, Orders.Order_ID
)
SELECT Customer_ID, 
       Order_ID, 
       "Order Value",
       CASE 
           WHEN "Order Value" > AVG("Order Value") OVER () THEN 'Above Average'
           ELSE 'Below Average'
       END AS "Value Category"
FROM OrderValues LIMIT 10;


--Calculating the percentage of sales for each category
WITH CategorySales AS (
    SELECT Categories.Category_ID, Categories.Category_Name,
           SUM(Products.Unit_Price * Quantity * (1 - Discount)) AS "Total Sales"
    FROM Categories
    JOIN Products ON Categories.Category_ID = Products.Category_ID
    JOIN Order_Details ON Products.Product_ID = Order_Details.Product_ID
    GROUP BY Categories.Category_ID
)
SELECT Category_ID, Category_Name,
       "Total Sales" / SUM("Total Sales") OVER () * 100 AS "Sales Percentage"
FROM CategorySales;

--Beverages is the top category in terms of sales percentages, followed closely by Dairy Products. 
--Produce and Grains/Cereals are the categories with the smallest sales percentage.

--------------------------------------------------

--Top 3 products sold per category
WITH ProductSales AS (
    SELECT Products.Category_ID, 
           Products.Product_ID, Products.Product_Name,
           SUM(Products.Unit_Price * Quantity * (1 - Discount)) AS "Total Sales"
    FROM Products
    JOIN Order_Details ON Products.Product_ID = Order_Details.Product_ID
    GROUP BY Products.Category_ID, Products.Product_ID
)
SELECT Category_ID, 
       Product_ID, Product_Name,
       "Total Sales"
FROM (
    SELECT Category_ID, 
           Product_ID, Product_Name,
           "Total Sales", 
           ROW_NUMBER() OVER (PARTITION BY Category_ID ORDER BY "Total Sales" DESC) AS rn
    FROM ProductSales
) tmp
WHERE rn <= 3;


