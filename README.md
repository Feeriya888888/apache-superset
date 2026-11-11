 Crypto Market Analytics Dashboard (Apache Superset + PostgreSQL)

Комплексный BI-проект, демонстрирующий построение семантического слоя, настройку виртуальных датасетов и разработку аналитического дашборда в **Apache Superset** поверх витрин данных **PostgreSQL 17**.

## 1. Архитектура решения

```
[ PostgreSQL 17 (mart.crypto_summary) ]
                 │
                 ▼ (SQLAlchemy: psycopg2)
[ Apache Superset (Semantic Layer & Virtual Datasets) ]
                 │
                 ▼
[ Executive Dashboard: Volatility & Liquidity ]
```

## 2. Решённые бизнес-задачи
* **Мониторинг трендов:** Отслеживание отклонения текущей цены закрытия от 7-дневной скользящей средней (`MA_7`) для поиска точек перекупленности и перепроданности.
* **Оценка ликвидности:** Расчёт коэффициента оборачиваемости капитала (`Turnover Ratio = Volume / Market Cap`).
* **Анализ волатильности:** Визуализация внутридневного размаха цен (`Price Spread %`) в связке с объёмом торгов.

## 3. Структура проекта
* `README.md` — документация проекта, описание метрик и инструкция запуска.
* `docker-compose.yml` — конфигурация для локального развёртывания Apache Superset с автоматической инициализацией БД и администратора.
* `virtual_datasets.sql` — SQL-запросы для создания виртуальных датасетов и витрин в Superset SQL Lab.
* `dashboard_config.yaml` — декларативная конфигурация метаданных дашборда для импорта.

## 4. Пошаговая инструкция запуска

1. Убедитесь, что база данных PostgreSQL с витриной `mart.crypto_summary` запущена (из предыдущего ETL-пайплайна).
2. Поднимите контейнер Apache Superset:
   ```bash
   docker-compose up -d
   ```
3. Откройте веб-интерфейс по адресу `http://localhost:8088` и войдите под учётной записью `admin` / `admin`.
4. Перейдите в **Settings -> Database Connections -> + Database**, выберите **PostgreSQL** и укажите строку подключения:
   ```text
   postgresql+psycopg2://postgres:postgres@host.docker.internal:5432/dwh
   ```
5. Откройте **SQL Lab**, выполните запросы из файла `virtual_datasets.sql` и сохраните их как виртуальные датасеты (**Save -> Save dataset**).
6. Импортируйте конфигурацию дашборда или соберите виджеты по описанию ниже.

## 5. Семантический слой и метрики

### Настроенные расчётные метрики (Calculated Metrics)
* **Avg Volatility (Spread %):** `AVG(price_spread_pct)` — средний дневной размах цены.
* **Liquidity Turnover (%):** `SUM(total_volume) / NULLIF(SUM(market_cap), 0) * 100` — оборачиваемость капитализации.
* **Price vs MA7 Deviation (%):** `AVG((close_price - ma_7_price) / NULLIF(ma_7_price, 0) * 100)` — отклонение от скользящей средней.

### Виджеты дашборда
1. **Total Market Cap ($)** — Big Number with Trendline.
2. **24h Trading Volume ($)** — Big Number with Trendline.
3. **Avg Daily Volatility (%)** — Big Number.
4. **Price vs MA7 Trend** — Time-series Line Chart.
5. **Risk / Liquidity Matrix** — Bubble Chart (`Spread %` vs `Turnover %`, размер — `Market Cap`).
6. **Market Summary Table** — Pivot Table с условным форматированием дневной доходности.
