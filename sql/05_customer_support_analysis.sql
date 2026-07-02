/*
==========================================================
Project: NimbusHR Customer Churn Analysis
Phase: ANALYZE

Business Question:
Does customer support performance influence customer churn?

Business Stakeholder:
Director of Customer Success

Business Objective:
Evaluate whether support activity and resolution time
are associated with customer churn.
==========================================================
*/

----------------------------------------------------------
-- 1. Support Activity by Customer Status
----------------------------------------------------------

SELECT
    s.current_status,
    COUNT(t.ticket_id) AS total_tickets,
    ROUND(AVG(t.resolution_hours),2) AS avg_resolution_hours
FROM subscriptions_clean s
LEFT JOIN support_tickets_clean t
ON s.customer_id = t.customer_id
GROUP BY s.current_status;

----------------------------------------------------------
-- 2. Support Tickets by Category
----------------------------------------------------------

SELECT
    category,
    COUNT(ticket_id) AS total_tickets
FROM support_tickets_clean
GROUP BY category
ORDER BY total_tickets DESC;

----------------------------------------------------------
-- 3. Support Tickets by Priority
----------------------------------------------------------

SELECT
    priority,
    COUNT(ticket_id) AS total_tickets
FROM support_tickets_clean
GROUP BY priority
ORDER BY total_tickets DESC;

----------------------------------------------------------
-- 4. Average Resolution Time by Ticket Category
----------------------------------------------------------

SELECT
    category,
    ROUND(AVG(resolution_hours),2) AS avg_resolution_hours
FROM support_tickets_clean
GROUP BY category
ORDER BY avg_resolution_hours DESC;

----------------------------------------------------------
-- 5. Customers with the Highest Number of Support Tickets
----------------------------------------------------------

SELECT
    c.customer_id,
    c.company_name,
    COUNT(t.ticket_id) AS total_tickets
FROM customers_clean c
JOIN support_tickets_clean t
ON c.customer_id = t.customer_id
GROUP BY
    c.customer_id,
    c.company_name
ORDER BY total_tickets DESC
LIMIT 20;