from pathlib import Path
import sys

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "python"))

from pipeline import process_data


def test_pipeline_with_bundled_data():
    """Ensure the pipeline processes the bundled OA dataset deterministically."""
    result = process_data(REPO_ROOT / "data" / "heart_failure.csv", REPO_ROOT / "data" / "processed")
    assert result["certified"] is True
    assert result["status"] == "success"
    assert result["processed_records"] == 299
    assert result["mortality_rate"] == 0.3211
