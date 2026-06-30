# Day 3 — Marts layer, schema tests, full pipeline build

**Date:** 2026-06-25

## Built today

- Created `models/marts/mart_spending_by_agency.sql` — aggregates contract spending by awarding agency and sub-agency, built on top of `stg_contracts` using dbt's `ref()` dependency system
- Added `count`, `sum`, `avg`, `max`, and date-range aggregations per agency grouping
- Added `schema.yml` with `not_null` tests on key columns (`awarding_agency`, `total_award_amount`, `contract_count`)
- Ran `dbt build` — executed the full pipeline (staging → marts → tests) in correct dependency order, all passing

## Key result

Department of Defense leads logistics contract spending at $94.96B across 52 contracts in the sample pull; NASA has the highest average award size at $4.36B across just 3 contracts — a useful early signal about contract concentration that wouldn't be visible in the raw staging data.

## What I actually learned (not just what I did)

- **`{{ ref() }}` is the core of dbt's dependency graph.** Instead of hardcoding a table name, `ref('stg_contracts')` tells dbt this model depends on that one — dbt automatically builds things in the right order and tracks lineage across the whole project. This is what makes `dbt build` able to run staging before marts without me telling it to.
- **Materialization strategy matters.** Staging models are views (cheap, always fresh, no storage). Marts are tables (computed once, stored, fast to query) — the right choice for an aggregation that will get queried repeatedly by a dashboard.
- **Grouping granularity changes the story.** Grouping by `awarding_agency` + `awarding_sub_agency` together produced multiple rows for the same parent agency (DoD shows up 4 times under different sub-agencies) — correct, but worth understanding why before trusting a "top agency" number at a glance.
- **Schema tests are cheap insurance.** Three `not_null` tests took two minutes to write and now run automatically every time the pipeline builds — catching broken upstream data before it reaches a dashboard.

## How this ties to my overall goal

This is the layer that turns a working pipeline into an actual analytics product — the difference between "I can move data" and "I can produce something a stakeholder would look at and trust." Schema testing in particular maps directly to the kind of trust and validation needed in operational logistics reporting (a bad readiness number reaching a commander is the civilian-world equivalent of a bad spending number reaching a dashboard).

## Next

- Add a second, different data source (FEMA or a different USASpending slice)
- Start the dashboard layer to visualize `mart_spending_by_agency`
