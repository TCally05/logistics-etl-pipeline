# Day 1 — Project setup

**Date:** 2026-06-18

## Built today

- Initialized the repo structure: `data/`, `ingestion/`, `transforms/dbt_project/`, `orchestration/`, `dashboards/`, `docs/`, `tests/`
- Set up SSH auth between WSL2 and GitHub
- Created a Python 3.11 virtual environment with the core stack: `dbt-duckdb`, `duckdb`, `requests`, `pandas`, `python-dotenv`
- Wrote the initial README and pushed the first commits

## Problems hit

| Problem | Fix |
|---|---|
| No GitHub password on hand | Set up SSH key auth instead — the standard, password-free way to connect |
| dbt failed to run on Python 3.14 (`mashumaro` incompatibility) | Installed Python 3.11 via deadsnakes PPA and rebuilt the venv on a stable version |
| Divergent branches on first push | GitHub auto-created a README on repo creation; merged histories and resolved the conflict |
| Accidentally committed `.venv` (97MB) | Untracked it with `git rm -r --cached .venv` — it was already in `.gitignore`, just needed removing from git's index |

## Takeaway

Production data tooling rarely runs on the newest language release — pinning to a stable version (Python 3.11 here) avoids a class of dependency errors before they start. Also relearned that `.gitignore` only blocks *future* tracking, not files already committed.

## Next

- Initialize the dbt project and connect it to DuckDB
- Write the first ingestion script (USASpending.gov)
- Build the first dbt staging model
