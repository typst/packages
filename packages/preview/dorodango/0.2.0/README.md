# dorodango

[![Manual](https://img.shields.io/badge/User_manual-blue)](./docs/manual.pdf)
[![GitHub repository](https://img.shields.io/badge/GitHub-Repository-black?logo=github)](https://github.com/apcamargo/dorodango)

`dorodango` is a Typst package for drawing squircles.

## Background

Squircles are rounded rectangles with corners that blend smoothly into their straight edges. Unlike a standard rounded rectangle, which transitions abruptly from a straight edge to a circular arc, a squircle changes curvature gradually around each corner. As a result, a squircle reads as one unified shape, rather than a square that has simply had its corners clipped or rounded off.

# Documentation

Refer to the [manual](./docs/manual.pdf) for a full API reference and usage examples.

## Quickstart

In a Typst document, import the `dorodango` package:

```typ
#import "@preview/dorodango:0.2.0": *
```

`dorodango` provides a `squircle` function that mirrors the built-in `rect` element but adds parameters for controlling corner smoothing. The example below compares a rectangle and a squircle of the same size and corner radius, illustrating how their corner-to-edge transitions differ.

```typ
#grid(
  columns: (1fr, 1fr),
  gutter: 14pt,
  rect(width: 90pt, height: 60pt, radius: (top-left: 50%), fill: aqua),
  squircle(
    width: 90pt,
    height: 60pt,
    radius: (top-left: 50%),
    smoothing: 100%,
    fill: aqua,
  ),
)
```

<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="assets/rectangle-vs-squircle-dark.svg"
  />
  <img
    src="assets/rectangle-vs-squircle-light.svg"
    alt="Side-by-side comparison of a rounded rectangle and a squircle with the same size and corner radius. The rectangle's top-left corner has an abrupt transition from straight edge to circular arc, while the squircle's corner curves smoothly into the edges."
  />
</picture>

## Customize squircle corners

Two parameters control the appearance of a squircle's corners:

- `smoothing` controls how gradually a straight edge blends into its rounded corner. At `0%`, the shape is an ordinary rounded rectangle. Higher values make the transition more gradual, and at `100%` the circular arc has zero length and the two Bézier transitions meet at a single point.
- `preserve-smoothing` determines how the corner adapts when its requested radius and smoothing do not both fit.

The shapes below share the same size and radius. The final shape preserves its requested smoothing after it no longer fits.

```typ
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 14pt,
  squircle(
    width: 85pt,
    height: 55pt,
    radius: 20pt,
    smoothing: 5%,
    fill: aqua,
  ),
  squircle(
    width: 85pt,
    height: 55pt,
    radius: 20pt,
    smoothing: 100%,
    fill: aqua,
  ),
  squircle(
    width: 85pt,
    height: 55pt,
    radius: 20pt,
    smoothing: 100%,
    preserve-smoothing: true,
    fill: aqua,
  ),
)
```

<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="assets/smoothing-comparison-dark.svg"
  />
  <img
    src="assets/smoothing-comparison-light.svg"
    alt="Three squircles of the same size and corner radius. The first and second set the smoothing parameter to 5% and 100%, respectively. The third adds preserve-smoothing, retaining full smoothing and looking visibly compressed at the corners."
  />
</picture>
