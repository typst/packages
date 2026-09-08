# The `sprintf-package` Package
<div align="center">Version 0.1.0</div>

`%`-style (printf) str format for typst


## Getting Started


Simplest example:

```typ
#import "@preview/sprintf:0.1.0": *

#sprintf("%s", "Tom")
```

Another example:
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg" alt="demo showing usage of %06d, %.2f, etc">
</picture>


## Usage

A more in-depth description of usage:

Just use as if using Python's `%` of `str`

```typ
#import "@preview/sprintf:0.1.0": *

#let s-example = sprintf("%s-%.1f", "asd", 1.23)
```

## Additional Documentation and Acknowledgments

* This package is based on: https://pyformats.nimpylib.org/pyformats/percent
* `pyformats/percent` is an implementation in Nim of Python's printf-style string formatting:
  https://docs.python.org/3/library/stdtypes.html#printf-style-string-formatting
* This package also exposes `sprintf-map`, which formats strings using a mapping of names to values.
  Example: `sprintf-map("name=%(name)s", (name: "Alice"))`


### Development
> This section is for developers or advanced users only

To build this package locally,
there is the guide to show how to get the development environment up and running.

Firstly, install [Nim](https://nim-lang.org/install.html).

Then, compile plugin via:

```shell
$ cd lib
$ nimble run
$ cd ..
```

Afterward, entrypoint `src/lib.typ` along with its dependency `src/lib.wasm` shall be generated.

