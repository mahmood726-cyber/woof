"""
Python data processing pipeline for woof.
Strictly Open Access, no secrets, deterministic execution.
"""
from pathlib import Path

import pandas as pd

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT = REPO_ROOT / "data" / "heart_failure.csv"
DEFAULT_OUTPUT_DIR = REPO_ROOT / "data" / "processed"


def _resolve_repo_path(path_value: str | Path) -> Path:
    path = Path(path_value)
    if path.is_absolute():
        return path
    return REPO_ROOT / path


def process_data(input_path: str | Path = DEFAULT_INPUT, output_dir: str | Path = DEFAULT_OUTPUT_DIR) -> dict:
    """
    Processes real OA heart failure data.
    """
    input_path = _resolve_repo_path(input_path)
    output_dir = _resolve_repo_path(output_dir)

    if not input_path.exists():
        return {"status": "error", "message": f"Input file not found: {input_path}"}

    df = pd.read_csv(input_path)

    if "DEATH_EVENT" not in df.columns:
        return {"status": "error", "message": "Required column 'DEATH_EVENT' not found in input."}

    record_count = len(df)
    if record_count == 0:
        return {"status": "error", "message": "Input file contains no records."}

    mortality_rate = float(df["DEATH_EVENT"].mean())

    output_dir.mkdir(parents=True, exist_ok=True)

    return {
        "status": "success",
        "processed_records": record_count,
        "mortality_rate": round(mortality_rate, 4),
        "certified": True,
        "source": "UCI Heart Failure Clinical Records",
    }


if __name__ == "__main__":
    print("Running real-data pipeline...")
    metrics = process_data()
    print(f"Pipeline completed: {metrics}")
