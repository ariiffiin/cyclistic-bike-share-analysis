-- Combine all six months into one working table
CREATE OR REPLACE TABLE cyclistic.trips_combined AS
SELECT * FROM cyclistic.trips_202601
UNION ALL SELECT * FROM cyclistic.trips_202602
UNION ALL SELECT * FROM cyclistic.trips_202603
UNION ALL SELECT * FROM cyclistic.trips_202604
UNION ALL SELECT * FROM cyclistic.trips_202605
UNION ALL SELECT * FROM cyclistic.trips_202606;

-- Check whether missing station names are actually explained by bike type
-- (expect the vast majority of nulls to be electric_bike)
SELECT rideable_type,
       COUNTIF(start_station_name IS NULL) AS missing_start,
       COUNTIF(end_station_name IS NULL) AS missing_end,
       COUNT(*) AS total
FROM cyclistic.trips_combined
GROUP BY rideable_type;

-- Add ride_length and day_of_week, and drop bad rows
-- Note: station-name nulls are NOT dropped here — they're valid e-bike trips.
-- They're only excluded later, inside station-specific queries.
CREATE OR REPLACE TABLE cyclistic.trips_clean AS
SELECT
  *,
  TIMESTAMP_DIFF(ended_at, started_at, SECOND) AS ride_length_sec,
  FORMAT_TIMESTAMP('%A', started_at) AS day_of_week
FROM cyclistic.trips_combined
WHERE TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 60      -- drop false starts (<60s, per Divvy's own convention)
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) < 86400   -- drop outliers over 24h (likely undocked/lost bikes)
  AND member_casual IS NOT NULL;


-- Calculating nunmber of rows dropped from initial data uploaded

SELECT 
  (select count(*)from cyclistic.trips_combined) as row_total,
  count(*) as row_cleaned,
  (select count(*)from cyclistic.trips_combined) - count(*) as row_removed,
  round(((select count(*)from cyclistic.trips_combined) - count(*))*100/(select count(*)from cyclistic.trips_combined),
  2
  ) as perc_removed
FROM cyclistic.trips_clean;

-- Calculating number and percentage of rows with null station name retained
SELECT
    COUNTIF(start_station_name IS NULL) AS missing_start,
    COUNTIF(end_station_name IS NULL) AS missing_end,
    ROUND(
        COUNTIF(start_station_name IS NULL)*100/COUNT(*),
        2
    ) AS missing_start_PERCENTAGE,
    ROUND(
        COUNTIF(end_station_name IS NULL)*100/COUNT(*),
        2
    ) AS missing_end_PERCENTAGE,
FROM cyclistic.trips_clean;

-- Calculating percentage of rideable_type with NULL station name retained
SELECT
    rideable_type,
    ROUND(
        COUNTIF(start_station_name IS NULL) * 100.0 /
        (SELECT COUNTIF(start_station_name IS NULL)
         FROM cyclistic.trips_clean),
        2
    ) AS pct_of_all_missing_start,
    ROUND(
        COUNTIF(end_station_name IS NULL) * 100.0 /
        (SELECT COUNTIF(end_station_name IS NULL)
         FROM cyclistic.trips_clean),
        2
    ) AS pct_of_all_missing_end
FROM cyclistic.trips_clean
GROUP BY rideable_type
ORDER BY rideable_type;