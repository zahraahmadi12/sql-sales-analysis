-- =============================================
-- Q1
-- =============================================
-- Query 1: Top 10 most profitable orders in the West region
-- Insight: Identifies high-value transactions to understand what drives profitability in the West
SELECT
    order_id,
    customer_name,
    product_name,
    category,
    ROUND(sales, 2)  AS sales,
    ROUND(profit, 2) AS profit,
    order_date
FROM orders
WHERE region = 'West'
  AND profit > 0
ORDER BY profit DESC
LIMIT 10;

-- =============================================
-- Q2
-- =============================================
-- Query 2: Total sales and profit by region, ranked by revenue
-- Insight: Reveals which regions generate the most revenue and which are most profitable
SELECT
    region,
    COUNT(DISTINCT order_id)      AS total_orders,
    SUM(quantity)                  AS units_sold,
    ROUND(SUM(sales), 2)           AS total_sales,
    ROUND(SUM(profit), 2)          AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100, 1) AS profit_margin_pct
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

-- =============================================
-- Q3
-- =============================================
-- Query 3: Sales breakdown by category and sub-category
-- Insight: Pinpoints which product lines contribute most to revenue within each category
SELECT
    category,
    sub_category,
    COUNT(*)                 AS order_lines,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(AVG(sales), 2)     AS avg_sale,
    ROUND(SUM(profit), 2)    AS total_profit
FROM orders
GROUP BY category, sub_category
ORDER BY category, total_sales DESC;

-- =============================================
-- Q4
-- =============================================
-- Query 4: Customers whose average order value exceeds the overall average (subquery)
-- Insight: Segments high-value customers worth targeting for retention or upselling
SELECT
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id)     AS num_orders,
    ROUND(SUM(sales), 2)         AS total_spent,
    ROUND(AVG(sales), 2)         AS avg_order_value
FROM orders
GROUP BY customer_id, customer_name, segment
HAVING AVG(sales) > (
    SELECT AVG(sales) FROM orders
)
ORDER BY avg_order_value DESC
LIMIT 15;

-- =============================================
-- Q5
-- =============================================
-- Query 5: Monthly sales trend for 2023 with month-over-month change
-- Insight: Tracks seasonal patterns to identify peak selling periods
SELECT
    strftime('%Y-%m', order_date)       AS year_month,
    COUNT(DISTINCT order_id)             AS orders,
    ROUND(SUM(sales), 2)                 AS monthly_sales,
    ROUND(SUM(profit), 2)                AS monthly_profit,
    ROUND(SUM(sales) - LAG(SUM(sales), 1) OVER (ORDER BY strftime('%Y-%m', order_date)), 2) AS mom_change
FROM orders
WHERE strftime('%Y', order_date) = '2023'
GROUP BY year_month
ORDER BY year_month;

-- =============================================
-- Q6
-- =============================================
-- Query 6: Discount impact analysis — how discount tiers affect profit margin
-- Insight: Quantifies whether heavy discounting hurts profitability (often critical for business decisions)
SELECT
    CASE
        WHEN discount = 0        THEN '0% – No Discount'
        WHEN discount <= 0.10    THEN '1–10%'
        WHEN discount <= 0.20    THEN '11–20%'
        WHEN discount <= 0.30    THEN '21–30%'
        ELSE                          '31%+'
    END                              AS discount_tier,
    COUNT(*)                         AS num_orders,
    ROUND(SUM(sales), 2)             AS total_sales,
    ROUND(SUM(profit), 2)            AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100, 1) AS profit_margin_pct
FROM orders
GROUP BY discount_tier
ORDER BY profit_margin_pct DESC;

