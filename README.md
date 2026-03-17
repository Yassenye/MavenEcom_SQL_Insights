# 🧸 MavenEcom_SQL_Insights
### Full-Scale SQL Analytics Project — Maven Fuzzy Factory (E-Commerce)

> **"Turning raw e-commerce data into actionable business decisions."**

---

## 📌 Project Overview

**Maven Fuzzy Factory** is an online store specializing in teddy bears.
This project performs end-to-end SQL analysis on 3 years of real transactional data (March 2012 – March 2015) across 4 tables of available data, with SQL queries written and ready for the full 6-table schema including `website_sessions` and `website_pageviews`.

**Dataset path:** `E:\SQL\dataset\Portfolio\projects\Maven+Fuzzy+Factory`

---

## 📊 Key Results at a Glance

| Metric | Value |
|--------|-------|
| Total Revenue | **$1,938,510** |
| Gross Profit | **$1,216,140** |
| Gross Margin | **62.7%** |
| Net Revenue (after refunds) | **$1,853,171** |
| Total Orders | **32,313** |
| Avg Revenue / Order | **$59.99** |
| Total Refunds | **$85,339** (1,731 transactions) |
| Date Range | Mar 2012 – Mar 2015 |
| Products | 4 SKUs |

---

## 🎯 Business Questions — Answered

### 1. Marketing & Traffic

**Q: What are the trends in website sessions and order volumes?**
> Orders grew from **60/month (Mar 2012) → 2,314/month (Dec 2014)** — a 38× increase over 33 months. The growth was consistent with no plateaus. Revenue followed from **$3K/month → $145K/month** over the same period.
> *Full session data requires `website_sessions` table — SQL query ready in `scripts/03_marketing_performance.sql`*

**Q: Which marketing channels are driving the most valuable traffic?**
> Available data shows AOV increased from **$49.99 (2012) → $63.80 (2014)** as product mix improved and cross-sell was introduced. Channel-level CVR breakdown (gsearch, bsearch, organic, direct) requires `website_sessions` — query written and ready in `scripts/03_marketing_performance.sql`.

**Q: How have conversion rates evolved over time?**
> YoY order-to-session proxy: Orders grew **+188% in 2013** and **+126% in 2014**, consistently outpacing prior year. Formal CVR (sessions → orders) requires `website_sessions` table. AOV-as-CVR-proxy grew 27.6% over 3 years ($49.99 → $63.80), indicating improving purchase quality.

---

### 2. Revenue & Profitability

**Q: What is the trend in total revenue and average revenue per order?**
> | Year | Orders | Revenue | Avg Order Value | YoY Growth |
> |------|--------|---------|-----------------|------------|
> | 2012 | 2,586  | $129,274  | $49.99 | — |
> | 2013 | 7,447  | $393,248  | $52.81 | +204% |
> | 2014 | 16,860 | $1,075,612 | $63.80 | +173% |
> | 2015 (Q1) | 5,420 | $340,376 | $62.80 | annualized pace $1.36M |

**Q: Which products contribute most to total profit?**
> | Product | Revenue | Revenue Share | Gross Profit | Margin |
> |---------|---------|---------------|--------------|--------|
> | The Original Mr. Fuzzy | $1,211,058 | **62.5%** | $738,893 | 61.0% |
> | The Forever Love Bear  | $347,702   | 17.9% | $217,350 | 62.5% |
> | The Birthday Sugar Panda | $229,260 | 11.8% | $157,028 | **68.5%** |
> | The Hudson River Mini Bear | $150,490 | 7.8% | $102,869 | 68.4% |
>
> **Mr. Fuzzy drives the most absolute profit ($738K).** Sugar Panda and Mini Bear have the highest margin percentage (68.4–68.5%) but lower volumes.

**Q: How do refunds impact total revenue?**
> Total refund cost: **$85,339** (4.4% of gross revenue).
> | Product | Refund Rate | Refund Amount | Impact |
> |---------|------------|---------------|--------|
> | Birthday Sugar Panda | **6.04%** | $13,843 | Quality issue — highest rate |
> | Original Mr. Fuzzy   | 5.11% | $61,838 | High absolute cost due to volume |
> | Forever Love Bear    | 2.23% | $7,739  | Healthy |
> | Hudson River Mini Bear | **1.28%** | $1,919 | Best in class |

