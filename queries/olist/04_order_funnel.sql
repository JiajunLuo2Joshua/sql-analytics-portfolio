-- ============================================================
-- Case 4: Order Status Funnel Conversion
-- ============================================================
-- Business Question:
--   What is the conversion rate through each order stage?
--   (created -> approved -> shipped -> delivered)
--   Where are the biggest drop-offs in the fulfillment process?
--
-- Note: Olist data has no browse/cart data, so we use the order
--       status lifecycle as our funnel instead.
--
-- Key Skills: conditional aggregation, CASE WHEN, percentage calc
-- Tables: olist_orders_dataset
-- ============================================================

-- Step 1: Count orders reaching each stage
-- An order that is "delivered" has also passed through all prior stages
-- Use conditional counting based on whether timestamp columns are NOT NULL

WITH funnel AS (
    SELECT
        COUNT(*)                                                         AS total_orders,
        SUM(CASE WHEN order_approved_at IS NOT NULL THEN 1 ELSE 0 END)  AS approved,
        SUM(CASE WHEN order_delivered_carrier_date IS NOT NULL
                  THEN 1 ELSE 0 END)                                     AS shipped,
        SUM(CASE WHEN order_delivered_customer_date IS NOT NULL
                  THEN 1 ELSE 0 END)                                     AS delivered
    FROM olist_orders_dataset
    WHERE order_status != 'canceled'
)

-- Step 2: Calculate conversion rate at each stage

SELECT
    total_orders,
    approved,
    ROUND(approved / total_orders * 100, 2)  AS approval_rate,
    shipped,
    ROUND(shipped / approved * 100, 2)       AS ship_rate,
    delivered,
    ROUND(delivered / shipped * 100, 2)      AS delivery_rate,
    ROUND(delivered / total_orders * 100, 2) AS overall_conversion
FROM funnel;
