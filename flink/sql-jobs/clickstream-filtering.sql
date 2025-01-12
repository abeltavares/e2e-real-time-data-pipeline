-- Configure Flink Settings for Streaming and State Management
SET 'state.backend' = 'rocksdb';
SET 'state.backend.incremental' = 'true';
SET 'execution.checkpointing.mode' = 'EXACTLY_ONCE';
SET 'execution.checkpointing.interval' = '10s';
SET 'execution.checkpointing.min-pause' = '10s';
SET 'sql-client.execution.result-mode' = 'TABLEAU';
SET 'parallelism.default' = '1';

-- Load Required Jars
ADD JAR '/opt/flink/lib/flink-sql-connector-kafka-3.1.0-1.18.jar';
ADD JAR '/opt/flink/lib/flink-json-1.18.1.jar';
ADD JAR '/opt/flink/lib/iceberg-flink-runtime-1.18-1.5.0.jar';
ADD JAR '/opt/flink/lib/hadoop-common-2.8.3.jar';
ADD JAR '/opt/flink/lib/hadoop-hdfs-2.8.3.jar';
ADD JAR '/opt/flink/lib/hadoop-client-2.8.3.jar';
ADD JAR '/opt/flink/lib/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar';
ADD JAR '/opt/flink/lib/bundle-2.20.18.jar';

-- Confirm Jars are Loaded
SHOW JARS;

DROP CATALOG IF EXISTS iceberg;
CREATE CATALOG iceberg WITH (
    'type' = 'iceberg',
    'catalog-impl' = 'org.apache.iceberg.rest.RESTCatalog',  -- Use REST catalog
    'uri' = 'http://iceberg-rest:8181',                     -- REST catalog server URL
    'warehouse' = 's3://warehouse/',                        -- Warehouse location
    'io-impl' = 'org.apache.iceberg.aws.s3.S3FileIO',       -- S3 file IO
    's3.endpoint' = 'http://minio:9000',                    -- MinIO endpoint
    's3.path-style-access' = 'true',                        -- Enable path-style access
    'client.region' = 'us-east-1',                          -- S3 region
    's3.access-key-id' = 'admin',                           -- MinIO access key
    's3.secret-access-key' = 'password'                     -- MinIO secret key
);

-- Define Kafka Source Table
DROP TABLE IF EXISTS clickstream_source;
CREATE TABLE IF NOT EXISTS clickstream_source (
    event_id STRING,
    user_id STRING,
    event_type STRING,
    url STRING,
    session_id STRING,
    device STRING,
    event_time TIMESTAMP_LTZ(3) METADATA FROM 'timestamp',
    geo_location ROW<lat DOUBLE, lon DOUBLE>,
    purchase_amount DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'clickstream',
    'properties.bootstrap.servers' = 'broker:29092',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true',
    'json.timestamp-format.standard' = 'ISO-8601'
);

-- Define Iceberg Sink Table
CREATE DATABASE IF NOT EXISTS iceberg.db;
DROP TABLE IF EXISTS iceberg.db.clickstream_sink;
CREATE TABLE iceberg.db.clickstream_sink
WITH (
    'catalog-name' = 'iceberg',
    'format' = 'parquet'
)
AS
SELECT
    event_id,
    user_id,
    event_type,
    url,
    session_id,
    device,
    event_time,
    geo_location.lat AS latitude,
    geo_location.lon AS longitude,
    purchase_amount
FROM clickstream_source
WHERE event_type = 'purchase'
  AND device IS NOT NULL;

