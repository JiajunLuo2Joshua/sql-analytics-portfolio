-- ============================================================
-- Case 6: Longest Consecutive Order Streak per Customer
-- ============================================================
-- Business Question:
--   Which customers have the longest streak of consecutive days
--   with orders? Identifies the most engaged power users.
--
-- Key Skills: ROW_NUMBER gap-and-island method, DATEDIFF
-- Tables: olist_orders_dataset, olist_customers_dataset
-- ============================================================

-- Step 1: Get distinct order dates per customer

WITH customer_dates AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE(o.order_purchase_timestamp) AS order_date
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE o.order_status != 'canceled'
),

-- Step 2: Gap-and-island technique
-- Assign a row number to each date per customer
-- If dates are consecutive, (order_date - row_number) is constant
-- This constant becomes the "island group"

islands AS (
    SELECT
        customer_unique_id,
        order_date,
        DATE_SUB(
            order_date,
            INTERVAL ROW_NUMBER() OVER (
                PARTITION BY customer_unique_id
                ORDER BY order_date
            ) DAY
        ) AS island_group
    FROM customer_dates
),

-- Step 3: Count consecutive days in each island

streaks AS (
    SELECT
        customer_unique_id,
        island_group,
        MIN(order_date)    AS streak_start,
        MAX(order_date)    AS streak_end,
        COUNT(*)           AS streak_days
    FROM islands
    GROUP BY customer_unique_id, island_group
)

-- Step 4: Get the longest streak per customer, show top results

SELECT
    customer_unique_id,
    streak_start,
    streak_end,
    streak_days
FROM streaks
ORDER BY streak_days DESC
LIMIT 20;
