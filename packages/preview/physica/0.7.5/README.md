# The physica module (for physics)

Current semantic version: `0.7`. [Manual](https://github.com/Leedehai/typst-physics/blob/master/physica-manual.pdf).

Available at [https://typst.app/docs/packages/](https://typst.app/docs/packages/).

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

See the [manual](https://github.com/Leedehai/typst-physics/blob/master/physica-manual.pdf) for more details.

![demo](https://user-images.githubusercontent.com/18319900/236073825-e91b4601-7e92-490b-a7e4-e9e405a2147b.png)

## Using phyiscs in your Typst document

### With `typst` package management (recommended)

See https://github.com/typst/packages.

```
#import "@preview/physica:0.7.5": *

$op("curl")(op("grad") f) = curl (grad f)$
```

### Without `typst` package management

* To use the `physics` package, simply insert `#import "physics.typ": *` at the
beginning of your document.
* To reduce the possibility of name collisions, you may want to import the
package under name scope `physics`:
  ```
  #import "physics.typ"

  $op("curl")(op("grad") f) = physics.curl (physics.grad f)$
  ```
* You may also import names specifically:
  ```
  #import "physics.typ": curl, grad

  $op("curl")(op("grad") f) = curl (grad f)$
  ```

## Manual

See the manual [physics-manual.pdf](https://github.com/Leedehai/typst-physics/blob/master/physica-manual.pdf) for a more comprehensive coverage, a PDF file
generated directly with the [Typst](https://typst.app) binary.

CLI Version:

```sh
$ typst --version
typst 0.6.0 (2dfd44fe)
```

To regenerate the manual, use command

```sh
typst watch physics-manual.typ
```

## Contribution

* Bug fixes are welcome!

* New features: welcome as well. If it is small, feel free to create a pull
request. If it is large, the best first step is creating an issue and let us
explore the design together. Some features might warrant a package on its own.

* Testing: currently testing is done by closely inspecting the generated
[physics-manual.pdf](physics-manual.pdf). This does not scale well. I plan to add programmatic
testing by comparing rendered pictures with golden images.

## License

* Code: the [MIT License](LICENSE.txt).
* Docs: the [Creative Commons BY-ND 4.0 license](https://creativecommons.org/licenses/by-nd/4.0/).