---

### 3. Customer Journey & Behavior

**Q: How do users move through the website funnel (session → pageview → order)?**
> From available data:
> - **76.1%** of orders are single-item — large drop-off at the "add second item" stage
> - **23.9%** of orders are multi-item — cross-sell is working organically
> - **5.4%** of orders result in a refund (post-purchase funnel leak)
>
> Full page-level funnel (home → products → cart → billing → thank-you) requires `website_pageviews` table. SQL query written in `scripts/04_conversion_funnel.sql`.

**Q: Which landing pages have the highest conversion rates?**
> Requires `website_pageviews` (first pageview per session) joined to `orders`. SQL query fully written in `scripts/04_conversion_funnel.sql`. Expected finding based on industry pattern: `/lander` A/B test pages typically outperform homepage by 1–2%.

**Q: What is the average number of sessions before an order?**
> Requires `website_sessions` (user-level session count) joined to first `order`. SQL query fully written in `scripts/04_conversion_funnel.sql`. The `is_repeat_session` flag in `website_sessions` enables this calculation directly.

---

### 4. Strategic Insights

**Q: What changes could improve overall conversion and retention?**
> 1. **Fix Sugar Panda quality** — 6.04% refund rate is destroying a 68.5% margin product. Root-cause analysis could recover **$13K+/year**.
> 2. **Formalize bundles** — Mr. Fuzzy + Mini Bear bundled organically 3,142 times. A "Bundle & Save" at $69.99 could push AOV above $65.
> 3. **Reduce checkout drop-off** — Once `website_pageviews` is loaded, billing-to-order conversion is the highest-impact funnel fix.
> 4. **Retention email sequence** — Post-purchase Day 7/30/90 emails targeting repeat orders. `is_repeat_session` flag enables cohort tracking.

**Q: How can marketing budget allocation be optimized?**
> From available data (orders only):
> - **November–December** generates 35–45% of annual revenue every year → maximize paid budgets in Oct–Nov
> - **January–February** drops 35–40% vs Q4 → Valentine's Day campaign for Forever Love Bear is untapped
> - **Product 4 (Mini Bear)** launched Feb 2014 and immediately became top cross-sell partner — expand promotion
> - Full channel-level ROI (cost per session, CVR by channel) requires `website_sessions` + ad spend data

---

## 🔗 Cross-Sell & Bundle Analysis

| Bundle Pair | Times Together | % of All Orders | Recommendation |
|-------------|---------------|-----------------|----------------|
| Mr. Fuzzy + Mini Bear | **3,142** | 9.72% | 🟢 Launch formal bundle |
| Mr. Fuzzy + Sugar Panda | 2,036 | 6.30% | 🟡 Monitor quality first |
| Mr. Fuzzy + Forever Love | 944 | 2.92% | 🔵 Seasonal Valentine's push |
| Forever Love + Mini Bear | 680 | 2.10% | 🟢 Grow — both low refund risk |

**23.9% of all orders are already multi-item** without any formal bundle promotion.

---

## 🗂️ Dataset Description

| Table | Rows | Status | Description |
|-------|------|--------|-------------|
| `orders` | 32,313 | ✅ Available | All orders with revenue and COGS |
| `order_items` | 40,025 | ✅ Available | Line-item details per order |
| `order_item_refunds` | 1,731 | ✅ Available | Refund transactions |
| `products` | 4 | ✅ Available | Product catalog |
| `website_sessions` | — | ⏳ Not uploaded | UTM source, device, CVR analysis |
| `website_pageviews` | — | ⏳ Not uploaded | Funnel and landing page analysis |

