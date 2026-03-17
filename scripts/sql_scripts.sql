-- ============================================================
-- MavenEcom_SQL_Insights — Complete SQL Scripts
-- Dataset path: E:\SQL\dataset\Portfolio\projects\Maven+Fuzzy+Factory
-- Database: PostgreSQL
-- Author: Yaseen Ali | linkedin.com/in/yaseen-saeed
-- ============================================================

-- ============================================================
-- 00_data_load.sql — Table Creation & Data Import
-- ============================================================

CREATE TABLE IF NOT EXISTS products (
    product_id   INT PRIMARY KEY,
    created_at   TIMESTAMP,
    product_name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS website_sessions (
    website_session_id INT PRIMARY KEY,
    created_at         TIMESTAMP,
    user_id            INT,
    is_repeat_session  SMALLINT,
    utm_source         VARCHAR(50),
    utm_campaign       VARCHAR(50),
    utm_content        VARCHAR(50),
    device_type        VARCHAR(20),
    http_referer       VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS website_pageviews (
    website_pageview_id INT PRIMARY KEY,
    created_at          TIMESTAMP,
    website_session_id  INT REFERENCES website_sessions(website_session_id),
    pageview_url        VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id            INT PRIMARY KEY,
    created_at          TIMESTAMP,
    website_session_id  INT,
    user_id             INT,
    primary_product_id  INT REFERENCES products(product_id),
    items_purchased     INT,
    price_usd           NUMERIC(8,2),
    cogs_usd            NUMERIC(8,2)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id   INT PRIMARY KEY,
    created_at      TIMESTAMP,
    order_id        INT REFERENCES orders(order_id),
    product_id      INT REFERENCES products(product_id),
    is_primary_item SMALLINT,
    price_usd       NUMERIC(8,2),
    cogs_usd        NUMERIC(8,2)
);

CREATE TABLE IF NOT EXISTS order_item_refunds (
    order_item_refund_id INT PRIMARY KEY,
    created_at           TIMESTAMP,
    order_item_id        INT REFERENCES order_items(order_item_id),
    order_id             INT REFERENCES orders(order_id),
    refund_amount_usd    NUMERIC(8,2)
);

-- ============================================================
-- 01_data_validation.sql — Data Quality Checks
-- ============================================================

-- Row counts per table
SELECT 'orders'              AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL SELECT 'order_items',              COUNT(*) FROM order_items
UNION ALL SELECT 'order_item_refunds',       COUNT(*) FROM order_item_refunds
UNION ALL SELECT 'products',                 COUNT(*) FROM products
UNION ALL SELECT 'website_sessions',         COUNT(*) FROM website_sessions
UNION ALL SELECT 'website_pageviews',        COUNT(*) FROM website_pageviews;

-- Date range
SELECT
    MIN(created_at)::DATE AS first_date,
    MAX(created_at)::DATE AS last_date,
    MAX(created_at)::DATE - MIN(created_at)::DATE AS days_span
FROM orders;

-- Null checks
SELECT
    COUNT(*) FILTER (WHERE price_usd IS NULL) AS null_price,
    COUNT(*) FILTER (WHERE cogs_usd  IS NULL) AS null_cogs,
    COUNT(*) FILTER (WHERE user_id   IS NULL) AS null_user
FROM orders;

-- Orphan order_items (no parent order)
SELECT COUNT(*) AS orphan_items
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- ============================================================
-- 02_exploration.sql — KPI Overview
-- Answers: Revenue Q1 — What is the trend in total revenue
--          and average revenue per order?
-- ============================================================

-- Overall KPIs
SELECT
    COUNT(DISTINCT order_id)                              AS total_orders,
    ROUND(SUM(price_usd), 2)                             AS gross_revenue,
    ROUND(SUM(cogs_usd), 2)                              AS total_cogs,
    ROUND(SUM(price_usd) - SUM(cogs_usd), 2)            AS gross_profit,
    ROUND((SUM(price_usd)-SUM(cogs_usd))
          / SUM(price_usd) * 100, 1)                    AS gross_margin_pct,
    ROUND(AVG(price_usd), 2)                             AS avg_order_value,
    MIN(created_at)::DATE                                AS first_order_date,
    MAX(created_at)::DATE                                AS last_order_date
FROM orders;

-- Annual KPIs with YoY growth
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM created_at)::INT               AS year,
        COUNT(*)                                         AS orders,
        ROUND(SUM(price_usd), 2)                        AS revenue,
        ROUND(SUM(price_usd) - SUM(cogs_usd), 2)       AS gross_profit,
        ROUND(AVG(price_usd), 2)                        AS avg_order_value
    FROM orders
    GROUP BY 1
)
SELECT
    year,
    orders,
    revenue,
    gross_profit,
    ROUND(gross_profit / revenue * 100, 1)              AS margin_pct,
    avg_order_value,
    LAG(revenue) OVER (ORDER BY year)                   AS prev_year_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY year))
          / LAG(revenue) OVER (ORDER BY year) * 100, 1) AS yoy_revenue_growth_pct,
    ROUND((orders  - LAG(orders)  OVER (ORDER BY year))::NUMERIC
          / LAG(orders)  OVER (ORDER BY year) * 100, 1) AS yoy_orders_growth_pct
