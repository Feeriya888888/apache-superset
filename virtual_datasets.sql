-- 1. Основной виртуальный датасет для обзора рынка и трендов (ds_crypto_market_overview)
SELECT 
    snapshot_date,
    coin_id,
    UPPER(symbol) AS symbol,
    close_price,
    ma_7_price,
    daily_return_pct,
    price_spread_pct,
    market_cap,
    total_volume,
    -- Коэффициент оборачиваемости (ликвидности)
    ROUND((total_volume / NULLIF(market_cap, 0)) * 100, 2) AS turnover_ratio_pct,
    -- Отклонение от 7-дневной скользящей средней (%)
    ROUND(((close_price - ma_7_price) / NULLIF(ma_7_price, 0)) * 100, 2) AS ma7_deviation_pct,
    market_cap_rank,
    CASE 
        WHEN market_cap_rank <= 5 THEN 'Top-5'
        WHEN market_cap_rank <= 10 THEN 'Top-10'
        ELSE 'Other'
    END AS tier_group
FROM mart.crypto_summary
WHERE snapshot_date >= CURRENT_DATE - INTERVAL '90 days';


-- 2. Виртуальный датасет для матрицы рисков и ликвидности за последние 7 дней (ds_crypto_risk_matrix)
SELECT 
    coin_id,
    UPPER(symbol) AS symbol,
    MAX(market_cap_rank) AS current_rank,
    AVG(market_cap) AS avg_market_cap,
    AVG(total_volume) AS avg_daily_volume,
    ROUND(AVG(price_spread_pct), 2) AS avg_volatility_pct,
    ROUND(AVG((total_volume / NULLIF(market_cap, 0)) * 100), 2) AS avg_turnover_pct,
    ROUND(SUM(daily_return_pct), 2) AS cumulative_7d_return_pct
FROM mart.crypto_summary
WHERE snapshot_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY coin_id, UPPER(symbol);
