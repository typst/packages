# `k-mapper` for Typst (v0.1.0)

📖 See the `k-mapper` Manual [here](https://github.com/derekchai/typst-karnaugh-map/blob/437f80880eceb441ccecff7343dcc5183109bad7/karnaugh-map-manual.pdf)!

This is a package for adding Karnaugh maps into your Typst projects.

## Features

- 2-variable (2 by 2) Karnaugh maps
- 3-variable (2 by 4) Karnaugh maps
- 4-variable (4 by 4) Karnaugh maps

## Getting Started

Simply import `k-mapper` using the Typst package manager to begin using `k-mapper` within your Typst documents.

```typst
#import "@preview/k-mapper:0.1.0": *
```

## Example

```typst
#karnaugh(
    variables: ($A$, $B$, $C$, $D$),
    manual-terms: (
        "0", "0", "0", "0", 
        "1", "1", "1", "1", 
        "0", "1", "1", "1",
        "0", "1", "0", "0"
    ),
    implicants: ((4, 5, 6, 7), (9, 13), (6, 7, 10, 11))
)
```

![Code result](https://github.com/derekchai/typst-karnaugh-map/blob/f1ec99d51b1e28e53c041e0d2a6220480d0dc52e/readme-example.png?raw=true)


For more detailed documentation and examples, including function parameters, see the Manual [PDF](https://github.com/derekchai/typst-karnaugh-map/blob/437f80880eceb441ccecff7343dcc5183109bad7/karnaugh-map-manual.pdf) and [Typst file](https://github.com/derekchai/typst-karnaugh-map/blob/437f80880eceb441ccecff7343dcc5183109bad7/karnaugh-map-manual.typ) in the [Github repo](https://github.com/derekchai/typst-karnaugh-map).