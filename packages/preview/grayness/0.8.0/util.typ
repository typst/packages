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


/// Provides direct access to the webassebmly functions, which can be used to chain several operations after oneanother.
/// The available methods are:
///
/// - `grayscale(imagebytes)`
/// - `svg_grayscale(image_bytes)`
/// - `convert(image_bytes)`
/// - `mask(target_image_bytes, mask_image_bytes, use_alpha)`
/// - `svg_mask(target_image_bytes, mask_image_bytes)`
/// - `crop(image_bytes, start_x, start_y, width, height)`
/// - `svg_crop(image_bytes, start_x, start_y, width, height)`
/// - `blur(image_bytes, sigma)`
/// - `svg_blur(image_bytes, sigma)`
/// - `transparency(image_bytes, alpha)`
/// - `svg_transparency(image_bytes, alpha)`
/// - `invert(image_bytes)`
/// - `svg_invert(image_bytes)`
/// - `brighten(image_bytes, amount)`
/// - `svg_brighten(image_bytes, amount)`
/// - `huerotate(image_bytes, amount)`
/// - `svg_huerotate(image_bytes, amount)`
/// - `matrix(imagebytes, m00, m01, m02, m03, m04, m10, m11, m12, m13, m14, m20, m21, m22, m23, m24, m30, m31, m32, m33, m34)`
/// - `svg_matrix(imagebytes, m00, m01, m02, m03, m04, m10, m11, m12, m13, m14, m20, m21, m22, m23, m24, m30, m31, m32, m33, m34)`
/// - `infos(imagebytes)`
/// - `svg_infos(imagebytes)`
/// - `decode(imagebytes)`
///
/// #colbreak()
///    _Raster Example:_
/// ```example
/// #import "@preview/grayness:0.8.0": plg
/// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
/// #let grayscaled-bytes = plg.grayscale(arturo)
/// #let blurred-and-grayscaled = plg.blur(grayscaled-bytes,float(5).to-bytes(size: 4))
/// #image(blurred-and-grayscaled)
/// ```
///    _Vector Example:_
/// ```example
/// #import "@preview/grayness:0.8.0": plg
/// <<<#let gallardo = read("gallardo.svg", encoding: none)
/// #let grayscaled-bytes = plg.svg_grayscale(gallardo)
/// #let blurred-and-grayscaled = plg.svg_blur(grayscaled-bytes,float(40).to-bytes(size: 4))
/// #image(blurred-and-grayscaled)
/// ```
#let plg = plugin("grayness.wasm")
//the webassembly plugin has it's own version number, make sure it is the correct one.
#assert(str(plg.plugin_version()) == "0.7.0")

#let __guess_format(data, args) = {
  if args.named().keys().contains("format") {
    if type(args.named().format) == dictionary {
      panic("format-dictionary is not supported")
    } else if args.named().format == "svg" { return "svg" }
  } else {
    if data.slice(0, count: 4).at(0) == str.to-unicode("<") { return "svg" }
  }
}

#let __dataformat(imagedata) = if type(imagedata) == path { read(imagedata, encoding: none) } else if (
  type(imagedata) == bytes
) {
  imagedata
} else { panic("imagedata must be raw bytes or given as path") }
