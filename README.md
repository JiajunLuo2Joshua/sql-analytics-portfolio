# SQL Analytics Portfolio

10+ business query cases demonstrating SQL analytics skills using real-world datasets.

## Datasets

### 1. Brazilian E-Commerce (Olist)
- Source: [Kaggle - Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- 8 tables: orders, order_items, customers, payments, products, sellers, reviews, geolocation
- ~100k orders, 2016-2018

### 2. Chocolate Sales
- Source: Kaggle
- 5 tables: sales, customers, products, stores, calendar
- Star schema model with profit/cost data

## Query Cases

### Olist E-Commerce
| # | Case | Key Skills | File |
|---|------|-----------|------|
| 1 | Monthly GMV Trend + MoM/YoY Growth | LAG, date functions | [01_gmv_trend.sql](queries/olist/01_gmv_trend.sql) |
| 2 | Customer RFM Segmentation | CTE, CASE, aggregation | [02_rfm_segmentation.sql](queries/olist/02_rfm_segmentation.sql) |
| 3 | User Retention Cohort Analysis | CTE, self-join, COUNT DISTINCT | [03_cohort_retention.sql](queries/olist/03_cohort_retention.sql) |
| 4 | Order Status Funnel Conversion | multi-table JOIN, conditional agg | [04_order_funnel.sql](queries/olist/04_order_funnel.sql) |
| 5 | Top N Products per Category | ROW_NUMBER, PARTITION BY | [05_topn_products.sql](queries/olist/05_topn_products.sql) |
| 6 | Longest Consecutive Order Streak | ROW_NUMBER gap method | [06_consecutive_orders.sql](queries/olist/06_consecutive_orders.sql) |
| 7 | Repurchase Rate & Cycle | self-join, DATEDIFF, HAVING | [07_repurchase.sql](queries/olist/07_repurchase.sql) |
| 8 | Seller Performance Ranking | RANK, DENSE_RANK, multi-dim agg | [08_seller_ranking.sql](queries/olist/08_seller_ranking.sql) |
| 9 | Frequently Bought Together | self-join, GROUP BY | [09_association.sql](queries/olist/09_association.sql) |
| 10 | Anomaly Order Detection | window AVG/STDDEV, CASE | [10_anomaly_detection.sql](queries/olist/10_anomaly_detection.sql) |
| 11 | New vs Returning Customer Trend | CTE, MIN first order, JOIN | [11_new_vs_returning.sql](queries/olist/11_new_vs_returning.sql) |
| 12 | Cumulative Sales & 7-Day Moving Avg | SUM/AVG OVER (ROWS BETWEEN) | [12_cumulative_moving_avg.sql](queries/olist/12_cumulative_moving_avg.sql) |

### Chocolate Sales
| # | Case | Key Skills | File |
|---|------|-----------|------|
| 13 | Loyalty vs Non-Loyalty Analysis | JOIN, conditional agg, CASE | [13_loyalty_analysis.sql](queries/chocolate/13_loyalty_analysis.sql) |
| 14 | Store Type & Region Profit | multi-table JOIN, GROUP BY | [14_store_profit.sql](queries/chocolate/14_store_profit.sql) |
| 15 | Discount Impact on Profit | correlation analysis, CASE buckets | [15_discount_impact.sql](queries/chocolate/15_discount_impact.sql) |

## How to Run

1. Download datasets from Kaggle and place CSVs in `E_Commerce/` and `Chocolate_Sales/` folders
2. Import CSVs into your SQL database (MySQL / PostgreSQL / SQLite)
3. Run `.sql` files in the `queries/` folder

## Skills Demonstrated

- Window functions: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, SUM/AVG OVER
- CTEs and recursive CTEs
- Complex JOINs: self-join, multi-table join, LEFT JOIN filtering
- Date functions and time-series analysis
- Conditional aggregation (CASE WHEN)
- Cohort analysis, RFM segmentation, funnel analysis