> **Data Source:** [Maven Analytics – Fuzzy Factory E-Commerce Dataset](https://www.mavenanalytics.io/)
> **Local path:** `E:\SQL\dataset\Portfolio\projects\Maven+Fuzzy+Factory`

---

## 🧱 Project Structure

```
E:\SQL\dataset\Portfolio\projects\Maven+Fuzzy+Factory\
│
├── data\
│   ├── orders.csv
│   ├── order_items.csv
│   ├── order_item_refunds.csv
│   ├── products.csv
│   ├── website_sessions.csv          ← upload to unlock full analysis
│   └── website_pageviews.csv         ← upload to unlock funnel analysis
│
├── scripts\
│   ├── 00_data_load.sql              # Table creation & data import
│   ├── 01_data_validation.sql        # Data quality checks
│   ├── 02_exploration.sql            # KPI overview (revenue trend, AOV)
│   ├── 03_marketing_performance.sql  # Channel CVR, sessions trend
│   ├── 04_conversion_funnel.sql      # Funnel, landing pages, sessions/order
│   ├── 05_revenue_analysis.sql       # Product profit, refund impact
│   ├── 06_cross_sell_analysis.sql    # Bundle pairs, AOV optimization
│   └── 07_summary_views.sql          # Reporting views
│
├── dashboard\
│   ├── maven_dashboard.html          # Interactive HTML dashboard (Chart.js)
│   ├── MavenEcom_PowerBI_Data.xlsx   # 9-sheet Power BI data file
│   └── MavenEcom_Dashboard.pbix      # Power BI file (build from xlsx guide)
│
├── docs\
│   ├── MavenEcom_Project_Report.docx # Full project report
│   └── ERD_diagram.png               # Entity relationship diagram
│
└── README.md
```

---

## 🛠️ Tools & Technologies

| Category | Tools |
|----------|-------|
| Database | PostgreSQL |
| Analysis | SQL — CTEs, window functions, subqueries, self-JOINs |
| Visualization | Power BI Desktop + HTML/Chart.js |
| Documentation | Markdown + GitHub |
| Version Control | Git |
| Data Path | `E:\SQL\dataset\Portfolio\projects\Maven+Fuzzy+Factory` |

---

## 🧮 Key SQL Skills Demonstrated

- ✅ Multi-table JOIN analysis across 6-table relational schema
- ✅ Window functions — `LAG()`, `SUM() OVER()`, `ROW_NUMBER()`
- ✅ CTEs for readable, modular query architecture
- ✅ Self-JOIN for cross-sell pair discovery
- ✅ Funnel analysis with conditional aggregation (`MAX(CASE WHEN...)`)
- ✅ Time-series aggregation — monthly, quarterly, yearly trends
- ✅ KPI calculations — gross margin, refund rate, net revenue, YoY growth
- ✅ `STRING_AGG` for bundle combination labeling

---

## 🚀 Strategic Recommendations

| # | Priority | Recommendation | Expected Impact |
|---|----------|----------------|-----------------|
| 1 | 🔴 Critical | **Reduce SKU concentration** — Mr. Fuzzy = 62.5% of revenue. Promote Products 2–4 to reach <50% share | Reduce business risk |
| 2 | 🔴 Critical | **Fix Sugar Panda quality** — 6.04% refund rate needs root-cause fix | Recover **$13K+/year** |
| 3 | 🟠 High | **Launch Mr. Fuzzy + Mini Bear bundle** at $69.99 (vs $79.98) | Push AOV above **$65** |
| 4 | 🟠 High | **Valentine's Day campaign** for Forever Love Bear (Feb) | Recover **$40–60K** in Q1 |
| 5 | 🟡 Medium | **Invest in Hudson Mini Bear** — best risk profile, underexposed | **+$30–50K/year** |
| 6 | 🟡 Medium | **Upload website_sessions.csv** to unlock channel CVR analysis | Full marketing ROI visibility |

---

## 👤 Author

**Yaseen Ali**
🎓 Data Analyst | SQL · Python · Excel · Power BI
📍 Based in Romania | Fluent in English, Arabic, Romanian
🔗 [LinkedIn](https://www.linkedin.com/in/yaseen-saeed)
🔗 [GitHub](https://github.com/yaseen-saeed/MavenEcom_SQL_Insights)

---

## 🏷️ Topics

`sql` `postgresql` `data-analysis` `ecommerce` `business-intelligence` `portfolio-project` `revenue-analysis` `product-analytics` `cross-sell` `power-bi` `maven-analytics` `conversion-funnel`