FROM yearly
ORDER BY year;

-- Monthly revenue trend
SELECT
    DATE_TRUNC('month', created_at)::DATE               AS month,
    EXTRACT(YEAR  FROM created_at)::INT                  AS year,
    EXTRACT(MONTH FROM created_at)::INT                  AS month_num,
    COUNT(*)                                             AS orders,
    ROUND(SUM(price_usd), 2)                            AS revenue,
    ROUND(SUM(price_usd) - SUM(cogs_usd), 2)           AS gross_profit,
    ROUND((SUM(price_usd)-SUM(cogs_usd))
          / SUM(price_usd) * 100, 1)                   AS margin_pct,
    ROUND(AVG(price_usd), 2)                            AS avg_order_value
FROM orders
GROUP BY 1, 2, 3
ORDER BY 1;

-- ============================================================
-- 03_marketing_performance.sql
-- Answers: Marketing Q1 — Sessions & order volume trends
--          Marketing Q2 — Which channels drive most valuable traffic?
--          Marketing Q3 — How have conversion rates evolved?
-- NOTE: Requires website_sessions table
-- ============================================================

-- Q: What are the trends in website sessions and order volumes?
SELECT
    DATE_TRUNC('month', ws.created_at)::DATE            AS month,
    COUNT(DISTINCT ws.website_session_id)               AS total_sessions,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    ROUND(COUNT(DISTINCT o.order_id)::NUMERIC
          / COUNT(DISTINCT ws.website_session_id) * 100, 2) AS conversion_rate_pct,
    ROUND(SUM(o.price_usd), 2)                         AS revenue
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY 1
ORDER BY 1;

-- Q: Which marketing channels are driving the most valuable traffic?
SELECT
    ws.utm_source,
    ws.utm_campaign,
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id)               AS sessions,
    COUNT(DISTINCT o.order_id)                          AS orders,
    ROUND(COUNT(DISTINCT o.order_id)::NUMERIC
          / COUNT(DISTINCT ws.website_session_id) * 100, 2) AS cvr_pct,
    ROUND(SUM(o.price_usd), 2)                         AS revenue,
    ROUND(AVG(o.price_usd), 2)                         AS avg_order_value
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY 1, 2, 3
ORDER BY sessions DESC;

-- Q: How have conversion rates evolved over time by channel?
SELECT
    DATE_TRUNC('month', ws.created_at)::DATE            AS month,
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id)               AS sessions,
    COUNT(DISTINCT o.order_id)                          AS orders,
    ROUND(COUNT(DISTINCT o.order_id)::NUMERIC
          / COUNT(DISTINCT ws.website_session_id) * 100, 2) AS cvr_pct
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2;

