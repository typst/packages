#import "@preview/tidy:0.4.3"
#import "@preview/grayness:0.4.0": *

#[
  #show link: underline.with(stroke: blue)
  = Grayness

  #sym.copyright 2025 Nikolai Neff-Sarnow, Licensed under the #link("http://www.apache.org/licenses/LICENSE-2.0")[Apache License, Version 2.0]\
  Version #toml("typst.toml").package.version, #datetime.today().display()

  #v(0.5cm)
  This Typst package provides basic image editing functions like grayscaling, inverting and cropping. Moreover, this package supports image-formats not natively available in Typst. The following formats can be used:
  #columns(4)[
    - BMP
    - DDS
    - Farbfeld
    - GIF
    #colbreak()
    - HDR
    - ICO
    - JPEG
    - OpenEXR
    #colbreak()
    - PNG
    - PNM
    - QOI
    - TGA
    #colbreak()
    - TIFF
    - WebP
    - SVG
  ]
  #v(0.5cm)
  All examples in this manual use one of the following images as their base:
  #columns(2)[
    #figure(
      image-show(read("Arturo_Nieto-Dorantes.webp", encoding: none), width: 80%),
      caption: [*WebP:* Pianist #link("https://commons.wikimedia.org/wiki/File:Arturo_Nieto-Dorantes.webp")[Arturo Nieto Dorantes],\ #link("https://creativecommons.org/licenses/by-sa/4.0/deed.en")[CC BY-SA 4.0] by Laëtitia Boudaud],
      supplement: none,
    )
    #colbreak()
    #figure(
      image("gallardo.svg", width: 100%),
      caption: [*SVG:* A traced #link("https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/gallardo.svg")[Lamborghini Gallardo],\ #link("https://creativecommons.org/licenses/by-nc-sa/2.5/")[CC BY-NC-SA 2.5] by Michael Grosberg],
      supplement: none,
    )]
]

#v(1cm)
== Available functions
#show heading.where(level: 2): it => {
  colbreak(weak: true)
  it
}

#let docs = tidy.parse-module(read("lib.typ"))
#tidy.show-module(docs, sort-functions: none, first-heading-level: 1)
