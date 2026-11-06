#import "@preview/polylux:0.4.0": *
#import "@preview/tiaoma:0.2.1"

#import "icons/icons.typ"

#let accent1 = rgb("637A9F")
#let accent2 = rgb("E8C872")
#let accent3 = rgb("80B9AD")
#let accent4 = rgb("B3E2A7")

#let get-in-touch(
  title: [Get in touch!],
  email: none,
  website: none,
  mastodon: none,
) = {
  let rows = (
    if email != none {
      (icons.email, email)
    } else { () },
    if website != none {
      (icons.www, website)
    } else { () },
    if mastodon != none {
      (icons.mastodon, mastodon)
    } else { () },
  ).flatten()

  title
  grid(columns: 2, column-gutter: .5em, row-gutter: 1em, align: horizon, ..rows)
}

#let titled-block(title: [], body, ..kwargs) = {
  stack(
    dir: ttb,
    spacing: 5pt,
    text(
      size: .8em,
      fill: accent1,
      sym.triangle.small.stroked.r + sym.space + title
    ),
    block(
      inset: 10pt,
      width: 100%,
      stroke: 2pt + accent1.lighten(50%),
      ..kwargs.named(),
      body
    )
  )
}

#let setup(
  body,
  short-title: [],
  short-speaker: [],
) = {
  set page(
    paper: "presentation-16-9",
    margin: 1em,
    footer: {
      set align(bottom)
      show: pad.with(bottom: .2em)
      set text(size: .5em, fill: gray)
      short-title
      h(1fr)
      short-speaker
      h(2fr)
      toolbox.slide-number
    },
  )
  show heading.where(level: 1): underline.with(
    background: true,
    stroke: (thickness: .3em, paint: accent2.lighten(50%), cap: "round"),
    evade: false,
    extent: .2em,
  )
  show heading: set block(below: 1em)

  body
}

#let title-slide(
  title: [],
  speaker: [],
  speaker-website: none,
  conference: [],
  slides-url: none,
  qr-caption: [these slides],
  logo: auto,
) = slide({
  set page(margin: 0pt, footer: none)
  set align(horizon)
  grid(
    columns: (1fr, 2fr),
    rows: (100%, ),
    gutter: 1em,
    grid.cell(inset: (top: 2em, bottom: 1em, left: .5em), align: right, {
      show image: set block(spacing: 0pt)

      if slides-url != none {
        toolbox.side-by-side(
          {
            show: rotate.with(-10deg)
            set text(size: .6em)
            qr-caption
            sym.space
            icons.right-arrow
          },{
            set image(width: 100%)
            tiaoma.barcode(
              slides-url,
              "QRCode",
              options: ( fg-color: accent2, bg-color: none, )
            )
          }
        )
      }

      v(1fr)
      if logo == auto {
        rect(width: 100%, height: 3em)[
          #set text(size: .3em)
          (specify `logo:` in `title-slide` to replace this by your logo, or
          set it to `none` to show nothing)
        ]
      } else if logo == none {
        // do nothing
      } else {
        logo
      }
    }), grid.cell(fill: accent1, inset: 1em, align: left)[
      #set text(fill: white,)
      #title

      #v(1cm)

      #smallcaps(conference)

      #v(1cm)

      #speaker \
      #if speaker-website != none {
        icons.www-white
        sym.space.nobreak
        link("https://" + speaker-website)[#speaker-website]
      }
    ]
  )
})

#let last-slide(
  title: [],
  project-url: none,
  qr-caption: [],
  contact-appeal: [Get in touch!],
  ..args,
) = slide({
  heading(level: 1, title)

  v(1fr)

  grid(
    columns: (2fr, 5fr),
    gutter: 2em,
    align: top,
    if project-url != none {
      set image(width: 100%)
      tiaoma.barcode(
        project-url,
        "QRCode",
        options: ( fg-color: accent2, bg-color: none, ),
      )
      show: rotate.with(5deg)
      set text(size: .6em)
      icons.up-arrow
      qr-caption
    },
    get-in-touch(title: contact-appeal, ..args.named())
  )

  v(1fr)
})
