CREATE TABLE ticker (
	id BIGSERIAL PRIMARY KEY,
	symbol TEXT NOT NULL
);
CREATE TABLE ticker_price (
  ticker_id INTEGER NOT NULL,
  dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  open DOUBLE PRECISION NOT NULL,
  high DOUBLE PRECISION NOT NULL,
  low DOUBLE PRECISION NOT NULL,
  close DOUBLE PRECISION NOT NULL,
  volume DOUBLE PRECISION NOT NULL,
  PRIMARY KEY (ticker_id, dt),
  CONSTRAINT fk_symbol FOREIGN KEY (ticker_id) REFERENCES ticker(id)
);
CREATE INDEX ON ticker_price (ticker_id, dt DESC);
CREATE TABLE tick_data (
  ticker_id INTEGER NOT NULL,
  dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  bid NUMERIC NOT NULL,
  ask NUMERIC NOT NULL,
  bid_vol NUMERIC,
  ask_vol NUMERIC,
  PRIMARY KEY (ticker_id, dt),
  CONSTRAINT fk_symbol FOREIGN KEY (ticker_id) REFERENCES ticker(id)
);
CREATE INDEX ON tick_data (ticker_id, dt DESC);
SELECT
  create_hypertable('ticker_price', 'dt');
SELECT
  create_hypertable('tick_data', 'dt');
CREATE MATERIALIZED VIEW daily_bars WITH (timescaledb.continuous) AS
SELECT
  ticker_id,
  time_bucket(INTERVAL '1 day', dt) AS day,
  first(open, dt) as open,
  max(high) as high,
  min(low) as low,
  last(close, dt) as close,
  sum(volume) as volume
FROM
  ticker_price
GROUP BY
  ticker_id,
  day;
CREATE MATERIALIZED VIEW "hourly_bars" WITH (timescaledb.continuous) AS
SELECT
  ticker_id,
  time_bucket(INTERVAL '1 hour', dt) AS hour,
  first(open, dt) as open,
  max(high) as high,
  min(low) as low,
  last(close, dt) as close,
  sum(volume) as volume
FROM
  ticker_price
GROUP BY
  ticker_id,
  hour;
