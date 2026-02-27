-- Count of all customers and top 5 customers in each country
WITH all_customers AS (
SELECT
co.country AS country,
COUNT(DISTINCT cu.customer_id) AS all_customer_count
FROM customer cu
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY co.country
),
top_5_customers AS (
WITH top_countries AS (
SELECT
co.country_id,
COUNT(DISTINCT cu.customer_id) AS customer_count
FROM customer cu
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY co.country_id
ORDER BY customer_count DESC
LIMIT 10
),
top_cities AS (
SELECT
ci.city_id
FROM customer cu
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
JOIN top_countries tc ON co.country_id = tc.country_id
GROUP BY ci.city_id
ORDER BY COUNT(DISTINCT cu.customer_id) DESC, ci.city
LIMIT 10
)
SELECT
cu.customer_id,
co.country AS country,
ROUND(SUM(p.amount), 2) AS total_amount_paid
FROM payment p
JOIN customer cu ON p.customer_id = cu.customer_id
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
JOIN top_cities tc ON ci.city_id = tc.city_id
GROUP BY cu.customer_id, co.country
ORDER BY total_amount_paid DESC
LIMIT 5
)
SELECT
ac.country,
ac.all_customer_count,
COUNT(DISTINCT t5.customer_id) AS top_customer_count
FROM all_customers ac
LEFT JOIN top_5_customers t5
ON ac.country = t5.country
GROUP BY ac.country, ac.all_customer_count
ORDER BY top_customer_count DESC, ac.all_customer_count DESC;
