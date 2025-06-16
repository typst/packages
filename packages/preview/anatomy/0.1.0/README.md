# Anatomy

*Anatomy of a Font*. Visualise metrics.

Import the `anatomy` package:

```typst
#import "@preview/anatomy:0.1.0": metrics
```

## Samples

`metrics(72pt, "EB Garamond", "Typewriter")` will be rendered as follows:

![](https://github.com/E8D08F/packages/raw/main/packages/preview/anatomy/0.1.0/img/export-1.svg)

Additionally, a closure using `metrics` dictionary as parameter can be specified for further typesetting:

```typ
metrics(54pt, "一點明體", "電傳打字機",
  typeset: metrics => table(
    columns: 2,
    ..metrics.pairs().flatten().map(x => [ #x ])
  )
)
```

It will generate:

![](https://github.com/E8D08F/packages/raw/main/packages/preview/anatomy/0.1.0/img/export-2.svg)

**Remark**: To typeset CJK text, adopting font’s ascender/descender as
`top-edge`/`bottom-edge` makes more sense in some cases. As for most
CJK fonts, the difference between ascender and descender heights will
be exact 1em.

Tested with `metrics(54pt, "Hiragino Mincho ProN", "テレタイプ端末")`:

![](https://github.com/E8D08F/packages/raw/main/packages/preview/anatomy/0.1.0/img/export-3.svg)
