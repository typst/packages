## Polario Frame
**`polario-frame`** is a package for easy to use photo frame in Typst. It provides lots of themes and image crop util to make
your photo frame. `polario` is derived from **Polaroid**, reflecting the aspiration for this tool to deliver desired photos as quickly as a Polaroid camera.

## Simple Usage
Import `polario-frame` package with

```typst
#import "@preview/polario-frame:0.1.0": *
```

Use crop-util to crop image

```typst
let img = crop(bytes(read("simple.jpg", encoding: none)), start: (25%, 25%), resize: 75%)
```

Use `polario-frame` to render photo frame

```typst
let ext-info = (
    "title": text(size: 20pt)[瞭望远方],
    "address": text(size: 8pt)[丽江 \ 玉龙雪山],
    "date": text(size: 8pt)[2025-10-01],
    "logo": image("CGA.png"),
    "background": rgb("#ff0404"),
)
render("A6", flipped: true, theme: "theme1", img: img, ext-info: ext-info)
```
This makes it easy to add the `theme1` frame to the photo. If you need other theme frames, you can check the content in [simple.typ](https://github.com/NPCRay/photo-frame/blob/master/example/simple.typ) to see what **ext-info** are required for each frame.
![result](https://raw.githubusercontent.com/NPCRay/polario-frame/refs/heads/master/example/theme1.png)

## Versions

### 0.1.0
Initial release