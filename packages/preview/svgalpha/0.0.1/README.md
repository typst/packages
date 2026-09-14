# SVGAlpha
This is a simple package adds a global alpha layer to an SVG image. 

Example of usage: 

```typ
#import "@preview/svgalpha:0.0.1": transparent-svg
#let img = read("carrot.svg", encoding: "utf8")
#transparent-svg(img, 0.290, width: 40%)
```

The requiered paramaters are the first two ones (image data and alpha value). The rest are passed _as is_ to the `#image` function. 