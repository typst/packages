# Confy (Typst)

Reusable confusion matrix renderer for Typst, built on CeTZ.

> TL;DR
>
> ```typst
> #import "@preview/confy:0.1.0": confy
> ```

## Features

- Heatmap-style confusion matrix with contrast‑aware cell labels
- Column/row titles, ticks, optional colorbar
- Typed colormap input: pass a palette (e.g., `color.map.viridis`) or a ready-made gradient
- Small, dependency‑light API (CeTZ only; fetched automatically)

## Quickstart

```typst
#import "@preview/confy:0.1.0": confy

#let labels = ("Covered", "ConditionUnmet", "NotCovered", "Uncertain")
#let M = (
  (18, 3, 6, 2),
  (2, 31, 3, 2),
  (1, 0, 16, 1),
  (2, 2, 0, 28),
)

#confy(labels, M)
```

## API

```typst
#confy(
  labels,                    // array of n labels (text or content)
  M,                         // n×n array of non-negative numbers
  // Axis titles
  title-row: "Predicted",    // column-axis title
  title-col: "Ground Truth", // row-axis title
  // Colormap (typed)
  cmap: color.map.viridis,   // array of colors (e.g., color.map.viridis, magma, inferno, plasma, cividis)
  grad: none,            // alternatively pass a ready-made gradient
  // Layout
  cell-size: 1.3,            // canvas units
  show-colorbar: true,
  colorbar-ticks: 7,        // number of ticks on colorbar
  label-rotate: -35deg,
  value-font-size: 9pt,
  tick-scale: 0.07,
)
```

### Custom colormaps

Pass a palette:

```typst
#confy(labels, M, cmap: color.map.inferno)
```

…or pass a gradient:

```typst
#let g = gradient.linear(..color.map.cividis, angle: 270deg, relative: "self")
#confy(labels, M, grad: g)
```

Typst ships predefined color maps as arrays in `color.map` which can be used directly as gradient stops (spread with `..`).

## Demo

```bash
typst compile demo.typ
```

## Notes

- If all values are zero, a uniform color is used and the colorbar omits ticks.
- Cell text switches between black/white to preserve contrast.

## Validation & extensions

- Recommended validations: ensure `len(labels) == len(M)` and `M` is square.
- Possible future option: `normalize: "none" | "row" | "column"` + percentage formatter.

## License

MIT — see `LICENSE`.
