-- 1) Cities with both Employees & Customers
SELECT city
FROM employees
WHERE city in (
    SELECT city
    FROM customers
);

-- 2a) Cities with Customers, no Employee (subquery)
SELECT DISTINCT city
FROM Customers
WHERE city NOT IN (
    SELECT city
    FROM employees
);

-- 2b) Cities with Customers, no Employee (no subquery)
SELECT DISTINCT c.city
FROM Customers c
LEFT JOIN Employees e USING(city)
WHERE e.city IS NULL;

-- 3) Products total order qty
SELECT p.product_name, SUM(od.quantity) AS total_qty
FROM products p
JOIN order_details od USING(product_id)
GROUP BY 1;

-- 4) Customer Cities total products
SELECT city, COALESCE(SUM(od.quantity), 0) AS total
FROM Customers c 
LEFT JOIN orders o USING(customer_id)
LEFT JOIN order_details od USING(order_id)
GROUP BY 1;

-- 5) Customer Cities ≥ 2 customers
SELECT city, COUNT(*) AS total_cust 
FROM customers
GROUP BY 1
HAVING COUNT(*) >= 2;

-- 6) Customer Cities ≥ 2 product types
SELECT c.city, COUNT(DISTINCT od.product_id) AS num_distinct_prod
FROM Customers c 
JOIN orders o USING(customer_id)
JOIN order_details od USING(order_id)
GROUP BY 1
HAVING COUNT(DISTINCT od.product_id) >= 2;

-- 7) Customers with ship city ≠ customer city
SELECT DISTINCT c.customer_id, c.city as cust_city, o.ship_city
FROM Customers c 
JOIN orders o USING(customer_id)
WHERE c.city != o.ship_city;

-- 8) Top 5 products, avg price, city with max qty
WITH top_5_popular_prod as (
    SELECT p.product_id, SUM(od.quantity) AS total, AVG(od.unit_price) AS avg_unit_price
    FROM products p 
    JOIN order_details od USING(product_id)
    GROUP BY p.product_id
    ORDER BY total DESC 
    LIMIT 5
), rnk_prod_by_city as (
    SELECT 
        od.product_id, 
        c.city, 
        SUM(od.quantity) AS total,
        RANK() OVER(PARTITION BY od.product_id ORDER BY SUM(od.quantity) DESC) as rnk
    FROM customers c 
    JOIN orders o USING(customer_id)
    JOIN order_details od USING(order_id)
    WHERE od.product_id IN (
        SELECT product_id FROM top_5_popular_prod
    )
    GROUP BY 1,2
)

SELECT product_id, avg_unit_price, city
FROM rnk_prod_by_city
JOIN top_5_popular_prod USING(product_id)
WHERE rnk = 1;

-- 9a) Cities never ordered, have employees (subquery)
SELECT DISTINCT city
FROM employees
WHERE city NOT IN (
    SELECT DISTINCT c.city
    FROM customers c
    JOIN orders o USING(customer_id)
);

-- 9b) Cities never ordered, have employees (no-subquery)
SELECT DISTINCT e.city
FROM Employees e
LEFT JOIN Customers c USING(city)
LEFT JOIN Orders o USING(customer_id)
WHERE o.order_id IS NULL;

-- 10) City with most orders & most product qty
WITH top_employee_city AS (
    SELECT e.city, 'employee_city' as employee_type
    FROM employees e
    JOIN orders o USING(employee_id)
    GROUP BY 1
    ORDER BY COUNT(o.order_id) DESC
    LIMIT 1
), top_cust_city AS (
    SELECT c.city, 'customer_city' as city_type
    FROM customers c
    JOIN orders o USING(customer_id)
    JOIN order_details od USING(order_id)
    GROUP BY 1
    ORDER BY SUM(od.quantity) DESC
    LIMIT 1
)

SELECT *
FROM top_employee_city
UNION 
SELECT *
FROM top_cust_city

-- 11) Remove duplicate records
-- We could use row_number() over(partition by col1, col2, .. (all the column) order by select(0)) to identify duplicate records
-- then we will delete from Table Where row_number > 1 to remove duplicate records