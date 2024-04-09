# GrayNess

A package providing simple image editing capabilities via a WASM plugin.

Available functionality includes converting images to grayscale, cropping and flipping the images.
Furthermore, this package supports adding transparency and bluring (very slow) as well as handling additional raster image formats.

The package name is inspired by the blurry, gray images of Nessie, the [Loch Ness Monster](https://en.wikipedia.org/wiki/Loch_Ness_Monster)

## Usage

Due to the way typst currently interprets given paths, you have to read the images yourself in the calling typst file. This raw imagedata can then be passed to the grayscale function:

```typst
#import "@preview/gray_ness:0.1.0": grayscale

#let data = read("Art.webp", encoding: none)
#grayscale(data, width: 50%)
```

## Examples

here are several functions applied to a WEBP image of [Arturo Nieto Dorantes](https://commons.wikimedia.org/wiki/File:Arturo_Nieto-Dorantes.webp) (CC-By-SA 4.0):
![Example image manipulations](arturo.png)
