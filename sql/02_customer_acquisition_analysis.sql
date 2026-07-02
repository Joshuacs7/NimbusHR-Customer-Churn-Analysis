/*
==========================================================
Project: NimbusHR Customer Churn Analysis
Phase: ANALYZE

Business Question:
Which acquisition channels generate the highest-value customers?

Business Stakeholder:
VP of Growth

Business Objective:
Evaluate customer acquisition channels based on customer quality,
retention, and revenue contribution instead of acquisition volume.
==========================================================
*/

----------------------------------------------------------
-- 1. Customer Distribution by Acquisition Channel
----------------------------------------------------------

SELECT
    acquisition_channel,
    COUNT(customer_id) AS total_customers
FROM customers_clean
GROUP BY acquisition_channel
ORDER BY total_customers DESC;

----------------------------------------------------------
-- 2. Churn Rate by Acquisition Channel
----------------------------------------------------------

SELECT
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
GROUP BY c.acquisition_channel
ORDER BY churn_rate_pct DESC;

----------------------------------------------------------
-- 3. Average Monthly Revenue by Acquisition Channel
----------------------------------------------------------

SELECT
    c.acquisition_channel,
    ROUND(AVG(s.monthly_subscription),2) AS avg_monthly_revenue
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id
WHERE s.current_status='Active'
GROUP BY c.acquisition_channel
ORDER BY avg_monthly_revenue DESC;

----------------------------------------------------------
-- 4. Revenue Contribution by Acquisition Channel
----------------------------------------------------------

SELECT
    c.acquisition_channel,
    ROUND(SUM(s.monthly_subscription),2) AS total_mrr
FROM customers_clean c
JOIN subscriptions_clean s
ON c.customer_id = s.customer_id
WHERE s.current_status='Active'
GROUP BY c.acquisition_channel
ORDER BY total_mrr DESC;