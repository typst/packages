# panfig

Import PGF, TikZ, Matplotlib PGF, and SVG figures into Typst with native text
and math.

Labels and inline math are lifted into native Typst `text` and `math.equation`
elements so figures inherit your document fonts and work with normal `set` and
`show` rules. Vector geometry is coalesced into paint-ordered SVG layers, and
PGF/TikZ code that needs TeX runs in a bundled WebAssembly e-TeX engine.

Requires Typst 0.15 or later. [panfig on Typst Universe](https://typst.app/universe/package/panfig/)

## Usage

```typst
#import "@preview/panfig:0.1.0": panfig

#panfig(`\begin{tikzpicture}\draw[->] (0,0) -- (2,0);\end{tikzpicture}`)
```

You can also pass the path to a figure in your project. For figures with
linked files, bind `resolve` in your document so panfig can find each file
relative to the figure. Give linked images their file extensions (for example,
`\includegraphics{plot.png}`). To try the Matplotlib example below, copy
`hydrogen.pgf` and its four PNGs into an `examples/` directory in your project.
The [complete example](examples/hydrogen.typ) uses these same files.

```typst
#import "@preview/panfig:0.1.0": panfig
#let panfig = panfig.with(resolve: p => path(p))

#figure(
  panfig("examples/hydrogen.pgf", width: 8cm, height: 6cm, fit: "contain"),
  caption: [Hydrogen atom wavefunction probability densities],
)
```

Because lifted labels are ordinary Typst text, you can restyle or replace them
with a scoped `show` rule:

```typst
#import "@preview/panfig:0.1.0": panfig

#{
  show "peak": [$E_"max"$]
  panfig(```svg
    <svg xmlns="http://www.w3.org/2000/svg" width="80pt" height="30pt">
      <path d="M5 25 Q40 0 75 25" fill="none" stroke="#35a" stroke-width="2"/>
      <text x="40" y="10" text-anchor="middle" font-size="10">peak</text>
    </svg>
  ```)
}
```

## API

```typst
panfig(
  source,
  format: auto,
  resolve: none,
  width: auto,
  height: auto,
  fit: "cover",
)
```

- `source`: a caller-relative filename, Typst `path`, raw block, source string, or `bytes`.
- `width` and `height` size the whole figure, including labels. As with Typst's [`image`](https://typst.app/docs/reference/visualize/image/), lengths and percentages resolve on their respective axes. A fractional height such as `1fr` takes a share of the remaining vertical space. With both dimensions set to `auto`, the drawing uses its natural size up to the available space.
- `fit` controls how the drawing fills an area with a different aspect ratio. The default `"cover"` centers and crops it to fill the area. Use `"contain"` to show the entire drawing with space on either side or above and below, or `"stretch"` to scale each axis independently.
- `format`: `auto` (default), `"pgf"` (aliases: `"tikz"`, `"tex"`, `"latex"`), or `"svg"`.
- `resolve`: optional caller-site path resolver (`resolve: p => path(p)`). Not needed for self-contained figures; bind `#let panfig = panfig.with(resolve: p => path(p))` when importing figures that reference external files via `\input` or `\includegraphics` across package or directory boundaries.

## License

MIT. See [LICENSE](LICENSE) for project code. The bundled TeX runtime in `latex.wasm` builds on [rust_tikz](https://crates.io/crates/rust_tikz/0.1.0) ([rust-tikz.LICENSE](rust-tikz.LICENSE)), LaTeX2e ([LPPL](https://www.latex-project.org/lppl/)), and PGF/TikZ ([license](https://tikz.dev/license)).
