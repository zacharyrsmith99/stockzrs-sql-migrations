BEGIN;

CREATE OR REPLACE FUNCTION v2.create_aggregated_tables(asset_type TEXT)
RETURNS VOID AS $$
DECLARE
    intervals TEXT[] := ARRAY['5min', '15min', '1hour'];
    interval_name TEXT;
    create_table_sql TEXT;
    price_precision TEXT;
BEGIN
    CASE 
        WHEN asset_type = 'cryptocurrency' THEN
            price_precision := 'NUMERIC(20, 8)';
        WHEN asset_type = 'currency' THEN
            price_precision := 'NUMERIC(10, 4)';
        ELSE
            price_precision := 'NUMERIC(12, 4)';
    END CASE;

    FOREACH interval_name IN ARRAY intervals LOOP
        create_table_sql := format('
            CREATE TABLE IF NOT EXISTS v2.%I_%s (
                symbol VARCHAR(255) NOT NULL,
                timestamp TIMESTAMP NOT NULL,
                open_price %s NOT NULL,
                high_price %s NOT NULL,
                low_price %s NOT NULL,
                close_price %s NOT NULL,
                PRIMARY KEY (symbol, timestamp)
            )', asset_type, interval_name, price_precision, price_precision, price_precision, price_precision);
        EXECUTE create_table_sql;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION v2.create_update_functions(asset_type TEXT)
RETURNS VOID AS $$
DECLARE
    intervals TEXT[] := ARRAY['5min', '15min', '1hour'];
    interval_name TEXT;
    create_function_sql TEXT;
BEGIN
    FOREACH interval_name IN ARRAY intervals LOOP
        create_function_sql := format('
            CREATE OR REPLACE FUNCTION v2.update_%I_%s(new_symbol TEXT, new_timestamp TIMESTAMP, new_open NUMERIC, new_high NUMERIC, new_low NUMERIC, new_close NUMERIC)
            RETURNS VOID AS $func$
            DECLARE
                interval_start TIMESTAMP;
            BEGIN
                interval_start := date_trunc(''%s'', new_timestamp)' ||
                CASE 
                    WHEN interval_name = '5min' THEN ' + interval ''5 min'' * (extract(minute from new_timestamp)::integer / 5);'
                    WHEN interval_name = '15min' THEN ' + interval ''15 min'' * (extract(minute from new_timestamp)::integer / 15);'
                    WHEN interval_name = '1hour' THEN ';'
                END || '

                INSERT INTO v2.%I_%s (symbol, timestamp, open_price, high_price, low_price, close_price)
                VALUES (new_symbol, interval_start, new_open, new_high, new_low, new_close)
                ON CONFLICT (symbol, timestamp) DO UPDATE
                SET high_price = GREATEST(v2.%I_%s.high_price, EXCLUDED.high_price),
                    low_price = LEAST(v2.%I_%s.low_price, EXCLUDED.low_price),
                    close_price = EXCLUDED.close_price;
            END;
            $func$ LANGUAGE plpgsql;',
            asset_type, interval_name,
            CASE 
                WHEN interval_name = '5min' THEN 'hour'
                WHEN interval_name = '15min' THEN 'hour'
                WHEN interval_name = '1hour' THEN 'hour'
            END,
            asset_type, interval_name, asset_type, interval_name, asset_type, interval_name
        );
        EXECUTE create_function_sql;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION v2.create_all_intervals_update_function(asset_type TEXT)
RETURNS VOID AS
$outer$
DECLARE
    create_function_sql TEXT;
BEGIN
    create_function_sql := format(
$string$
    CREATE OR REPLACE FUNCTION v2.update_%I_all_intervals()
    RETURNS TRIGGER AS
    $func$ 
    BEGIN
        PERFORM v2.update_%I_5min(NEW.symbol, NEW.timestamp, NEW.open_price, NEW.high_price, NEW.low_price, NEW.close_price);
        PERFORM v2.update_%I_15min(NEW.symbol, NEW.timestamp, NEW.open_price, NEW.high_price, NEW.low_price, NEW.close_price);
        PERFORM v2.update_%I_1hour(NEW.symbol, NEW.timestamp, NEW.open_price, NEW.high_price, NEW.low_price, NEW.close_price);
        RETURN NEW;
    END;
    $func$ LANGUAGE plpgsql;
$string$, asset_type, asset_type, asset_type, asset_type);
    EXECUTE create_function_sql;
END;
$outer$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION v2.create_update_trigger(asset_type TEXT, source_table_name TEXT)
RETURNS VOID AS $$
DECLARE
    create_trigger_sql TEXT;
BEGIN
    create_trigger_sql := format('
        CREATE TRIGGER update_%I_all_intervals_trigger
        AFTER INSERT ON v2.%I
        FOR EACH ROW
        EXECUTE FUNCTION v2.update_%I_all_intervals();',
        asset_type, source_table_name, asset_type
    );
    EXECUTE create_trigger_sql;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION v2.insert_initial_data(asset_type TEXT, source_table_name TEXT)
RETURNS VOID AS $$
DECLARE
    intervals TEXT[] := ARRAY['5min', '15min', '1hour'];
    interval_name TEXT;
    insert_data_sql TEXT;
BEGIN
    FOREACH interval_name IN ARRAY intervals LOOP
        insert_data_sql := format('
            INSERT INTO v2.%I_%s
            SELECT DISTINCT ON (symbol, calculated_timestamp)
                symbol,
                date_trunc(''%s'', timestamp)' ||
                CASE 
                    WHEN interval_name = '5min' THEN ' + interval ''5 min'' * (extract(minute from timestamp)::integer / 5)'
                    WHEN interval_name = '15min' THEN ' + interval ''15 min'' * (extract(minute from timestamp)::integer / 15)'
                    ELSE ''
                END || ' AS calculated_timestamp,
                r_open_price,
                max(high_price) OVER w AS high_price,
                min(low_price) OVER w AS low_price,
                r_close_price
            FROM (
                SELECT *,
                       first_value(open_price) OVER w AS r_open_price,
                       last_value(close_price) OVER w AS r_close_price
                FROM v2.%I
                WINDOW w AS (
                    PARTITION BY symbol, 
                    date_trunc(''%s'', timestamp)' ||
                    CASE 
                        WHEN interval_name = '5min' THEN ' + interval ''5 min'' * (extract(minute from timestamp)::integer / 5)'
                        WHEN interval_name = '15min' THEN ' + interval ''15 min'' * (extract(minute from timestamp)::integer / 15)'
                        ELSE ''
                    END || '
                    ORDER BY timestamp
                    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                )
            ) subq
            WINDOW w AS (PARTITION BY symbol, date_trunc(''%s'', timestamp)' ||
            CASE 
                WHEN interval_name = '5min' THEN ' + interval ''5 min'' * (extract(minute from timestamp)::integer / 5)'
                WHEN interval_name = '15min' THEN ' + interval ''15 min'' * (extract(minute from timestamp)::integer / 15)'
                ELSE ''
            END || ')
            ORDER BY symbol, calculated_timestamp, timestamp;',
            asset_type, interval_name,
            CASE 
                WHEN interval_name = '5min' THEN 'hour'
                WHEN interval_name = '15min' THEN 'hour'
                WHEN interval_name = '1hour' THEN 'hour'
            END,
            source_table_name,
            CASE 
                WHEN interval_name = '5min' THEN 'hour'
                WHEN interval_name = '15min' THEN 'hour'
                WHEN interval_name = '1hour' THEN 'hour'
            END,
            CASE 
                WHEN interval_name = '5min' THEN 'hour'
                WHEN interval_name = '15min' THEN 'hour'
                WHEN interval_name = '1hour' THEN 'hour'
            END
        );
        EXECUTE insert_data_sql;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION v2.create_indexes(asset_type TEXT)
RETURNS VOID AS $$
DECLARE
    intervals TEXT[] := ARRAY['5min', '15min', '1hour'];
    interval_name TEXT;
BEGIN
    FOREACH interval_name IN ARRAY intervals LOOP
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_%s_timestamp ON v2.%I_%s(timestamp);', 
                       asset_type, interval_name, asset_type, interval_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_%s_symbol ON v2.%I_%s(symbol);', 
                       asset_type, interval_name, asset_type, interval_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION v2.setup_time_aggregation(source_table_name TEXT)
RETURNS VOID AS $$
DECLARE
    asset_type TEXT;
BEGIN
    asset_type := (
        CASE
            WHEN source_table_name ~ '^(cryptocurrency|currency)_1min$' THEN
                substring(source_table_name from '^(\w+)_1min$')
            WHEN source_table_name ~ '^(market_index|stock|etf)_(pre|main|after)_market_1min$' THEN
                (regexp_match(source_table_name, '^(\w+)_'))[1]
            ELSE
                NULL
        END
    );

    IF asset_type IS NULL THEN
        RAISE EXCEPTION 'Invalid table name format. Expected either "<asset_type>_1min" or "<asset_type>_<market_type>_market_1min"';
    END IF;
    
    PERFORM v2.create_aggregated_tables(asset_type);
    PERFORM v2.create_update_functions(asset_type);
    PERFORM v2.create_all_intervals_update_function(asset_type);
    PERFORM v2.create_update_trigger(asset_type, source_table_name);
    PERFORM v2.insert_initial_data(asset_type, source_table_name);
    PERFORM v2.create_indexes(asset_type);
END;
$$ LANGUAGE plpgsql;

COMMIT;