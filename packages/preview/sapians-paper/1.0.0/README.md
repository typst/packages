# sapians-paper

Two-column A4 scientific paper template in the SAPIANS design system, with
abstract box, author grid, IEEE-style bibliography, math, and code boxes.
Venue branding (`kicker`, `journal`), language, and section labels are all
parameters.

## Usage

```bash
typst init @preview/sapians-paper my-paper
cd my-paper
typst compile main.typ
```

Or start from this repository:

```bash
just install-preview   # installs the packages into Typst's local preview cache
typst compile --font-path assets/fonts templates/scientific-paper/template/main.typ
```

## Fonts

Designed for **Inter** and **JetBrains Mono** (SIL OFL). Install them from
their official releases or run `scripts/install_fonts.sh` in the source
repository; without them the paper falls back to system fonts.

## License

Template content: MIT-0 — write your paper on it with no attribution
required. Part of [sapians-design](https://github.com/wbendinelli/sapians-design).
