-- ============================================================
-- Case 3: User Retention Cohort Analysis
-- ============================================================
-- Business Question:
--   For each monthly cohort (grouped by first purchase month),
--   what percentage of users come back to purchase in subsequent
--   months? This reveals whether the platform retains customers.
--
-- Key Skills: CTE, self-join, COUNT DISTINCT, DATE_FORMAT
-- Tables: olist_orders_dataset, olist_customers_dataset
-- ============================================================

-- Step 1: Find each customer's first purchase month (cohort)

WITH customer_cohort AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(MIN(o.order_purchase_timestamp), '%Y-%m') AS cohort_month
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE o.order_status != 'canceled'
    GROUP BY c.customer_unique_id
),

-- Step 2: Get all purchase months per customer

customer_orders AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE o.order_status != 'canceled'
),

-- Step 3: Calculate month offset from cohort month
-- PERIOD_DIFF converts 'YYYY-MM' format into months difference

cohort_activity AS (
    SELECT
        cc.cohort_month,
        PERIOD_DIFF(
            EXTRACT(YEAR_MONTH FROM STR_TO_DATE(CONCAT(co.order_month, '-01'), '%Y-%m-%d')),
            EXTRACT(YEAR_MONTH FROM STR_TO_DATE(CONCAT(cc.cohort_month, '-01'), '%Y-%m-%d'))
        ) AS month_offset,
        COUNT(DISTINCT co.customer_unique_id) AS active_customers
    FROM customer_cohort cc
    JOIN customer_orders co
        ON cc.customer_unique_id = co.customer_unique_id
    GROUP BY cc.cohort_month, month_offset
),

-- Step 4: Get cohort size (number of customers in each cohort)

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_customers
    FROM customer_cohort
    GROUP BY cohort_month
)

-- Step 5: Calculate retention rate

SELECT
    cs.cohort_month,
    cs.cohort_customers,
    ca.month_offset,
    ca.active_customers,
    ROUND(ca.active_customers / cs.cohort_customers * 100, 2) AS retention_pct
FROM cohort_size cs
JOIN cohort_activity ca
    ON cs.cohort_month = ca.cohort_month
WHERE ca.month_offset <= 12   -- Show up to 12 months retention
ORDER BY cs.cohort_month, ca.month_offset;
