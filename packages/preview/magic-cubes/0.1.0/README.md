# magic-cubes

magic-cubes is a [Typst](https://typst.app) package built on top of [CeTZ](https://typst.app/universe/package/cetz/) that allows you to create, manipulate, and render Rubik’s cubes of any size.

See the [manual](https://github.com/rodAlc24/magic-cubes/releases/download/v0.1.0/manual.pdf) for documentation.

## Examples

<table>
  <tr>
    <td style="background: white;">
      <a href="docs/examples/04.typ">
        <center>
          <img src="docs/examples/04.svg" width="100%" alt="example cube 04"/>
        </center>
      </a>
    </td>
    <td style="background: white;">
      <a href="docs/examples/05.typ">
        <center>
          <img src="docs/examples/05.svg" width="100%" alt="example cube 05"/>
        </center>
      </a>
    </td>
    <td style="background: white;">
      <a href="docs/examples/06.typ">
        <center>
          <img src="docs/examples/06.svg" width="100%" alt="example cube 06"/>
        </center>
      </a>
    </td>
  </tr>
  <tr>
    <td style="background: white;">
      <a href="docs/examples/07.typ">
        <center>
          <img src="docs/examples/07.svg" width="100%" alt="example cube 07"/>
        </center>
      </a>
    </td>
    <td style="background: white;">
      <a href="docs/examples/08.typ">
        <center>
          <img src="docs/examples/08.svg" width="100%" alt="example cube 08"/>
        </center>
      </a>
    </td>
    <td style="background: white;">
      <a href="docs/examples/09.typ">
        <center>
          <img src="docs/examples/09.svg" width="100%" alt="example cube 09"/>
        </center>
      </a>
    </td>
  </tr>
  <tr>
    <td style="background: white;">
      <a href="docs/examples/10.typ">
        <center>
          <img src="docs/examples/10.svg" width="100%" alt="example cube 10"/>
        </center>
      </a>
    </td>
    <td style="background: white;">
      <a href="docs/examples/11.typ">
        <center>
          <img src="docs/examples/11.svg" width="100%" alt="example cube 11"/>
        </center>
      </a>
    </td>
  </tr>
</table>

## Quick Start

To start using magic-cubes, add the following import at the top of your `.typ` file:

```typst
#import "@preview/magic-cubes:0.1.0": *
```

Creating and rendering a solved cube only requires two functions:

```typst
#draw-cube(cube())
```

![draw cube](docs/examples/01.svg)

You can apply an algorithm before rendering the cube:

```typst
#draw-cube(
  apply(
    cube(),
    "R U R' U'"
  )
)
```

![apply an algorithm](docs/examples/02.svg)

The package supports cubes of arbitrary size:

```typst
#draw-cube(
  cube(size: 5)
)
```

![arbitrary size](docs/examples/03.svg)

## Changelog

### v0.1.0

- Initial release
