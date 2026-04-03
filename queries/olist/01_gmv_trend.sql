-- ============================================================
-- Case 1: Monthly GMV Trend with MoM & YoY Growth Rate
-- ============================================================
-- Business Question:
--   What is the monthly GMV and how does it change over time?
--   Compare each month to the previous month (MoM) and same
--   month last year (YoY).
--
-- GMV Definition: price + freight_value (total buyer payment)
-- Key Skills: LAG window function, DATE_FORMAT, CTE
-- Tables: olist_orders_dataset, olist_order_items_dataset
-- ============================================================

-- Step 1: Aggregate GMV by month
-- JOIN orders (has timestamp & status) with order_items (has price)
-- Filter out canceled orders since they have no actual transaction

WITH monthly_gmv AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        COUNT(DISTINCT o.order_id)                       AS total_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2)       AS gmv
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status != 'canceled'
    GROUP BY order_month
),

-- Step 2: Use LAG to get previous month and same month last year
-- LAG(gmv, 1)  = one row above = previous month
-- LAG(gmv, 12) = twelve rows above = same month last year
-- Returns NULL when there is no prior row (first month, first year)

gmv_with_lag AS (
    SELECT
        order_month,
        total_orders,
        gmv,
        LAG(gmv, 1)  OVER (ORDER BY order_month) AS prev_month_gmv,
        LAG(gmv, 12) OVER (ORDER BY order_month) AS prev_year_gmv
    FROM monthly_gmv
)

-- Step 3: Calculate MoM and YoY growth percentages
-- Formula: (current - previous) / previous * 100

SELECT
    order_month,
    total_orders,
    gmv,
    prev_month_gmv,
    ROUND((gmv - prev_month_gmv) / prev_month_gmv * 100, 2) AS mom_growth_pct,
    prev_year_gmv,
    ROUND((gmv - prev_year_gmv) / prev_year_gmv * 100, 2)   AS yoy_growth_pct
FROM gmv_with_lag
ORDER BY order_month;
