# Process

## Tool chosen
Google BigQuery Sandbox is free, handles the combined multi-month dataset comfortably
within the 10GB storage / 1TB query monthly limits, and keeps the whole workflow online.

## Cleaning steps
1. Combined March-June 2026 monthly tables into `trips_combined` (see sql/01_clean_data.sql)
2. Investigated null `start_station_name`/`end_station_name` values before deciding how to   
   handle them. It's found they're concentrated on `rideable_type = electric_bike` (almost 100% of NULL values are from `electric_bike`), consistent with Divvy's system design (e-bikes can lock to any public rack,
   not just a docking station). **Kept these rows** — they're valid trips, just excluded from
   station-level queries specifically, not from the dataset as a whole.
3. Removed trips under 60 seconds (false starts/re-docks — consistent with Divvy's own
   published data-processing convention)
4. Removed trips over 24 hours (likely lost/undocked bikes, not genuine rides)
5. Removed rows with a null member_casual value
6. Added `ride_length_sec` (TIMESTAMP_DIFF) and `day_of_week` (FORMAT_TIMESTAMP) columns

## Row counts
- Before cleaning: 2,520,780
- After cleaning: 2,451,105
- Rows dropped: 69,675 (2.76% of total)
- Rows with null station name retained: 479,393 (19.56% of total, ~99.97% on electric_bike)