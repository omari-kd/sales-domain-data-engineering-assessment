-- 1. List all clients along with their regions and the total number of sales they have made. Include clients with zero sales.
SELECT c.client_id,
    c.client_name,
    c.region,
    COUNT(s.sale_id) AS total_sales
FROM clients c
    LEFT JOIN sales s ON c.client_id = s.client_id
GROUP BY c.client_id,
    c.client_name,
    c.region
ORDER BY total_sales;
-- 2. Find the top 5 products with the highest total revenue (quantity * unit_price).
SELECT p.product_id,
    p.product_name,
    SUM(s.quantity * p.unit_price) AS total_revenue
FROM sales s
    JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_id,
    p.product_name
ORDER BY total_revenue DESC
LIMIT 5;
-- 3 Using a CTE, calculate the monthly revenue for each region for June, July and August 2025.
WITH monthly_rev AS (
    SELECT c.region AS region,
        DATE_TRUNC('month', s.sale_date) AS month,
        SUM(s.quantity * p.unit_price) AS revenue
    FROM sales s
        JOIN clients c ON s.client_id = c.client_id
        JOIN products p ON s.product_id = p.product_id
    WHERE s.sale_date BETWEEN '2025-06-01' AND '2025-08-31'
    GROUP BY c.region,
        DATE_TRUNC('month', s.sale_date)
)
SELECT *
FROM monthly_rev
ORDER BY region,
    month;
-- 4. Rank Clients by total purchase amount and return the top 3 per region
WITH ranked_clients AS (
    SELECT c.client_id,
        c.client_name,
        c.region,
        SUM(s.quantity * p.unit_price) AS total_amount,
        RANK() OVER(
            PARTITION BY c.region
            ORDER BY SUM(s.quantity * p.unit_price) DESC
        ) AS rank
    FROM clients c
        LEFT JOIN sales s ON c.client_id = s.client_id
        LEFT JOIN products p ON s.product_id = p.product_id
    GROUP BY c.client_id,
        c.client_name,
        c.region
)
SELECT *
FROM ranked_clients
WHERE rank <= 3
ORDER BY region,
    rank;
-- 5 Sales where quantity is greater than the average quantity for that product
SELECT *
FROM sales s
WHERE s.quantity > (
        SELECT AVG(quantity)
        FROM sales
        WHERE product_id = s.product_id
    );
-- 6 Clients who brought in July 2025 but not in August 2025
SELECT DISTINCT c.client_id,
    c.client_name
FROM clients c
    JOIN sales s ON c.client_id = s.client_id
WHERE s.sale_date BETWEEN '2025-07-01' AND '2025-07-31'
    AND c.client_id NOT IN (
        SELECT client_id
        FROM sales
        WHERE sale_date BETWEEN '2025-08-01' AND '2025-08-31'
    );
--7 For each product category, compute the % contribution of each client to total category revenue
WITH category_totals AS (
    SELECT p.category,
        SUM(s.quantity * p.unit_price) AS category_revenue
    FROM sales s
        JOIN products p ON s.product_id = p.product_id
    GROUP BY p.category
),
client_category AS (
    SELECT c.client_id,
        c.client_name,
        p.category,
        SUM(s.quantity * p.unit_price) AS client_revenue
    FROM sales s
        JOIN clients c ON s.client_id = c.client_id
        JOIN products p ON s.product_id = p.product_id
    GROUP BY c.client_id,
        c.client_name,
        p.category
)
SELECT cc.client_id,
    cc.client_name,
    cc.category,
    cc.client_revenue,
    ROUND(
        (cc.client_revenue / ct.category_revenue) * 100,
        2
    ) AS percentage_contribution
FROM client_category cc
    JOIN category_totals ct ON cc.category = ct.category
ORDER BY cc.category,
    percentage_contribution DESC;
-- 8. Clients whose total purchase amount exceeds the average purchase of all clients (correlated subquery).
SELECT c.client_id,
    c.client_name
FROM clients c
WHERE (
        SELECT SUM(s.quantity * p.unit_price)
        FROM sales s
            JOIN products p ON p.product_id = s.product_id
        WHERE s.client_id = c.client_id
    ) > (
        SELECT AVG(total_amount)
        FROM (
                SELECT SUM(s2.quantity * p2.unit_price) AS total_amount
                FROM sales s2
                    JOIN products p2 ON p2.product_id = s2.product_id
                GROUP BY s2.client_id
            ) subquery
    );
-- 9. an update statement that applies a 15% discount on unit price for products in the 'Office' category.
UPDATE products
SET unit_price = unit_price * 0.85
WHERE category = 'Office';
-- 10. The product with the greatest month-over-month growth in sales quantity between June and July 2025.
WITH monthly_qty AS(
    SELECT p.product_id,
        product_name,
        DATE_TRUNC('month', s.sale_date) AS month,
        SUM(s.quantity) AS qty
    FROM sales s
        JOIN products p ON s.product_id = p.product_id
    WHERE s.sale_date BETWEEN '2025-06-1' AND '2025-07-31'
    GROUP BY p.product_id,
        DATE_TRUNC('month', s.sale_date)
),
pivoted AS (
    SELECT product_id,
        product_name,
        MAX(
            case
                WHEN month = '2025-06-01' THEN qty
            END
        ) AS june_qty,
        MAX(
            CASE
                WHEN month = '2025-07-01' THEN qty
            END
        ) as july_qty
    FROM monthly_qty
    GROUP BY product_id,
        product_name
)
SELECT product_id,
    product_name,
    (july_qty - june_qty) AS growth
FROM pivoted
ORDER BY growth DESC
LIMIT 1;