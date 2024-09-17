DO $$
DECLARE
    asset_types TEXT[] := ARRAY['cryptocurrency', 'stock', 'market_index', 'currency', 'etf'];
    market_types TEXT[] := ARRAY['pre_market', 'main_market', 'after_market'];
    intervals TEXT[] := ARRAY['5min', '15min', '1hour'];
    asset_type TEXT;
    market_type TEXT;
    interval_name TEXT;
    full_asset_type TEXT;
BEGIN
    FOREACH asset_type IN ARRAY asset_types LOOP
        IF asset_type IN ('cryptocurrency', 'currency') THEN
            FOREACH interval_name IN ARRAY intervals LOOP
                EXECUTE format('DROP TABLE IF EXISTS v2.%I_%s CASCADE', asset_type, interval_name);
            END LOOP;
        ELSE
            FOREACH market_type IN ARRAY market_types LOOP
                FOREACH interval_name IN ARRAY intervals LOOP
                    EXECUTE format('DROP TABLE IF EXISTS v2.%I_%s_%s CASCADE', asset_type, market_type, interval_name);
                END LOOP;
            END LOOP;
        END IF;
    END LOOP;

    FOREACH asset_type IN ARRAY asset_types LOOP
        IF asset_type IN ('cryptocurrency', 'currency') THEN
            FOREACH interval_name IN ARRAY intervals LOOP
                EXECUTE format('DROP FUNCTION IF EXISTS v2.update_%I_%s(TEXT, TIMESTAMP, NUMERIC, NUMERIC, NUMERIC, NUMERIC) CASCADE', asset_type, interval_name);
            END LOOP;
        ELSE
            FOREACH market_type IN ARRAY market_types LOOP
                FOREACH interval_name IN ARRAY intervals LOOP
                    EXECUTE format('DROP FUNCTION IF EXISTS v2.update_%I_%s_%s(TEXT, TIMESTAMP, NUMERIC, NUMERIC, NUMERIC, NUMERIC) CASCADE', asset_type, market_type, interval_name);
                END LOOP;
            END LOOP;
        END IF;
    END LOOP;

    FOREACH asset_type IN ARRAY asset_types LOOP
        IF asset_type IN ('cryptocurrency', 'currency') THEN
            EXECUTE format('DROP FUNCTION IF EXISTS v2.update_%I_all_intervals() CASCADE', asset_type);
        ELSE
            FOREACH market_type IN ARRAY market_types LOOP
                EXECUTE format('DROP FUNCTION IF EXISTS v2.update_%I_%s_all_intervals() CASCADE', asset_type, market_type);
            END LOOP;
        END IF;
    END LOOP;

    FOREACH asset_type IN ARRAY asset_types LOOP
        IF asset_type IN ('cryptocurrency', 'currency') THEN
            full_asset_type := asset_type || '_1min';
            EXECUTE format('DROP TRIGGER IF EXISTS update_%I_all_intervals_trigger ON v2.%I CASCADE', asset_type, full_asset_type);
        ELSE
            FOREACH market_type IN ARRAY market_types LOOP
                full_asset_type := asset_type || '_' || market_type || '_1min';
                EXECUTE format('DROP TRIGGER IF EXISTS update_%I_%s_all_intervals_trigger ON v2.%I CASCADE', asset_type, market_type, full_asset_type);
            END LOOP;
        END IF;
    END LOOP;

    DROP FUNCTION IF EXISTS v2.create_aggregated_tables(TEXT) CASCADE;
    DROP FUNCTION IF EXISTS v2.create_update_functions(TEXT) CASCADE;
    DROP FUNCTION IF EXISTS v2.create_all_intervals_update_function(TEXT) CASCADE;
    DROP FUNCTION IF EXISTS v2.create_update_trigger(TEXT, TEXT) CASCADE;
    DROP FUNCTION IF EXISTS v2.insert_initial_data(TEXT, TEXT) CASCADE;
    DROP FUNCTION IF EXISTS v2.create_indexes(TEXT) CASCADE;
    DROP FUNCTION IF EXISTS v2.setup_time_aggregation(TEXT) CASCADE;

    FOREACH asset_type IN ARRAY asset_types LOOP
        IF asset_type IN ('cryptocurrency', 'currency') THEN
            EXECUTE format('DROP TABLE IF EXISTS v2.%I_1min CASCADE', asset_type);
        ELSE
            FOREACH market_type IN ARRAY market_types LOOP
                EXECUTE format('DROP TABLE IF EXISTS v2.%I_%s_1min CASCADE', asset_type, market_type);
            END LOOP;
        END IF;
    END LOOP;

END $$;