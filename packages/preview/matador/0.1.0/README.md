# Matador

A package for parsing `.mat` files, supporting a subset of the version 6 and 7
formats. No guarantee is made about the correctness of the parser.

The currently supported features are:

- Floats
- Integers
- Charactes
- Booleans ("logic" values)
- Structs
- Non-MCOS objects
- Cell arrays
- Sparse matrices
- Multidimensional matrices and cell arrays

MCOS objects (which includes the string type) are not yet supported.

## Quick start

This library consists of a single function, `mat`, to load all the variables
stored in the file.

```typst
#import "@preview/matador:0.1.0": mat
#let data = mat(read("path/to/some/file.mat", encoding: none));
```

Matrices are stored in column major order, which is how the data is stored in
the file. To return row major matrices instead, use the `transpose` argument:

```typst
#let data = mat(read("path/to/some/file.mat", encoding: none), transpose: true);
```

## Documentation

```
mat(
  bytes,
  transpose: bool,
  keep-unit-dims: bool,
) -> any
```

Reads a `.mat` file and returns the contained data. Panics if the file is
invalid and adds placeholders for unsupported values.

- `source`: The raw contents of the file.

- `transpose`: Default: `false`. When `true`, the matrices are transposed along
  the first two dimensions, so that the data appears in row major order. Does
  not affect the other dimensions for multidimensional matrices, and does not
  affect sparse matrices.

- `keep-unit-dims`: Default: `false`. When `true`, the matrix dimensions with
  size `1` are kept. By default, those dimensions are omitted in the resulting
  object as it results in a large amount of nesting due to the format storing
  scalars and vectors as 2D matrices. Does not affect sparse matrices.
