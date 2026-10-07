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


/// Performs a Gaussian blur on the imagedata.
///
/// _Warning:_ This operation is slow, especially for large sigmas.
///
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = path("Arturo_Nieto-Dorantes.webp")
/// #image-blur(arturo, sigma:3.14)
/// ```
///
/// -> content
#let image-blur(
  /// Raw imagedata in any of the supported formats, e.g. provided by the `read()` function
  /// or a path to a file
  /// -> bytes | path
  imagedata,
  /// A measure of how much to blur by (standard deviation)
  ///
  /// ```example
  /// #import "@preview/grayness:0.8.0": *
  /// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
  /// #image-blur(arturo, sigma:6.28)
  /// ```
  /// -> int|float
  sigma: 5,
  /// Arguments to pass to the Typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  /// ```example
  /// #import "@preview/grayness:0.8.0": *
  /// <<<#let gallardo = read("gallardo.svg")
  /// #image-blur(gallardo, sigma: 40, format: "svg")
  /// ```
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    image(plg.svg_blur(imagebytes, float(sigma).to-bytes(size: 4)), ..args)
  } else {
    image(plg.blur(imagebytes, float(sigma).to-bytes(size: 4)), ..args)
  }
}
