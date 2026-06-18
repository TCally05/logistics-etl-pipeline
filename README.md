# Logistics ETL Pipeline

An open-source data pipeline that ingests, transforms, and visualizes public logistics and supply-chain data. Built to mirror real-world operational data engineering patterns used in military and disaster-response logistics — fuel consumption tracking, resource allocation, and supply chain visibility.

## Why this project exists

Operational logistics data is often siloed, manually tracked in spreadsheets, and disconnected from predictive analytics. This project demonstrates an end-to-end pipeline pattern: ingesting raw public data, transforming it into clean analytical models, and surfacing it through dashboards — the same pattern used to build production logistics systems.

## Tech stack

- **Python** — ingestion scripts
- **DuckDB** — local analytical database
- **dbt** — data transformation and modeling
- **Docker** — containerized, reproducible environment
- *(planned)* Airflow — orchestration
- *(planned)* Dashboard layer

## Project structure

\`\`\`
logistics-etl-pipeline/
├── data/
│   ├── raw/          # untouched source data
│   ├── processed/    # cleaned, pipeline-ready data
│   └── external/     # reference/lookup data
├── ingestion/         # scripts that pull data from public APIs
├── transforms/
│   └── dbt_project/   # dbt models
├── orchestration/      # pipeline scheduling (Airflow, future)
├── dashboards/         # visualization layer (future)
├── docs/
│   └── architecture.md
└── tests/
\`\`\`

## Status

🚧 Actively under development. This is a learning-in-public project — see commit history for build progress.

## Data sources

- [USASpending.gov API](https://api.usaspending.gov/) — federal spending and contract data
- [FEMA OpenFEMA API](https://www.fema.gov/about/openfema/api) — disaster response and resource data

## Setup

\`\`\`bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
\`\`\`

## License

MIT
