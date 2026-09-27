#import "@preview/tidy:0.4.3"
#import "@preview/grayness:0.8.0": *

#[
  #show link: underline.with(stroke: blue)
  = Grayness
  #sym.copyright 2024 -- 2026 Nikolai Neff-Sarnow, Licensed under the #link("http://www.apache.org/licenses/LICENSE-2.0")[Apache License, Version 2.0]\
  Version #toml("../typst.toml").package.version, #datetime.today().display()

  #v(0.5cm)
  This Typst package provides basic image editing functions like grayscaling, inverting, cropping and applying color transforms. Moreover, this package supports image-formats not natively available in Typst. The following formats can be used:
  #columns(4)[
    - BMP
    - DDS
    - Farbfeld
    - GIF\*
    #colbreak()
    - HDR
    - ICO
    - JPEG\*
    - OpenEXR
    #colbreak()
    - PNG\*
    - PNM
    - QOI
    - TGA
    #colbreak()
    - TIFF
    - WebP\*
    - SVG\*
  ]
  \* Natively supported by Typst
  #v(0.5cm)
  All examples in this manual use one of the following images as their base:
  #columns(2)[
    #figure(
      image-show(read("../examples/Arturo_Nieto-Dorantes.webp", encoding: none), width: 80%),
      caption: [*WebP:* Pianist #link("https://commons.wikimedia.org/wiki/File:Arturo_Nieto-Dorantes.webp")[Arturo Nieto Dorantes],\ #link("https://creativecommons.org/licenses/by-sa/4.0/deed.en")[CC BY-SA 4.0] by Laëtitia Boudaud],
      supplement: none,
    )
    #colbreak()
    #figure(
      image("../examples/gallardo.svg", width: 100%),
      caption: [*SVG:* A traced #link("https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/gallardo.svg")[Lamborghini Gallardo],\ #link("https://creativecommons.org/licenses/by-nc-sa/2.5/")[CC BY-NC-SA 2.5] by Michael Grosberg],
      supplement: none,
    )]
]

#v(1cm)
== Available functions
#show heading.where(level: 2): it => {
  colbreak(weak: false)
  it
}

#let mask = read("../examples/mask.png", encoding: none)
#let arturo = read("../examples/Arturo_Nieto-Dorantes.webp", encoding: none)
#let gallardo = read("../examples/gallardo.svg", encoding: none)

#let docs = tidy.parse-module(read("../lib.typ"), scope: (
  mask: mask,
  arturo: arturo,
  gallardo: gallardo,
))
#tidy.show-module(docs, sort-functions: none, first-heading-level: 1)

The wasm plugin has its own version numer which can be queried using `#str(plg.plugin_version())`. The current plugin version is #str(plg.plugin_version())
