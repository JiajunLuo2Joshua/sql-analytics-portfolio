-- ============================================================
-- Case 15: Discount Impact on Profit Analysis
-- ============================================================
-- Business Question:
--   How does discount level affect profit margin? Is higher
--   discount driving more volume, or just eroding profit?
--   Find the optimal discount range.
--
-- Key Skills: CASE WHEN buckets, GROUP BY, profit margin calc
-- Tables: sales, products
-- ============================================================

-- Step 1: Bucket orders by discount range and analyze each

SELECT
    CASE
        WHEN s.discount = 0                 THEN '0% (No Discount)'
        WHEN s.discount > 0  AND s.discount <= 0.05 THEN '1-5%'
        WHEN s.discount > 0.05 AND s.discount <= 0.10 THEN '6-10%'
        WHEN s.discount > 0.10 AND s.discount <= 0.15 THEN '11-15%'
        WHEN s.discount > 0.15 AND s.discount <= 0.20 THEN '16-20%'
        ELSE '20%+'
    END AS discount_bucket,
    COUNT(*)                                 AS order_count,
    ROUND(AVG(s.quantity), 2)                AS avg_quantity,
    ROUND(AVG(s.revenue), 2)                 AS avg_revenue,
    ROUND(AVG(s.profit), 2)                  AS avg_profit,
    ROUND(SUM(s.profit), 2)                  AS total_profit,
    ROUND(SUM(s.profit) / SUM(s.revenue) * 100, 2) AS profit_margin_pct
FROM sales s
GROUP BY discount_bucket
ORDER BY
    CASE discount_bucket
        WHEN '0% (No Discount)' THEN 1
        WHEN '1-5%'             THEN 2
        WHEN '6-10%'            THEN 3
        WHEN '11-15%'           THEN 4
        WHEN '16-20%'           THEN 5
        ELSE 6
    END;
