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

/// Hue rotate the supplied image.
///
/// _Example:_
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
/// #image-huerotate(arturo, amount:100)
/// ```
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let gallardo = read("gallardo.svg")
/// #image-huerotate(gallardo, amount:100, format:"svg")
/// ```
/// -> content
#let image-huerotate(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// -> bytes | path
  imagedata,
  /// Number of degrees to rotate each pixels color by. 0 and 360 do nothing,
  /// the rest rotates by the given degree value. Smallest step for raster images is 1°.
  /// -> int | float
  amount: 0,
  /// Arguments to pass to the Typst image function
  /// e.g. width, height, alt, fit, ...
  /// -> arguments
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    image(plg.svg_huerotate(imagebytes, float(amount).to-bytes(size: 4)), ..args)
  } else {
    image(plg.huerotate(imagebytes, int(amount).to-bytes(size: 4)), ..args)
  }
}
