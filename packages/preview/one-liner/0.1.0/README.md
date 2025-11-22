# One-liner typst package

One-liner is a package containing a helper function to fit text to the available width, without wrapping, by 
adjusting the text size based upon the context. This is useful in templates where you 
don't know the length of text that is supposed to fit in specific locations in your template.

## Example
In the current version(0.1.0) one-liner contains 1 function: fit-to-width that can used as follows:

```typst
#import "@preview/one-liner:0.1.0": fit-to-width 

#block(
  height: 3cm,
  width: 10cm,
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  align(horizon + center,fit-to-width(lorem(2))),
)
```

Here we have a block of specific dimensions. Using fit-to-width will change the font-size to the content passed 
to fit-to-width will fit the full width without wrapping the content.

![Example1](./img/example1.png "Example1 of Typst one-liner: fit-to-width")

## fit-to-width function
Besides content the function has two parameters:

*max-text-size* of type length. It has a default of 64pt. When fit-to-width is limited by the max-text-size you will see that not
the entire width of space is used.

*min-text-size* of type length. It has a default of 4pt. When fit-to-width is limited by the min-text-size you will see that the text will wrap,
because the min-text-size is bigger than the size that would be required to prevent wrapping.

## Disclaimer
This package was only tested in a few of my own documents and only to fit text. Not tested with other content yet.