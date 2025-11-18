# Typst Voronay

A typst library to generate the Delaunay triangulation of points as well as its dual, the Voronoi diagram.

## Example

![voronay_example](./example.svg)

The source of this example can be found [here](https://github.com/Lieunoir/typst-voronay/blob/main/example.typ)

## Usage

```typst
#import "@preview/voronay:0.1.0": *

// Generate points
#let points = range(100).map(r2-sequence)
// Sorts the point along a Hilbert curve (significantly improves the performance of the triangulation)
#let points = hilbert-point-sort(points)
// Compute the Delaunay triangulation
#let faces = delaunay-triangulate(points)

// Compute the triangulation dual (the Voronoi diagram)
#let dual-vertices = get-circumcenters(points, faces)
#let dual-edges = get-dual-edges(faces)

// Draw the triangulation and Voronoi diagram...
```

### Noise generation

The two pseudorandom sequences `r2-sequence` and `halton-2-3` are provided. Both should fill a square of size 1 rather uniformly, with the former giving a result with more regularity than the latter.

### Performance and stability

This is not a wasm, and while the triangulation has been decently optimized, expect it to take hundreds of milliseconds to seconds for 100 to 1000 points.

The method relies on an external face with vertices "at infinity", which for now is emulated by vertices with positions at 10e7. This should handle most cases well, but may not always be stable.
