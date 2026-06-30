# Day 4 — Containerizing the pipeline with Docker

**Date:** 2026-06-26

## Built today

- Enabled Docker Desktop WSL2 integration and fixed a docker group permissions issue (`sudo usermod -aG docker $USER`)
- Wrote a multi-stage `Dockerfile` for the pipeline: Python 3.11-slim base, non-root user, dependency layer caching
- Added a proper `.dockerignore` (was previously empty) — cut build context from 426MB down to 5.79kB by excluding `.venv`, `.git`, and generated data files
- Built and ran the containerized pipeline successfully — confirmed the ingestion script pulls live USASpending.gov data identically inside the container as it does locally

## Problems hit

| Problem | Fix |
|---|---|
| `docker` command not found in WSL2 | Enabled WSL integration for the distro in Docker Desktop settings |
| `permission denied` connecting to Docker socket | Added user to the `docker` group; required a fresh terminal session to take effect |
| Build context was 426MB | Empty `.dockerignore` meant `.venv` and `.git` were being copied into every build — filled in proper exclusions |

## What I actually learned

- **Build context size is a real signal of engineering care.** A 426MB context wasn't broken, just sloppy — every Docker build was uploading the entire virtual environment to the build daemon for no reason. Fixing it dropped build time from over a minute to ~2 seconds on a cached build.
- **Running containers as root is a common, avoidable security finding.** Created a dedicated non-root `appuser` in the Dockerfile rather than running as the default root user — directly relevant to the container security practices called out in the job postings I'm targeting.
- **Layer caching rewards ordering decisions.** Copying `requirements.txt` and installing dependencies *before* copying the rest of the code means Docker only re-runs the slow `pip install` step when dependencies actually change, not on every code edit.
- **Containers are ephemeral by default.** The CSV the ingestion script wrote landed inside the container's filesystem, not my host machine — it disappeared when the container exited. This is the reason persistent volumes exist, which is next on the list once we move to docker-compose/Kubernetes.

## How this ties to my overall goal

This is the first concrete piece of infrastructure work tied directly to the Palantir FDSE (Tactical Edge) and Defense Unicorns Data Engineer postings I'm targeting — both call out containerization, Kubernetes, and container security explicitly. A working, optimized Dockerfile with a documented security decision (non-root user) is something I can point to directly in an interview, not just claim I understand conceptually.

## Next

- Run the containerized pipeline with persistent volumes via docker-compose
- Stand up a local Kubernetes cluster (kind or minikube) and deploy this same image as a Job/CronJob
- Add basic monitoring (Prometheus/Grafana) once the K8s deployment is live
