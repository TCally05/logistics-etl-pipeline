"""
fetch_usaspending.py
Pulls federal contract spending data from the USASpending.gov API
and saves it as a raw CSV to data/raw/.
"""

import requests
import pandas as pd
import time
import os
from dotenv import load_dotenv

load_dotenv()

BASE_URL = os.getenv("USASPENDING_API_BASE", "https://api.usaspending.gov/api/v2")
RAW_PATH = os.getenv("DATA_RAW_PATH", "./data/raw")

def fetch_contracts(keyword: str = "logistics", limit: int = 100) -> pd.DataFrame:
    """
    Fetch contract awards from USASpending.gov matching a keyword.
    Returns a pandas DataFrame of raw results.
    """
    url = f"{BASE_URL}/search/spending_by_award/"

    payload = {
        "filters": {
            "keywords": [keyword],
            "award_type_codes": ["A", "B", "C", "D"]  # procurement contracts
        },
        "fields": [
            "Award ID",
            "Recipient Name",
            "Award Amount",
            "Total Outlays",
            "Description",
            "Start Date",
            "End Date",
            "Awarding Agency",
            "Awarding Sub Agency",
            "Place of Performance State Code"
        ],
        "page": 1,
        "limit": limit,
        "sort": "Award Amount",
        "order": "desc"
    }

    print(f"Fetching contracts for keyword: '{keyword}'...")
    response = requests.post(url, json=payload, timeout=30)
    response.raise_for_status()

    data = response.json()
    results = data.get("results", [])

    if not results:
        print("No results returned.")
        return pd.DataFrame()

    df = pd.DataFrame(results)
    print(f"Fetched {len(df)} records.")
    return df


def save_raw(df: pd.DataFrame, filename: str = "contracts_raw.csv") -> str:
    """Save raw DataFrame to data/raw/."""
    os.makedirs(RAW_PATH, exist_ok=True)
    filepath = os.path.join(RAW_PATH, filename)
    df.to_csv(filepath, index=False)
    print(f"Saved to {filepath}")
    return filepath


if __name__ == "__main__":
    df = fetch_contracts(keyword="logistics", limit=100)
    if not df.empty:
        save_raw(df, "contracts_raw.csv")
        print("\nSample data:")
        print(df[["Award ID", "Recipient Name", "Award Amount"]].head(5))
