# bizu-sheet

Create compact revision sheets with cards, formulas, units, and checklists.

## Usage

```typst
#import "@preview/bizu-sheet:0.1.0": *

#show: bizuario.with(
  title: "Álgebra",
  subtitle: "Revisão rápida",
)

#b-formula(
  title: "Bhaskara",
  $ x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2 a) $,
)
```

## Components

- `bizuario`
- `b-card`
- `b-alert`
- `b-definition`
- `b-mnemonic`
- `b-compare`
- `b-table`
- `b-checklist`
- `b-columns`
- `b-formula`
- `b-result`
- `b-steps`
- `b-unit`
- `b-constant`
- `b-condition`
- `b-formula-pair`

The package is designed for Portuguese-language revision sheets, while the components can be used in any language.

## License

MIT
