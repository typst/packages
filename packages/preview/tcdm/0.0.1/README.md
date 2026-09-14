# TCDM Generator

HTML generator for best-of lists, especially [Best of Typst (TCDM)](https://ydx-2147483647.github.io/best-of-typst/).

It loads metadata fetched by the canonical [best-of-generator][], and generates an HTML index page.

## Usage

1. Follow [the official instruction for creating a best-of list](https://github.com/best-of-lists/best-of/blob/main/create-best-of-list.md), and trigger at least one update.

2. Run `typst init @preview/tcdm:0.0.1 typ` at the root of the project. This should create a `typ/` directory next to `projects.yaml`.

3. Edit `typ/main.typ` and replace placeholder contents with real ones.

```diff
  #let (configuration, statistics, assets, body) = load(
-   projects-data: json(placeholder.latest-history-json),
-   projects-yaml: yaml(placeholder.projects-yaml),
+   projects-data: json("/build/latest.json"),
+   projects-yaml: yaml("/projects.yaml"),
  )
```

4. Append the following to your build script, and publish the `build/` directory.

```shell
mkdir -p build

# Convert best-of-generator's python-specific CSV to JSON.
uv run typ/history_to_json.py > build/latest.json

# Generate the HTML index page. (Available localizations: en, zh.)
typst compile typ/main.typ build/index.html --root . --features html --input lang=en
```

## License

- The source code of this generator is licensed under [GPL-3.0](https://choosealicense.com/licenses/gpl-3.0/ "GNU General Public License v3.0 | Choose a License"), as some of its files originate from the canonical [best-of-generator][] (GPL-3.0).

- The example scaffold is licensed under [MIT-0](https://choosealicense.com/licenses/mit-0/ "MIT No Attribution | Choose a License") for ease of use.

Note that these licenses are different from CC BY-SA 4.0 [used by the main TCDM project](https://ydx-2147483647.github.io/best-of-typst/#license).

[best-of-generator]: https://github.com/best-of-lists/best-of-generator
