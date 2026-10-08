# Bulb

Bulb is a package for creating dithered images straight in [Typst](https://typst.app).

## Usage

The package exports a single function, `dither`. It takes raw image bytes and returns PNG bytes you can pass straight to `image()`.

```typst
#import "@preview/bulb:0.3.0": dither
```

Black & white:

```typst
#image(dither(
  path("photo.png"),
  colors: "bw",
  method: "cluster8",
  size: 800,
))
```

Palette preset:

```typst
#image(dither(
  path("photo.png"),
  colors: "gameboy",
))
```

Custom palette with Typst colours:

```typst
#image(dither(
  path("photo.png"),
  colors: (black, red, rgb("#ff8800"), white),
))
```

Auto-generated palette:

```typst
#image(dither(
  path("photo.png"),
  colors: 16,
))
```

Tonal pre-pass (gamma / contrast / brightness):

```typst
#image(dither(
  path("photo.png"),
  gamma: 2.2,
  contrast: 1.2,
  brightness: -0.1,
))
```

Edge-preserving snap (sharper silhouettes, flats stay dithered):

```typst
#image(dither(
  path("photo.png"),
  colors: "pico8",
  edge-threshold: 0.2,
))
```

### Parameters

| Parameter           | Default      | Description                                                                                                                            |
| ------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| `path` (positional) | -            | `path` object that resolves to a JPEG or PNG image.                                                                                    |
| `colors`            | `"rgb"`      | Output colours. `"bw"` (black & white), `"rgb"` (uniform levels per channel, see `levels`), an integer >= 2 (generate that many colours from the image), a preset name (`"gameboy"`, `"nes"`, `"cga"`, `"pico8"`, `"mac"`, `"c64"`), or an array of >= 2 colours |
| `method`            | `"bayer8x8"` | Dither method: `"bayer2x2"`, `"bayer4x4"`, `"bayer8x8"`, `"cluster4"`, `"cluster6"`, `"cluster8"`                                     |
| `size`              | `none`       | Max pixel size of the longest axis. `none` keeps original size                                                                         |
| `filter`            | `"nearest"`  | Resize filter: `"nearest"`, `"triangle"`, `"catmull-rom"`, `"gaussian"`, `"lanczos3"` (nearest fastest, lanczos3 highest quality)      |
| `levels`            | `3`          | Colour levels per channel (`colors: "rgb"` only)                                                                                       |
| `accent`            | `none`       | Accent colours for the hybrid palette generator (`colors: <int>` only, defaults to one third of the colours)                           |
| `palette-method`    | `"hybrid"`   | `"hybrid"`, `"fps"`, or `"kmeans"` (`colors: <int>` only)                                                                              |
| `linear`            | `true`       | Use linear light for palette selection (`colors: <int>` only)                                                                          |
| `perceptual-cap`    | `false`      | Cap dominant colour weight (`colors: <int>` only)                                                                                      |
| `gamma`             | `1.0`        | Gamma correction applied before dithering (must be positive)                                                                           |
| `contrast`          | `1.0`        | Contrast multiplier around midgrey (`1.0` = no change)                                                                                 |
| `brightness`        | `0.0`        | Additive brightness offset in `[-1.0, 1.0]`                                                                                            |
| `edge-threshold`    | `none`       | `none` (off) or non-negative number. Snap pixels above the Sobel gradient threshold; smaller = more snapped                            |

## Examples

Here's what it looks like in practice:

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./docs/assets/bw-dark.png">
  <img alt="high contrast black and white image with stippled (cluster) dithering" src="./docs/assets/bw-light.png">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./docs/assets/preset-dark.png">
  <img alt="preset palette dithered image" src="./docs/assets/preset-light.png">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./docs/assets/palette-dark.png">
  <img alt="auto-generated palette dithered image" src="./docs/assets/palette-light.png">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./docs/assets/rgb-dark.png">
  <img alt="dithered image with 3 channels (RGB) each with 4 levels" src="./docs/assets/rgb-light.png">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./docs/assets/given-palette-dark.png">
  <img alt="dithered image using user-defined palette" src="./docs/assets/given-palette-light.png">
</picture>
