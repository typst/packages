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

/// Inverts the colors of the supplied image
///
/// _Example:_
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
/// #image-invert(arturo)
/// ```
/// -> content
#let image-invert(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// -> bytes | path
  imagedata,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  /// ```example
  /// #import "@preview/grayness:0.8.0": *
  /// <<<#let gallardo = read("gallardo.svg")
  /// #image-invert(gallardo, format:"svg")
  /// ```
  /// -> arguments
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    image(plg.svg_invert(imagebytes), ..args)
  } else {
    image(plg.invert(imagebytes), ..args)
  }
}
