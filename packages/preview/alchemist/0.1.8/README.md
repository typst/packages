[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Falchemist%2Fmaster%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://github.com/Typsium/alchemist)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/alchemist/blob/master/LICENSE)
[![User Manual](https://img.shields.io/badge/manual-.pdf-purple)](https://raw.githubusercontent.com/Robotechnic/alchemist/master/doc/manual.pdf)

# alchemist

Alchemist is a typst package to draw skeletal formulae. It is based on the [chemfig](https://ctan.org/pkg/chemfig) package. The main goal of alchemist is not to reproduce one-to-one chemfig. Instead, it aims to provide an interface to achieve the same results in Typst.

<!--EXAMPLE(links)-->
````typ
#skeletize({
  fragment(name: "A", "A")
  single()
  fragment("B")
  branch({
    single(angle: 1)
    fragment(
      "W",
      links: (
        "A": double(stroke: red),
      ),
    )
    single()
    fragment(name: "X", "X")
  })
  branch({
    single(angle: -1)
    fragment("Y")
    single()
    fragment(
      name: "Z",
      "Z",
      links: (
        "X": single(stroke: black + 3pt),
      ),
    )
  })
  single()
  fragment(
    "C",
    links: (
      "X": cram-filled-left(fill: blue),
      "Z": single(),
    ),
  )
})
````
![links](https://raw.githubusercontent.com/Typsium/alchemist/master/tests/README-graphic1/ref/1.png)

Alchemist uses cetz to draw the molecules. This means that you can draw cetz shapes in the same canvas as the molecules. Like this:

<!--EXAMPLE(cetz)-->
````typ
#skeletize({
  import cetz.draw: *
  double(absolute: 30deg, name: "l1")
  single(absolute: -30deg, name: "l2")
  fragment("X", name: "X")
  hobby(
    "l1.50%",
    ("l1.start", 0.5, 90deg, "l1.end"),
    "l1.start",
    stroke: (paint: red, dash: "dashed"),
    mark: (end: ">"),
  )
  hobby(
    (to: "X.north", rel: (0, 1pt)),
    ("l2.end", 0.4, -90deg, "l2.start"),
    "l2.50%",
    mark: (end: ">"),
  )
})
````
![cetz](https://raw.githubusercontent.com/Typsium/alchemist/master/tests/README-graphic2/ref/1.png)

## Usage

To start using alchemist, just use the following code:

```typ
#import "@preview/alchemist:0.1.8": *

#skeletize({
  // Your molecule here
})
```

For more information, check the [manual](https://raw.githubusercontent.com/Robotechnic/alchemist/master/doc/manual.pdf).

## Changelog

### 0.1.8

- Fixed bus introduced in 0.1.7

### 0.1.7

- Updated cetz to version 0.4.1
- Added default values for `color` and `font` for `fragment` elements
- Added a `skeletize-config` function to create a `skeletize` function with a specific configuration
- Fixed a bug with cetz anchors not being correctly translated
- Added an `over` argument to links to allow hiding overlapped links

### 0.1.6

- Fixed the parenthesis height to work with the new typst version
- Renamed `molecule` into `fragment`
- Added support for charges and apostrophes in the string of a molecule
- Fixed the parenthesis auto positioning and alignment
- Added a new operator element and a new parameter in parenthesis to write resonance formulae

### 0.1.5

- Update to compiler 0.13.1 and Cetz 0.3.4

### 0.1.4

- Added the possibility to create Lewis formulae
- Added parenthesis element to create groups and polymer

### 0.1.3

- Added the possibility to add exponent in the string of a molecule.

### 0.1.2

- Added default values for link style properties.
- Updated `cetz` to version 0.3.1.
- Added a `tip-length` argument to dashed cram links.

### 0.1.1

- Exposed the `draw-skeleton` function. This allows to draw in a cetz canvas directly.
- Fixed multiples bugs that causes overdraws of links.

### 0.1.0

- Initial release
