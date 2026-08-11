# Typst package: `tessera`

`tessera` is a package for combining multiple images into masonry or matrix layout. Sometimes in a document you want to put multiple images together, but it could be a challenge to layout them nicely, as different images may have different aspect ratios and you must precisely calculate the sizes of each image to to make sure that they fit into a rectangular region. This package aims to automate such calculation process and provide the desired layout as long as you pass in the images.

## Masonry layout

![Masonry Layout](assets/excalidraw/masonry-layout.excalidraw.svg)

Masonry layout is the layout format that stacks images continuously in a primary direction into groups and then stack the groups in a secondary direction. We assume the primary direction be top-to-bottom and secondary direction be left-to-right in the following section. In this case, images are first separated into columns. In each column, the images share the same width, and all columns share the same total height.

Given the images in each columns, it requires the images' aspect ratios and the gap between images and columns to calculate the exact size of each image. The `masonry` function provided by `tessera` completes the calculation and lays out the images as long as you pass in the images in each column.


```typ
#import "@preview/tessera:x.y.z": masonry

// wrap images in each column into a sub-array
// if a column contains 1 image only then you may omit the array and just pass in the image
#masonry(
  // column 1, with 2 images
  (image("cat1.jpg"), image("cat2.jpg")),
  // column 2, with 1 image
  image("cat3.jpg"),
  // column 3, with 3 images
  (image("dog1.jpg"), image("dog2.jpg"), image("dog3.jpg")),
  // add gap between images
  gutter: 1em,
)
```

`masonry` by default uses the original aspect ratio of each image. This can be changed by wrapping the `image` into a `scalable` and passing the `aspect-ratio` argument. `aspect-ratio` is defined as the ratio of image height over width.

```typ
#import "@preview/tessera:x.y.z": masonry, scalable

#masonry(
  (
    // force the image to have an aspect ratio of 1,
    // regardless of the original image's aspect ratio
    scalable(image("cat1.jpg"), aspect-ratio: 1),
    image("cat2.jpg"),
  ),
  image("cat3.jpg"),
  (image("dog1.jpg"), image("dog2.jpg"), image("dog3.jpg")),
  gutter: 1em,
)
```

You may also rotate or mirror images if you like.

```typ
#import "@preview/tessera:x.y.z": masonry, scalable
#import tessera.transform: upside-down, cw, ccw, mirrored-x, mirrored-y

#masonry(
  (
    image("cat1.jpg"),
    mirrored-x(image("cat2.jpg")),
  ),
  cw(image("cat3.jpg")),
  (
    ccw(image("dog1.jpg")),
    // custom aspect ratio can be combined with transforms
    scalable(upside-down(image("dog2.jpg")), aspect-ratio: 3/4),
    mirrored-y(image("dog3.jpg")),
  ),
  gutter: 1em,
)
```

# Matrix layout

![Matrix Layout](assets/excalidraw/matrix-layout.excalidraw.svg)

Matrix layout lays out images in grids. This format is often seen in social media posts and CAPTCHAs. In matrix layout you can specify the number of rows and columns. By default all rows and columns have the same width and height, and the images have aspect ratio of 1. Currently, row and column widths must be specified in `fr`. The absolute length for `1fr` is equal in horizontal and vertical direction, and the matrix layout always fills up the horizontal space available.

```typ
#import "@preview/oxifmt:1.0.0": strfmt
#import "@preview/tessera:x.y.z": matrix

#let images = range(1, 10).map(i => image(strfmt("image{:}.jpg", i)))

// creates a 3*3 matrix layout
// each image has aspect ratio 1 (square)
#matrix(..images, columns: 3, gutter: 1em)

// specify different widths for rows and columns
#matrix(
  ..images,
  rows: (3fr, 4fr, 5fr),
  columns: (2fr, 3fr, 4fr),
  gutter: 1em
)
```
