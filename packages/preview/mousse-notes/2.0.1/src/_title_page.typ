#import "_constants.typ": FONTS

#let _fit(min: 2em, max: 4em, max-ratio: 100%, body) = layout(size => {
  let fits(it) = {
    let measured-size = measure(width: size.width, it)
    measured-size.height < size.height and measured-size.width < size.width * max-ratio
  }
  let measured-size = measure(width: size.width, body)

  let size = max
  let INCREMENT = 0.1em

  while not fits({
    set text(size: size)
    body
  }) {
    if size - INCREMENT < min {
      break
    }
    size -= INCREMENT
  }

  {
    set text(size: size)
    body
  }
})

/// Title page of the document.
///
/// Title is read directly from the `document.title` metadata.
///
/// - subtitle (content): Description immediately besides the title
/// - primary (content): Content below the title
/// - secondary (content): Content below the primary description
/// -> content
#let title-page(
  subtitle: none,
  primary: none,
  secondary: none,
) = {
  set text(font: FONTS.heading)
  set par(first-line-indent: 0em, hanging-indent: 0em)

  v(5%)

  set par(spacing: 1em, leading: 0.25em, justify: false)
  _fit(upper(context document.title))
  if subtitle != none {
    text(size: 2em, subtitle)
  }
  v(2em, weak: true)
  line(length: 90%)
  set par(leading: 0.5em)
  v(2em, weak: true)
  text(size: 1.5em, primary)
  v(0.5em)

  {
    set text(size: 1em)
    secondary
  }

  align(bottom, {
    context for author in document.author {
      upper(author)
    }
  })

  [#v(0em) <__mousse_title_page>]

  pagebreak()
}