-- ============================================================
-- 04_conversion_funnel.sql
-- Answers: CJ Q1 — How do users move through the funnel?
--          CJ Q2 — Which landing pages have the highest CVR?
--          CJ Q3 — Average sessions before an order?
-- NOTE: Requires website_sessions & website_pageviews tables
-- ============================================================

-- Q: How do users move through the website funnel?
WITH funnel AS (
    SELECT
        ws.website_session_id,
        MAX(CASE WHEN wp.pageview_url = '/home'          THEN 1 ELSE 0 END) AS saw_home,
        MAX(CASE WHEN wp.pageview_url = '/products'      THEN 1 ELSE 0 END) AS saw_products,
        MAX(CASE WHEN wp.pageview_url LIKE '/the-%'      THEN 1 ELSE 0 END) AS saw_product_detail,
        MAX(CASE WHEN wp.pageview_url = '/cart'          THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN wp.pageview_url = '/shipping'      THEN 1 ELSE 0 END) AS saw_shipping,
        MAX(CASE WHEN wp.pageview_url = '/billing'       THEN 1 ELSE 0 END) AS saw_billing,
        MAX(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS completed_order
    FROM website_sessions ws
    LEFT JOIN website_pageviews wp ON ws.website_session_id = wp.website_session_id
    GROUP BY 1
)
SELECT
    SUM(saw_home)           AS step1_home,
    SUM(saw_products)       AS step2_products,
    SUM(saw_product_detail) AS step3_product_detail,
    SUM(saw_cart)           AS step4_cart,
    SUM(saw_shipping)       AS step5_shipping,
    SUM(saw_billing)        AS step6_billing,
    SUM(completed_order)    AS step7_order_complete,
    ROUND(SUM(saw_products)::NUMERIC       / NULLIF(SUM(saw_home),0)           * 100, 1) AS home_to_products_pct,
    ROUND(SUM(saw_cart)::NUMERIC           / NULLIF(SUM(saw_product_detail),0) * 100, 1) AS detail_to_cart_pct,
    ROUND(SUM(completed_order)::NUMERIC    / NULLIF(SUM(saw_billing),0)        * 100, 1) AS billing_to_order_pct
FROM funnel;

-- Q: Which landing pages have the highest conversion rates?
WITH first_pageview AS (
    SELECT
        website_session_id,
        MIN(website_pageview_id) AS landing_pageview_id
    FROM website_pageviews
    GROUP BY 1
),
landing_pages AS (
    SELECT fp.website_session_id, wp.pageview_url AS landing_page
    FROM first_pageview fp
    JOIN website_pageviews wp ON fp.landing_pageview_id = wp.website_pageview_id
)
SELECT
    lp.landing_page,
    COUNT(DISTINCT lp.website_session_id)               AS sessions,
    COUNT(DISTINCT o.order_id)                          AS orders,
    ROUND(COUNT(DISTINCT o.order_id)::NUMERIC
          / COUNT(DISTINCT lp.website_session_id) * 100, 2) AS conversion_rate_pct
FROM landing_pages lp
LEFT JOIN orders o ON lp.website_session_id = o.website_session_id
GROUP BY 1
ORDER BY sessions DESC;

-- Q: Average number of sessions before an order?
WITH user_sessions AS (
    SELECT
        user_id,
        COUNT(DISTINCT website_session_id)              AS total_sessions,
        MIN(created_at)                                 AS first_session,
        MAX(created_at)                                 AS last_session
    FROM website_sessions
    GROUP BY 1
),
user_orders AS (
    SELECT user_id, MIN(created_at) AS first_order_date
    FROM orders
    GROUP BY 1
)
SELECT
    ROUND(AVG(us.total_sessions), 2)                    AS avg_sessions_per_user,
    ROUND(AVG(CASE WHEN uo.user_id IS NOT NULL
                   THEN us.total_sessions END), 2)      AS avg_sessions_users_who_ordered,
    COUNT(DISTINCT us.user_id)                          AS total_users,
    COUNT(DISTINCT uo.user_id)                          AS users_who_ordered,
    ROUND(COUNT(DISTINCT uo.user_id)::NUMERIC
          / COUNT(DISTINCT us.user_id) * 100, 1)        AS user_conversion_rate_pct
FROM user_sessions us
LEFT JOIN user_orders uo ON us.user_id = uo.user_id;

-- ============================================================
-- 05_revenue_analysis.sql
-- Answers: Revenue Q1 — Revenue & avg revenue/order trend
--          Revenue Q2 — Which products contribute most to profit?
--          Revenue Q3 — How do refunds impact total revenue?
-- ============================================================

-- Q: Which products contribute most to total profit?
SELECT
    p.product_id,
    p.product_name,
    COUNT(DISTINCT oi.order_item_id)                    AS units_sold,
    ROUND(SUM(oi.price_usd), 2)                        AS revenue,
    ROUND(SUM(oi.price_usd) /
          SUM(SUM(oi.price_usd)) OVER () * 100, 1)     AS revenue_share_pct,
    ROUND(SUM(oi.price_usd) - SUM(oi.cogs_usd), 2)    AS gross_profit,
    ROUND((SUM(oi.price_usd) - SUM(oi.cogs_usd))
          / SUM(oi.price_usd) * 100, 1)                AS margin_pct,
    COUNT(DISTINCT r.order_item_refund_id)              AS refund_count,
    ROUND(COUNT(DISTINCT r.order_item_refund_id)::NUMERIC
          / COUNT(DISTINCT oi.order_item_id) * 100, 2) AS refund_rate_pct,
    ROUND(COALESCE(SUM(r.refund_amount_usd), 0), 2)    AS total_refunds,
    ROUND(SUM(oi.price_usd) - SUM(oi.cogs_usd)
          - COALESCE(SUM(r.refund_amount_usd), 0), 2)  AS net_profit
FROM order_items oi
JOIN products p       ON oi.product_id    = p.product_id
LEFT JOIN order_item_refunds r ON oi.order_item_id = r.order_item_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- Q: How do refunds impact total revenue?
SELECT
    ROUND(SUM(o.price_usd), 2)                         AS gross_revenue,
    ROUND(COALESCE(SUM(r.refund_amount_usd), 0), 2)    AS total_refund_amount,
    ROUND(SUM(o.price_usd)
          - COALESCE(SUM(r.refund_amount_usd), 0), 2)  AS net_revenue,
    ROUND(COALESCE(SUM(r.refund_amount_usd), 0)
          / SUM(o.price_usd) * 100, 2)                 AS refund_impact_pct,
    COUNT(DISTINCT r.order_item_refund_id)              AS refund_transactions,
    ROUND(COUNT(DISTINCT r.order_item_refund_id)::NUMERIC
          / COUNT(DISTINCT o.order_id) * 100, 2)       AS refund_order_rate_pct
FROM orders o
LEFT JOIN order_item_refunds r ON o.order_id = r.order_id;

-- Monthly refund trend
SELECT
    DATE_TRUNC('month', r.created_at)::DATE             AS month,
    COUNT(*)                                             AS refunds,
    ROUND(SUM(r.refund_amount_usd), 2)                  AS refund_amount,
    p.product_name
FROM order_item_refunds r
JOIN order_items oi ON r.order_item_id = oi.order_item_id
JOIN products p     ON oi.product_id   = p.product_id
GROUP BY 1, 4
ORDER BY 1, 4;

-- ============================================================
-- 06_cross_sell_analysis.sql
-- Answers: Strategic Q3 — How can marketing budget be optimized?
--          CJ Q2 — Which landing pages / products convert best?
-- ============================================================

-- Q: Items per order distribution
SELECT
    items_purchased,
    COUNT(*)                                            AS order_count,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER() * 100, 1) AS pct_of_total
