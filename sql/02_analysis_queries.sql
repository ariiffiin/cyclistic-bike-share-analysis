-- Average ride length by rider type
SELECT member_casual, ROUND(AVG(ride_length_sec)/60, 1) AS avg_ride_length_min
FROM cyclistic.trips_clean
GROUP BY member_casual;

-- Rides and avg length by day of week, split by rider type
SELECT
  member_casual,
  day_of_week,
  COUNT(*) AS number_of_rides,
  ROUND(AVG(ride_length_sec)/60, 1) AS avg_ride_length_min
FROM cyclistic.trips_clean
GROUP BY member_casual, day_of_week
ORDER BY member_casual,
  CASE day_of_week WHEN 'Sunday' THEN 1 WHEN 'Monday' THEN 2 WHEN 'Tuesday' THEN 3
    WHEN 'Wednesday' THEN 4 WHEN 'Thursday' THEN 5 WHEN 'Friday' THEN 6 ELSE 7 END;

-- Bike type preference by rider type
SELECT member_casual, rideable_type, COUNT(*) AS rides
FROM cyclistic.trips_clean
GROUP BY member_casual, rideable_type
ORDER BY member_casual, rides DESC;

-- Top 10 start stations by rider type
SELECT member_casual, start_station_name, COUNT(*) AS rides
FROM cyclistic.trips_clean
WHERE start_station_name IS NOT NULL
GROUP BY member_casual, start_station_name
ORDER BY member_casual, rides DESC
LIMIT 10;