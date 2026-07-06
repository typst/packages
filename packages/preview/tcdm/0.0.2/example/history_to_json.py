"""Convert the latest history CSV to JSON in stdout."""

# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pandas>=2.3.3",
# ]
# ///

from ast import literal_eval
from pathlib import Path
from sys import stderr, stdout

import pandas as pd

root_dir = Path(__file__).parent.parent

histories = list((root_dir / "history").glob("*_projects.csv"))
histories.sort()
latest_history = histories[-1]
print(f"Converting {latest_history.relative_to(root_dir).as_posix()}…", file=stderr)

pd.read_csv(
    latest_history,
    index_col=0,
    converters={
        "labels": lambda x: literal_eval(x) if x != "" else [],
    },
).to_json(
    stdout,
    force_ascii=False,
    orient="records",
    indent=2,
)
