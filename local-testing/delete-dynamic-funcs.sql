DO $$
DECLARE
    asset_types TEXT[] := ARRAY['cryptocurrency', 'stock', 'market', 'currency', 'etf'];
    intervals TEXT[] := ARRAY['5min', '15min', '1hour', '1day'];
    asset_type TEXT;
    interval_name TEXT;
BEGIN
    FOREACH asset_type IN ARRAY asset_types LOOP
        FOREACH interval_name IN ARRAY intervals LOOP
            EXECUTE format('DROP TABLE IF EXISTS %I_%s CASCADE', asset_type, interval_name);
        END LOOP;
    END LOOP;

    FOREACH asset_type IN ARRAY asset_types LOOP
        FOREACH interval_name IN ARRAY intervals LOOP
            EXECUTE format('DROP FUNCTION IF EXISTS update_%I_%s() CASCADE', asset_type, interval_name);
        END LOOP;
    END LOOP;

    FOREACH asset_type IN ARRAY asset_types LOOP
        EXECUTE format('DROP FUNCTION IF EXISTS update_%I_all_intervals() CASCADE', asset_type);
    END LOOP;

    FOREACH asset_type IN ARRAY asset_types LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS update_%I_all_intervals_trigger ON minute_by_minute_%I CASCADE', asset_type, asset_type);
    END LOOP;

    DROP FUNCTION IF EXISTS create_aggregated_tables(TEXT) CASCADE;
    DROP FUNCTION IF EXISTS create_update_functions(TEXT) CASCADE;
    DROP FUNCTION IF EXISTS create_all_intervals_update_function(TEXT) CASCADE;
    DROP FUNCTION IF EXISTS create_update_trigger(TEXT, TEXT) CASCADE;
    DROP FUNCTION IF EXISTS insert_initial_data(TEXT, TEXT) CASCADE;
    DROP FUNCTION IF EXISTS create_indexes(TEXT) CASCADE;
    DROP FUNCTION IF EXISTS setup_time_aggregation(TEXT) CASCADE;

END $$;