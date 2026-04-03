-- ============================================================
-- Case 10: Anomaly Order Detection
-- ============================================================
-- Business Question:
--   Which orders have abnormally high prices compared to their
--   product category average? Flag potential pricing errors,
--   fraud, or premium outliers.
--
-- Key Skills: window function AVG/STDDEV, CASE WHEN, z-score
-- Tables: olist_order_items_dataset, olist_products_dataset,
--         product_category_name_translation
-- ============================================================

-- Step 1: Calculate category-level stats using window functions
-- Compute mean and stddev per category WITHOUT collapsing rows

WITH order_with_stats AS (
    SELECT
        oi.order_id,
        oi.product_id,
        COALESCE(t.product_category_name_english, p.product_category_name)
            AS category,
        oi.price,
        AVG(oi.price) OVER (PARTITION BY p.product_category_name)    AS cat_avg_price,
        STDDEV(oi.price) OVER (PARTITION BY p.product_category_name) AS cat_stddev_price,
        COUNT(*) OVER (PARTITION BY p.product_category_name)         AS cat_item_count
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
)

-- Step 2: Calculate z-score and flag anomalies
-- z-score = (value - mean) / stddev
-- |z| > 2 is commonly used as an anomaly threshold

SELECT
    order_id,
    product_id,
    category,
    price,
    ROUND(cat_avg_price, 2)    AS category_avg,
    ROUND(cat_stddev_price, 2) AS category_stddev,
    ROUND(
        (price - cat_avg_price) / NULLIF(cat_stddev_price, 0), 2
    ) AS z_score,
    CASE
        WHEN cat_stddev_price = 0 THEN 'Single Price'
        WHEN (price - cat_avg_price) / cat_stddev_price > 3  THEN 'Extreme High'
        WHEN (price - cat_avg_price) / cat_stddev_price > 2  THEN 'High Outlier'
        WHEN (price - cat_avg_price) / cat_stddev_price < -2 THEN 'Low Outlier'
        ELSE 'Normal'
    END AS anomaly_flag
FROM order_with_stats
WHERE cat_item_count >= 20    -- Only categories with enough data
HAVING anomaly_flag != 'Normal'
ORDER BY z_score DESC
LIMIT 50;
