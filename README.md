# SQL Sales Analysis Project

A hands-on SQL project built to demonstrate core data analyst skills using a realistic retail sales dataset. All queries run in **SQLite** — no server setup required.

---

## Dataset

**Superstore-style Sales Data** — 2,000 order line items across 4 years (2021–2024), covering:
- 4 US regions (West, East, South, Central)
- 3 product categories (Technology, Furniture, Office Supplies)
- 200+ unique customers across 3 segments (Consumer, Corporate, Home Office)

**Schema:**

| Column | Type | Description |
|--------|------|-------------|
| `order_id` | TEXT | Unique order identifier |
| `order_date` | TEXT | Date of purchase (YYYY-MM-DD) |
| `ship_date` | TEXT | Date shipped |
| `ship_mode` | TEXT | Shipping class (Standard, First Class, etc.) |
| `customer_id` | TEXT | Unique customer ID |
| `customer_name` | TEXT | Full name |
| `segment` | TEXT | Customer segment |
| `state` | TEXT | US state |
| `region` | TEXT | US region |
| `category` | TEXT | Product category |
| `sub_category` | TEXT | Product sub-category |
| `sales` | REAL | Revenue from line item |
| `quantity` | INTEGER | Units sold |
| `discount` | REAL | Discount applied (0 to 0.5) |
| `profit` | REAL | Profit from line item |

---

## Setup — 3 Steps

### Option A: DB Browser for SQLite (Recommended for Beginners)
1. Download [DB Browser for SQLite](https://sqlitebrowser.org/dl/) (free, no account needed)
2. Open `sales_analysis.db` directly in the app
3. Click **Execute SQL** tab → paste any query from `queries.sql` → Run

### Option B: Python (if you prefer code)
```bash
pip install pandas
python3 load_data.py    # re-creates the DB from CSV if needed
```

### Option C: SQLite CLI
```bash
sqlite3 sales_analysis.db
.mode column
.headers on
-- paste any query below
```

---

## Queries & Business Insights

### Query 1 — Basic SELECT + WHERE + ORDER BY
**File:** `queries.sql` → Q1

**Goal:** Find the 10 most profitable orders in the West region.

```sql
SELECT order_id, customer_name, product_name, category,
       ROUND(sales, 2) AS sales, ROUND(profit, 2) AS profit, order_date
FROM orders
WHERE region = 'West'
  AND profit > 0
ORDER BY profit DESC
LIMIT 10;
```

**Insight:** Technology products (Phones, Copiers, Machines) dominate the top profitable orders, confirming they are the highest-margin category in the West.

---

### Query 2 — GROUP BY with Aggregation (Regional Performance)
**File:** `queries.sql` → Q2

**Goal:** Compare total sales, orders, and profit margin across all 4 regions.

```sql
SELECT region,
       COUNT(DISTINCT order_id)              AS total_orders,
       ROUND(SUM(sales), 2)                  AS total_sales,
       ROUND(SUM(profit), 2)                 AS total_profit,
       ROUND(SUM(profit)/SUM(sales)*100, 1)  AS profit_margin_pct
FROM orders
GROUP BY region
ORDER BY total_sales DESC;
```

**Insight:** South leads in revenue, but Central has the highest profit margin (13.7%) — meaning it generates more value per dollar sold despite lower volume.

---

### Query 3 — GROUP BY with Two Levels (Category & Sub-Category)
**File:** `queries.sql` → Q3

**Goal:** Break down sales and profit by category and sub-category to find the best-performing product lines.

```sql
SELECT category, sub_category,
       COUNT(*) AS order_lines,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(AVG(sales), 2)  AS avg_sale,
       ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY category, sub_category
ORDER BY category, total_sales DESC;
```

**Insight:** Technology sub-categories (Copiers, Phones, Machines, Accessories) all generate $700K+ in sales individually, far outpacing the entire Office Supplies category combined.

---

### Query 4 — Subquery: High-Value Customers Above Average
**File:** `queries.sql` → Q4

**Goal:** Identify customers whose average order value exceeds the overall average — the "VIP" segment.

```sql
SELECT customer_id, customer_name, segment,
       COUNT(DISTINCT order_id)  AS num_orders,
       ROUND(SUM(sales), 2)      AS total_spent,
       ROUND(AVG(sales), 2)      AS avg_order_value
FROM orders
GROUP BY customer_id, customer_name, segment
HAVING AVG(sales) > (
    SELECT AVG(sales) FROM orders   -- ← scalar subquery
)
ORDER BY avg_order_value DESC
LIMIT 15;
```

**Insight:** High-value customers span all three segments (Consumer, Corporate, Home Office), suggesting that upselling potential is not limited to corporate accounts.

---

### Query 5 — Date Filter: Monthly Sales Trend with Window Function
**File:** `queries.sql` → Q5

**Goal:** Track month-over-month revenue changes throughout 2023.

```sql
SELECT strftime('%Y-%m', order_date) AS year_month,
       COUNT(DISTINCT order_id)       AS orders,
       ROUND(SUM(sales), 2)           AS monthly_sales,
       ROUND(SUM(profit), 2)          AS monthly_profit,
       ROUND(SUM(sales) - LAG(SUM(sales),1) OVER (
           ORDER BY strftime('%Y-%m', order_date)), 2) AS mom_change
FROM orders
WHERE strftime('%Y', order_date) = '2023'
GROUP BY year_month
ORDER BY year_month;
```

**Insight:** Sales peak in Q1 (Feb–Mar) and Q4 (Oct), with notable dips in April and November — a classic retail seasonality pattern suggesting holiday and new-year purchasing spikes.

---

### Query 6 — Discount Impact on Profit Margin
**File:** `queries.sql` → Q6

**Goal:** Measure how different discount tiers affect profitability.

```sql
SELECT
    CASE
        WHEN discount = 0      THEN '0% – No Discount'
        WHEN discount <= 0.10  THEN '1–10%'
        WHEN discount <= 0.20  THEN '11–20%'
        WHEN discount <= 0.30  THEN '21–30%'
        ELSE                        '31%+'
    END                                      AS discount_tier,
    COUNT(*)                                 AS num_orders,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100, 1)     AS profit_margin_pct
FROM orders
GROUP BY discount_tier
ORDER BY profit_margin_pct DESC;
```

**Insight:** Orders with **no discount** yield the highest margin (13.4%), and margin drops progressively with higher discounts — confirming that discount strategy needs careful management to protect profitability.

---

## Skills Demonstrated

| SQL Concept | Query |
|-------------|-------|
| SELECT, WHERE, ORDER BY, LIMIT | Q1 |
| GROUP BY + aggregate functions (SUM, AVG, COUNT) | Q2, Q3 |
| Multi-level GROUP BY | Q3 |
| Subquery (scalar, in HAVING clause) | Q4 |
| Date filtering with `strftime()` | Q5 |
| Window function (`LAG` for period-over-period) | Q5 |
| CASE WHEN for custom bucketing | Q6 |

---

## Files

```
sql-sales-analysis/
├── README.md                  ← This file
├── superstore_sales.csv       ← Raw dataset (2,000 rows)
├── sales_analysis.db          ← SQLite database (ready to open)
├── queries.sql                ← All 6 queries in one file
└── load_data.py               ← Script to recreate DB from CSV
```

---

*Project by Zahra Ahmadi | [github.com/zahraahmadi12](https://github.com/zahraahmadi12)*
