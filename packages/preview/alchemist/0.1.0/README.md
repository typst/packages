# alchemist

Alchemist is a typst package to draw skeletal formulae. It is based on the [chemfig](https://ctan.org/pkg/chemfig) package. The main goal of alchemist is not to reproduce one-to-one chemfig. Instead, it aims to provide an interface to achieve the same results in Typst.

<!--EXAMPLE(links)-->
````typ
#skeletize({
  molecule(name: "A", "A")
  single()
  molecule("B")
  branch({
    single(angle: 1)
    molecule(
      "W",
      links: (
        "A": double(stroke: red),
      ),
    )
    single()
    molecule(name: "X", "X")
  })
  branch({
    single(angle: -1)
    molecule("Y")
    single()
    molecule(
      name: "Z",
      "Z",
      links: (
        "X": single(stroke: black + 3pt),
      ),
    )
  })
  single()
  molecule(
    "C",
    links: (
      "X": cram-filled-left(fill: blue),
      "Z": single(),
    ),
  )
})
````
![links](https://raw.githubusercontent.com/Robotechnic/alchemist/master/images/links1.png)

Alchemist uses cetz to draw the molecules. This means that you can draw cetz shapes in the same canvas as the molecules. Like this:

<!--EXAMPLE(cetz)-->
````typ
#skeletize({
  import cetz.draw: *
  double(absolute: 30deg, name: "l1")
  single(absolute: -30deg, name: "l2")
  molecule("X", name: "X")
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
![cetz](https://raw.githubusercontent.com/Robotechnic/alchemist/master/images/cetz1.png)

## Usage

To start using alchemist, just use the following code:

```typ
#import "@preview/alchemist:0.1.0": *

#skeletize({
  // Your molecule here
})
```

For more information, check the [manual](https://raw.githubusercontent.com/Robotechnic/alchemist/master/doc/manual.pdf).

## Changelog

### 0.1.0

- Initial release
