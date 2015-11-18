SELECT quantileExactWeighted(0.5)(number, 1) FROM (SELECT number FROM system.numbers LIMIT 1001);
SELECT quantilesExactWeighted(0, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999, 1)(number, 1) FROM (SELECT number FROM system.numbers LIMIT 1001);
SELECT quantilesExactWeighted(0, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999, 1)(number, number) FROM (SELECT number FROM system.numbers LIMIT 1001);

SELECT quantileTimingWeighted(0.5)(number, 1) FROM (SELECT number FROM system.numbers LIMIT 1001);
SELECT quantilesTimingWeighted(0, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999, 1)(number, 1) FROM (SELECT number FROM system.numbers LIMIT 1001);
SELECT quantilesTimingWeighted(0, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999, 1)(number, number) FROM (SELECT number FROM system.numbers LIMIT 1001);

DROP TABLE IF EXISTS test.numbers_1001;
CREATE TABLE test.numbers_1001 (number UInt64) ENGINE = Memory;
SET max_block_size = 10;
INSERT INTO test.numbers_1001 SELECT number FROM system.numbers LIMIT 1001;

SELECT quantileExactWeighted(0.5)(number, 1) FROM remote('127.0.0.{1,2}', test.numbers_1001);
SELECT quantilesExactWeighted(0, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999, 1)(number, 1) FROM remote('127.0.0.{1,2}', test.numbers_1001);
SELECT quantilesExactWeighted(0, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999, 1)(number, number) FROM remote('127.0.0.{1,2}', test.numbers_1001);

SELECT quantileTimingWeighted(0.5)(number, 1) FROM remote('127.0.0.{1,2}', test.numbers_1001);
SELECT quantilesTimingWeighted(0, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999, 1)(number, 1) FROM remote('127.0.0.{1,2}', test.numbers_1001);
SELECT quantilesTimingWeighted(0, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999, 1)(number, number) FROM remote('127.0.0.{1,2}', test.numbers_1001);

DROP TABLE test.numbers_1001;