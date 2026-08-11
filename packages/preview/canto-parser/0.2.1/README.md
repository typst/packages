canto-parser
===

A Typst package to render Cantonese text with Jyutping (粵拼) or Yale (耶魯)
romanizations from "Cantonese words JSON array".

Sample output
---

![package output](pycanto_parser.png)

Input Data Format
---

The `render-word-groups` function accepts an array of JSON objects. Each object represents a segmented word or symbol and must follow this structure:

| Field | Type | Description |
| :--- | :--- | :--- |
| `word` | string | The Chinese character(s) or text snippet. |
| `jyutping` | string (optional) | The combined Jyutping for the word (e.g., `"hou2jek6"`). Use `null` for non-Chinese text. |
| `yale` | array (optional) | An array of Yale romanization strings, segmented by character (e.g., `["hóu", "yehk"]`). |

**Example:**
```json
[
  {
    "word": "你好",
    "jyutping": "nei5hou2",
    "yale": ["néih", "hóu"]
  },
  {
    "word": "!",
    "jyutping": null,
    "yale": null
  }
]
```

Usage
---

### Option A: Automatic (Recommended)
Use the [auto-canto](https://github.com/VincentTam/auto-canto) package. This is the easiest way as it uses a WASM-based logic to segment and annotate text directly within Typst without needing Python.

### Option B: Pre-processed JSON (Manual)
If you prefer to use [PyCantonese](https://pycantonese.org) for specific linguistic needs, you can generate a JSON file using the script below.

<details>
<summary>View Python helper script</summary>

```py
import pycantonese
import json
import sys

# Script to generate compatible JSON format
lines = sys.argv[1].split('\n')
result = []

for line in lines:
    words = pycantonese.segment(line)
    for word in words:
        pairs = pycantonese.characters_to_jyutping(word)
        jyutping = "".join([p[1] for p in pairs if p[1]]) if pairs else None
        # Note: adjust pycantonese call to return array for yale if needed
        yale = [pycantonese.jyutping_to_yale(p[1]) for p in pairs if p[1]] if pairs else None
        result.append({"word": word, "jyutping": jyutping, "yale": yale})
    result.append({"word": "\n", "jyutping": None})

print(json.dumps(result, ensure_ascii=False))
```
</details>

1. Generate your data: `python script.py "你好" > data.json`
1. Import and render:

    ```typ
    #import "@preview/canto-parser:0.2.1": *
    #let data = json("data.json")
    #render-word-groups(data)
    ```

License
---

MIT