FROM orders
GROUP BY 1
ORDER BY 1;

-- Q: Top product pairs bought together (cross-sell discovery)
WITH pairs AS (
    SELECT
        a.order_id,
        a.product_id                                    AS product_1_id,
        b.product_id                                    AS product_2_id
    FROM order_items a
    JOIN order_items b
      ON a.order_id    = b.order_id
     AND a.product_id  < b.product_id
)
SELECT
    p1.product_name                                     AS product_1,
    p2.product_name                                     AS product_2,
    COUNT(*)                                            AS times_bought_together,
    ROUND(COUNT(*)::NUMERIC
          / (SELECT COUNT(*) FROM orders) * 100, 2)    AS pct_of_all_orders,
    ROUND(COUNT(*)::NUMERIC
          / (SELECT COUNT(*) FROM orders WHERE items_purchased > 1) * 100, 1) AS pct_of_multi_orders
FROM pairs
JOIN products p1 ON pairs.product_1_id = p1.product_id
JOIN products p2 ON pairs.product_2_id = p2.product_id
GROUP BY 1, 2
ORDER BY times_bought_together DESC;

-- Q: Which product combinations drive highest AOV?
SELECT
    STRING_AGG(p.product_name, ' + ' ORDER BY p.product_id) AS bundle_combo,
    COUNT(DISTINCT o.order_id)                          AS orders_with_combo,
    ROUND(AVG(o.price_usd), 2)                         AS avg_order_value,
    ROUND(SUM(o.price_usd), 2)                         AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id  = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
