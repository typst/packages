## Photo Frame
photo-frame is a package for easy to use photo frame in Typst. It provides lots of themes and image crop util to make
your photo frame. For usage, please refer to [simple.typ]("https://github.com/NPCRay/photo-frame/blob/master/example/simple.typ") and render result
is [simple.png]("https://github.com/NPCRay/photo-frame/blob/master/example/simple.png").

## Simple Usage

Import photo-frame package with

```typst
#import "@preview/photo-frame:0.1.0": *
```

Use crom util to crop image

```typst
let img = crop(bytes(read("simple.jpg", encoding: none)), start: (25%, 25%), resize: 75%)
```

Use photo-frame to render photo frame

```typst
let ext_info = (
    "title": text(size: 20pt)[瞭望远方],
    "address": text(size: 8pt)[丽江 \ 玉龙雪山],
    "date": text(size: 8pt)[2025-10-01],
    "logo": image("CGA.png"),
    "background": rgb("#bf021b"),
)
render("a6", flipped: true, theme: "theme1", img: img, ext_info: ext_info)
```

## Versions

### 0.1.0

Initial release