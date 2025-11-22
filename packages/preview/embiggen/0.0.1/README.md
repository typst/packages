# embiggen

Get LaTeX-like delimeter sizing in Typst!

## Usage

```typst
#import "@preview/embiggen:0.0.1": *

= embiggen

Here's an equation of sorts:

$ {lr(1/2x^2|)^(x=n)_(x=0) + (2x+3)} $

And here are some bigger versions of it:

$ {big(1/2x^2|)^(x=n)_(x=0) + big((2x+3))} $
$ {Big(1/2x^2|)^(x=n)_(x=0) + Big((2x+3))} $
$ {bigg(1/2x^2|)^(x=n)_(x=0) + bigg((2x+3))} $
$ {Bigg(1/2x^2|)^(x=n)_(x=0) + Bigg((2x+3))} $

And now, some smaller versions (#text([#link("https://x.com/tsoding/status/1756517251497255167", "cAn YoUr LaTeX dO tHaT?")], fill: rgb(50, 20, 200), font: "Noto Mono")):

$ small(1/2x^2|)^(x=n)_(x=0) $
$ Small(1/2x^2|)^(x=n)_(x=0) $
$ smalll(1/2x^2|)^(x=n)_(x=0) $
$ Smalll(1/2x^2|)^(x=n)_(x=0) $
```

## Functions

### big(...)

Applies a scale factor of `125%` to `#lr` pre-determined scale. Delimeters are enlarged by this amount compared to what `#lr` would normally do.

### Big(...)

Like `big(...)`, but applies a scale factor of `156.25%`.

### bigg(...)

Like `big(...)`, but applies a scale factor of `195.313%`.

### Bigg(...)

Like `big(...)`, but applies a scale factor of `244.141%`.

### small(...)

Applies a scale factor of `80%` to `#lr` pre-determined scale. Delimeters are shrunk by this amount compared to what `#lr` would normally do. This does *not* exist in standard LaTeX, but is necessary in this package because these functions scale the output of `#lr`, so delimeter sizes will get larger depending on the content.

### Small(...)

Like `small(...)`, but applies a scale factor of `64%`.

### smalll(...)

Like `small(...)`, but applies a scale factor of `51.2%`.

### Smalll(...)

Like `small(...)`, but applies a scale factor of `40.96%`.
