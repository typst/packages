# Periodic Table for Typst

[![Test](https://github.com/GiggleLiu/periodic-table/actions/workflows/test.yml/badge.svg)](https://github.com/GiggleLiu/periodic-table/actions/workflows/test.yml)

A Typst package for rendering periodic tables of elements with two style options:

1. **`periodic-table()`** - Compact version for slides and handouts
2. **`periodic-table-detailed()`** - Professional ACS-style version with full details

## Installation

```typst
#import "@preview/periodic-table:0.1.0": periodic-table, periodic-table-detailed
```

Or for local use:

```typst
#import "lib.typ": periodic-table, periodic-table-detailed
```

## Usage

### Compact Version

```typst
#periodic-table()
```

![Compact periodic table](images/compact.png)

With custom parameters:

```typst
#periodic-table(length: 0.8cm, size: 1.0, gap: 0.1)
```

### Detailed (ACS-style) Version

```typst
#periodic-table-detailed()
```

![Detailed periodic table](images/detailed.png)

With custom parameters:

```typst
#periodic-table-detailed(length: 0.8cm, size: 1.8, gap: 0.15)
```

## Parameters

### Common Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `length` | `0.8cm` | Base length unit for the canvas |
| `size` | `1.0` (compact) / `1.8` (detailed) | Size of each element box |
| `gap` | `0.1` (compact) / `0.15` (detailed) | Gap between element boxes |
| `show-legend` | `true` | Whether to show the category legend |
| `highlighted` | `()` | Array of atomic numbers to highlight |
| `highlight-stroke` | `luma(20%) + 3pt` | Stroke style for highlighted elements (dark gray) |

### Function-Specific Parameters

| Function | Parameter | Default | Description |
|----------|-----------|---------|-------------|
| `periodic-table-detailed` | `show-labels` | `true` | Whether to show group/period labels |

### Highlighting Elements

You can highlight specific elements by passing their atomic numbers:

```typst
// Highlight Rydberg atom elements: Rb, Cs, Sr
#periodic-table-detailed(
  highlighted: (37, 55, 38),
)
```

![Rydberg atoms highlighted](images/rydberg.png)

```typst
// Highlight noble gases
#periodic-table(highlighted: (2, 10, 18, 36, 54, 86, 118))

// Highlight with custom color
#periodic-table(
  highlighted: (26, 27, 28, 29),  // Fe, Co, Ni, Cu
  highlight-stroke: blue + 3pt
)

// Minimal compact table without title and legend
#periodic-table(show-title: false, show-legend: false)

// Minimal detailed table without labels and legend
#periodic-table-detailed(show-labels: false, show-legend: false)
```

## Features

- All 118 elements with atomic numbers, symbols, names, and atomic masses
- Color-coded by element category (alkali metals, noble gases, etc.)
- Standard periodic table layout with lanthanoids and actinoids separated
- Built on the `cetz` package for high-quality vector graphics

## Dependencies

- [cetz](https://typst.app/universe/package/cetz) version 0.4.2

## License

MIT
