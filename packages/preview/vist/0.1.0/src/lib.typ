#import "type.typ"

#let lib = plugin("./plugin.wasm")

// Function to brighten the image. `data` is the image byte array, `value` is the brightness level (int).
#let brighten(data, value: 0) = {
  lib.brighten(data, cbor.encode(value))
}

// Function to apply hue rotation to the image. `data` is the image byte array, `value` is the angle of rotation (int).
#let huerotate(data, value: 0) = {
  lib.huerotate(data, cbor.encode(value))
}

// Function to invert the colors of the image. `data` is the image byte array.
#let invert(data) = {
  lib.invert(data)
}

// Function to blur the image. `data` is the image byte array, `sigma` is the Gaussian blur radius (float).
#let blur(data, sigma: 0.0) = {
  lib.blur(data, cbor.encode(sigma))
}

// Function to apply an unsharpen mask to the image. `data` is the image byte array, `sigma` is the radius (float), `threshold` is the minimum brightness change that will be sharpened (int).
#let unsharpen(data, sigma: 0.0, threshold: 0) = {
  lib.unsharpen(data, cbor.encode(( sigma, threshold)))
}

// Function to adjust the contrast of the image. `data` is the image byte array, `value` is the level of contrast (int).
#let adjust_contrast(data, value: 0) = {
  lib.adjust_contrast(data, cbor.encode(value))
}

// Function to rotate the image by 180 degrees. `data` is the image byte array.
#let rotate180(data) = {
  lib.rotate180(data)
}

// Function to rotate the image by 270 degrees. `data` is the image byte array.
#let rotate270(data) = {
  lib.rotate270(data)
}

// Function to convert the image to grayscale. `data` is the image byte array.
#let grayscale(data) = {
  lib.grayscale(data)
}

// Function to crop the image. `data` is the image byte array, `x` and `y` are the top-left coordinates (uint), `width` and `height` are the dimensions of the crop (uint).
#let crop(data, x: 0, y: 0, width: 0, height: 0) = {
  lib.crop(data, cbor.encode((x: x, y: y, width: width, height: height)))
}

// Function to create a thumbnail of the image. `data` is the image byte array, `width` and `height` are the dimensions of the thumbnail (uint).
#let thumbnail(data, width: 0, height: 0) = {
  lib.thumbnail(data, cbor.encode((width: width, height: height)))
}

// Function to resize the image. `data` is the image byte array, `width` and `height` are the new dimensions (uint), `filter_type` is the filter used for resizing (uint).
#let resize(data, width: 0, height: 0, filter_type: 0) = {
  lib.resize(data, cbor.encode((width: width, height: height, filter_type: filter_type)))
}

// Function to resize the image to fill specified dimensions, cropping if necessary. `data` is the image byte array, `width` and `height` are the dimensions (uint), `filter_type` is the filter used (uint).
#let resize_to_fill(data, width: 0, height: 0, filter_type: 0) = {
  lib.resize_to_fill(data, cbor.encode((width: width, height: height, filter_type: filter_type)))
}

// Function to apply a 3x3 convolution filter to the image. `data` is the image byte array, `kernel` is an array of 9 float values representing the filter kernel.
#let filter3x3(data, kernel: (0,)*9) = {
  lib.filter3x3(data, cbor.encode(kernel))
}

// Function to fill the image with a horizontal gradient. `data` is an empty image byte array, `width` and `height` are the dimensions (uint), `start_color` and `end_color` are the RGBA color arrays for the gradient.
#let horizontal_gradient( width: 0, height: 0, start_color: (0,0,0,0), end_color: (255,255,255,255)) = {
  lib.horizontal_gradient(cbor.encode((width: width, height: height, start_color: start_color, end_color: end_color)))
}

// Function to fill the image with a vertical gradient. `data` is an empty image byte array, `width` and `height` are the dimensions (uint), `start_color` and `end_color` are the RGBA color arrays for the gradient.
#let vertical_gradient( width: 0, height: 0, start_color: (0,0,0,0), end_color: (255,255,255,255)) = {
  lib.vertical_gradient(cbor.encode((width: width, height: height, start_color: start_color, end_color: end_color)))
}

// Function to overlay one image over another. `base_data` is the base image byte array, `overlay_data` is the overlay image byte array, `x` and `y` are the coordinates at which to overlay (int).
#let overlay(base_data, overlay_data, x: 0, y: 0) = {
  lib.overlay(base_data, overlay_data, cbor.encode((x: x, y: y)))
}

// Function to tile an image over another. `base_data` is the base image byte array, `tile_data` is the tile image byte array.
#let tile(base_data, tile_data) = {
  lib.tile(base_data, tile_data)
}

// Function to interpolate the color of a pixel using bilinear sampling. `data` is the image byte array, `x` and `y` are the floating-point coordinates within the image.
#let interpolate_bilinear(data, x: 0.0, y: 0.0) = {
  lib.interpolate_bilinear(data, cbor.encode((x: x, y: y)))
}

// Function to interpolate the color of a pixel using nearest-neighbor sampling. `data` is the image byte array, `x` and `y` are the floating-point coordinates within the image.
#let interpolate_nearest(data, x: 0.0, y: 0.0) = {
  lib.interpolate_nearest(data, cbor.encode((x: x, y: y)))
}

// Function to flip the image vertically. `data` is the image byte array.
#let flip_vertical(data) = {
  lib.flip_vertical(data)
}

// Function to flip the image horizontally. `data` is the image byte array.
#let flip_horizontal(data) = {
  lib.flip_horizontal(data)
}

// Function to rotate the image by 90 degrees clockwise. `data` is the image byte array.
#let rotate90(data) = {
  lib.rotate90(data)
}

// Function to convert the image to a specified format. `data` is the image byte array, `format` is the desired image format (string), `quality` is the image quality for certain formats (optional uint).
#let convert_format(data, format: "png", quality: 80) = {
  lib.convert_format(data, cbor.encode((format: format, quality: quality)))
}

#let get_image_metadata(data) = {
  cbor.decode(lib.get_image_metadata(data))
}