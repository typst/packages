
#import "defaults.typ": * // imports default theme and layout

#let poster-syndrome(
  title: none, 
  subtitle: none,
  authors: none,
  affiliation: none,
  date: none,
  qr-code: none,
  credit: none,
  cover-image: none,
  background: none,
  foreground: none,
  // objects needed for layout and display
  frame: none,
  container: none,
  styles: none,
  palette: none,
  // further frames
  body,
) = {

  // set document

  set page(
    width: container.width * 1mm,
    height: container.height * 1mm,
    margin: 0pt,
    foreground: foreground,
    background: background,
  )


  show: styles.default
  show raw: styles.raw
  show math.equation: styles.math

  set strong(delta: 200)

  set list(marker: text([•], baseline: 0pt))

  show heading.where(level: 2): it => [
    #set align(left)
    #block(it.body)
  ]
  show heading.where(level: 2): styles.heading

  show heading.where(level: 3): it => [
    #set align(left)
    #block(it.body)
  ]
  show heading.where(level: 3): styles.subheading

  set image(width: 100%)

  show "•": text.with(weight: "extralight", fill: palette.highlight)
  show "·": text.with(weight: "extralight", fill: palette.highlight)

  set list(marker: text([•], baseline: 0pt))
  set enum(numbering: n => text(fill: palette.highlight.darken(20%))[#n ·])

  show bibliography: it => {
  show link: set text(fill: palette.contrast.darken(40%))

  set enum(numbering: n => text(fill: palette.highlight.darken(20%))[#n ·])
  it
  }

  // set fixed frames

  frame(tag: "cover-image")[
    #cover-image
  ]

  frame(tag: "cover-image")[
    #show: styles.credit
    #align(bottom + right, move(dy: 1em, credit))
  ]

  frame(tag: "title")[
    #show: styles.title
    #title
  ]

  frame(tag: "subtitle")[
    #show: styles.subtitle
    #subtitle
  ]

  frame(tag: "details")[
    #show: styles.author
    #authors
    #v(1fr)
    #if qr-code != none {
      v(1fr)
      qr-code
    }
    #show: styles.affiliation
    #affiliation
    #v(1fr)
    #show: styles.date
    #date
    #v(1fr)
  ]

  // custom frames left to the user
  body
}

#let insta(
  img: none,
  description: none,
  width: 100%,
  margin: 8mm,
  fill: luma(92%),
  radius: 5pt,
  aspect-ratio: 1.3,
) = layout(container => {
  
  let height = container.width * aspect-ratio
  rect(
    fill: white.transparentize(0%),
    width: width,
    height: height,
    radius: radius,
    {
      set image(width: 100%, height: 100%, fit: "cover")
      show text: smallcaps
      stack(
        box(height: 0.5 * margin),
        spacing: 0pt,
        align(center, square(
          inset: 0pt,
          width: container.width - margin,
          stroke: none,
          fill: fill,
        )[#img]),
        box(height: 0.5 * (height - container.width - 3 * margin)),
        align(center + horizon, description),
      )
    },
  )
})


#let poster-syndrome-setup(
  theme: _default-theme,
  frames: _default-frames,
  container: _default-container,
) = {
  // create styles for supplied theme elements
  let tags-in-use = (theme.text.keys(), theme.par.keys()).flatten().dedup()
  let styles = create-styles(theme: theme, tags: tags-in-use)

  let frame(tag: "none", body) = {
    let f = frames.at(tag)
    // show-set rule for that frame if defined
    show: {
      if tag in styles.keys() {
        styles.at(tag)
      } else {
        styles.default
      }
    }
    place(dx: f.x * 1mm, dy: f.y * 1mm, box(
      width: f.width * 1mm,
      height: f.height * 1mm,
    )[#body])
  }

  return (
    poster: poster-syndrome.with(
      styles: styles,
      palette: theme.palette,
      frame: frame,
      container: container,
    ),
    frame: frame,
  )
}

