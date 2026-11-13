# na-courbe

Function plotting for Typst on top of CeTZ / cetz-plot.
رسم الدوال في Typst فوق CeTZ / cetz-plot.

## Install from Typst Universe / من Typst Universe
```typ
#import "@preview/na-courbe:0.1.0": courbe, integrale, papier-milli
```

## Install (local) / التثبيت المحلي
Copy this folder to / انسخ المجلد إلى:
- Linux:   `~/.local/share/typst/packages/local/na-courbe/0.1.0/`
- macOS:   `~/Library/Application Support/typst/packages/local/na-courbe/0.1.0/`
- Windows: `%APPDATA%\\typst\\packages\\local\\na-courbe\\0.1.0\\`

```typ
#import "@local/na-courbe:0.1.0": courbe, integrale, papier-milli
```

## Quick start

```typ
#set text(dir: ltr)
// millimetre graph paper / ورقة مليمترية
#courbe(x => x * x / 4 - 1, x: (-4, 4), y: (-2, 4),
  grille: "millimetre", grille-couleur: blue,
  nom: $C_f$, xlabel: $x$, ylabel: $y$, origine: $O$)
```

## Features / الميزات
| group | parameters |
|---|---|
| grid type | `grille`: `true`/`"principale"` · `"secondaire"` · `"toutes"` · **`"millimetre"`** · `false`; per axis `grille-x`, `grille-y`; style `grille-trait`, `grille-couleur`, `grille-epaisseur` |
| millimetre paper | `milli-fin`, `milli-ancre`, shortcut `papier-milli(..)` |
| appearance | `fond`, `cadre`, `titre`, `axes-couleur`, `axes-epaisseur` |
| tick length | `xtick`, `ytick` (cm), `tick-minor` (ratio), `tick-taille` (label size) |
| tick labels | `xnum`, `ynum`: `"normal"` or `"pi"`; denominator `xpi`, `ypi` |
| unit length | `xunite`, `yunite`: cm per unit on each axis (cm per π with `"pi"`) |
| label placement | `nom-pos`, `nom-t`, `nom-x`, `nom-dx`, `nom-dy`, `nom-ancre` |

## Documentation
- English: `doc-en.typ` (`typst compile doc-en.typ`), including a reference guide to rational, exponential, logarithmic, absolute value and square root functions
- العربية: `doc.typ` (`typst compile doc.typ`) مع دليل الدوال الكسرية والأسية واللوغاريتمية والقيمة المطلقة والجذر التربيعي

License: MIT
