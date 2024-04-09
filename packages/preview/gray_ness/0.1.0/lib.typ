#let plg = plugin("gray_ness.wasm")

///Create a grayscale represenation of the provided imagedata
///
/// - imagebytes (bytes): Raw imagedata provided by the read function
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #grayscale(data)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #grayscale(data, width: 50%, height: 80%)
/// ```
/// -> content
#let grayscale(imagebytes, ..args) = {
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
/// - startx (int, str): left starting coordinate (in pixels) of the crop window
/// - starty (int, str): top starting coordinate (in pixels) of the crop window
/// - width (int, str): horizontal size (in pixels) of the crop window
/// - height (int, str): vertical size (in pixels) of the crop window
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #crop_image(data, 0, 70, 120, 250, width: 50%, height: 80%)
/// ```
/// -> content
#let crop_image(imagebytes, startx: 0, starty: 0, width, height, ..args) = {
  image.decode(
    plg.crop(imagebytes, bytes(str(startx)), bytes(str(starty)), bytes(str(width)), bytes(str(height))),
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
///  #flip_image_horizontal(data)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #flip_image_horizontal(data, width: 50%, height: 80%)
/// ```
/// -> content
#let flip_image_horizontal(imagebytes, ..args) = {
  image.decode(plg.fliph(imagebytes), ..args)
}

///Flip the provided imagedata vertically
///
/// - imagebytes (bytes): Raw imagedata provided by the read function
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #flip_image_vertical(data)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #flip_image_vertical(data, width: 50%, height: 80%)
/// ```
/// -> content
#let flip_image_vertical(imagebytes, ..args) = {
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
///  #blur_image(data)
///  ```
/// - sigma (int, str): a measure of how much to blur by (standard deviation)
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #blur_image(data, 5)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #blur_image(data, 7, width: 50%, height: 80%)
/// ```
/// -> content
#let blur_image(imagebytes, sigma: 5, ..args) = {
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
///  #convert_image(data)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #convert_image(data, width: 50%, height: 80%)
/// ```
/// -> content
#let convert_image(imagebytes, ..args) = {
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
///  #transparent_image(data)
///  ```
/// - alpha (ratio): remaining amount of visibility
///
///	 0% = fully transparent, 100% = fully opaque
///
///  _Example:_
///	 ```typst
///  #let data = read("file.webp", encoding:none)
///  #transparent_image(data, 70%)
///  ```
/// - ..args (any): Arguments to pass to typst image function
///   i.e. width, height, alt and fit
///
///  _Example:_
///  ```typst
///  #let data = read("file.webp", encoding:none)
///  #transparent_image(data, width: 50%, height: 80%)
/// ```
/// -> content
#let transparent_image(imagebytes, alpha: 50%, ..args) = {
  let ratio = bytes(str(int(float(alpha) * 255)))
  image.decode(plg.transparency(imagebytes, ratio), ..args)
}