# Day 5 — docker-compose orchestration, volumes, and killing hardcoded paths

**Date:** 2026-06-30

## Built today

- Added a `pipeline` service and a `dbt` service to `docker-compose.yml`, with `depends_on` + `service_completed_successfully` so dbt only runs after ingestion finishes
- Mounted persistent volumes for `data/raw`, `data/processed`, the dbt project folder, and the dbt profile directory (`~/.dbt`) — data and config now survive container restarts
- Discovered and eliminated every hardcoded absolute host path in the project: the dbt profile's database path and the staging model's raw CSV path
- Replaced them with dbt's native `vars` mechanism (`raw_data_path` defined in `dbt_project.yml`, overridden per-environment via `--vars` at runtime) and an environment-variable-driven dbt profile path (`DBT_DUCKDB_PATH`)
- Ran the full pipeline (ingestion → staging → marts → tests) entirely inside Docker containers, end to end, successfully

## Problems hit

| Problem | Fix |
|---|---|
| `dbt build` inside the container couldn't find `~/.dbt/profiles.yml` | Mounted the host's `~/.dbt` directory into the container at the path the container's user expects |
| dbt connected but `stg_contracts` failed reading the raw CSV | The model's SQL had a hardcoded absolute host path (`/home/taylo/...`) baked into a `read_csv_auto()` call — meaningless inside the container's isolated filesystem |
| Same root cause appeared twice (profile path, then model path) | Fixed both with the same pattern: externalize the path through configuration (env var for the profile, dbt var for the model) instead of hardcoding it anywhere |
| Stray Docker Desktop UI text repeatedly leaking into terminal pastes | Identified as a real, recurring issue — likely a UI focus/clipboard interaction with the Docker Desktop window; caught and cleaned each time before it caused lasting damage |

## What I actually learned (the big one today)

Today was less about a single new tool and more about a concept: **containers are isolated filesystems, and hardcoded absolute paths are fundamentally incompatible with that isolation.** A path like `/home/taylo/logistics-etl-pipeline/...` only exists on my exact laptop. A Docker container has its own separate filesystem and has no idea that path exists — even when the same underlying file is available, just mounted somewhere else via a volume.

This is why **volumes** exist: they're an explicit, deliberate bridge between a folder on the host machine and a folder inside the container, letting code on either side read/write the same real data without the container needing to know anything about the host's actual directory structure.

The fix in both places I hit this (the dbt profile and the staging model) followed the same engineering pattern: **never hardcode a path — externalize it through configuration that's supplied differently per environment.** Locally, the config defaults to my real path. In the container, the same config is explicitly overridden to the container's internal mounted path. The model and profile code itself never changes — only the value handed to it at runtime changes. This is the same pattern used in real production systems (CI pipelines, Kubernetes Jobs, cloud deployments) — code that assumes nothing about where it's running, and gets everything it needs to know from its environment.

## How this ties to my overall goal

This is the exact discipline both the Palantir FDSE (Tactical Edge) and Defense Unicorns Data Engineer postings are implicitly testing for: building things that work reliably across different environments, not just on a personal machine. Today's fix is something I can speak to directly and specifically in an interview — not "I used Docker," but "I found and fixed every hardcoded host path in the project, and replaced them with environment-driven configuration so the pipeline behaves identically whether it's running locally, in a container, or eventually in a Kubernetes job."

## Next

- Stand up a local Kubernetes cluster (kind or minikube)
- Deploy the same Docker image as a Kubernetes Job, then a CronJob
- Continue the discipline: zero hardcoded paths, all config externalized via ConfigMaps/Secrets once we're in K8s
