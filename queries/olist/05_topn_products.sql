-- ============================================================
-- Case 5: Top N Products per Category
-- ============================================================
-- Business Question:
--   What are the top 3 best-selling products in each category
--   by revenue? This helps identify hero products per category.
--
-- Key Skills: ROW_NUMBER, PARTITION BY, multi-table JOIN
-- Tables: olist_order_items_dataset, olist_products_dataset,
--         product_category_name_translation
-- ============================================================

-- Step 1: Calculate revenue per product with English category name

WITH product_revenue AS (
    SELECT
        p.product_id,
        COALESCE(t.product_category_name_english, p.product_category_name)
            AS category,
        COUNT(DISTINCT oi.order_id)                AS order_count,
        ROUND(SUM(oi.price), 2)                    AS total_revenue
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY p.product_id, category
),

-- Step 2: Rank products within each category by revenue
-- ROW_NUMBER gives unique ranks (no ties); use RANK if ties matter

ranked AS (
    SELECT
        category,
        product_id,
        order_count,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS rn
    FROM product_revenue
    WHERE category IS NOT NULL
)

-- Step 3: Keep only top 3 per category

SELECT
    category,
    rn                AS rank_in_category,
    product_id,
    order_count,
    total_revenue
FROM ranked
WHERE rn <= 3
ORDER BY category, rn;
