:green_book: The [manual](https://github.com/Leedehai/typst-physics/blob/v0.9.6/physica-manual.pdf).
<p align="center">
<img width="545" alt="logo" src="https://github.com/Leedehai/typst-physics/assets/18319900/ed86198a-8ddb-4473-aed3-8111d5ecde60">
</p>

# The physica package for Typst (v0.9.6)

[![CI](https://github.com/Leedehai/typst-physics/actions/workflows/ci.yml/badge.svg)](https://github.com/Leedehai/typst-physics/actions/workflows/ci.yml)
[![Latest release](https://img.shields.io/github/v/release/Leedehai/typst-physics.svg?color=gold)][latest-release]

Available in the collection of [Typst packages](https://typst.app/docs/packages/): `#import "@preview/physica:0.9.6": *`

> physica _noun_.
> * Latin, study of nature

This [Typst](https://typst.app) package provides handy typesetting utilities for
natural sciences, including:
* Braces,
* Vectors and vector fields,
* Matrices, including Jacobian and Hessian,
* Smartly render `..^T` as transpose and `..^+` as dagger (conjugate transpose),
* Dirac braket notations,
* Common math functions,
* Differentials and derivatives, including partial derivatives of mixed orders with automatic order summation,
* Familiar "h-bar", tensor abstract index notations, isotopes, Taylor series term,
* Signal sequences i.e. digital timing diagrams.

## A quick look

See the [manual](https://github.com/Leedehai/typst-physics/blob/v0.9.6/physica-manual.pdf) for more details and examples.

![demo-quick](https://github.com/Leedehai/typst-physics/assets/18319900/4a9f40df-f753-4324-8114-c682d270e9c7)

A larger [demo.typ](https://github.com/Leedehai/typst-physics/blob/master/demo.typ):

![demo-larger](https://github.com/Leedehai/typst-physics/assets/18319900/75b94ef8-cc98-434f-be5f-bfac1ef6aef9)

## Using physica in your Typst document

### With `typst` package management (recommended)

See https://github.com/typst/packages. If you are using the Typst's web app,
packages listed there are readily available; if you are using the Typst
compiler locally, it downloads packages on-demand and caches them on-disk, see
[here](https://github.com/typst/packages#downloads) for details.

<p align="center">
<img src="https://github.com/Leedehai/typst-physics/assets/18319900/f2a3a2bd-3ef7-4383-ab92-9a71affb4e12" width="173" alt="effect">
</p>

```typst
// Style 1
#import "@preview/physica:0.9.6": *

$ curl (grad f), tensor(T, -mu, +nu), pdv(f,x,y,[1,2]) $
```

```typst
// Style 2
#import "@preview/physica:0.9.6": curl, grad, tensor, pdv

$ curl (grad f), tensor(T, -mu, +nu), pdv(f,x,y,[1,2]) $
```

```typst
// Style 3
#import "@preview/physica:0.9.6"

$ physica.curl (physica.grad f), physica.tensor(T, -mu, +nu), physica.pdv(f,x,y,[1,2]) $
```

### Without `typst` package management

Similar to examples above, but import with the undecorated file path like `"physica.typ"`.

## Typst version

The version requirement for the compiler is in [typst.toml](typst.toml)'s
`compiler` field. If you are using an unsupported Typst version, the compiler
will throw an error. You may want to update your compiler with `typst update`,
or choose an earlier version of the `physica` package.

Developed with compiler version:

```sh
$ typst --version
typst 0.13.0 (8dce676d)
```

## Manual

See the [manual](https://github.com/Leedehai/typst-physics/blob/v0.9.6/physica-manual.pdf) for a more comprehensive coverage, a PDF file
generated directly with the [Typst](https://typst.app) binary.

To regenerate the manual, use command

```sh
typst watch physica-manual.typ
```

## Contribution

* Bug fixes are welcome!

* New features: welcome as well. If it is small, feel free to create a pull
request. If it is large, the best first step is creating an issue and let us
explore the design together. Some features might warrant a package on its own.

* Testing: currently testing is done by closely inspecting the generated
[manual](https://github.com/Leedehai/typst-physics/blob/v0.9.6/physica-manual.pdf).
This does not scale well. I plan to add programmatic testing by comparing
rendered pictures with golden images.

## Change log

[changelog.md](https://github.com/Leedehai/typst-physics/blob/v0.9.6/changelog.md).

## License

* Code: the [MIT License](LICENSE.txt).
* Docs: the [Creative Commons BY-ND 4.0 license](https://creativecommons.org/licenses/by-nd/4.0/).

[latest-release]: https://github.com/Leedehai/typst-physics/releases/latest "The latest release"
