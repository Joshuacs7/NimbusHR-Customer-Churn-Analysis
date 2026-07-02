/*
==========================================================
Project: NimbusHR Customer Churn Analysis
Phase: ANALYZE

Business Question:
Does customer engagement influence customer retention?

Business Stakeholder:
VP of Growth
VP of Product
Director of Customer Success

Business Objective:
Determine whether customer engagement metrics can help
identify customers at risk of churning.
==========================================================
*/

----------------------------------------------------------
-- 1. Average Product Engagement by Customer Status
----------------------------------------------------------

SELECT
    s.current_status,
    ROUND(AVG(p.total_logins),2)      AS avg_logins,
    ROUND(AVG(p.active_days),2)       AS avg_active_days,
    ROUND(AVG(p.features_used),2)     AS avg_features_used,
    ROUND(AVG(p.health_score),2)      AS avg_health_score
FROM subscriptions_clean s
JOIN product_usage_clean p
ON s.customer_id = p.customer_id
GROUP BY s.current_status;

----------------------------------------------------------
-- 2. Health Score Distribution
----------------------------------------------------------

SELECT
    CASE
        WHEN health_score >= 80 THEN 'Healthy'
        WHEN health_score >= 60 THEN 'Moderate'
        ELSE 'At Risk'
    END AS customer_health_segment,
    COUNT(*) AS monthly_records
FROM product_usage_clean
GROUP BY customer_health_segment
ORDER BY monthly_records DESC;

----------------------------------------------------------
-- 3. Average Engagement by Subscription Plan
----------------------------------------------------------

SELECT
    s.subscription_plan,
    ROUND(AVG(p.total_logins),2)      AS avg_logins,
    ROUND(AVG(p.active_days),2)       AS avg_active_days,
    ROUND(AVG(p.features_used),2)     AS avg_features_used,
    ROUND(AVG(p.health_score),2)      AS avg_health_score
FROM subscriptions_clean s
JOIN product_usage_clean p
ON s.customer_id = p.customer_id
GROUP BY s.subscription_plan
ORDER BY avg_health_score DESC;

----------------------------------------------------------
-- 4. Lowest Health Score Customers
----------------------------------------------------------

SELECT
    c.customer_id,
    c.company_name,
    s.subscription_plan,
    ROUND(AVG(p.health_score),2) AS health_score
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id
JOIN product_usage_clean p
ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.company_name,
    s.subscription_plan
ORDER BY health_score ASC
LIMIT 20;