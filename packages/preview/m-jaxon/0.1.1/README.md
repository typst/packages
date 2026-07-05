# [M-Jaxon](https://github.com/Enter-tainer/m-jaxon)

Render LaTeX equation in typst using MathJax.

**Note:** This package is made for fun and to demonstrate the capability of typst plugins.
And it is **slow**. To actually convert LaTeX equations to typst ones, you should use **pandoc** or **texmath**.

![](mj.svg)


````typ
#import "./typst-package/lib.typ" as m-jaxon
// Uncomment the following line to use the m-jaxon from the official package registry
// #import "@preview/m-jaxon:0.1.1"

= M-Jaxon

Typst, now with *MathJax*.

The equation of mass-energy equivalence is often written as $E=m c^2$ in modern physics.

But we can also write it using M-Jaxon as: #m-jaxon.render("E = mc^2", inline: true)

````

## Limitations

- The baseline of the inline equation still looks a bit off.


## Documentation

### `render`

Render a LaTeX equation string to an svg image. Depending on the `inline` argument, the image will be rendered as an inline image or a block image.

#### Arguments

* `src`: `str` or `raw` block - The LaTeX equation string
* `inline`: `bool` - Whether to render the image as an inline image or a block image

#### Returns

The image, of type `content`
