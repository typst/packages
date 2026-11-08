# cink

A small signature-image helper for correspondence. Supply an image and a height
in points; the caller controls placement and the document layout.

```typst
#import "@preview/cink:0.1.4": signature-image
#let sample = bytes("<svg xmlns='http://www.w3.org/2000/svg' width='120' height='24'><path d='M2 18 Q25 2 40 16 T85 12 L118 8' fill='none' stroke='black'/></svg>")
#signature-image(sample, 20)
```

`signature-image(path, height-pt, width-pt: none)` returns Typst image content.
The first argument accepts the paths or image bytes accepted by Typst's `image`.
The height and optional width are numeric point values. When width is omitted,
Typst determines it from the image; supply a width when your application has
already calculated a size constraint. For files in your document, pass `read("signature.png", encoding: none)` so
the document explicitly loads the bytes. Image decoding and unsupported-image errors follow Typst's
`image` behavior. This helper does not create or authenticate signatures.

## License

Copyright 2026 Julian Y. Richard Corbet. [Apache-2.0](LICENSE).
