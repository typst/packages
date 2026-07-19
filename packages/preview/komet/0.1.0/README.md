![komet2](https://github.com/user-attachments/assets/a45f2579-8e91-43ab-9ca0-e79e46ddb121)

---

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FMc-Zen%2Fkomet%2Fv0.1.0%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/komet)
[![ci](https://github.com/Mc-Zen/komet/actions/workflows/ci.yml/badge.svg)](https://github.com/Mc-Zen/komet/actions/workflows/ci.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Mc-Zen/komet/blob/main/LICENSE)


_Selected high-performance computations for Typst_


This package provides Rust implementations and a Typst wrapper for selected routines that are expensive to compute in pure Typst. 
In particular, this package supercharges the plotting package [Lilaq](https://lilaq.org/) by speeding up some essential computations. 


Currently, the following functions are available:
- [`komet.histogram`](#histogram)
- [`komet.boxplot`](#boxplot)
- [`komet.fft`](#fft)
- [`komet.ifft`](#ifft)
- [`komet.contour`](#contour)
- [`komet.thomas-algorithm`](#thomas-algorithm)

Contributions are welcome as long as they keep the binary size low (which also means they ideally add no crates as dependencies). 

## Repository structure

This repository contains two Rust crates in the `crates/` directory
- `komet`: A library that contains the source code for the actual algorithms (e.g., `contour`). 
- `komet-plugin`: Compiles to a WASM plugin for Typst. 

and a Typst package `komet` in `src/`. You can build the plugin via
```
rustup target add wasm32-unknown-unknown
cargo build --release --target wasm32-unknown-unknown
```


## Documentation


### Histogram
```typ
#komet.histogram(
    values: array,
    bins: int | array
)
```
Computes a histogram of the given array. Elements need to be of type `int` or `float`. Through the parameter `bins` you can either specify 
- the number of bins (evenly spaced over the value range) 
- or an array of bin edges: if n+1 bin edges are given, the values will be sorted into n bins where the lower edge is always included in the bin and the upper edge is always excluded except for the last bin. 


---
### Boxplot
```typ
#komet.boxplot(
    values: array,
    whisker-pos: float = 1.5
) -> dictionary
```
Computes the statistics needed to generate a box plot, including
- `median`
- first and third quartile `q1` and `q3`,
- `min` and `max`,
- lower and upper whisker positions `whisker-low` and `whisker-high`,
- `mean`, and
- an array of `outliers`. 

All of these values are returned together in form of a dictionary. 



---
### FFT
```typ
#komet.fft(
    values: array,
    norm = "backward"
)
```
Computes the Fourier transform of an array of real (`float`) or complex (real/imaginary pairs of `float`) values through the FFT algorithm. Returns an array of complex (i.e., real/imaginary `float` pairs) numbers. 

The normalization mode determines how the output is normalized. Options are:
- `"backward"`: the entire normalization of $1/N$ happens to the inverse DFT. 
- `"forward"`: the entire normalization of $1/N$ happens to the forward DFT. 
- `"ortho"`: the normalization is split across DFT and its inverse and to both the factor $1/\sqrt{N}$ is applied. 


---
### IFFT
```typ
#komet.ifft(
    values: array,
    norm = "backward"
)
```
Computes the inverse Fourier transform of an array of real (`float`) or complex (real/imaginary pairs of `float`) values. Returns an array of complex (i.e., real/imaginary `float` pairs) numbers. 

---
### Contour
```typ
#komet.contour(
    x: array,
    y: array,
    z: array,
    levels: int | float | array
)
```
Generates contours from intersecting a function on a 2d rectangular mesh
with planes parallel to the z-plane at `z=level`.

Here, 
- `x` and `y` are arrays of x and y coordinates, respectively, defining up a rectangular grid for the mesh, 
- `z` can either be a 
    - two-dimensional `m×n` array where `m` matches the number of y-values
    and `n` matches the number of x-values. 
    - or a function that takes an `x` and a `y` value and returns a 
    corresponding `z` coordinate.,
- and `levels` defines one or more z coordinates at which to compute the intersecting contour. 

The return value is an array with
1. a contour for each level, 
2. where each contour consists of an array of contour lines (there can be more 
   than one disjoint curve per level), 
3. where each contour line comprises a set of vertices `(x, y)` making up the curve. 


---
### Thomas Algorithm
```typ
#komet.thomas-algorithm(
    A: array,
    b: array
)
```
Solves a system of linear equations $A\vec{x} = \vec{b}$
where $A$ is a tridiagonal matrix and returns the solution $\vec{x}$.
See https://en.wikipedia.org/wiki/Tridiagonal_matrix_algorithm
for more information.

The expected format of the matrix is an array of arrays, in row-major order.
