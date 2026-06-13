from pathlib import Path
import sys

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "python"))

from pipeline import process_data


def test_pipeline_missing_input(tmp_path):
    """Missing input file returns an error status rather than raising."""
    result = process_data(tmp_path / "nope.csv", tmp_path / "out")
    assert result["status"] == "error"


def test_pipeline_missing_column(tmp_path):
    """A file without DEATH_EVENT returns an error instead of a KeyError."""
    bad = tmp_path / "bad.csv"
    bad.write_text("age,time\n75,4\n")
    result = process_data(bad, tmp_path / "out")
    assert result["status"] == "error"


def test_pipeline_empty_input(tmp_path):
    """An empty (header-only) file returns an error instead of NaN mortality."""
    empty = tmp_path / "empty.csv"
    empty.write_text("DEATH_EVENT,time\n")
    result = process_data(empty, tmp_path / "out")
    assert result["status"] == "error"


def test_pipeline_with_bundled_data():
    """Ensure the pipeline processes the bundled OA dataset deterministically."""
    result = process_data(REPO_ROOT / "data" / "heart_failure.csv", REPO_ROOT / "data" / "processed")
    assert result["certified"] is True
    assert result["status"] == "success"
    assert result["processed_records"] == 299
    assert result["mortality_rate"] == 0.3211
