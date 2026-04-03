-- ============================================================
-- Case 7: Repurchase Rate & Average Repurchase Cycle
-- ============================================================
-- Business Question:
--   What percentage of customers make more than one purchase?
--   For those who do, how many days on average between purchases?
--
-- Key Skills: self-join, DATEDIFF, HAVING, subquery
-- Tables: olist_orders_dataset, olist_customers_dataset
-- ============================================================

-- Step 1: Get each customer's orders with timestamps

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_seq
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE o.order_status != 'canceled'
),

-- Step 2: Self-join consecutive orders to get gap between purchases
-- Join order N with order N+1 for the same customer

order_gaps AS (
    SELECT
        a.customer_unique_id,
        a.order_purchase_timestamp AS prev_order_date,
        b.order_purchase_timestamp AS next_order_date,
        DATEDIFF(b.order_purchase_timestamp, a.order_purchase_timestamp) AS days_between
    FROM customer_orders a
    JOIN customer_orders b
        ON  a.customer_unique_id = b.customer_unique_id
        AND a.order_seq = b.order_seq - 1
),

-- Step 3: Overall repurchase rate

total_customers AS (
    SELECT COUNT(DISTINCT customer_unique_id) AS total
    FROM customer_orders
),

repeat_customers AS (
    SELECT COUNT(DISTINCT customer_unique_id) AS repeats
    FROM customer_orders
    WHERE order_seq >= 2
)

-- Step 4: Combine repurchase rate with average cycle

SELECT
    tc.total                                              AS total_customers,
    rc.repeats                                            AS repeat_customers,
    ROUND(rc.repeats / tc.total * 100, 2)                 AS repurchase_rate_pct,
    ROUND(AVG(og.days_between), 1)                        AS avg_days_between_orders,
    ROUND(MIN(og.days_between), 1)                        AS min_days_between,
    ROUND(MAX(og.days_between), 1)                        AS max_days_between
FROM total_customers tc
CROSS JOIN repeat_customers rc
CROSS JOIN order_gaps og;
