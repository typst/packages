#import "helpers.typ": linked-text
#import "config.typ": default-person, default-placement, default-page, default-spacing, spacing-state

// The page parameter shadows the built-in page function.
#let page-set = page

#let resume(
  person: (:),
  placement: (:),
  page: (:),
  spacing: (:),
  body,
) = {
  let who = default-person + person
  let place = default-placement + placement
  let p = default-page + page
  let s = default-spacing + spacing

  set document(author: who.name, title: who.name)
  set text(font: p.font, size: p.at("font-size"), lang: p.lang, ligatures: false)
  set page-set(margin: p.margin, paper: p.paper)

  show link: it => {
    set text(fill: rgb(p.at("accent-color")))
    if type(it.dest) == str and it.dest.starts-with("tel:") {
      it
    } else {
      underline(it)
    }
  }

  show heading: set text(fill: rgb(p.at("accent-color")))
  show heading.where(level: 1): it => [
    #set align(place.name)
    #set text(weight: 600, size: p.at("name-size"))
    #pad(it.body)
  ]

  spacing-state.update(s)
  [= #(who.name)]

  pad(top: 0em, bottom: s.at("after-header"), align(place.contact)[
    #{
      let items = (
        linked-text(who.pronouns),
        linked-text(who.phone, link-prefix: "tel:"),
        linked-text(who.location),
        linked-text(who.email, link-prefix: "mailto:", text: who.at("email-text")),
        linked-text(who.linkedin, link-prefix: "https://", text: who.at("linkedin-text")),
        linked-text(who.github, link-prefix: "https://", text: who.at("github-text")),
        linked-text(
          who.at("personal-site"),
          link-prefix: "https://",
          text: who.at("personal-site-text"),
        ),
      )
      items.filter(x => x != none).join(" | ")
    }
  ])

  set par(justify: true, leading: s.at("line-spacing"), spacing: s.at("block-spacing"))
  set block(spacing: s.at("block-spacing"))
  // A tight list would swallow the space under an entry header.
  show list: set block(above: s.at("item-spacing"))

  // Negative pads pull the section rule up against the title.
  show heading.where(level: 2): it => {
    pad(bottom: -2pt)[
      #set text(weight: 500)
      #pad(top: 0pt, bottom: -10pt, smallcaps(it.body))
      #line(length: 100%, stroke: s.at("section-rule"))
    ]
  }

  body
}
