BEGIN;

CREATE OR REPLACE FUNCTION create_aggregated_tables(asset_type TEXT)
RETURNS VOID AS $$
DECLARE
    intervals TEXT[] := ARRAY['5min', '15min', '1hour', '1day'];
    interval_name TEXT;
    create_table_sql TEXT;
BEGIN
    FOREACH interval_name IN ARRAY intervals LOOP
        create_table_sql := format('
            CREATE TABLE IF NOT EXISTS %I_%s (
                symbol VARCHAR(255) NOT NULL,
                timestamp TIMESTAMP NOT NULL,
                open_price NUMERIC(10, 4) NOT NULL,
                high_price NUMERIC(10, 4) NOT NULL,
                low_price NUMERIC(10, 4) NOT NULL,
                close_price NUMERIC(10, 4) NOT NULL,
                PRIMARY KEY (symbol, timestamp)
            )', asset_type, interval_name);
        EXECUTE create_table_sql;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_update_functions(asset_type TEXT)
RETURNS VOID AS $$
DECLARE
    intervals TEXT[] := ARRAY['5min', '15min', '1hour', '1day'];
    interval_name TEXT;
    create_function_sql TEXT;
BEGIN
    FOREACH interval_name IN ARRAY intervals LOOP
        create_function_sql := format('
            CREATE OR REPLACE FUNCTION update_%I_%s(new_symbol TEXT, new_timestamp TIMESTAMP, new_open NUMERIC, new_high NUMERIC, new_low NUMERIC, new_close NUMERIC)
            RETURNS VOID AS $func$
            DECLARE
                interval_start TIMESTAMP;
            BEGIN
                interval_start := date_trunc(''%s'', new_timestamp)' ||
                CASE 
                    WHEN interval_name = '5min' THEN ' + interval ''5 min'' * (extract(minute from new_timestamp)::integer / 5);'
                    WHEN interval_name = '15min' THEN ' + interval ''15 min'' * (extract(minute from new_timestamp)::integer / 15);'
                    WHEN interval_name = '1hour' THEN ';'
                    WHEN interval_name = '1day' THEN ';'
                END || '

                INSERT INTO %I_%s (symbol, timestamp, open_price, high_price, low_price, close_price)
                VALUES (new_symbol, interval_start, new_open, new_high, new_low, new_close)
                ON CONFLICT (symbol, timestamp) DO UPDATE
                SET high_price = GREATEST(%I_%s.high_price, EXCLUDED.high_price),
                    low_price = LEAST(%I_%s.low_price, EXCLUDED.low_price),
                    close_price = EXCLUDED.close_price;
            END;
            $func$ LANGUAGE plpgsql;',
            asset_type, interval_name,
            CASE 
                WHEN interval_name = '5min' THEN 'hour'
                WHEN interval_name = '15min' THEN 'hour'
                WHEN interval_name = '1hour' THEN 'hour'
                WHEN interval_name = '1day' THEN 'day'
            END,
            asset_type, interval_name, asset_type, interval_name, asset_type, interval_name
        );
        EXECUTE create_function_sql;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_all_intervals_update_function(asset_type TEXT)
RETURNS VOID AS
$outer$
DECLARE
    create_function_sql TEXT;
BEGIN
    create_function_sql := format(
$string$
    CREATE OR REPLACE FUNCTION update_%I_all_intervals()
    RETURNS TRIGGER AS
    $func$ 
    BEGIN
        PERFORM update_%I_5min(NEW.symbol, NEW.timestamp, NEW.open_price, NEW.high_price, NEW.low_price, NEW.close_price);
        PERFORM update_%I_15min(NEW.symbol, NEW.timestamp, NEW.open_price, NEW.high_price, NEW.low_price, NEW.close_price);
        PERFORM update_%I_1hour(NEW.symbol, NEW.timestamp, NEW.open_price, NEW.high_price, NEW.low_price, NEW.close_price);
        PERFORM update_%I_1day(NEW.symbol, NEW.timestamp, NEW.open_price, NEW.high_price, NEW.low_price, NEW.close_price);
        RETURN NEW;
    END;
    $func$ LANGUAGE plpgsql;
$string$, asset_type, asset_type, asset_type, asset_type, asset_type);
    EXECUTE create_function_sql;
END;
$outer$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_update_trigger(asset_type TEXT, source_table_name TEXT)
RETURNS VOID AS $$
DECLARE
    create_trigger_sql TEXT;
BEGIN
    create_trigger_sql := format('
        CREATE TRIGGER update_%I_all_intervals_trigger
        AFTER INSERT ON %I
        FOR EACH ROW
        EXECUTE FUNCTION update_%I_all_intervals();',
        asset_type, source_table_name, asset_type
    );
    EXECUTE create_trigger_sql;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_initial_data(asset_type TEXT, source_table_name TEXT)
RETURNS VOID AS $$
DECLARE
    intervals TEXT[] := ARRAY['5min', '15min', '1hour', '1day'];
    interval_name TEXT;
    insert_data_sql TEXT;
BEGIN
    FOREACH interval_name IN ARRAY intervals LOOP
        insert_data_sql := format('
            INSERT INTO %I_%s
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
                FROM %I
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
                WHEN interval_name = '1day' THEN 'day'
            END,
            source_table_name,
            CASE 
                WHEN interval_name = '5min' THEN 'hour'
                WHEN interval_name = '15min' THEN 'hour'
                WHEN interval_name = '1hour' THEN 'hour'
                WHEN interval_name = '1day' THEN 'day'
            END,
            CASE 
                WHEN interval_name = '5min' THEN 'hour'
                WHEN interval_name = '15min' THEN 'hour'
                WHEN interval_name = '1hour' THEN 'hour'
                WHEN interval_name = '1day' THEN 'day'
            END
        );
        EXECUTE insert_data_sql;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_indexes(asset_type TEXT)
RETURNS VOID AS $$
DECLARE
    intervals TEXT[] := ARRAY['5min', '15min', '1hour', '1day'];
    interval_name TEXT;
BEGIN
    FOREACH interval_name IN ARRAY intervals LOOP
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_%s_timestamp ON %I_%s(timestamp);', 
                       asset_type, interval_name, asset_type, interval_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_%s_symbol ON %I_%s(symbol);', 
                       asset_type, interval_name, asset_type, interval_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION setup_time_aggregation(source_table_name TEXT)
RETURNS VOID AS $$
DECLARE
    asset_type TEXT;
BEGIN
    asset_type := substring(source_table_name from 'minute_by_minute_(.*)');
    
    IF asset_type IS NULL THEN
        RAISE EXCEPTION 'Invalid table name format. Expected "minute_by_minute_<asset_type>"';
    END IF;
    
    PERFORM create_aggregated_tables(asset_type);
    PERFORM create_update_functions(asset_type);
    PERFORM create_all_intervals_update_function(asset_type);
    PERFORM create_update_trigger(asset_type, source_table_name);
    PERFORM insert_initial_data(asset_type, source_table_name);
    PERFORM create_indexes(asset_type);
END;
$$ LANGUAGE plpgsql;

COMMIT;