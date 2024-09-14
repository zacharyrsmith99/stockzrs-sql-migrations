BEGIN;

CREATE TABLE IF NOT EXISTS minute_by_minute_cryptocurrency (
    symbol VARCHAR(255) NOT NULL
    , timestamp TIMESTAMP NOT NULL
    , open_price NUMERIC(10, 4) NOT NULL
    , high_price NUMERIC(10, 4) NOT NULL
    , low_price NUMERIC(10, 4) NOT NULL
    , close_price NUMERIC(10, 4) NOT NULL 
    , PRIMARY KEY (symbol, timestamp)
);

CREATE INDEX idx_cryptocurrency_timestamp ON minute_by_minute_cryptocurrency(timestamp);
CREATE INDEX idx_cryptocurrency_symbol ON minute_by_minute_cryptocurrency(symbol);

CREATE TABLE IF NOT EXISTS minute_by_minute_market_index (
    symbol VARCHAR(255) NOT NULL
    , timestamp TIMESTAMP NOT NULL
    , open_price NUMERIC(10, 4) NOT NULL
    , high_price NUMERIC(10, 4) NOT NULL
    , low_price NUMERIC(10, 4) NOT NULL
    , close_price NUMERIC(10, 4) NOT NULL
    , PRIMARY KEY (symbol, timestamp)
);

CREATE INDEX idx_market_index_timestamp ON minute_by_minute_market_index(timestamp);
CREATE INDEX idx_market_index_symbol ON minute_by_minute_market_index(symbol);

CREATE TABLE IF NOT EXISTS minute_by_minute_currency (
    symbol VARCHAR(255) NOT NULL
    , timestamp TIMESTAMP NOT NULL
    , open_price NUMERIC(10, 4) NOT NULL
    , high_price NUMERIC(10, 4) NOT NULL
    , low_price NUMERIC(10, 4) NOT NULL
    , close_price NUMERIC(10, 4) NOT NULL
    , PRIMARY KEY (symbol, timestamp)
);

CREATE INDEX idx_currency_timestamp ON minute_by_minute_currency(timestamp);
CREATE INDEX idx_currency_symbol ON minute_by_minute_currency(symbol);

CREATE TABLE IF NOT EXISTS minute_by_minute_stock (
    symbol VARCHAR(255) NOT NULL
    , timestamp TIMESTAMP NOT NULL
    , open_price NUMERIC(10, 4) NOT NULL
    , high_price NUMERIC(10, 4) NOT NULL
    , low_price NUMERIC(10, 4) NOT NULL
    , close_price NUMERIC(10, 4) NOT NULL
    , PRIMARY KEY (symbol, timestamp)
);

CREATE INDEX idx_stock_timestamp ON minute_by_minute_stock(timestamp);
CREATE INDEX idx_stock_symbol ON minute_by_minute_stock(symbol);

CREATE TABLE IF NOT EXISTS minute_by_minute_etf (
    symbol VARCHAR(255) NOT NULL
    , timestamp TIMESTAMP NOT NULL
    , open_price NUMERIC(10, 4) NOT NULL
    , high_price NUMERIC(10, 4) NOT NULL
    , low_price NUMERIC(10, 4) NOT NULL
    , close_price NUMERIC(10, 4) NOT NULL
    , PRIMARY KEY (symbol, timestamp)
);

CREATE INDEX idx_etf_timestamp ON minute_by_minute_etf(timestamp);
CREATE INDEX idx_etf_symbol ON minute_by_minute_etf(symbol);

COMMIT;
