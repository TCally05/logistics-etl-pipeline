# Day 2 — dbt project, first ingestion script, first staging model

**Date:** 2026-06-24

## Built today

- Initialized the dbt project (`logistics_etl`) inside `transforms/dbt_project/`
- Configured dbt to connect to DuckDB, pointing the database file to `data/processed/dev.duckdb`
- Verified the connection with `dbt debug` — all checks passed
- Wrote `ingestion/fetch_usaspending.py` — pulls live federal contract data from the USASpending.gov API
- Built the first dbt staging model `stg_contracts.sql` — cleans column names, casts types, filters nulls
- Queried the staged data directly in DuckDB — 100 contracts, $151.74B total award value
- Added `data/raw/*.csv` and `data/processed/*.duckdb` to `.gitignore` so generated files never hit version control

## Problems hit

| Problem | Fix |
|---|---|
| `dbt init transforms/dbt_project` rejected the path as a project name | Used the project name `logistics_etl` when prompted; moved the generated folder into the right location after |
| dbt created the project folder in the repo root instead of `transforms/dbt_project/` | Moved it with `mv logistics_etl transforms/dbt_project` |
| DuckDB file and raw CSV were staged for commit | Added both patterns to `.gitignore` and removed with `git rm --cached` |

## Takeaway

The staging layer in dbt is where raw data gets its first cleanup pass — standardized column names, correct types, nulls filtered. Nothing gets added or derived here, just made consistent. Every downstream model builds on top of this clean foundation, which means fixing a naming issue once in staging fixes it everywhere. This mirrors the same pattern used in production pipelines — raw zone → staging zone → analytical models.

Also reinforced that generated files (databases, CSVs, compiled artifacts) never belong in version control. The code that generates them does — the files themselves don't.

## Next

- Build a `marts` model on top of `stg_contracts` (aggregated spending by agency)
- Add a second data source (FEMA or a second USASpending keyword)
- Start wiring up a simple dashboard layer to visualize the data
