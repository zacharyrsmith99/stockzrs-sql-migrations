BEGIN;

SELECT setup_time_aggregation('minute_by_minute_cryptocurrency');
SELECT setup_time_aggregation('minute_by_minute_stock');
SELECT setup_time_aggregation('minute_by_minute_market_index');
SELECT setup_time_aggregation('minute_by_minute_currency');
SELECT setup_time_aggregation('minute_by_minute_etf');

COMMIT;