# Prepare

## Where the data is located
- Source: Divvy trip data, public S3 bucket (divvy-tripdata.s3.amazonaws.com), one zipped
  CSV per month.
- Staged in: Google Drive folder `Cyclistic/raw_data/` (working copy, not committed to GitHub)
- Loaded into: Google BigQuery Sandbox, dataset `cyclistic`, for cleaning and analysis.

## How it's organized
- One CSV per month, released on a monthly schedule.
- 13 columns: ride_id, rideable_type, started_at, ended_at, start_station_name,
  start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat,
  end_lng, member_casual
- Months used: January-June 2026 (6 files)
- Row count: 2,520,780

## Steps taken to store and organize the data
1. Downloaded the six monthly zip files from the S3 bucket.
2. Unzipped and kept the original `YYYYMM-divvy-tripdata.csv` naming for traceability
3. Uploaded to a dedicated Google Drive folder as a staging area, separate from any
   cleaned outputs.
4. Loaded each month into its own BigQuery table (`trips_202601`, `trips_202602`, etc.)
   individually, rather than merging on upload. So each month's schema could be
   verified before combining them (see sql/01_clean_data.sql).

## Credibility: does the data ROCCC?
Full breakdown in `data/README.md`; summary:
- **Reliable / Original / Cited**: official first-party release from Divvy/Lyft under
  the Divvy Data License Agreement, not scraped or aggregated.
- **Current**: released monthly; this analysis uses the most recent complete months
  available at the time of writing.
- **Comprehensive**: complete at the trip level, but *not* comprehensive for anything
  requiring rider identity, demographics, or payment. Those fields are excluded by
  design, not missing by error.

## Licensing, privacy, security, accessibility
- Licensed for public use under the Divvy Data License Agreement
  (https://ride.divvybikes.com/data-license-agreement); attribution included in this
  repo's README and data/README.md
- No PII in the release. No name, account ID, or payment data. So rides cannot be
  traced to individuals. This is a hard limit on the analysis (e.g. can't tell if one
  "casual" rider bought five single-ride passes or five different people each bought one), not something introduced during processing.
- Raw CSVs are kept out of GitHub (size + tidiness); only cleaned/aggregated outputs and
  the code to reproduce them are version-controlled, so the repo stays lightweight and
  reviewable.

## Verifying data integrity
Before merging months, each monthly BigQuery table was checked individually:
- Row count in BigQuery matched the row count in the source CSV (no silent truncation
  on upload).
- Column names and data types were identical across all six months (no schema drift
  between files).
- `started_at` min/max per file confirmed each file only contained rows from its
  expected month.
- Ran a null-count profile per column, cross-tabbed against `rideable_type`, to
  understand the missing-station-name pattern *before* deciding how to treat it
  (see sql/01_clean_data.sql; This check carries into Process rather than being
  resolved here).

## Sorting / filtering at this stage
None yet, deliberately. Prepare is scoped to getting the data in, organized, and
verified as trustworthy. Row-level filtering (short/long rides, nulls) is a Process
decision made once the full picture is understood, so it's documented and reproducible
rather than done ad hoc while loading.

## Problems identified, carried into Process
- ~13-15% of rows have null station name/id, concentrated on `electric_bike` trips;
  expected behavior (e-bikes can lock to any public rack, not just a Divvy station),
  not corrupt data. Handled in docs/03_process.md
- Some trips have implausible durations (near-zero or multi-day) likely representing
  false starts or lost/undocked bikes. It's flagged for filtering in Process, not removed here. 
- No demographic or pricing fields; limits this analysis to behavioral patterns
  (timing, duration, station, bike type) rather than revenue impact per rider type.

## How this data helps answer the business question
Trip-level records: who (member vs casual), when, how long, and what bike type are
exactly the granularity needed to answer "how do annual members and casual riders use
Cyclistic bikes differently?" No other public, free dataset offers this level of detail
for Cyclistic/Divvy's system.