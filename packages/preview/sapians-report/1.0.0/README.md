# sapians-report

Single-column technical report / memo template in the SAPIANS design
system, with version and author headers, accent cards, hairline tables,
and code boxes. Organization branding, language, and metadata labels are
all parameters.

## Usage

```bash
typst init @preview/sapians-report my-report
cd my-report
typst compile main.typ
```

Or start from this repository:

```bash
just install-preview   # installs the packages into Typst's local preview cache
typst compile --font-path assets/fonts templates/technical-report/template/main.typ
```

## Fonts

Designed for **Inter** and **JetBrains Mono** (SIL OFL). Install them from
their official releases or run `scripts/install_fonts.sh` in the source
repository; without them the report falls back to system fonts.

## License

Template content: MIT-0 — write your report on it with no attribution
required. Part of [sapians-design](https://github.com/wbendinelli/sapians-design).
