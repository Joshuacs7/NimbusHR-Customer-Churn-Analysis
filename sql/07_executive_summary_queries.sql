/*
==========================================================
Project: NimbusHR Customer Churn Analysis
Phase: ANALYZE

Business Question:
What are the final executive-level findings from the analysis?

Business Stakeholder:
Executive Leadership

Business Objective:
Summarize the key metrics and findings that explain slower MRR growth.
==========================================================
*/

----------------------------------------------------------
-- 1. Executive KPI Summary
----------------------------------------------------------

SELECT
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN s.current_status = 'Active' THEN c.customer_id END) AS active_customers,
    COUNT(DISTINCT CASE WHEN s.current_status = 'Churned' THEN c.customer_id END) AS churned_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.current_status = 'Churned' THEN c.customer_id END) * 100.0 /
        COUNT(DISTINCT c.customer_id),
        2
    ) AS churn_rate_pct,
    ROUND(SUM(CASE WHEN s.current_status = 'Active' THEN s.monthly_subscription ELSE 0 END), 2) AS current_mrr
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id;

----------------------------------------------------------
-- 2. Revenue at Risk from Active Low-Health Customers
----------------------------------------------------------

SELECT
    COUNT(DISTINCT c.customer_id) AS high_risk_active_customers,
    ROUND(SUM(s.monthly_subscription),2) AS mrr_at_risk
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id
JOIN product_usage_clean p
ON c.customer_id = p.customer_id
WHERE s.current_status = 'Active'
GROUP BY s.current_status
HAVING AVG(p.health_score) < 60;

----------------------------------------------------------
-- 3. Average Engagement Comparison
----------------------------------------------------------

SELECT
    s.current_status,
    ROUND(AVG(p.health_score),2) AS avg_health_score,
    ROUND(AVG(p.total_logins),2) AS avg_logins,
    ROUND(AVG(p.active_days),2) AS avg_active_days,
    ROUND(AVG(p.features_used),2) AS avg_features_used
FROM subscriptions_clean s
JOIN product_usage_clean p
ON s.customer_id = p.customer_id
GROUP BY s.current_status;

----------------------------------------------------------
-- 4. MRR by Plan
----------------------------------------------------------

SELECT
    subscription_plan,
    COUNT(customer_id) AS active_customers,
    ROUND(SUM(monthly_subscription),2) AS current_mrr
FROM subscriptions_clean
WHERE current_status = 'Active'
GROUP BY subscription_plan
ORDER BY current_mrr DESC;

----------------------------------------------------------
-- 5. Churn by Acquisition Channel
----------------------------------------------------------

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN s.current_status = 'Churned' THEN c.customer_id END) AS churned_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.current_status = 'Churned' THEN c.customer_id END) * 100.0 /
        COUNT(DISTINCT c.customer_id),
        2
    ) AS churn_rate_pct
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id
GROUP BY c.acquisition_channel
ORDER BY churn_rate_pct DESC;