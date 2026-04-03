-- ============================================================
-- Case 8: Seller Performance Ranking
-- ============================================================
-- Business Question:
--   Rank sellers by multiple dimensions: revenue, order volume,
--   and average review score. Identify top performers and
--   underperformers for the marketplace operations team.
--
-- Key Skills: RANK, DENSE_RANK, multi-dimensional aggregation
-- Tables: olist_order_items_dataset, olist_sellers_dataset,
--         olist_order_reviews_dataset, olist_orders_dataset
-- ============================================================

-- Step 1: Aggregate seller metrics from multiple tables

WITH seller_metrics AS (
    SELECT
        s.seller_id,
        s.seller_city,
        s.seller_state,
        COUNT(DISTINCT oi.order_id)                AS total_orders,
        ROUND(SUM(oi.price), 2)                    AS total_revenue,
        ROUND(AVG(oi.price), 2)                    AS avg_order_value,
        ROUND(AVG(r.review_score), 2)              AS avg_review_score,
        COUNT(DISTINCT oi.product_id)              AS unique_products
    FROM olist_sellers_dataset s
    JOIN olist_order_items_dataset oi
        ON s.seller_id = oi.seller_id
    JOIN olist_orders_dataset o
        ON oi.order_id = o.order_id
    LEFT JOIN olist_order_reviews_dataset r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_id, s.seller_city, s.seller_state
    HAVING total_orders >= 10   -- Only sellers with meaningful volume
)

-- Step 2: Rank sellers by different dimensions
-- RANK: leaves gaps after ties (1,1,3)
-- DENSE_RANK: no gaps (1,1,2)

SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_revenue,
    avg_order_value,
    avg_review_score,
    RANK()       OVER (ORDER BY total_revenue DESC)    AS revenue_rank,
    RANK()       OVER (ORDER BY total_orders DESC)     AS volume_rank,
    DENSE_RANK() OVER (ORDER BY avg_review_score DESC) AS review_rank
FROM seller_metrics
ORDER BY total_revenue DESC
LIMIT 50;
