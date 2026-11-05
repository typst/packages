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
#import "image-show.typ": *

/// Flip the provided imagedata horizontally
/// _Example:_
///
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let gallardo = read("gallardo.svg")
/// #image-flip-horizontal(gallardo, format:"svg")
/// ```
/// -> content
#let image-flip-horizontal(
  /// Raw imagedata, e.g. provided by the `read()` function or a path to a file
  /// -> bytes | path
  imagedata,
  /// Arguments to pass to the Typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ..args,
) = {
  scale(x: -100%, image-show(imagedata, ..args))
}

/// Flip the provided imagedata vertically
/// _Example:_
///
/// ```example
/// #import "@preview/grayness:0.8.0": *
/// <<<#let gallardo = read("gallardo.svg")
/// #image-flip-vertical(gallardo, format:"svg")
/// ```
/// -> content
#let image-flip-vertical(imagedata, ..args) = {
  scale(y: -100%, image-show(imagedata, ..args))
}
