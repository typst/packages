/*
Copyright 2024-2025 Nikolai Neff-Sarnow

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

#let plg = plugin("grayness.wasm")

/// Create a grayscale-image representation of the provided imagedata (Raster or SVG)
///
///  _Example:_
/// ```example
/// <<<#import "@preview/grayness:0.3.0": *
/// >>>#import "@local/grayness:0.3.0": *
/// #let data = read("Arturo_Nieto-Dorantes.webp", encoding:none)
/// #image-grayscale(data)
/// ```
/// -> content
#let image-grayscale(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  ///	extra arguments to pass to the typst image function
  /// e.g. width, height, format, etc...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ///
  /// _Example:_
  /// ```example
  /// >>>#import "@local/grayness:0.3.0": *
  /// #let data = read("gallardo.svg", encoding:none)
  /// #image-grayscale(data, format:"svg", width:4cm, alt:"Lamborghini Gallardo")
  /// ```
  ..args,
) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  if args.named().keys().contains("format") and args.named().format == "svg" {
    image(plg.svg_grayscale(imagebytes), ..args)
  } else {
    image(plg.grayscale(imagebytes), ..args)
  }
}

/// Displays an image from bytes.
/// This enables the usage of imageformats not natively supported by typst
///
///  _Example:_
///	 ```example
///  <<<#import "@preview/grayness:0.3.0": *
///  >>>#import "@local/grayness:0.3.0": *
///  #image-show(read("Arturo_Nieto-Dorantes.webp", encoding: none))
///  ```
/// -> content
#let image-show(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  ///	extra arguments to pass to the typst image function
  /// e.g. width, height, format, etc...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ///
  /// _Example:_
  /// ```example
  /// >>>#import "@local/grayness:0.3.0": *
  /// #let data = read("gallardo.svg", encoding:none)
  /// #image-show(data, format:"svg", width:2cm, alt:"Lamborghini Gallardo")
  /// ```
  ..args,
) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  if args.named().keys().contains("format") and args.named().format == "svg" {
    image(imagebytes, ..args)
  } else {
    image(plg.convert(imagebytes), ..args)
  }
}

/// Crop the given imagedata to the specified width and height
///
/// _Example:_
/// ```example
/// >>>#import "@local/grayness:0.3.0": *
/// <<<#import "@preview/grayness:0.3.0": *
/// #let data = read("Arturo_Nieto-Dorantes.webp", encoding:none)
/// #image-crop(
/// 	data,
/// 	crop-width: 100,
///   crop-height: 120,
///   crop-start-x: 190,
///   crop-start-y: 95
/// )
/// ```
/// -> content
#let image-crop(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
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
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ///
  /// _Example:_
  /// ```example
  /// >>>#import "@local/grayness:0.3.0": *
  /// #let data = read("gallardo.svg", encoding:none)
  /// #image-crop(
  ///  data,
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
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  if args.named().keys().contains("format") and args.named().format == "svg" {
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

/// Flip the provided imagedata horizontally
/// _Example:_
///
/// ```example
/// >>>#import "@local/grayness:0.3.0": *
/// <<<#import "@preview/grayness:0.3.0": *
/// #let data = read("gallardo.svg", encoding:none)
/// #image-flip-horizontal(data, format:"svg")
/// ```
/// -> content
#let image-flip-horizontal(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ..args,
) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  scale(x: -100%, image-show(imagebytes, ..args))
}

/// Flip the provided imagedata vertically
/// _Example:_
///
/// ```example
/// >>>#import "@local/grayness:0.3.0": *
/// <<<#import "@preview/grayness:0.3.0": *
/// #let data = read("gallardo.svg", encoding:none)
/// #image-flip-vertical(data, format:"svg")
/// ```
/// -> content
#let image-flip-vertical(imagebytes, ..args) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  scale(y: -100%, image-show(imagebytes, ..args))
}

/// Performs a Gaussian blur on the imagedata.
///
/// _Warning:_ This operation is slow, especially for large sigmas.
///
/// ```example
/// >>>#import "@local/grayness:0.3.0": *
/// <<<#import "@preview/grayness:0.3.0": *
/// #let data = read("Arturo_Nieto-Dorantes.webp", encoding:none)
/// #image-blur(data, sigma:3.14)
/// ```
///
/// -> content
#let image-blur(
  /// Raw imagedata in any of the supported formats, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  /// A measure of how much to blur by (standard deviation)
  ///
  /// ```example
  /// >>>#import "@local/grayness:0.3.0": *
  /// #let data = read("Arturo_Nieto-Dorantes.webp", encoding:none)
  /// #image-blur(data, sigma:6.28)
  /// ```
  /// -> int|float
  sigma: 5,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  /// ```example
  /// >>>#import "@local/grayness:0.3.0": *
  /// #let data = read("gallardo.svg", encoding:none)
  /// #image-blur(data, sigma: 40, format: "svg")
  /// ```
  ..args,
) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  if args.named().keys().contains("format") and args.named().format == "svg" {
    image(plg.svg_blur(imagebytes, float(sigma).to-bytes(size: 4)), ..args)
  } else {
    image(plg.blur(imagebytes, float(sigma).to-bytes(size: 4)), ..args)
  }
}


/// Adds transparency to the provided image data
///
/// _Example:_
/// ```example
/// >>>#import "@local/grayness:0.3.0": *
/// <<<#import "@preview/grayness:0.3.0": *
/// //Place rectangle in background to demonstrate transparency
/// #place(top+center, dx:-3cm)[#rect(fill:blue, width:4cm, height:100%)]
/// //Add image over rectangle
/// #let data = read("Arturo_Nieto-Dorantes.webp", encoding:none)
/// #image-transparency(data, alpha:50%)
/// ```
/// -> content
#let image-transparency(
  /// Raw imagedata in any of the supported formats, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  /// Remaining amount of visibility
  ///
  ///	0% = fully transparent, 100% = fully opaque
  ///
  /// ```example
  /// >>>#import "@local/grayness:0.3.0": *
  /// #let data = read("gallardo.svg", encoding:none)
  /// #image-transparency(data, alpha: 30%, format: "svg")
  /// ```
  /// -> ratio
  alpha: 50%,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ..args,
) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  if args.named().keys().contains("format") and args.named().format == "svg" {
    let ratio = float(alpha).to-bytes(size: 4)
    image(plg.svg_transparency(imagebytes, ratio), ..args)
  } else {
    let ratio = int(float(alpha) * 255).to-bytes(size: 1)
    image(plg.transparency(imagebytes, ratio), ..args)
  }
}

/// Brightens the supplied image
///
/// _Example:_
/// ```example
/// >>>#import "@local/grayness:0.3.0": *
/// <<<#import "@preview/grayness:0.3.0": *
/// #let data = read("Arturo_Nieto-Dorantes.webp", encoding:none)
/// #image-brighten(data, amount:50%)
/// ```
/// -> content
#let image-brighten(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  /// Amount to brighten by.
  /// 0% = no brightening, 100% = completely white
  /// -> ratio
  amount: 50%,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  /// -> any
  ..args,
) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  if args.named().keys().contains("format") and args.named().format == "svg" {
    image(plg.svg_brighten(imagebytes, float(amount).to-bytes(size: 4)), ..args)
  } else {
    image(plg.brighten(imagebytes, int(float(amount) * 255).to-bytes(size: 4)), ..args)
  }
}

/// Darkenes the supplied image
///
/// _Example:_
/// ```example
/// >>>#import "@local/grayness:0.3.0": *
/// <<<#import "@preview/grayness:0.3.0": *
/// #let data = read("Arturo_Nieto-Dorantes.webp", encoding:none)
/// #image-darken(data, amount:50%)
/// ```
/// -> content
#let image-darken(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  /// Amount to darken by
  /// 0% = no darkening, 100% = completely black
  /// -> int
  amount: 50%,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  ///  ```example
  /// >>>#import "@local/grayness:0.3.0": *
  /// #let data = read("gallardo.svg", encoding:none)
  /// #image-darken(data, amount:50%, format:"svg")
  /// ```
  /// -> any
  ..args,
) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  image-brighten(imagebytes, amount: -amount, ..args)
}

/// Inverts the colors of the supplied image
///
/// _Example:_
/// ```example
/// >>>#import "@local/grayness:0.3.0": *
/// <<<#import "@preview/grayness:0.3.0": *
/// #let data = read("Arturo_Nieto-Dorantes.webp", encoding:none)
/// #image-invert(data)
/// ```
/// -> content
#let image-invert(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  /// ```example
  /// >>>#import "@local/grayness:0.3.0": *
  /// #let data = read("gallardo.svg", encoding:none)
  /// #image-invert(data, format:"svg")
  /// ```
  /// -> any
  ..args,
) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  if args.named().keys().contains("format") and args.named().format == "svg" {
    image(plg.svg_invert(imagebytes), ..args)
  } else {
    image(plg.invert(imagebytes), ..args)
  }
}

/// Hue rotate the supplied image.
///
/// _Example:_
/// ```example
/// >>>#import "@local/grayness:0.3.0": *
/// <<<#import "@preview/grayness:0.3.0": *
/// #let data = read("Arturo_Nieto-Dorantes.webp", encoding:none)
/// #image-huerotate(data, amount:100)
/// ```
/// -> content
#let image-huerotate(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  /// Number of degrees to rotate each pixels color by. 0 and 360 do nothing,
  /// the rest rotates by the given degree value. Smallest step for raster images is 1°.
  /// -> int | float
  amount: 0,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  ///
  /// You must pass `format:"svg"` as argument if you use a SVG-image as your input.
  /// ```example
  /// >>>#import "@local/grayness:0.3.0": *
  /// #let data = read("gallardo.svg", encoding:none)
  /// #image-huerotate(data, amount:100, format:"svg")
  /// ```
  /// -> any
  ..args,
) = {
  if args.named().keys().contains("format") and type(args.named().format) == dictionary {
    panic("format-dictionary is not supported")
  }
  if args.named().keys().contains("format") and args.named().format == "svg" {
    image(plg.svg_huerotate(imagebytes, float(amount).to-bytes(size: 4)), ..args)
  } else {
    image(plg.huerotate(imagebytes, int(amount).to-bytes(size: 4)), ..args)
  }
}

///Update the alpha-channel of the image by applying the masking image to it.
///The if the mask image is not the same size as the target image, it will be resized automatically
///This function does not work with SVG data.
#let image-mask(
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  imagebytes,
  /// Raw imagedata, e.g. provided by the `read()` function
  /// -> bytes
  maskbytes,
  /// Defines if the alpha-channel of the mask image is used (default). If set to false, the brightness
  /// of the mask image is used instead. Therefore, images without an alpha-channel can also be used as mask.
  use-alpha-channel: true,
  /// Arguments to pass to the typst image function
  /// e.g. width, height, alt, fit, ...
  /// -> any
  ..args,
) = {
  if args.named().keys().contains("format") and args.named().format == "svg" {
    panic("The image-mask() function does not work with SVG-Data")
  }
  let alpha = 1.to-bytes()
  if not use-alpha-channel { alpha = 0.to-bytes() }
  image(plg.mask(imagebytes, maskbytes, alpha, ..args))
}

#let help(..args) = {
  import "@preview/tidy:0.4.3"
  let namespace = (
    ".": read.with("lib.typ"),
  )
  tidy.generate-help(namespace: namespace, package-name: "grayness")(..args)
}
