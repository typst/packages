/*
Copyright 2024-2026 Nikolai Neff-Sarnow

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

#import "../util.typ": *

/// Gets the images dimensions and its format as string
/// The dimensions are given in pixels for raster images.
/// For SVG, the width, height and viewBox for the toplevel SVG Element
/// are returned if present in the original. They should include units if the
/// file adheres to the SVG 2.0 standard.
///
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = path("Arturo_Nieto-Dorantes.webp")
/// <<<#let gallardo = path("Arturo_Nieto-Dorantes.webp")
/// #let infos_a = image-infos(arturo)
/// #let infos_g = image-infos(gallardo, format:"svg")
///
/// Width: #infos_a.width, Height: #infos_a.height, Format: #infos_a.format\
/// Width: #infos_g.width, Height: #infos_g.height, Viewbox: #infos_g.viewBox
/// ```
/// -> dictionary
#let image-infos(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// -> bytes | path
  imagedata,
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    let infos = cbor(plg.svg_infos(imagebytes))
    (width: infos.w, height: infos.h, viewBox: infos.viewBox, format: "svg")
  } else {
    let infos = cbor(plg.infos(imagebytes))
    let width = infos.w
    let height = infos.h
    let format = infos.f
    (width: width, height: height, format: format)
  }
}
