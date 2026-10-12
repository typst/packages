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
/// Create a grayscale-image representation of the provided imagedata (Raster or SVG)
///
///  _Example:_
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = path("Arturo_Nieto-Dorantes.webp")
/// #image-grayscale(arturo)
/// ```
/// -> content
#let image-grayscale(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to the file
  /// -> bytes | path
  imagedata,
  ///	extra arguments to pass to the Typst image function
  /// e.g. width, height, format, etc...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ///
  /// _Example:_
  /// ```example
  /// #import "@preview/grayness:0.8.0": *
  /// <<<#let gallardo = read("gallardo.svg")
  /// #image-grayscale(gallardo, format:"svg", width:4cm, alt:"Lamborghini Gallardo")
  /// ```
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    image(plg.svg_grayscale(imagebytes), ..args)
  } else {
    image(plg.grayscale(imagebytes), ..args)
  }
}
