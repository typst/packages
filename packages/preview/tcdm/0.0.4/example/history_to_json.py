"""Convert the latest history CSV to JSON in stdout.

This conversion is difficult to implement in Typst, because the CSV is quite specific to Python and Pandoc.
The following is a typical row. It contains Python lists and numbers. It is even more complicated that some numbers should not be parsed as numbers because they are version numbers.
    math,"['runnable', 'web']",,True,,2.8,2026-01-13 15:41:30.000,3.1.0,2.8,Apache-2.0

It is recommended that templates contain only the Typst document and its assets.
However, this script is included in the template because it was permitted when tcdm v0.0.1 was submitted, and the setup workflow has not changed since then.

- Initial submission of v0.0.1 (2025-12/2026-01): https://github.com/typst/packages/pull/3748
- Discussion about this script during the v0.0.3 submission (2026-07): https://github.com/typst/packages/pull/5421#discussion_r3656416430
"""

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
