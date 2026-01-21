# The physica package for Typst

[![CI](https://github.com/Leedehai/typst-physics/actions/workflows/ci.yml/badge.svg)](https://github.com/Leedehai/typst-physics/actions/workflows/ci.yml)
[![Latest release](https://img.shields.io/github/v/release/Leedehai/typst-physics.svg?color=gold)][latest-release]

:green_book: The [manual](https://github.com/Leedehai/typst-physics/blob/master/physica-manual.pdf).

Available in the collection of [Typst packages](https://typst.app/docs/packages/): `#import "@preview/physica:0.9.0": *`

> physica _noun_.
> * Latin, study of nature

This [Typst](https://typst.app) package provides handy typesetting utilities for
natural sciences, including:
* Braces,
* Vectors and vector fields,
* Matrices,
* Dirac braket notations,
* Common math functions,
* Differentials and derivatives, including partial derivatives of mixed orders with automatic order summation,
* Familiar "h-bar", tensor abstract index notations, isotopes,
* Signal sequences i.e. digital timing diagrams.

:warning: [Typst](https://typst.app) is in beta and evolving, and this package
evolves with it. As a result, no backward compatibility is guaranteed yet.

:information_source: In response to the official Typst package [guideline](https://github.com/typst/packages/tree/main#submission-guidelines)
"Package names should not be merely descriptive to create level grounds for
everybody", this package was renamed from `physics` to `physica`.

## A quick look

See the [manual](https://github.com/Leedehai/typst-physics/blob/master/physica-manual.pdf) for more details.

![demo-quick](https://github.com/Leedehai/typst-physics/assets/18319900/4a9f40df-f753-4324-8114-c682d270e9c7)

![demo-larger](https://github.com/Leedehai/typst-physics/assets/18319900/3a5cc613-bf36-4b13-ac28-790150c5fb94)

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
#import "@preview/physica:0.9.0": *

$ curl (grad f), tensor(T, -mu, +nu), pdv(f,x,y,[1,2]) $
```

```typst
// Style 2
#import "@preview/physica:0.9.0": curl, grad, tensor, pdv

$ curl (grad f), tensor(T, -mu, +nu), pdv(f,x,y,[1,2]) $
```

```typst
// Style 3
#import "@preview/physica:0.9.0"

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
typst 0.10.0 (70ca0d25)
```

## Manual

See the manual [physica-manual.pdf](https://github.com/Leedehai/typst-physics/blob/master/physica-manual.pdf) for a more comprehensive coverage, a PDF file
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
[physica-manual.pdf](https://github.com/Leedehai/typst-physics/blob/master/physica-manual.pdf). This does not scale well. I plan to add programmatic
testing by comparing rendered pictures with golden images.

## License

* Code: the [MIT License](LICENSE.txt).
* Docs: the [Creative Commons BY-ND 4.0 license](https://creativecommons.org/licenses/by-nd/4.0/).

[latest-release]: https://github.com/Leedehai/typst-physics/releases/latest "The latest release"
