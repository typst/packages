# sapians-slides

16:9 slide deck template in the SAPIANS design system: Crisp White canvas,
Inter typography, hairline rules, and 10 standardized slide families
(cover, problem, definition, equation, three-column, evidence, limitation,
contrast, takeaway, index).

## Usage

```bash
typst init @preview/sapians-slides my-talk
cd my-talk
typst compile main.typ
```

Or start from this repository:

```bash
just install-preview   # installs the packages into Typst's local preview cache
typst compile --font-path assets/fonts templates/slides-deck/template/main.typ
```

## Fonts

Designed for **Inter** and **JetBrains Mono** (SIL OFL). Install them from
their official releases or run `scripts/install_fonts.sh` in the source
repository; without them the deck falls back to system fonts.

## License

Template content: MIT-0 — build your talk on it with no attribution
required. Part of [sapians-design](https://github.com/wbendinelli/sapians-design).
