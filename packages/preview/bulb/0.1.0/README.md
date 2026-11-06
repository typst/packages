# Bulb

Bulb is a package for creating dithered images straight in [Typst](https://typst.app).

## Usage

The package exports a single function, `dither`. It takes raw image bytes and returns PNG bytes you can pass straight to `image()`.

```typst
#import "@preview/bulb:0.1.0": dither

// Basic black & white dithering
#image(
  dither(
    read("photo.png", encoding: none),
    mode: "bw",
    method: "cluster8",
    size: 800,
  ),
)
```

### Parameters

| Parameter           | Default      | Description                                                                                                  |
| ------------------- | ------------ | ------------------------------------------------------------------------------------------------------------ |
| `data` (positional) | -            | Image bytes (PNG/JPEG), via `read("...", encoding: none)`                                                    |
| `mode`              | `"rgb"`      | `"bw"` (black & white), `"rgb"` (multi-level per channel), or `"palette"` (extracted palette)                |
| `method`            | `"bayer8x8"` | Dither method: `"bayer2x2"`, `"bayer4x4"`, `"bayer8x8"`, `"cluster4"`, `"cluster6"`, `"cluster8"`, `"noise"` |
| `size`              | `none`       | Max pixel size of the longest axis. `none` keeps original size                                               |
| `levels`            | `3`          | Colour levels per channel (rgb mode only)                                                                    |
| `colors`            | `8`          | Number of palette colours (palette mode only)                                                                |
| `accent`            | `none`       | FPS accent colours for hybrid palette (palette mode only, defaults to `colors / 3`)                          |
| `palette-method`    | `"hybrid"`   | `"hybrid"`, `"fps"`, or `"kmeans"` (palette mode only)                                                       |
| `linear`            | `true`       | Use linear light for palette selection (palette mode only)                                                   |
| `perceptual-cap`    | `false`      | Cap dominant colour weight (palette mode only)                                                               |

## Examples

Here's what it looks like in practice:

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/eed31c30-a99b-4a0a-a3c6-b6ef5eb6321b">
  <img alt="Cluster BW" src="https://github.com/user-attachments/assets/1cab80b2-6473-4859-ae88-9787dd0739ba">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/28fe16c6-c333-40df-a81b-6699661dc78d">
  <img alt="Bayer RGB" src="https://github.com/user-attachments/assets/01a1f502-32a1-4dbf-930d-70ff2dc31de1">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/20a92281-980c-4493-b921-49dcfc619fa2">
  <img alt="Bayer Palette" src="https://github.com/user-attachments/assets/d271ba24-2e3f-4915-97c3-ec3882957749">
</picture>
