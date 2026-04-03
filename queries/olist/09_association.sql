-- ============================================================
-- Case 9: Frequently Bought Together (Product Association)
-- ============================================================
-- Business Question:
--   Which products are most frequently purchased together in
--   the same order? Used for "customers also bought" recommendations.
--
-- Key Skills: self-join, GROUP BY pair, ORDER BY frequency
-- Tables: olist_order_items_dataset, olist_products_dataset,
--         product_category_name_translation
-- ============================================================

-- Step 1: Self-join order_items to find product pairs in the same order
-- Use a.product_id < b.product_id to avoid duplicate pairs (A,B) and (B,A)

WITH product_pairs AS (
    SELECT
        a.product_id AS product_a,
        b.product_id AS product_b,
        COUNT(DISTINCT a.order_id) AS co_purchase_count
    FROM olist_order_items_dataset a
    JOIN olist_order_items_dataset b
        ON  a.order_id = b.order_id
        AND a.product_id < b.product_id   -- Avoid duplicates and self-pairs
    GROUP BY product_a, product_b
    HAVING co_purchase_count >= 3         -- Filter noise: at least 3 co-purchases
)

-- Step 2: Enrich with category names for readability

SELECT
    pp.product_a,
    COALESCE(ta.product_category_name_english, pa.product_category_name)
        AS category_a,
    pp.product_b,
    COALESCE(tb.product_category_name_english, pb.product_category_name)
        AS category_b,
    pp.co_purchase_count
FROM product_pairs pp
JOIN olist_products_dataset pa ON pp.product_a = pa.product_id
JOIN olist_products_dataset pb ON pp.product_b = pb.product_id
LEFT JOIN product_category_name_translation ta
    ON pa.product_category_name = ta.product_category_name
LEFT JOIN product_category_name_translation tb
    ON pb.product_category_name = tb.product_category_name
ORDER BY pp.co_purchase_count DESC
LIMIT 30;
