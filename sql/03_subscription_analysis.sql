/*
==========================================================
Project: NimbusHR Customer Churn Analysis
Phase: ANALYZE

Business Question:
Which subscription plans are driving revenue and which
plans represent the greatest retention risk?

Business Stakeholder:
VP of Growth

Business Objective:
Evaluate subscription performance by customer volume,
revenue generation and churn.
==========================================================
*/

----------------------------------------------------------
-- 1. Customer Distribution by Subscription Plan
----------------------------------------------------------

SELECT
    subscription_plan,
    COUNT(*) AS total_customers
FROM subscriptions_clean
GROUP BY subscription_plan
ORDER BY total_customers DESC;

----------------------------------------------------------
-- 2. Monthly Recurring Revenue by Subscription Plan
----------------------------------------------------------

SELECT
    subscription_plan,
    COUNT(*) AS active_customers,
    SUM(monthly_subscription) AS monthly_recurring_revenue
FROM subscriptions_clean
WHERE current_status='Active'
GROUP BY subscription_plan
ORDER BY monthly_recurring_revenue DESC;

----------------------------------------------------------
-- 3. Average Revenue per Customer
----------------------------------------------------------

SELECT
    subscription_plan,
    ROUND(AVG(monthly_subscription),2) AS average_monthly_revenue
FROM subscriptions_clean
WHERE current_status='Active'
GROUP BY subscription_plan
ORDER BY average_monthly_revenue DESC;

----------------------------------------------------------
-- 4. Churn Rate by Subscription Plan
----------------------------------------------------------

SELECT
    subscription_plan,
    COUNT(*) AS total_customers,
    SUM(CASE
            WHEN current_status='Churned'
            THEN 1
            ELSE 0
        END) AS churned_customers,
    ROUND(
        SUM(CASE
                WHEN current_status='Churned'
                THEN 1
                ELSE 0
            END)*100.0/
        COUNT(*),
        2
    ) AS churn_rate_pct
FROM subscriptions_clean
GROUP BY subscription_plan
ORDER BY churn_rate_pct DESC;

----------------------------------------------------------
-- 5. Upgrade Activity
----------------------------------------------------------

SELECT
    subscription_plan,
    SUM(upgrade_count) AS total_upgrades,
    SUM(downgrade_count) AS total_downgrades
FROM subscriptions_clean
GROUP BY subscription_plan
ORDER BY total_upgrades DESC;