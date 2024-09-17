BEGIN;

CREATE SCHEMA IF NOT EXISTS v2;

CREATE TABLE IF NOT EXISTS v2.cryptocurrency_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(20, 8) NOT NULL,
    high_price NUMERIC(20, 8) NOT NULL,
    low_price NUMERIC(20, 8) NOT NULL,
    close_price NUMERIC(20, 8) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_cryptocurrency_timestamp ON v2.cryptocurrency_1min(timestamp);
CREATE INDEX idx_cryptocurrency_symbol ON v2.cryptocurrency_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.market_index_pre_market_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(12, 4) NOT NULL,
    high_price NUMERIC(12, 4) NOT NULL,
    low_price NUMERIC(12, 4) NOT NULL,
    close_price NUMERIC(12, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_market_index_pre_market_timestamp ON v2.market_index_pre_market_1min(timestamp);
CREATE INDEX idx_market_index_pre_market_symbol ON v2.market_index_pre_market_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.market_index_main_market_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(12, 4) NOT NULL,
    high_price NUMERIC(12, 4) NOT NULL,
    low_price NUMERIC(12, 4) NOT NULL,
    close_price NUMERIC(12, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_market_index_main_market_timestamp ON v2.market_index_main_market_1min(timestamp);
CREATE INDEX idx_market_index_main_market_symbol ON v2.market_index_main_market_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.market_index_after_market_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(12, 4) NOT NULL,
    high_price NUMERIC(12, 4) NOT NULL,
    low_price NUMERIC(12, 4) NOT NULL,
    close_price NUMERIC(12, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_market_index_after_market_timestamp ON v2.market_index_after_market_1min(timestamp);
CREATE INDEX idx_market_index_after_market_symbol ON v2.market_index_after_market_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.currency_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(10, 4) NOT NULL,
    high_price NUMERIC(10, 4) NOT NULL,
    low_price NUMERIC(10, 4) NOT NULL,
    close_price NUMERIC(10, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_currency_timestamp ON v2.currency_1min(timestamp);
CREATE INDEX idx_currency_symbol ON v2.currency_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.stock_pre_market_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(12, 4) NOT NULL,
    high_price NUMERIC(12, 4) NOT NULL,
    low_price NUMERIC(12, 4) NOT NULL,
    close_price NUMERIC(12, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_stock_pre_market_timestamp ON v2.stock_pre_market_1min(timestamp);
CREATE INDEX idx_stock_pre_market_symbol ON v2.stock_pre_market_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.stock_main_market_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(12, 4) NOT NULL,
    high_price NUMERIC(12, 4) NOT NULL,
    low_price NUMERIC(12, 4) NOT NULL,
    close_price NUMERIC(12, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_stock_main_market_timestamp ON v2.stock_main_market_1min(timestamp);
CREATE INDEX idx_stock_main_market_symbol ON v2.stock_main_market_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.stock_after_market_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(12, 4) NOT NULL,
    high_price NUMERIC(12, 4) NOT NULL,
    low_price NUMERIC(12, 4) NOT NULL,
    close_price NUMERIC(12, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_stock_after_market_timestamp ON v2.stock_after_market_1min(timestamp);
CREATE INDEX idx_stock_after_market_symbol ON v2.stock_after_market_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.etf_pre_market_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(12, 4) NOT NULL,
    high_price NUMERIC(12, 4) NOT NULL,
    low_price NUMERIC(12, 4) NOT NULL,
    close_price NUMERIC(12, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_etf_pre_market_timestamp ON v2.etf_pre_market_1min(timestamp);
CREATE INDEX idx_etf_pre_market_symbol ON v2.etf_pre_market_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.etf_main_market_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(12, 4) NOT NULL,
    high_price NUMERIC(12, 4) NOT NULL,
    low_price NUMERIC(12, 4) NOT NULL,
    close_price NUMERIC(12, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_etf_main_market_timestamp ON v2.etf_main_market_1min(timestamp);
CREATE INDEX idx_etf_main_market_symbol ON v2.etf_main_market_1min(symbol);

CREATE TABLE IF NOT EXISTS v2.etf_after_market_1min (
    symbol VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open_price NUMERIC(12, 4) NOT NULL,
    high_price NUMERIC(12, 4) NOT NULL,
    low_price NUMERIC(12, 4) NOT NULL,
    close_price NUMERIC(12, 4) NOT NULL,
    PRIMARY KEY (symbol, timestamp)
);
CREATE INDEX idx_etf_after_market_timestamp ON v2.etf_after_market_1min(timestamp);
CREATE INDEX idx_etf_after_market_symbol ON v2.etf_after_market_1min(symbol);

COMMIT;