
/// Display an image (figure) with a text below
///
/// ```example
/// >>>#import "@local/gqe-lemoulon-presentation:0.0.6":*
/// #image-legende( image: example-human-height-image,[Distribution of student's height in a brittish university])
/// ```
///
/// -> content
#let image-legende(
  /// Width of the image and description *Optional*.
  /// -> length | ratio
  width: auto,
  /// The content to display as a figure/image
  /// -> content
  image: none,

  /// the text to display below the image
  /// -> content
  body
) = block(width: width, {
    stack(dir: ttb, spacing: 0.2em,{
        image
    },{
        set align(horizon+center)
        set text(size: 0.5em)
        body
    }
    )
}
)


