-- ============================================================
-- Case 2: Customer RFM Segmentation
-- ============================================================
-- Business Question:
--   Segment customers into groups (e.g. high-value, at-risk,
--   churned) based on their Recency, Frequency, and Monetary
--   value to prioritize marketing efforts.
--
-- RFM Model:
--   R (Recency)  = days since last purchase
--   F (Frequency) = total number of orders
--   M (Monetary)  = total spend
--
-- Key Skills: CTE, NTILE, CASE WHEN, DATEDIFF, aggregation
-- Tables: olist_orders_dataset, olist_order_items_dataset,
--         olist_customers_dataset
-- ============================================================

-- Step 1: Calculate R, F, M for each unique customer
-- Use customer_unique_id (not customer_id) to track repeat buyers
-- because the same person can have different customer_id per order

WITH rfm_raw AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp) FROM olist_orders_dataset),
            MAX(o.order_purchase_timestamp)
        )                                            AS recency_days,
        COUNT(DISTINCT o.order_id)                   AS frequency,
        ROUND(SUM(oi.price + oi.freight_value), 2)   AS monetary
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status != 'canceled'
    GROUP BY c.customer_unique_id
),

-- Step 2: Score each dimension 1-4 using NTILE
-- NTILE(4) splits rows into 4 equal buckets ordered by the metric
-- For recency: lower days = more recent = better, so use DESC

rfm_scored AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,  -- 4 = most recent
        NTILE(4) OVER (ORDER BY frequency ASC)      AS f_score,  -- 4 = most frequent
        NTILE(4) OVER (ORDER BY monetary ASC)        AS m_score   -- 4 = highest spend
    FROM rfm_raw
)

-- Step 3: Assign customer segments based on combined scores

SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CASE
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 2                  THEN 'Loyal Customers'
        WHEN r_score >= 3 AND f_score = 1                   THEN 'New Customers'
        WHEN r_score = 2  AND f_score >= 2                  THEN 'At Risk'
        WHEN r_score = 1  AND f_score >= 2                  THEN 'Cannot Lose'
        WHEN r_score = 1  AND f_score = 1                   THEN 'Lost'
        ELSE 'Others'
    END AS segment
FROM rfm_scored
ORDER BY monetary DESC;
