# meshpad

Configurable grid backgrounds for printable worksheets, in [Typst](https://typst.app),
drawn with [CeTZ](https://github.com/cetz-package/cetz). Square grid, ruled paper
(horizontal or vertical lines only) or dot grid, with an optional darker "major"
line/dot every N steps — the classic look of engineering/milimetrado paper.

<p align="center">
  <img src="https://raw.githubusercontent.com/13Stokes31/meshpad/v0.1.0/gallery/g1.png" width="47%" alt="Square grid with major lines every 2 steps">
  <img src="https://raw.githubusercontent.com/13Stokes31/meshpad/v0.1.0/gallery/g2.png" width="47%" alt="Dot grid with major dots every 2 steps">
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/13Stokes31/meshpad/v0.1.0/gallery/g3.png" width="47%" alt="Ruled paper, horizontal lines only">
  <img src="https://raw.githubusercontent.com/13Stokes31/meshpad/v0.1.0/gallery/g4.png" width="47%" alt="Custom background and line colors">
</p>

## Usage

```typ
#import "@preview/meshpad:0.1.0": grid-paper

#grid-paper(size: (6, 4), kind: "square", step: 0.5, major-every: 2)
```

This is exactly the first image in the gallery above. Use it standalone, wrapped
in a `box`/`place` behind other content, or as a whole-page background —
`meshpad` doesn't need to know about pages, Typst already handles that:

```typ
#set page(background: grid-paper(size: (21, 29.7), step: 0.5, major-every: 2))
```

## Parameters

| Parameter      | Default   | Meaning |
|----------------|-----------|---------|
| `size`         | `(10, 10)`| `(width, height)`. Plain numbers are CeTZ units (cm by convention), but you can pass explicit Typst lengths instead — `(5cm, 3cm)`, `(4in, 3in)`, etc. |
| `kind`         | `"square"`| `"square"` (lines) or `"dot"` (dot grid). |
| `lines`        | `"both"`  | `"both"`, `"horizontal"` or `"vertical"` — only meaningful for `kind: "square"`; `"horizontal"` gives ruled/pautado paper. |
| `step`         | `0.5`     | Spacing between minor lines/dots. Same rule as `size`: a plain number is cm, or pass an explicit length like `5mm`. |
| `major-every`  | `none`    | Every Nth line/dot is drawn as "major" (thicker/darker). `none` disables it. |
| `background`   | `none`    | Fill color behind the pattern. `none` is transparent. |
| `color`        | `gray`    | Color of minor lines/dots. |
| `major-color`  | `none`    | Color of major lines/dots. `none` defaults to a darker shade of `color`. |
| `frame`        | `true`    | Draw a border around the rectangle. |

### Sizes that aren't a multiple of the step

`size` and `step` are independent, and neither is silently rounded: the grid draws
every full cell that fits and leaves the remainder as a narrower strip against the
frame. It never overflows.

```typ
#grid-paper(size: (7, 3), step: 0.6, major-every: 3)
```

Here 7 ÷ 0.6 = 11.67, so you get 11 columns of 0.6 (6.6 wide in total) and a 0.4
strip left over on the right; the height divides exactly (3 ÷ 0.6 = 5), so there is
no strip at the top. That is the same thing real graph paper does at the edge of the
page. For a flush fit, pick a `size` that is a whole multiple of `step` — `(7.2, 3)`
in this example.

## Compatibility

- Typst `>= 0.14.0`
- CeTZ `0.5.2`

## Known limitations

See [`ROADMAP.md`](https://github.com/13Stokes31/meshpad/blob/v0.1.0/ROADMAP.md) for
the current limits and the improvements on the list.

## License

[MIT](LICENSE).
