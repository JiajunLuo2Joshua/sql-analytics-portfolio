-- ============================================================
-- Case 11: New vs Returning Customer Revenue Trend
-- ============================================================
-- Business Question:
--   What percentage of monthly revenue comes from new customers
--   vs returning customers? A healthy business should see growing
--   contribution from returning customers over time.
--
-- Key Skills: CTE, MIN for first order, CASE WHEN, conditional SUM
-- Tables: olist_orders_dataset, olist_order_items_dataset,
--         olist_customers_dataset
-- ============================================================

-- Step 1: Find each customer's first order month

WITH first_order AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(MIN(o.order_purchase_timestamp), '%Y-%m') AS first_month
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE o.order_status != 'canceled'
    GROUP BY c.customer_unique_id
),

-- Step 2: Tag each order as new or returning
-- If order_month = first_month, the customer is "new" that month

order_tagged AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        c.customer_unique_id,
        fo.first_month,
        oi.price + oi.freight_value AS order_value,
        CASE
            WHEN DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') = fo.first_month
            THEN 'New'
            ELSE 'Returning'
        END AS customer_type
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    JOIN first_order fo
        ON c.customer_unique_id = fo.customer_unique_id
    WHERE o.order_status != 'canceled'
)

-- Step 3: Aggregate by month and customer type

SELECT
    order_month,
    ROUND(SUM(CASE WHEN customer_type = 'New'
              THEN order_value ELSE 0 END), 2)       AS new_revenue,
    ROUND(SUM(CASE WHEN customer_type = 'Returning'
              THEN order_value ELSE 0 END), 2)       AS returning_revenue,
    ROUND(SUM(order_value), 2)                        AS total_revenue,
    ROUND(
        SUM(CASE WHEN customer_type = 'Returning' THEN order_value ELSE 0 END)
        / SUM(order_value) * 100, 2
    )                                                 AS returning_pct
FROM order_tagged
GROUP BY order_month
ORDER BY order_month;
