# MuchPDF

[MuchPDF][MuchPDF] allows you to insert PDF files as images into your Typst document.

Huge thanks to the contributors of the [MuPDF][MuPDF] library,
without which this project would not be possible!

## Usage

Import the `muchpdf` function, and give it the PDF data:

```typ
#import "@preview/muchpdf:0.1.0": muchpdf

#muchpdf(read("graphic.pdf", encoding: none))
```

---

The parameters provided by [image][image] do also work as expected:

```typ
#muchpdf(
  read("dolphins.pdf", encoding: none),
  width: 10cm,
  alt: "Dolphin population over time",
)
```

---

You can increase the render scale, if desired. This is useful if the PDF
contains images or gradients and you need a higher resolution.

```typ
#muchpdf(
  read("graphic.pdf", encoding: none),
  scale: 2.0,
)
```

---

If you do not want to insert every page into your document, you can provide the
`pages` argument. Note that it starts at zero, not one.

```typ
#let data = read("document.pdf", encoding: none)
#muchpdf(data, pages: 3)
#muchpdf(data, pages: (0, 2, 10))
#muchpdf(data, pages: (start: 5, end: 9))
#muchpdf(data, pages: (start: 5, end: 9, step: 2)) // every second page
#muchpdf(data, pages: (0, 2, (start: 4, end: 7))) // combine lists and ranges
```

## Questions

> I'm getting the following error message:
> ```
> error: plugin panicked: out of bounds memory access
> ```

You are likely rendering too many pages at once, causing the memory in the
plugin to fill up too much. Try calling the `muchpdf` function several times
with different ranges instead:
```typ
#let end = 50 // The number of pages you want to output.
#let step = 10 // Choose this value depending on the complexity of the document.
#for i in range(0, end, step: step) {
  muchpdf(data, pages: (start: i, end: calc.min(end, i + step - 1)))
}
```

> I'm getting the following error message:
> ```
> error: plugin panicked: wasm `unreachable` instruction executed
> ```

This most likely means that the PDF file you supplied is not valid.
If you don't think this is true, please do open an issue on the [Issue Tracker][Issue Tracker].

> Why is that error message so bad?

That's because of how hacky MuchPDF actually is. It overrides a number of
functions supplied by emscripten, which includes part of the error handling.
I don't think I can do much about it without significant time investments.

> My beautiful gradients are pixelated in the output. :(

MuPDF rasterizes some things in its SVG output, which does include gradients.
This is to be expected and there isn't much MuchPDF or MuPDF can do about it.
Increasing the scale parameter might lessen the impact of this, though.

[MuchPDF]: https://github.com/frozolotl/muchpdf
[MuPDF]: https://mupdf.com/
[image]: https://typst.app/docs/reference/visualize/image
[Issue Tracker]: https://github.com/frozolotl/muchpdf/issues
