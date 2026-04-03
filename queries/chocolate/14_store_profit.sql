-- ============================================================
-- Case 14: Store Type & Region Profit Comparison
-- ============================================================
-- Business Question:
--   Which store types (Retail, Mall, etc.) and countries are
--   most profitable? Where should the company open new stores?
--
-- Key Skills: multi-table JOIN, GROUP BY multiple dimensions
-- Tables: sales, stores
-- ============================================================

-- Part A: Profit by store type

SELECT
    st.store_type,
    COUNT(DISTINCT st.store_id)    AS store_count,
    COUNT(DISTINCT s.order_id)     AS total_orders,
    ROUND(SUM(s.revenue), 2)       AS total_revenue,
    ROUND(SUM(s.profit), 2)        AS total_profit,
    ROUND(SUM(s.profit) / SUM(s.revenue) * 100, 2)
                                    AS profit_margin_pct,
    ROUND(SUM(s.profit) / COUNT(DISTINCT st.store_id), 2)
                                    AS profit_per_store
FROM sales s
JOIN stores st
    ON s.store_id = st.store_id
GROUP BY st.store_type
ORDER BY total_profit DESC;


-- Part B: Profit by country, ranked

SELECT
    st.country,
    COUNT(DISTINCT st.store_id)    AS store_count,
    ROUND(SUM(s.revenue), 2)       AS total_revenue,
    ROUND(SUM(s.profit), 2)        AS total_profit,
    ROUND(SUM(s.profit) / SUM(s.revenue) * 100, 2)
                                    AS profit_margin_pct,
    RANK() OVER (ORDER BY SUM(s.profit) DESC) AS profit_rank
FROM sales s
JOIN stores st
    ON s.store_id = st.store_id
GROUP BY st.country
ORDER BY profit_rank;
