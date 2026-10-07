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

/// Adds transparency to the provided image data
///
/// _Example:_
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// //Place rectangle in background to demonstrate transparency
/// #place(top+center, dx:-3cm)[#rect(fill:blue, width:4cm, height:100%)]
/// //Add image over rectangle
/// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
/// #image-transparency(arturo, alpha:50%)
/// ```
/// -> content
#let image-transparency(
  /// Raw imagedata in any of the supported formats, e.g. provided by the `read()` function
  /// or a path to a file
  /// -> bytes | path
  imagedata,
  /// Remaining amount of visibility
  ///
  ///	0% = fully transparent, 100% = fully opaque
  ///
  /// ```example
  /// #import "@preview/grayness:0.8.0": *
  /// //Place rectangle in background to demonstrate transparency
  /// #place(top+center, dx:-3cm)[#rect(fill:blue, width:4cm, height:100%)]
  /// <<<#let gallardo = read("gallardo.svg")
  /// #image-transparency(gallardo, alpha: 30%, format: "svg")
  /// ```
  /// -> ratio
  alpha: 50%,
  /// Arguments to pass to the Typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    let ratio = float(alpha).to-bytes(size: 4)
    image(plg.svg_transparency(imagebytes, ratio), ..args)
  } else {
    let ratio = int(float(alpha) * 255).to-bytes(size: 1)
    image(plg.transparency(imagebytes, ratio), ..args)
  }
}
