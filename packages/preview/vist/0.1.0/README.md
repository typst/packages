# VisT: A Typst Library for Image Processing

VisT is a powerful and versatile image processing library for Typst that provides a range of functions to manipulate and transform images. It is designed to be easy to use and integrates seamlessly with Typst, allowing for efficient and effective image processing.

## Features

- **Image Adjustments**: Functions to adjust brightness, contrast, hue, and color inversion.
- **Filters**: Apply blur, unsharpen mask, and custom 3x3 convolution filters.
- **Transformations**: Rotate, resize, crop, flip, and overlay images with ease.
- **Color Gradients**: Generate images with smooth horizontal or vertical color gradients.
- **Interpolation**: Bilinear and nearest-neighbor pixel interpolation.
- **Conversion**: Change the image format and quality.

## Getting Started

To use VisT in your Typst project, import the library as follows:

```typst
#import "@preview/vist:0.1.0"
```

Make sure you have the plugin plugin.wasm available in your project directory as VisT relies on it for processing.

## Example Usage
Here are a few examples of how to use VisT to process images:
```typst
#import "@preview/vist:0.1.0"
#let image_data = read("image.png",encoding: none)

// Brighten the image by 20 units
#let brightened_image = vist.brighten(image_data, value: 20)

// Rotate the hue by 90 degrees
#let hue_rotated_image = vist.huerotate(image_data, value: 90)

// Invert the colors of the image
#let inverted_image = vist.invert(image_data)

// Apply Gaussian blur with a radius of 2.5
#let blurred_image = vist.blur(image_data, sigma: 2.5)

// Adjust contrast by 50 units
#let contrast_adjusted_image = vist.adjust_contrast(image_data, value: 50)

// More functions can be used similarly...
```
More usage can be checked in [example](./example.typ)
For decoding the processed byte stream to an image, you can use the #image.decode function provided by your environment.

# Documentation

To ensure compatibility and ease of use, VisT uses the PNG RGBA8 format as the standard for communication between functions. This format is widely supported and provides a good balance between image quality and file size, making it suitable for a vast array of image processing applications. Users can expect consistent behavior and high-fidelity results when processing images using VisT in the specified format.


# License
VisT is open-sourced software licensed under the Apache License 2.0. Feel free to use it, modify it, and distribute it as per the license terms.

# Contributing
Contributions to the VisT library are welcome. Please feel free to submit pull requests, report bugs, and suggest new features or improvements.

Happy Image Processing!