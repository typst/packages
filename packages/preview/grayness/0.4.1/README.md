# Grayness

A package providing simple image editing capabilities via a WASM plugin.

Available functionality includes converting images to grayscale, cropping and flipping the images.
Furthermore, this package supports adding transparency and bluring (very slow) as well as handling additional raster image formats.

The package name is inspired by the blurry, gray images of Nessie, the [Loch Ness Monster](https://en.wikipedia.org/wiki/Loch_Ness_Monster)

## Usage

Due to the way Typst currently interprets given paths, you have to read the images yourself in the calling Typst file. This raw imagedata can then be passed to the grayness-package functions, like `image-grayscale()`. These functions also optionally accept all additional parameters of the original Typst image function like `width` or `height`:

```typst
#import "@preview/grayness:0.4.1": image-grayscale

#let data = read("Arturo_Nieto-Dorantes.webp", encoding: none)
#image-grayscale(data, width: 50%)
```

A detailed descriptions of all available functions is provided in the [manual](manual.pdf).

You can also use the built-in help functions provided by tidy:

```typst
#import "@preview/grayness:0.4.1": *
#help("image-flip-vertical")
```

All functions except `image-mask()` also works with SVG images. To do so you must specify the format as `"svg"`:

```typst
#let data = read("gallardo.svg", encoding: none)
#image-grayscale(data, format: "svg")
```

## Examples

Here are several functions applied to a WEBP image of [Arturo Nieto Dorantes](https://commons.wikimedia.org/wiki/File:Arturo_Nieto-Dorantes.webp) (CC-By-SA 4.0):
![Example image manipulations](example.png)

## Limitations

The functions provided in this package are quite slow and only serve as a prove of concept. You really should use dedicated image processing software to edit and potentially convert your source images into a format Typst understands natively.
