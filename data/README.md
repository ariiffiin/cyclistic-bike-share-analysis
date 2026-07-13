# Data source

Trip data provided by Motivate International Inc. under the Divvy Data License Agreement:
https://ride.divvybikes.com/data-license-agreement

Downloaded from: https://divvy-tripdata.s3.amazonaws.com/index.html

Files used: 
202601-divvy-tripdata.csv, 
202602-divvy-tripdata.csv, 
202603-divvy-tripdata.csv, 
202604-divvy-tripdata.csv, 
202605-divvy-tripdata.csv, 
202606-divvy-tripdata.csv.
(Jan-June 2026)

Raw CSVs are not committed to this repo (482 MB). To reproduce: download the files above
and follow docs/03_process.md.

## ROCCC assessment
- Reliable: Yes — official operator data, not third-party scraped
- Original: Yes — primary source (Divvy/Lyft), not aggregated
- Comprehensive: Partial — trip-level detail is complete, but no rider demographics
  (age/gender fields were phased out; PII is excluded by design per data-privacy policy)
- Current: Yes — released on a monthly schedule; this analysis uses the most recent
  complete months available at time of writing
- Cited: Yes — licensed and publicly documented by the data provider

## Known limitations
- Cannot link rides to individual riders (no PII) — so can't tell if a "casual" rider
  is actually a repeat customer using multiple single-ride passes, or a true one-off user.
- No payment/pricing data — can't calculate revenue per rider type directly.
- `start_station_name`/`end_station_name`/`*_id` are null for ~13-15% of rows, almost
  entirely on `rideable_type = electric_bike`. This is expected, not a data error — e-bikes
  can be locked to any public rack, not just a Divvy docking station, so many e-bike trips
  genuinely have no station to record. These rows are still valid for duration/day-of-week/
  rider-type analysis; they're only excluded from station-specific queries (see docs/03_process.md).