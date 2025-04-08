/*
Copyright 2024-2025 Nikolai Neff-Sarnow

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#import "@preview/grayness:0.3.0": *
#let data = read("Arturo_Nieto-Dorantes.webp", encoding: none)
#let data2 = read("gallardo.svg", encoding: none)
#set page(height: 12cm, columns: 3)

Unmodified WebP-Image:
#image-show(data, width: 90%)

Flip (vertically):
#image-flip-vertical(data, width: 90%)

Grayscale:
#image-grayscale(data, width: 90%)

Blur:
#image-blur(data, sigma: 10, width: 90%)
#colbreak()

Transparency:
//#place(top+center, dx: -15%, dy: 15%, rect(width: 20%, height: 15%, fill:green))
#image-transparency(data, width: 90%)

Crop:
#image-crop(data, crop-width: 100, crop-height: 120, crop-start-x: 190, crop-start-y: 95, width: 50.5%)

#pagebreak()

Brighten:
#image-brighten(data, amount: 50%, width: 90%)

Darken:
#image-darken(data, amount: 50%, width: 90%)
#colbreak()

Invert:
#image-invert(
  data,
  width: 90%,
)

HueRotate:
#image-huerotate(data, amount: 100, width: 90%)
#colbreak()

Flip (horizontally):
#image-flip-horizontal(data, width: 90%)

#pagebreak()

Unmodified SVG-image:
#image-show(data2, width: 90%, format: "svg")

Flip (vertically):
#image-flip-vertical(data2, width: 90%, format: "svg")
#colbreak()

Grayscale:
#image-grayscale(data2, width: 90%, format: "svg")

Blur:
#image-blur(data2, sigma: 30, width: 90%, format: "svg")
#colbreak()

Transparency:
#image-transparency(data2, width: 90%, format: "svg")

Crop:
#image-crop(data2, crop-width: 100, crop-height: 220, crop-start-x: 750, crop-start-y: 500, width: 90%, format: "svg")

#pagebreak()

Brighten:
#image-brighten(data2, amount: 50%, width: 90%, format: "svg")

Darken:
#image-darken(data2, amount: 50%, width: 90%, format: "svg")
#colbreak()

Invert:
#image-invert(data2, width: 90%, format: "svg")

HueRotate:
#image-huerotate(data2, amount: 100, width: 90%, format: "svg")
#colbreak()