WHERE o.items_purchased > 1
GROUP BY o.order_id
HAVING COUNT(DISTINCT oi.product_id) >= 2
ORDER BY avg_order_value DESC
LIMIT 20;

-- ============================================================
-- 07_summary_views.sql — Final Reporting Views
-- ============================================================

-- View: Monthly KPI summary
CREATE OR REPLACE VIEW v_monthly_kpis AS
SELECT
    DATE_TRUNC('month', created_at)::DATE               AS month,
    EXTRACT(YEAR  FROM created_at)::INT                  AS year,
    EXTRACT(MONTH FROM created_at)::INT                  AS month_num,
    COUNT(*)                                             AS orders,
    ROUND(SUM(price_usd), 2)                            AS revenue,
    ROUND(SUM(price_usd) - SUM(cogs_usd), 2)           AS gross_profit,
    ROUND((SUM(price_usd)-SUM(cogs_usd))
          / SUM(price_usd) * 100, 1)                   AS margin_pct,
    ROUND(AVG(price_usd), 2)                            AS avg_order_value
FROM orders
GROUP BY 1, 2, 3;

-- View: Product performance summary
CREATE OR REPLACE VIEW v_product_summary AS
SELECT
    p.product_id,
    p.product_name,
    COUNT(DISTINCT oi.order_item_id)                    AS units_sold,
    ROUND(SUM(oi.price_usd), 2)                        AS revenue,
    ROUND((SUM(oi.price_usd)-SUM(oi.cogs_usd))
          / SUM(oi.price_usd) * 100, 1)               AS margin_pct,
    COUNT(DISTINCT r.order_item_refund_id)              AS refund_count,
    ROUND(COUNT(DISTINCT r.order_item_refund_id)::NUMERIC
          / COUNT(DISTINCT oi.order_item_id) * 100, 2) AS refund_rate_pct
FROM order_items oi
JOIN products p       ON oi.product_id    = p.product_id
LEFT JOIN order_item_refunds r ON oi.order_item_id = r.order_item_id
GROUP BY p.product_id, p.product_name;

-- View: Cross-sell pairs
CREATE OR REPLACE VIEW v_cross_sell_pairs AS
SELECT
    p1.product_name                                     AS product_1,
    p2.product_name                                     AS product_2,
    COUNT(*)                                            AS times_together,
    ROUND(COUNT(*)::NUMERIC
          / (SELECT COUNT(*) FROM orders) * 100, 2)    AS pct_of_orders
FROM order_items a
JOIN order_items b  ON a.order_id = b.order_id AND a.product_id < b.product_id
JOIN products p1    ON a.product_id = p1.product_id
JOIN products p2    ON b.product_id = p2.product_id
GROUP BY 1, 2
ORDER BY times_together DESC;
