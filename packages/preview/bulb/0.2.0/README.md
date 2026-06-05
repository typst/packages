# Bulb

Bulb is a package for creating dithered images straight in [Typst](https://typst.app).

## Usage

The package exports a single function, `dither`. It takes raw image bytes and returns PNG bytes you can pass straight to `image()`.

```typst
#import "@preview/bulb:0.2.0": dither
```

Black & white:

```typst
#image(dither(
  read("photo.png", encoding: none),
  mode: "bw",
  method: "cluster8",
  size: 800,
))
```

Palette preset (mode inferred):

```typst
#image(dither(
  read("photo.png", encoding: none),
  palette: "gameboy",
))
```

Custom palette with Typst colours:

```typst
#image(dither(
  read("photo.png", encoding: none),
  palette: (black, red, rgb("#ff8800"), white),
))
```

Tonal pre-pass (gamma / contrast / brightness):

```typst
#image(dither(
  read("photo.png", encoding: none),
  gamma: 2.2,
  contrast: 1.2,
  brightness: -0.1,
))
```

Edge-preserving snap (sharper silhouettes, flats stay dithered):

```typst
#image(dither(
  read("photo.png", encoding: none),
  palette: "pico8",
  edge-threshold: 0.2,
))
```

### Parameters

| Parameter           | Default      | Description                                                                                                                            |
| ------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| `data` (positional) | -            | Image bytes (PNG/JPEG), via `read("...", encoding: none)`                                                                              |
| `mode`              | `auto`       | `"bw"`, `"rgb"`, or `"palette"`. `auto` infers `"palette"` if `palette` is set, else `"rgb"`                                           |
| `method`            | `"bayer8x8"` | Dither method: `"bayer2x2"`, `"bayer4x4"`, `"bayer8x8"`, `"cluster4"`, `"cluster6"`, `"cluster8"`, `"noise"`                           |
| `size`              | `none`       | Max pixel size of the longest axis. `none` keeps original size                                                                         |
| `filter`            | `"nearest"`  | Resize filter: `"nearest"`, `"triangle"`, `"catmull-rom"`, `"gaussian"`, `"lanczos3"` (nearest fastest, lanczos3 highest quality)      |
| `levels`            | `3`          | Colour levels per channel (rgb mode only)                                                                                              |
| `colors`            | `8`          | Number of palette colours (palette mode only)                                                                                          |
| `accent`            | `none`       | FPS accent colours for hybrid palette (palette mode only, defaults to `colors / 3`)                                                    |
| `palette-method`    | `"hybrid"`   | `"hybrid"`, `"fps"`, or `"kmeans"` (palette mode only)                                                                                 |
| `linear`            | `true`       | Use linear light for palette selection (palette mode only)                                                                             |
| `perceptual-cap`    | `false`      | Cap dominant colour weight (palette mode only)                                                                                         |
| `gamma`             | `1.0`        | Gamma correction applied before dithering (must be positive)                                                                           |
| `contrast`          | `1.0`        | Contrast multiplier around midgrey (`1.0` = no change)                                                                                 |
| `brightness`        | `0.0`        | Additive brightness offset in `[-1.0, 1.0]`                                                                                            |
| `edge-threshold`    | `none`       | `none` (off) or non-negative number. Snap pixels above the Sobel gradient threshold; smaller = more snapped                            |
| `palette`           | `none`       | Preset name string, or array of colours (hex strings or Typst colours, e.g. `("#000", red, rgb("#ff8800"))`). Infers `mode: "palette"` |

## Examples

Here's what it looks like in practice:

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/3b4bfac6-e5c4-4c1c-8b0b-a93ce0295cd2">
  <img alt="high contrast black and white image with stippled (cluster) dithering" src="https://github.com/user-attachments/assets/acd088b2-eee8-4dd8-8db0-9d3eadd0178c">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/97a26fa3-dd36-42fa-ad20-29d47bad8a2c">
  <img alt="preset palette dithered image" src="https://github.com/user-attachments/assets/148e78f8-8034-44fe-ac53-c2e9e0439b1b">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/2d0eab30-0701-415a-b803-62c019109e35">
  <img alt="auto-generated palette dithered image" src="https://github.com/user-attachments/assets/ed21781a-f5a3-4709-9f0a-69b81ee7a5ad">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/ed97d634-3b11-4ad7-a46e-d18250afedaf">
  <img alt="dithered image with 3 channels (RGB) each with 4 levels" src="https://github.com/user-attachments/assets/36bcbb59-d2fd-437e-b3fc-851c38d74c59">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/3da3d70e-1ed9-4e41-ae16-a302c1e7ef01">
  <img alt="dithered image using user-defined palette" src="https://github.com/user-attachments/assets/5c278f87-c56f-44ac-9eb4-ab39a8817e5f">
</picture>
