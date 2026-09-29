# Pardioid

Pardioid (parametric cardioid) is a Typst package for drawing on a canvas using parametric curves. It features an adaptive sampling algorithm, an edge detection algorithm ([minmod edge detection](https://doi.org/10.1137/S0036142903435259)), and a consistent design. The name Pardioid comes from the fact that my motivation for developing this package was to draw a cardioid (pardioid.typ) `(*^▽^*)`.

Its design is inspired by [CeTZ](https://typst.app/universe/package/cetz) and [JAnim](https://github.com/jkjkil4/JAnim), a library for programmatic animation.

You can import pardioid by:
```typ
#import "@preview/pardioid:0.1.0": *
```

Here is the [manual](https://github.com/DevlinNul/pardioid/releases/download/v0.1.0/manual.pdf).

## Quick Start

```typ
// /assets/pardioid.typ
#import "@preview/pardioid:0.1.0": *

#set page(width: auto, height: auto, margin: 0pt)

#canvas(viewport: auto, length: 5em, inset: 2pt, {
  import draw: *
  import calc: *
  merge-curve(fill: gradient.linear(..color.map.turbo, angle: -67deg), {
    curve(
      vector-fn: {
        let den(t) = 4 - 3 * pow(cos(t), 2)
        let x-num(t) = 8 * pow(sin(t), 3)
        let y-num(t) = -3 * cos(t) * (3 - 2 * pow(cos(t), 2))
        t => (x-num(t) / den(t), y-num(t) / den(t))
      },
      clip-box: none,
      t-range: (-pi / 2, pi / 2),
    )
    curve(
      vector-fn: {
        t => (-1 * sin(t) + 1, 1 * cos(t))
      },
      t-range: (-pi / 2, pi / 2),
      clip-box: none,
    )
    curve(
      vector-fn: {
        t => (-1 * sin(t) - 1, 1 * cos(t))
      },
      t-range: (-pi / 2, pi / 2),
      clip-box: none,
    )
  })
})
```

## Demos

Clicking on any demo image below will bring you to the respective page containing its source code.

<table style="width:100%; border-collapse:collapse; table-layout:fixed;">
  <tr>
    <td style="width:50%; padding:4pt; text-align:center; vertical-align:top; box-sizing:border-box;">
      <div style="font-family:monospace; font-size:9pt; margin-bottom:4pt;">cubic.typ</div>
      <a href="https://github.com/DevlinNul/pardioid/blob/main/assets/cubic.typ"><img src="https://github.com/DevlinNul/pardioid/blob/main/assets/cubic.png?raw=true" alt="cubic" loading="lazy" style="display:block;width:100%;height:auto;margin:0 auto;"></a>
    </td>
    <td style="width:50%; padding:4pt; text-align:center; vertical-align:top; box-sizing:border-box;">
      <div style="font-family:monospace; font-size:9pt; margin-bottom:4pt;">detect-edge.typ</div>
      <a href="https://github.com/DevlinNul/pardioid/blob/main/assets/detect-edge.typ"><img src="https://github.com/DevlinNul/pardioid/blob/main/assets/detect-edge.png?raw=true" alt="detect edge" loading="lazy" style="display:block;width:100%;height:auto;margin:0 auto;"></a>
    </td>
  </tr>
  <tr>
    <td style="padding:4pt; text-align:center; vertical-align:top; box-sizing:border-box;">
      <div style="font-family:monospace; font-size:9pt; margin-bottom:4pt;">exponential-asymptotic-spiral.typ</div>
      <a href="https://github.com/DevlinNul/pardioid/blob/main/assets/exponential-asymptotic-spiral.typ"><img src="https://github.com/DevlinNul/pardioid/blob/main/assets/exponential-asymptotic-spiral.png?raw=true" alt="exponential asymptotic spiral" loading="lazy" style="display:block;width:100%;height:auto;margin:0 auto;"></a>
    </td>
    <td style="padding:4pt; text-align:center; vertical-align:top; box-sizing:border-box;">
      <div style="font-family:monospace; font-size:9pt; margin-bottom:4pt;">pardioid.typ</div>
      <a href="https://github.com/DevlinNul/pardioid/blob/main/assets/pardioid.typ"><img src="https://github.com/DevlinNul/pardioid/blob/main/assets/pardioid.png?raw=true" alt="pardioid" loading="lazy" style="display:block;width:100%;height:auto;margin:0 auto;"></a>
    </td>
  </tr>
  <tr>
    <td style="padding:4pt; text-align:center; vertical-align:top; box-sizing:border-box;">
      <div style="font-family:monospace; font-size:9pt; margin-bottom:4pt;">pointwise.typ</div>
      <a href="https://github.com/DevlinNul/pardioid/blob/main/assets/pointwise.typ"><img src="https://github.com/DevlinNul/pardioid/blob/main/assets/pointwise.png?raw=true" alt="pointwise" loading="lazy" style="display:block;width:100%;height:auto;margin:0 auto;"></a>
    </td>
    <td style="padding:4pt; text-align:center; vertical-align:top; box-sizing:border-box;">
      <div style="font-family:monospace; font-size:9pt; margin-bottom:4pt;">polyline.typ</div>
      <a href="https://github.com/DevlinNul/pardioid/blob/main/assets/polyline.typ"><img src="https://github.com/DevlinNul/pardioid/blob/main/assets/polyline.png?raw=true" alt="polyline" loading="lazy" style="display:block;width:100%;height:auto;margin:0 auto;"></a>
    </td>
  </tr>
  <tr>
    <td style="padding:4pt; text-align:center; vertical-align:top; box-sizing:border-box;">
      <div style="font-family:monospace; font-size:9pt; margin-bottom:4pt;">power-functions.typ</div>
      <a href="https://github.com/DevlinNul/pardioid/blob/main/assets/power-functions.typ"><img src="https://github.com/DevlinNul/pardioid/blob/main/assets/power-functions.png?raw=true" alt="power functions" loading="lazy" style="display:block;width:100%;height:auto;margin:0 auto;"></a>
    </td>
    <td style="padding:4pt; text-align:center; vertical-align:top; box-sizing:border-box;">
      <div style="font-family:monospace; font-size:9pt; margin-bottom:4pt;">tear-drop.typ</div>
      <a href="https://github.com/DevlinNul/pardioid/blob/main/assets/tear-drop.typ"><img src="https://github.com/DevlinNul/pardioid/blob/main/assets/tear-drop.png?raw=true" alt="tear drop" loading="lazy" style="display:block;width:100%;height:auto;margin:0 auto;"></a>
    </td>
  </tr>
  <tr>
    <td colspan="2" style="padding:4pt; text-align:center; vertical-align:top; box-sizing:border-box;">
      <div style="font-family:monospace; font-size:9pt; margin-bottom:4pt;">adaptive-sampling.typ</div>
      <a href="https://github.com/DevlinNul/pardioid/blob/main/assets/adaptive-sampling.typ"><img src="https://github.com/DevlinNul/pardioid/blob/main/assets/adaptive-sampling.png?raw=true" alt="adaptive sampling" loading="lazy" style="display:block;width:100%;height:auto;margin:0 auto;"></a>
    </td>
  </tr>
</table>

## License

Most of the source code is licensed under the MIT License. Files under `/src/format/` are licensed under the Apache License 2.0.