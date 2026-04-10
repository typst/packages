# `k-mapper` for Typst (1.2.0)

📖 See the `k-mapper` Manual [here](https://github.com/derekchai/k-mapper/blob/main/manual.pdf)! The Manual features much more documentation, and is typeset using Typst.

This is a package for adding Karnaugh maps into your Typst projects.

See the changelog for the package [here](https://github.com/derekchai/k-mapper/blob/main/changelog.md).

## Features

- 2-variable (2 by 2) Karnaugh maps
- 3-variable (2 by 4) Karnaugh maps
- 4-variable (4 by 4) Karnaugh maps

## Getting Started

Simply import `k-mapper` using the Typst package manager to begin using `k-mapper` within your Typst documents.

```typst
#import "@preview/k-mapper:1.2.0": *
```

## Example

```typst
  #karnaugh(
    16,
    x-label: $C D$,
    y-label: $A B$,
    manual-terms: (
      0, 1, 2, 3, 4, 5, 6, 7, 8, 
      9, 10, 11, 12, 13, 14, 15
    ),
    implicants: ((5, 7), (5, 13), (15, 15)),
    vertical-implicants: ((1, 11), ),
    horizontal-implicants: ((4, 14), ),
    corner-implicants: true,
  )
  ```

![Code result](https://github.com/derekchai/k-mapper/blob/005cb0a839499d0dfa90ee48d2128d41e582d755/readme-example.png)


For more detailed documentation and examples, including function parameters, see the Manual [PDF](https://github.com/derekchai/k-mapper/blob/1f334d9e0f02cc656c01835302474bf728db9f80/manual.pdf) and [Typst file](https://github.com/derekchai/k-mapper/blob/1f334d9e0f02cc656c01835302474bf728db9f80/manual.typ) in the [Github repo](https://github.com/derekchai/typst-karnaugh-map).
