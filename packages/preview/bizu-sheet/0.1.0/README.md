# bizu-sheet

Create compact revision sheets with cards, formulas, units, comparisons, and checklists.

![bizu-sheet banner](bizu-sheet-github-banner.png)

## Quick start

Import the package with its full version:

```typst
#import "@preview/bizu-sheet:0.1.0": *

#show: cheat_sheet.with(
  title: "Algebra",
  subtitle: "Quick revision",
  author: "Your name",
)

= Key formula

#formula(
  title: "Quadratic formula",
  $ x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2 a) $,
  note: [Check the discriminant before solving.],
)
```

## English API

The package provides English names for new projects:

| Function | Purpose |
|---|---|
| `cheat_sheet` | Apply the page layout, typography, header, footer, and title block. |
| `card` | Create a compact revision card. |
| `alert` | Highlight a warning, exception, or common mistake. |
| `definition` | Create a definition card. |
| `mnemonic` | Display a mnemonic and its explanation. |
| `compare` | Compare two concepts in parallel columns. |
| `data_table` | Create a styled summary table. |
| `checklist` | Create a revision checklist. |
| `columns` | Place two blocks side by side. |
| `formula` | Highlight a mathematical formula. |
| `result` | Display a final calculation result. |
| `steps` | Organize a solution into numbered steps. |
| `unit` | Summarize a unit, relation, and example. |
| `constant` | Present a useful constant or numerical approximation. |
| `condition` | Highlight a hypothesis, domain, or validity condition. |
| `formula_pair` | Place two formulas side by side. |
| `pagebreak` | Insert an explicit page break. |
| `small` | Render auxiliary text at a smaller size. |

All English names are aliases for the original API. The existing `bizuario`, `b-card`, `b-alert`, `b-formula`, and other `b-*` names remain available for backward compatibility.

## Tones

`card` and `alert` support the tones `info`, `success`, `warning`, `danger`, and `neutral`.

## Mathematics and physics

Pass mathematical content between `$...$`:

```typst
#formula(
  title: "Kinetic energy",
  $ E_c = (m v^2) / 2 $,
  note: [Use compatible units for mass and velocity.],
)

#steps((
  [Isolate the unknown.],
  [Convert all quantities to compatible units.],
  [Substitute the values.],
  [Check the final unit and order of magnitude.],
))

#result($ v = 12 "m" / "s" $, condition: [SI units])
```

## Template projects

Start a new project from the template with:

```bash
typst init @preview/bizu-sheet:0.1.0 my-revision-sheet
```

Then compile it with:

```bash
cd my-revision-sheet
typst compile main.typ
```

## License

MIT
