-- Creating database named SalesDashboard
CREATE DATABASE SalesDashboard;
GO
USE SalesDashboard;



-- Verify the import
SELECT COUNT(*) AS row_count FROM dbo.sales;
SELECT ROUND(SUM(Revenue),2) AS total_sales FROM dbo.sales;
SELECT TOP 5 * FROM dbo.sales;
SELECT COUNT(*) FROM dbo.customers;



-- KPIs
SELECT ROUND(SUM(Revenue),2) AS total_sales,
       COUNT(DISTINCT InvoiceNo) AS total_orders,
       ROUND(SUM(Revenue)/COUNT(DISTINCT InvoiceNo),2) AS avg_order_value,
       COUNT(DISTINCT CASE WHEN CustomerID <> 'Guest' THEN CustomerID END) AS customers
FROM dbo.sales;



-- By region
SELECT Region, ROUND(SUM(Revenue),2) AS total_sales,
       COUNT(DISTINCT InvoiceNo) AS orders,
       ROUND(SUM(Revenue)/COUNT(DISTINCT InvoiceNo),2) AS avg_order_value
FROM dbo.sales GROUP BY Region ORDER BY total_sales DESC;



-- By category
SELECT Category, ROUND(SUM(Revenue),2) AS total_sales, SUM(Quantity) AS units,
       COUNT(DISTINCT InvoiceNo) AS orders
FROM dbo.sales GROUP BY Category ORDER BY total_sales DESC;



-- Monthly sales with MoM growth (excludes the partial month)
WITH m AS (
  SELECT YearMonth, SUM(Revenue) AS sales, COUNT(DISTINCT InvoiceNo) AS orders
  FROM dbo.sales
  WHERE IsPartialMonth = 0
  GROUP BY YearMonth)
SELECT YearMonth, ROUND(sales,2) AS sales, orders,
       ROUND(100.0*(sales - LAG(sales) OVER (ORDER BY YearMonth))
             / NULLIF(LAG(sales) OVER (ORDER BY YearMonth),0),1) AS mom_growth_pct
FROM m ORDER BY YearMonth;



-- Top 10 products
SELECT TOP 10 Description, SUM(Quantity) AS units, ROUND(SUM(Revenue),2) AS revenue
FROM dbo.sales GROUP BY Description ORDER BY revenue DESC;



-- Region x month (heatmap data)
SELECT Region, YearMonth, ROUND(SUM(Revenue),2) AS sales
FROM dbo.sales GROUP BY Region, YearMonth ORDER BY Region, YearMonth;



-- Spend segments
SELECT SpendSegment, COUNT(*) AS customers, ROUND(SUM(TotalSpend),2) AS revenue,
       ROUND(100.0*SUM(TotalSpend)/(SELECT SUM(TotalSpend) FROM dbo.customers),1) AS pct_of_revenue
FROM dbo.customers GROUP BY SpendSegment;



-- Repeat vs one-time customers
SELECT CASE WHEN Orders=1 THEN 'One-time' ELSE 'Repeat' END AS customer_type, COUNT(*) AS customers
FROM dbo.customers GROUP BY CASE WHEN Orders=1 THEN 'One-time' ELSE 'Repeat' END;