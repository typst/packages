/*
Copyright 2024 Nikolai Neff-Sarnow

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

///Create a grayscale-image representation of the provided imagedata
///
/// - imagebytes (bytes): Raw imagedata provided by the read function
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #grayscale-image(data)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #grayscale-image(data, width: 50%, height: 80%)
/// ```
/// -> content
#let grayscale-image(imagebytes, ..args) = {
  image.decode(plg.grayscale(imagebytes), ..args)
}

///Crop the given imagedata to the specified width and height
///
/// - imagebytes (bytes): Raw imagedata provided by the read function
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #crop(data, 0, 0, 150, 200)
///  ```
/// - start-x (int, str): left starting coordinate (in pixels) of the crop window
/// - start-y (int, str): top starting coordinate (in pixels) of the crop window
/// - crop-width (int, str): horizontal size (in pixels) of the crop window
/// - crop-height (int, str): vertical size (in pixels) of the crop window
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #crop-image(data, 0, 70, 120, 250, width: 50%, height: 80%)
/// ```
/// -> content
#let crop-image(imagebytes, crop-width, crop-height, start-x: 0, start-y: 0, ..args) = {
  image.decode(
    plg.crop(imagebytes, bytes(str(start-x)), bytes(str(start-y)), bytes(str(crop-width)), bytes(str(crop-height))),
    ..args,
  )
}

///Flip the provided imagedata horizontally
///
/// - imagebytes (bytes): Raw imagedata provided by the read function
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #flip-image-horizontal(data)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #flip-image-horizontal(data, width: 50%, height: 80%)
/// ```
/// -> content
#let flip-image-horizontal(imagebytes, ..args) = {
  image.decode(plg.fliph(imagebytes), ..args)
}

///Flip the provided imagedata vertically
///
/// - imagebytes (bytes): Raw imagedata provided by the read function
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #flip-image-vertical(data)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #flip-image-vertical(data, width: 50%, height: 80%)
/// ```
/// -> content
#let flip-image-vertical(imagebytes, ..args) = {
  image.decode(plg.flipv(imagebytes), ..args)
}

///performs a Gaussian blur on the imagedata.
///
///Warning: This operation is *SLOW*
///
/// - imagebytes (bytes): Raw imagedata provided by the read function
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #blur-image(data)
///  ```
/// - sigma (int, str): a measure of how much to blur by (standard deviation)
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #blur-image(data, 5)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #blur-image(data, 7, width: 50%, height: 80%)
/// ```
/// -> content
#let blur-image(imagebytes, sigma: 5, ..args) = {
  image.decode(plg.blur(imagebytes, bytes(str(sigma))), ..args)
}

///Displays an image from bytes in formats not natively supported by typst
///
///Supported formats are:
///
/// - Bmp
/// - Dds
/// - Farbfeld
/// - Gif
/// - Hdr
/// - Ico
/// - Jpeg
/// - OpenExr
/// - Png
/// - Pnm
/// - Qoi
/// - Tga
/// - Tiff
/// - WebP
///
/// - imagebytes (bytes): Raw imagedata provided by the read function
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #show-image(data)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #show-image(data, width: 50%, height: 80%)
/// ```
/// -> content
#let show-image(imagebytes, ..args) = {
  image.decode(plg.convert(imagebytes), ..args)
}

///Adds transparency to the provided image data
///
///
/// - imagebytes (bytes): Raw imagedata provided by the read function
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #transparent-image(data)
///  ```
/// - alpha (ratio): remaining amount of visibility
///
///	 0% = fully transparent, 100% = fully opaque
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #transparent-image(data, 70%)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #transparent-image(data, width: 50%, height: 80%)
/// ```
/// -> content
#let transparent-image(imagebytes, alpha: 50%, ..args) = {
  let ratio = bytes(str(int(float(alpha) * 255)))
  image.decode(plg.transparency(imagebytes, ratio), ..args)
}
