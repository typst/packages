# The physica module (for physics)

[![CI](https://github.com/Leedehai/typst-physics/actions/workflows/ci.yml/badge.svg)](https://github.com/Leedehai/typst-physics/actions/workflows/ci.yml)
[![Latest release](https://img.shields.io/github/v/release/Leedehai/typst-physics.svg?color=gold)][latest-release]

The [manual](physica-manual.pdf).
Download releases [here](https://github.com/Leedehai/typst-physics/releases/).

Available at the official collection of [Typst packages](https://typst.app/docs/packages/).

This [Typst](https://typst.app) package provides handy typesetting utilities for
physics, including:
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

See the [manual](physica-manual.pdf) for more details.

![demo](https://user-images.githubusercontent.com/18319900/236073825-e91b4601-7e92-490b-a7e4-e9e405a2147b.png)

## Using phyiscs in your Typst document

### With `typst` package management (recommended)

See https://github.com/typst/packages.

<p align="center">
<img src="https://github.com/Leedehai/typst-physics/assets/18319900/f2a3a2bd-3ef7-4383-ab92-9a71affb4e12" width="173" alt="effect">
</p>

```
// Style 1
#import "@preview/physica:0.8.0": *

$ curl (grad f), tensor(T, -mu, +nu), pdv(f,x,y,[1,2]) $
```

```
// Style 2
#import "@preview/physica:0.8.0": curl, grad, tensor, pdv

$ curl (grad f), tensor(T, -mu, +nu), pdv(f,x,y,[1,2]) $
```

```
// Style 3
#import "@preview/physica:0.8.0"

$ physica.curl (physica.grad f), physica.tensor(T, -mu, +nu), physica.pdv(f,x,y,[1,2]) $
```

### Without `typst` package management

Similar to examples above, but import with the undecorated file path like `"physica.typ"`.

## Manual

See the manual [physica-manual.pdf](physica-manual.pdf) for a more comprehensive coverage, a PDF file
generated directly with the [Typst](https://typst.app) binary.

CLI Version:

```sh
$ typst --version
typst 0.8.0 (360cc9b9)
```

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
[physica-manual.pdf](physica-manual.pdf). This does not scale well. I plan to add programmatic
testing by comparing rendered pictures with golden images.

## License

* Code: the [MIT License](LICENSE.txt).
* Docs: the [Creative Commons BY-ND 4.0 license](https://creativecommons.org/licenses/by-nd/4.0/).

[latest-release]: https://github.com/Leedehai/typst-physics/releases/latest "The latest release"
