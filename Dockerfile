# Use a stable, production-grade Python base
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Install system dependencies needed for dbt/duckdb
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user (security best practice — relevant to both job postings)
RUN useradd --create-home --shell /bin/bash appuser

# Copy dependency file first (Docker layer caching — faster rebuilds)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY . .

# Set ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Default command: run the ingestion script
CMD ["python3", "ingestion/fetch_usaspending.py"]
