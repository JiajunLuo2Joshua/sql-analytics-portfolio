-- ============================================================
-- Case 13: Loyalty Member vs Non-Member Analysis
-- ============================================================
-- Business Question:
--   Do loyalty members spend more, buy more frequently, and
--   generate more profit than non-members? Should the company
--   invest more in the loyalty program?
--
-- Key Skills: JOIN, conditional aggregation, CASE WHEN, GROUP BY
-- Tables: sales, customers
-- ============================================================

-- Step 1: Compare key metrics between loyalty and non-loyalty groups

SELECT
    CASE WHEN c.loyalty_member = 1 THEN 'Member' ELSE 'Non-Member' END
        AS loyalty_status,
    COUNT(DISTINCT c.customer_id)          AS customer_count,
    COUNT(DISTINCT s.order_id)             AS total_orders,
    ROUND(COUNT(DISTINCT s.order_id) * 1.0
        / COUNT(DISTINCT c.customer_id), 2) AS orders_per_customer,
    ROUND(AVG(s.revenue), 2)               AS avg_order_revenue,
    ROUND(SUM(s.revenue), 2)               AS total_revenue,
    ROUND(SUM(s.profit), 2)                AS total_profit,
    ROUND(AVG(s.profit), 2)                AS avg_profit_per_order,
    ROUND(AVG(s.discount) * 100, 2)        AS avg_discount_pct
FROM sales s
JOIN customers c
    ON s.customer_id = c.customer_id
GROUP BY loyalty_status;
