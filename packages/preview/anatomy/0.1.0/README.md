# Anatomy

*Anatomy of a Font*. Visualise metrics.

Import the `anatomy` package:

```typst
#import "@preview/anatomy:0.1.0": metrics
```

## Samples

`metrics(72pt, "EB Garamond", "Typewriter")` will be rendered as follows:

![](https://github.com/E8D08F/packages/raw/main/packages/preview/anatomy/0.1.0/img/export1.svg)

**Remark**: To typeset CJK text, adopting font’s ascender/descender as
`top-edge`/`bottom-edge` makes more sense in some cases. As for most
CJK fonts, the difference between ascender and descender heights will
be exact 1em.

Tested with `metrics(54pt, "Hiragino Mincho ProN", "電傳打字機")`:

![](https://github.com/E8D08F/packages/raw/main/packages/preview/anatomy/0.1.0/img/export2.svg)
