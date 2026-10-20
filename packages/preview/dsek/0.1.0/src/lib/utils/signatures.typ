#import "../misc/_mod.typ": *
#import "../fmt/fmt-references.typ": ref-id
#import "translate.typ": translate, translate-str

// TODO: In typst 0.15.0+, we can take a path to the image.
//       We cannot do this at the moment since paths are resolved
//       relative to the file in which the image function was called.

#let signature(
  message,
  name,
  position,
  image: none,
  width: auto,
  signature_height: 15mm,
  minimum_width: 40mm,
) = context {
  let width = if width == auto {
    calc.max(
      measure(message).width,
      measure(name).width,
      measure(position).width,
      minimum_width,
    )
  } else {
    width
  }

  box(
    width: width,
  )[
    #message \
    #box(height: signature_height, align(horizon, image)) \
    #name \
    #position \
  ]
  h(2em)
}

// A helper function to load an image.
#let signature-image = image.with(height: 1fr, fit: "contain")

#let author-signatures(
  authors,
  default-message: translate("Lund, dag som ovan", "Lund, day as above"),
  default-position: translate("Sektionsmedlem", "Guild member"),
) = {
  let authors = if type(authors) == array {
    authors.map(author => {
      if type(author) == dictionary {
        required-keys(
          author,
          ("name",),
          allowed: ("name", "position", "message", "signature"),
          fn: "author-signatures",
          hint: "each author dict needs at least `name`, e.g. (name: \"Truls Teknolog\", position: \"Gammal och dryg\") -- `position`, `message`, and `signature` are optional (but have default values)",
        )
        author
      } else {
        (name: author)
      }
    })
  } else if type(authors) in (str, content) {
    ((name: authors),)
  } else {
    (authors,)
  }

  v(1.5em)
  table(
    stroke: none,
    columns: 3, // TODO: calculate based on longest width?
    row-gutter: 2em,
    ..authors.map(author => {
      let message = author.at("message", default: default-message)
      let position = author.at("position", default: default-position)
      let lbl = if type(author.name) == content {
        to-label(to-text(author.name))
      } else {
        to-label(author.name)
      }
      let name = context {
        show heading: set text(font: text.font, weight: text.weight, size: text.size)
        set heading(depth: ref-id.person, numbering: none, outlined: false)
        [#heading(author.name, supplement: position) #label(lbl)]
      }

      signature(
        message,
        box(name),
        position,
        image: author.at("signature", default: none),
      )
    })
  )
}
