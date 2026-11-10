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


/// Displays an image from raw bytes or a path to a file.
/// This enables the usage of imageformats not natively supported by Typst
///
///  _Example:_
///	 ```example
///  #import "@preview/grayness:0.8.0": *
///  <<<#let arturo = path("Arturo_Nieto-Dorantes.webp")
///  #image-show(arturo)
///  ```
/// -> content
#let image-show(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
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
  /// #image-show(gallardo, format:"svg", width:2cm, alt:"Lamborghini Gallardo")
  /// ```
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    image(imagebytes, ..args)
  } else {
    image(plg.convert(imagebytes), ..args)
  }
}
