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

/// Crop the given imagedata to the specified width and height
///
/// _Example:_
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
/// #image-crop(
/// 	arturo,
/// 	crop-width: 100,
///   crop-height: 120,
///   crop-start-x: 190,
///   crop-start-y: 95
/// )
/// ```
/// -> content
#let image-crop(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// -> bytes | path
  imagedata,
  /// Horizontal size (in pixels or "user space" in case of SVG) of the crop window. Must be >= 0.
  /// -> int
  crop-width: 10,
  /// Vertical size (in pixels or "user space" in case of SVG) of the crop window. Depending on the settings of the SVG, it might preserve it's aspect ratio even if crop-width and crop-height have a different ratio. Must be >= 0.
  /// -> int
  crop-height: 10,
  /// Left starting coordinate (in pixels or "user space" in case of SVG) of the crop window. Depending on the settings of the SVG, it might preserve it's aspect ratio even if crop-width and crop-height have a different ratio. Must be >= 0.
  /// -> int
  crop-start-x: 0,
  /// Top starting coordinate (in pixels or "user space" in case of SVG) of the crop window. Must be >= 0.
  /// -> int
  crop-start-y: 0,
  /// Arguments to pass to the Typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ///
  /// _Example:_
  /// ```example
  /// #import "@preview/grayness:0.8.0": *
  /// <<<#let gallardo = path("gallardo.svg")
  /// #image-crop(
  ///  gallardo,
  ///  crop-height: 200,
  ///  crop-width: 100,
  ///  crop-start-x: 10,
  ///  crop-start-y: 250,
  ///  format: "svg"
  /// )
  /// ```
  /// -> arguments
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    image(
      plg.svg_crop(
        imagebytes,
        float(crop-start-x).to-bytes(size: 4),
        float(crop-start-y).to-bytes(size: 4),
        float(crop-width).to-bytes(size: 4),
        float(crop-height).to-bytes(size: 4),
      ),
      ..args,
    )
  } else {
    image(
      plg.crop(
        imagebytes,
        int(crop-start-x).to-bytes(size: 4),
        int(crop-start-y).to-bytes(size: 4),
        int(crop-width).to-bytes(size: 4),
        int(crop-height).to-bytes(size: 4),
      ),
      ..args,
    )
  }
}
