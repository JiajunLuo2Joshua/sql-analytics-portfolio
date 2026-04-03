-- ============================================================
-- Case 12: Cumulative Sales & 7-Day Moving Average
-- ============================================================
-- Business Question:
--   What is the daily revenue, cumulative total, and 7-day
--   moving average? Moving average smooths out daily noise
--   to reveal the true trend.
--
-- Key Skills: SUM OVER (ROWS BETWEEN), frame specification
-- Tables: olist_orders_dataset, olist_order_items_dataset
-- ============================================================

-- Step 1: Aggregate daily revenue

WITH daily_revenue AS (
    SELECT
        DATE(o.order_purchase_timestamp) AS order_date,
        COUNT(DISTINCT o.order_id)       AS daily_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS daily_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status != 'canceled'
    GROUP BY order_date
)

-- Step 2: Calculate cumulative sum and 7-day moving average
-- ROWS BETWEEN 6 PRECEDING AND CURRENT ROW = current row + 6 prior = 7 days
-- ROWS UNBOUNDED PRECEDING = all rows from the start to current

SELECT
    order_date,
    daily_orders,
    daily_revenue,
    ROUND(
        SUM(daily_revenue) OVER (
            ORDER BY order_date
            ROWS UNBOUNDED PRECEDING
        ), 2
    ) AS cumulative_revenue,
    ROUND(
        AVG(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_7d
FROM daily_revenue
ORDER BY order_date;
