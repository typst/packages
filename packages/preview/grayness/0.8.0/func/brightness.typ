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

/// Brightens the supplied image
///
/// _Example:_
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
/// #image-brighten(arturo, amount:50%)
/// ```
/// -> content
#let image-brighten(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// -> bytes | path
  imagedata,
  /// Amount to brighten by.
  /// 0% = no brightening, 100% = completely white
  /// -> ratio
  amount: 50%,
  /// Arguments to pass to the Typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  /// -> arguments
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    image(plg.svg_brighten(imagebytes, float(amount).to-bytes(size: 4)), ..args)
  } else {
    image(plg.brighten(imagebytes, int(float(amount) * 255).to-bytes(size: 4)), ..args)
  }
}

/// Darkenes the supplied image
///
/// _Example:_
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = path("Arturo_Nieto-Dorantes.webp")
/// #image-darken(arturo, amount:50%)
/// ```
/// -> content
#let image-darken(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// -> bytes | path
  imagedata,
  /// Amount to darken by
  /// 0% = no darkening, 100% = completely black
  /// -> int
  amount: 50%,
  /// Arguments to pass to the Typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ///  ```example
  /// #import "@preview/grayness:0.8.0": *
  /// <<<#let gallardo = read("gallardo.svg")
  /// #image-darken(gallardo, amount:50%, format:"svg")
  /// ```
  /// -> arguments
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    image-brighten(imagebytes, amount: -amount, ..args)
  }
}
