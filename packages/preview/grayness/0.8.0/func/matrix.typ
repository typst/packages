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

/// Applies a color-matrix transformation to the supplied image according to the following formula:
///
/// ```
/// R' = r1*R + r2*G + r3*B + r4*A + r5
/// G' = g1*R + g2*G + g3*B + g4*A + g5
/// B' = b1*R + b2*G + b3*B + b4*A + b5
/// A' = a1*R + a2*G + a3*B + a4*A + a5
/// ```
///
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let arturo = path("Arturo_Nieto-Dorantes.webp")
/// #let matrix = (
///   (0.5, 0.0, 0.0, 0.0, 0.5),
///   (0.0, 1.0, 0.0, 0.0, 0.0),
///   (0.0, 5.0, 1.0, 0.0, 0.0),
///   (0.0, 0.0, 0.0, 1.0, 0.0),
/// )
/// #image-matrix(arturo, matrix)
/// ```
/// -> content
#let image-matrix(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// -> bytes | path
  imagedata,
  /// 5x4 matrix as array of arrays  with floats in the following order:
  /// ```
  /// (
  ///   (r1, r2, r3, r4, r5),
  ///   (g1, g2, g3, g4, g5),
  ///   (b1, b2, b3, b4, b5),
  ///   (a1, a2, a3, a4, a5),
  /// )
  /// ```
  ///
  /// -> array
  matrix,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  /// ```example
  /// #import "@preview/grayness:0.8.0": *
  /// <<<#let gallardo = read("gallardo.svg")
  /// #let matrix = (
  ///   (0.5, 0.0, 0.0, 0.0, 0.5),
  ///   (0.0, 1.0, 0.0, 0.0, 0.0),
  ///   (0.0, -5.0, 1.0, 0.0, 0.0),
  ///   (0.0, 0.0, 0.0, 1.0, 0.0),
  /// )
  /// #image-matrix(gallardo, matrix, format:"svg")
  /// ```
  /// -> arguments
  ..args,
) = {
  let imagebytes = if type(imagedata) == path { read(imagedata, encoding: none) } else if type(imagedata) == bytes {
    imagedata
  } else { panic("imagedata must be raw bytes or given as path") }
  if matrix.len() != 4 { panic("matrix must be 5x4") }
  for i in range(0, 4) {
    if matrix.at(i).len() != 5 { panic("matrix must be 5x4") }
  }
  let m00 = float(matrix.at(0).at(0)).to-bytes(size: 4)
  let m01 = float(matrix.at(0).at(1)).to-bytes(size: 4)
  let m02 = float(matrix.at(0).at(2)).to-bytes(size: 4)
  let m03 = float(matrix.at(0).at(3)).to-bytes(size: 4)
  let m04 = float(matrix.at(0).at(4)).to-bytes(size: 4)
  let m10 = float(matrix.at(1).at(0)).to-bytes(size: 4)
  let m11 = float(matrix.at(1).at(1)).to-bytes(size: 4)
  let m12 = float(matrix.at(1).at(2)).to-bytes(size: 4)
  let m13 = float(matrix.at(1).at(3)).to-bytes(size: 4)
  let m14 = float(matrix.at(1).at(4)).to-bytes(size: 4)
  let m20 = float(matrix.at(2).at(0)).to-bytes(size: 4)
  let m21 = float(matrix.at(2).at(1)).to-bytes(size: 4)
  let m22 = float(matrix.at(2).at(2)).to-bytes(size: 4)
  let m23 = float(matrix.at(2).at(3)).to-bytes(size: 4)
  let m24 = float(matrix.at(2).at(4)).to-bytes(size: 4)
  let m30 = float(matrix.at(3).at(0)).to-bytes(size: 4)
  let m31 = float(matrix.at(3).at(1)).to-bytes(size: 4)
  let m32 = float(matrix.at(3).at(2)).to-bytes(size: 4)
  let m33 = float(matrix.at(3).at(3)).to-bytes(size: 4)
  let m34 = float(matrix.at(3).at(4)).to-bytes(size: 4)

  let imagebytes = __dataformat(imagedata)
  if __guess_format(imagebytes, args) == "svg" {
    image(
      plg.svg_matrix(
        imagebytes,
        m00,
        m01,
        m02,
        m03,
        m04,
        m10,
        m11,
        m12,
        m13,
        m14,
        m20,
        m21,
        m22,
        m23,
        m24,
        m30,
        m31,
        m32,
        m33,
        m34,
      ),
      format: "svg",
      ..args,
    )
  } else {
    image(
      plg.matrix(
        imagebytes,
        m00,
        m01,
        m02,
        m03,
        m04,
        m10,
        m11,
        m12,
        m13,
        m14,
        m20,
        m21,
        m22,
        m23,
        m24,
        m30,
        m31,
        m32,
        m33,
        m34,
      ),
      ..args,
    )
  }
}
