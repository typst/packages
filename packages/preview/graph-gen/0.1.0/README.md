# graph-gen

Graph view for your typst notes

![Part of a large graph. Each vertex is a heading, question, or a theorem or definition-like content figure, color-coded by content type, for example "Finals", "RSA", "Signature schemes", "Key generation". Color-coded edges connect vertices that reference each other.](imgs/graph-example.png)

## Quick start

1. Import the package and use the show rule in your typst document:
    ```
    #import "@preview/graph-gen:0.1.0": *

    #show: graph-gen-rules
    ```

2. Clone the [graph-gen repository](https://github.com/euwbah/graph-gen) containing the python script for the graph viewer.

3. (Highly recommended) set up a virtual environment:
    ```sh
    cd path/to/graph-gen
    python -m venv .venv
    .venv/Scripts/activate
    ```

    or with `uv`:
    ```sh
    cd path/to/graph-gen
    uv venv .venv
    .venv/Scripts/activate
    ```

4. Install dependencies:
    ```sh
    pip install .
    ```

    with `uv`:
    ```sh
    uv sync
    ```

5. Open typst preview for your document (for preview sync feature).
6. Run the graph viewer. Use `-h` to see all options.
    ```sh
    python graph-gen.py path/to/document.typ
    ```

    If you want to only scroll the preview and not the `.typ` source, use the `-s` or `--no-src-point` flag:
    ```sh
    python graph-gen.py path/to/document.typ -s
    ```
7. Double-click any node to scroll to its location in typst preview.

8. The python script caches graphs in `graph-gen/`. The cache should be manually deleted after updating this typst package.

## Example

See [example.typ](example.typ) for how to add support for theorem-type content (definitions, theorems, etc...) and tutorial questions.

Generate the graph for the example with:
```py
python graph-gen.py example.typ
```