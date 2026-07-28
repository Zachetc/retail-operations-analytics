SET search_path TO retail;

-- 1. Monthly revenue, profit, and margin trend
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(net_sales) AS revenue,
        SUM(gross_profit) AS gross_profit
    FROM vw_sales_detail
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT
    month,
    revenue,
    gross_profit,
    gross_profit / NULLIF(revenue,0) AS margin_pct,
    revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_change,
    (revenue / NULLIF(LAG(revenue) OVER (ORDER BY month),0)) - 1 AS revenue_growth_pct
FROM monthly
ORDER BY month;

-- 2. Store performance ranking
SELECT
    store_id,
    store_name,
    state,
    SUM(net_sales) AS revenue,
    SUM(gross_profit) AS gross_profit,
    SUM(gross_profit) / NULLIF(SUM(net_sales),0) AS margin_pct,
    RANK() OVER (ORDER BY SUM(gross_profit) DESC) AS profit_rank,
    NTILE(4) OVER (ORDER BY SUM(gross_profit) DESC) AS performance_quartile
FROM vw_sales_detail
WHERE order_status = 'Completed'
GROUP BY store_id, store_name, state
ORDER BY profit_rank;

-- 3. Promotion profitability
SELECT
    COALESCE(pr.promotion_name,'No Promotion') AS promotion,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(v.net_sales) AS revenue,
    SUM(v.gross_profit) AS gross_profit,
    AVG(v.discount_rate) AS avg_discount_rate,
    SUM(v.gross_profit) / NULLIF(SUM(v.net_sales),0) AS margin_pct
FROM vw_sales_detail v
JOIN orders o ON o.order_id = v.order_id
LEFT JOIN promotions pr ON pr.promotion_id = o.promotion_id
WHERE o.order_status = 'Completed'
GROUP BY 1
ORDER BY gross_profit DESC;

-- 4. Supplier risk score
WITH supplier_sales AS (
    SELECT
        p.supplier_id,
        SUM(v.net_sales) AS revenue,
        SUM(v.gross_profit) AS gross_profit
    FROM vw_sales_detail v
    JOIN products p ON p.product_id = v.product_id
    WHERE v.order_status = 'Completed'
    GROUP BY p.supplier_id
),
supplier_returns AS (
    SELECT
        p.supplier_id,
        COUNT(*) AS return_count
    FROM returns r
    JOIN products p ON p.product_id = r.product_id
    GROUP BY p.supplier_id
)
SELECT
    s.supplier_id,
    s.supplier_name,
    s.avg_lead_time_days,
    s.on_time_rate,
    ss.revenue,
    ss.gross_profit,
    COALESCE(sr.return_count,0) AS return_count,
    ROUND(
        (1 - s.on_time_rate) * 50
        + LEAST(s.avg_lead_time_days / 30.0, 1) * 30
        + LEAST(COALESCE(sr.return_count,0) / 100.0, 1) * 20
    ,2) AS supplier_risk_score
FROM suppliers s
LEFT JOIN supplier_sales ss ON ss.supplier_id = s.supplier_id
LEFT JOIN supplier_returns sr ON sr.supplier_id = s.supplier_id
ORDER BY supplier_risk_score DESC;

-- 5. Customer value segmentation
WITH customer_value AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_id) AS order_frequency,
        SUM(net_sales) AS lifetime_revenue,
        SUM(gross_profit) AS lifetime_profit
    FROM vw_sales_detail
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    *,
    NTILE(5) OVER (ORDER BY lifetime_profit DESC) AS value_quintile,
    CASE
        WHEN lifetime_profit >= PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY lifetime_profit) OVER () THEN 'High Value'
        WHEN lifetime_profit >= PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY lifetime_profit) OVER () THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_value_segment
FROM customer_value
ORDER BY lifetime_profit DESC;

-- 6. Products to review for discontinuation
WITH product_perf AS (
    SELECT
        product_id,
        product_name,
        category,
        SUM(quantity) AS units_sold,
        SUM(net_sales) AS revenue,
        SUM(gross_profit) AS gross_profit,
        SUM(gross_profit) / NULLIF(SUM(net_sales),0) AS margin_pct
    FROM vw_sales_detail
    WHERE order_status = 'Completed'
    GROUP BY product_id, product_name, category
),
return_rates AS (
    SELECT product_id, SUM(quantity_returned) AS units_returned
    FROM returns
    GROUP BY product_id
)
SELECT
    pp.*,
    COALESCE(rr.units_returned,0) AS units_returned,
    COALESCE(rr.units_returned,0)::numeric / NULLIF(pp.units_sold,0) AS return_rate,
    CASE
        WHEN pp.margin_pct < 0.15 AND COALESCE(rr.units_returned,0)::numeric / NULLIF(pp.units_sold,0) > 0.10
            THEN 'Discontinue Review'
        WHEN pp.margin_pct < 0.20 THEN 'Pricing Review'
        ELSE 'Healthy'
    END AS recommendation
FROM product_perf pp
LEFT JOIN return_rates rr ON rr.product_id = pp.product_id
ORDER BY gross_profit ASC;
