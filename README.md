# Zuber (Chicago Taxi) — SQL & Python Analysis

## Description
Analytical case study for Zuber (ride-sharing) based on Chicago taxi data. The goal is to identify ride patterns, passenger preferences, and evaluate how weather affects trip duration.

## Objectives
- Analyze competitor activity and ride distribution across taxi companies (SQL).
- Identify popular drop-off areas and visualize results (Python).
- Test the hypothesis that trip duration from Loop to O’Hare changes on rainy Saturdays (SQL + Python).

## Data
Database tables:
- `neighborhoods` (neighborhood_id, name)
- `cabs` (cab_id, vehicle_id, company_name)
- `trips` (trip_id, cab_id, start_ts, end_ts, duration_seconds, distance_miles, pickup_location_id, dropoff_location_id)
- `weather_records` (record_id, ts, temperature, description)

Note: `trips.start_ts` is linked to `weather_records.ts` by hour.

## Project structure
- `sql/` — SQL queries for EDA and hypothesis dataset extraction
- `notebooks/` — Python analysis (EDA, plots, hypothesis test)
- `data/` — CSV outputs used in Python (if applicable)

## Key results (summary)
- The largest ride volume is concentrated in the top taxi companies during the analyzed period.
- Loop is the top drop-off area by average trips in November 2017.
- Hypothesis test indicates a statistically significant difference in trip duration between Good vs Bad weather conditions (p-value < 0.05).

## How to run
1. Open the notebook in `notebooks/`.
2. Run cells top to bottom (requires pandas, numpy, matplotlib, scipy).

## Notes
This repository is part of a SQL + analytics bootcamp project.
