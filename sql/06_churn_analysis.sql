/*
==========================================================
Project: NimbusHR Customer Churn Analysis
Phase: ANALYZE

Business Question:
Who is churning, why are they churning, and what actions
should NimbusHR take to reduce churn?

Business Stakeholder:
Executive Leadership
VP of Growth
Director of Customer Success

Business Objective:
Identify churn patterns by customer segment, subscription plan,
acquisition channel, and churn reason.
==========================================================
*/

----------------------------------------------------------
-- 1. Overall Churn Rate
----------------------------------------------------------

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN current_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN current_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*),
        2
    ) AS churn_rate_pct
FROM subscriptions_clean;

----------------------------------------------------------
-- 2. Churn by Company Size
----------------------------------------------------------

SELECT
    c.company_size,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN s.current_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN s.current_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id
GROUP BY c.company_size
ORDER BY churn_rate_pct DESC;

----------------------------------------------------------
-- 3. Churn by Industry
----------------------------------------------------------

SELECT
    c.industry,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN s.current_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN s.current_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id
GROUP BY c.industry
ORDER BY churn_rate_pct DESC;

----------------------------------------------------------
-- 4. Churn Reasons
----------------------------------------------------------

SELECT
    churn_reason,
    COUNT(*) AS churned_customers
FROM subscriptions_clean
WHERE current_status = 'Churned'
GROUP BY churn_reason
ORDER BY churned_customers DESC;

----------------------------------------------------------
-- 5. Churn by Plan and Acquisition Channel
----------------------------------------------------------

SELECT
    s.subscription_plan,
    c.acquisition_channel,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN s.current_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN s.current_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id
GROUP BY
    s.subscription_plan,
    c.acquisition_channel
ORDER BY churn_rate_pct DESC;

----------------------------------------------------------
-- 6. Churn Risk by Average Health Score
----------------------------------------------------------

SELECT
    s.current_status,
    ROUND(AVG(p.health_score),2) AS avg_health_score,
    ROUND(AVG(p.total_logins),2) AS avg_logins,
    ROUND(AVG(p.features_used),2) AS avg_features_used
FROM subscriptions_clean s
JOIN product_usage_clean p
ON s.customer_id = p.customer_id
GROUP BY s.current_status;

----------------------------------------------------------
-- 7. High-Risk Active Customers
----------------------------------------------------------

SELECT
    c.customer_id,
    c.company_name,
    c.company_size,
    c.industry,
    c.acquisition_channel,
    s.subscription_plan,
    ROUND(AVG(p.health_score),2) AS avg_health_score,
    ROUND(AVG(p.total_logins),2) AS avg_logins,
    ROUND(AVG(p.features_used),2) AS avg_features_used
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id
JOIN product_usage_clean p
ON c.customer_id = p.customer_id
WHERE s.current_status = 'Active'
GROUP BY
    c.customer_id,
    c.company_name,
    c.company_size,
    c.industry,
    c.acquisition_channel,
    s.subscription_plan
HAVING avg_health_score < 60
ORDER BY avg_health_score ASC;