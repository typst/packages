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

/// For raster images, this function updates the alpha-channel of the image by applying the masking image to it.
/// The if the mask image is not the same size as the target image, it will be resized automatically.
///
/// For SVG, the mask image is applied to the SVG directly without scaling if it has a different aspect ratio. The result image will appear transparent at areas not covered by the mask in this case.
///
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
/// <<<#let mask = read("mask.png", encoding:none)
/// #image-mask(arturo, mask)
/// ```
#let image-mask(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// for the source image
  /// -> bytes | path
  imagedata,
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// for the mask image
  /// -> bytes
  maskdata,
  /// For raster images, defines if the alpha-channel of the mask image is used (default). If set to false, the brightness
  /// of the mask image is used instead. Therefore, images without an alpha-channel can also be used as mask.
  ///
  /// For SVG images, the brigthness and alpha channel are always used both for masking.
  /// ```example
  /// #import "@preview/grayness:0.8.0": *
  /// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
  /// <<<#let mask = read("mask.png", encoding:none)
  /// #image-mask(arturo, mask, use-alpha-channel:false)
  /// ```
  /// -> bool
  use-alpha-channel: true,
  /// Arguments to pass to the Typst image function
  /// e.g. width, height, alt, fit, ...
  /// -> arguments
  ..args,
) = {
  let imagebytes = __dataformat(imagedata)
  let maskbytes = __dataformat(maskdata)
  let alpha = 1.to-bytes()
  if not use-alpha-channel { alpha = 0.to-bytes() }
  if __guess_format(imagebytes, args) == "svg" {
    image(plg.svg_mask(imagebytes, maskbytes), ..args)
  } else {
    image(plg.mask(imagebytes, maskbytes, alpha), ..args)
  }
}
