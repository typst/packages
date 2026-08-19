# Running the right-to-left examples

`example-rtl.typ` and `showcase-rtl.typ` need `blockst` 0.3.0 or newer —
that is the first release with right-to-left layout, the Arabic locale and
the `grayscale` theme. They compile like every other example:

```sh
typst compile examples/example-rtl.typ
```

## Fonts

The examples ask for `Noto Sans Arabic` and `Noto Sans Hebrew`. Without them
Typst falls back to whatever font covers the script; the block layout is
unaffected, but install them for the intended look:

```sh
typst compile examples/example-rtl.typ --font-path /path/to/fonts
```

The block labels themselves are measured with the family blockst is
configured for (`Helvetica Neue` by default), so pass the same family to
`set-blockst(font: ...)` if you change it — a `#set text(font: ...)` alone
changes what is drawn but not what was measured.
