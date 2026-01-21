# shadowed

Box shadows for [Typst](https://typst.app/).

## Usage

```typ
#import "@preview/shadowed:0.1.2": shadowed

#set par(justify: true)

#shadowed(radius: 4pt, inset: 12pt)[
    #lorem(50)
]
```

![Example](examples/lorem.png)

## Reference

The `shadowed` function takes the following arguments:

- **blur: Length** - The blur radius of the shadow. Also adds a padding of the same size.
- **radius: Length** - The corner radius of the inner block and shadow.
- **color: Color** - The color of the shadow.
- **inset: Length** - The inset of the inner block.
- **fill: Color** - The color of the inner block.

## Credits

This project was inspired by [Harbinger](https://github.com/typst-community/harbinger).
