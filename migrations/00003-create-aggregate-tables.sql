BEGIN;

-- Cryptocurrency
SELECT v2.setup_time_aggregation('cryptocurrency_1min');

-- Stock (for pre-market, main-market, and after-market)
SELECT v2.setup_time_aggregation('stock_pre_market_1min');
SELECT v2.setup_time_aggregation('stock_main_market_1min');
SELECT v2.setup_time_aggregation('stock_after_market_1min');

-- Market Index (for pre-market, main-market, and after-market)
SELECT v2.setup_time_aggregation('market_index_pre_market_1min');
SELECT v2.setup_time_aggregation('market_index_main_market_1min');
SELECT v2.setup_time_aggregation('market_index_after_market_1min');

-- Currency
SELECT v2.setup_time_aggregation('currency_1min');

-- ETF (for pre-market, main-market, and after-market)
SELECT v2.setup_time_aggregation('etf_pre_market_1min');
SELECT v2.setup_time_aggregation('etf_main_market_1min');
SELECT v2.setup_time_aggregation('etf_after_market_1min');

COMMIT;