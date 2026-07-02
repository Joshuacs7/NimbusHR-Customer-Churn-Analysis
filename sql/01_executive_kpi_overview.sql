
-- =========================================================
-- Project: NimbusHR Customer Churn Analysis
-- Phase: ANALYZE
-- File: 01_executive_kpi_overview.sql
-- Purpose: Calculate executive-level SaaS KPIs
-- =========================================================

-- 1. Customer base overview
SELECT
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN s.current_status = 'Active' THEN c.customer_id END) AS active_customers,
    COUNT(DISTINCT CASE WHEN s.current_status = 'Churned' THEN c.customer_id END) AS churned_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.current_status = 'Churned' THEN c.customer_id END) * 1.0 /
        COUNT(DISTINCT c.customer_id), 4
    ) AS customer_churn_rate
FROM customers_clean c
LEFT JOIN subscriptions_clean s
    ON c.customer_id = s.customer_id;


-- 2. Monthly Recurring Revenue from active subscriptions
SELECT
    ROUND(SUM(monthly_subscription), 2) AS current_mrr
FROM subscriptions_clean
WHERE current_status = 'Active';


-- 3. Annual Recurring Revenue estimate
SELECT
    ROUND(SUM(monthly_subscription) * 12, 2) AS estimated_arr
FROM subscriptions_clean
WHERE current_status = 'Active';


-- 4. Average Revenue Per Active Customer
SELECT
    ROUND(AVG(monthly_subscription), 2) AS avg_revenue_per_active_customer
FROM subscriptions_clean
WHERE current_status = 'Active';


-- 5. Revenue by subscription plan
SELECT
    subscription_plan,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(monthly_subscription), 2) AS mrr,
    ROUND(AVG(monthly_subscription), 2) AS avg_mrr_per_customer
FROM subscriptions_clean
WHERE current_status = 'Active'
GROUP BY subscription_plan
ORDER BY mrr DESC;


-- 6. Churn rate by subscription plan
SELECT
    subscription_plan,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN current_status = 'Churned' THEN customer_id END) AS churned_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN current_status = 'Churned' THEN customer_id END) * 1.0 /
        COUNT(DISTINCT customer_id), 4
    ) AS churn_rate
FROM subscriptions_clean
GROUP BY subscription_plan
ORDER BY churn_rate DESC;


-- 7. Revenue recognized from valid paid transactions
SELECT
    ROUND(SUM(revenue_amount), 2) AS recognized_revenue
FROM payments_clean;


-- 8. Customer acquisition by channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT CASE WHEN s.current_status = 'Churned' THEN c.customer_id END) AS churned_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.current_status = 'Churned' THEN c.customer_id END) * 1.0 /
        COUNT(DISTINCT c.customer_id), 4
    ) AS churn_rate,
    ROUND(AVG(s.monthly_subscription), 2) AS avg_mrr
FROM customers_clean c
JOIN subscriptions_clean s
    ON c.customer_id = s.customer_id
GROUP BY c.acquisition_channel
ORDER BY churn_rate DESC;


-- 9. Engagement by customer status
SELECT
    s.current_status,
    ROUND(AVG(pu.total_logins), 2) AS avg_monthly_logins,
    ROUND(AVG(pu.active_days), 2) AS avg_active_days,
    ROUND(AVG(pu.features_used), 2) AS avg_features_used,
    ROUND(AVG(pu.health_score), 2) AS avg_health_score
FROM subscriptions_clean s
JOIN product_usage_clean pu
    ON s.customer_id = pu.customer_id
GROUP BY s.current_status;


-- 10. Support ticket volume by churn status
SELECT
    s.current_status,
    COUNT(t.ticket_id) AS total_tickets,
    ROUND(AVG(t.resolution_hours), 2) AS avg_resolution_hours
FROM subscriptions_clean s
LEFT JOIN support_tickets_clean t
    ON s.customer_id = t.customer_id
GROUP BY s.current_status;
