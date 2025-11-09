# MavenEcom_SQL_Insights
Full SQL analytics project for an E-Commerce store (Maven Fuzzy Factory) — exploring marketing performance, user behavior, and revenue insights.
#  MavenEcom_SQL_Insights
**A Full-Scale SQL Analytics Project for an E-Commerce Business**

---

## Project Overview
This project analyzes the performance of **Maven Fuzzy Factory**, an online store specializing in teddy bears.  
Using real e-commerce data, the project explores marketing performance, user behavior, conversion optimization, and profitability — turning raw data into **actionable business insights**.

---

##  Business Objectives
The analysis aims to support strategic decision-making by answering key questions such as:

1. **Marketing & Traffic**
   - What are the trends in website sessions and order volumes?
   - Which marketing channels are driving the most valuable traffic?
   - How have conversion rates evolved over time?

2. **Revenue & Profitability**
   - What is the trend in total revenue and average revenue per order?
   - Which products contribute most to total profit?
   - How do refunds impact total revenue?

3. **Customer Journey & Behavior**
   - How do users move through the website funnel (session → pageview → order)?
   - Which landing pages have the highest conversion rates?
   - What is the average number of sessions before an order?

4. **Strategic Insights**
   - What changes could improve overall conversion and retention?
   - How can marketing budget allocation be optimized?

---

##  Dataset Description
The dataset contains 6 main tables:

| Table Name | Description |
|-------------|-------------|
| `website_sessions` | All user sessions with traffic source, device, and timestamps |
| `website_pageviews` | Detailed pageview data for each session |
| `orders` | All orders placed on the website |
| `order_items` | Line-item details per order |
| `order_item_refunds` | Information about refunded items |
| `products` | Product catalog including IDs and pricing |

Data Source: [Maven Analytics – Fuzzy Factory E-Commerce Dataset](https://www.mavenanalytics.io/)


