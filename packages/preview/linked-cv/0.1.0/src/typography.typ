#import "colours.typ": colours, get-accent-colour

#let fonts-state = state("fonts", (
  headings: "Arial",
  body: "Arial",
))
#let get-fonts() = fonts-state.get()
#let get-headings-font() = {
  let fonts = fonts-state.get()
  fonts.headings
}
#let get-body-font() = {
  let fonts = fonts-state.get()
  fonts.body
}
#let set-fonts(fonts) = {
  fonts-state.update(s => fonts)
}

#let name(content) = {
  context {
    let headings-font = get-headings-font()
    text(
      size: 32pt,
      weight: "bold",
      font: headings-font,
      fill: colours.black,
      content
    )
  }
}

#let social-entry(content) = text(
  size: 6.8pt,
  fill: colours.text,
  content
)

#let summary(content) = {
  context {
    let accent = get-accent-colour()
    text(
      size: 8.8pt,
      fill: accent,
      content
    )
  }
}

#let footer(content) = text(
  size: 8pt,
  fill: colours.lighttext,
  smallcaps(content)
)

#let section(content) = {
  context {
    let headings-font = get-headings-font()
    text(
      size: 16pt,
      weight: "bold",
      font: headings-font,
      fill: colours.text,
      content
    )
  }
}

#let subsection(content) = text(
  size: 12pt,
  fill: colours.text,
  smallcaps(content)
)

#let org(content) = {
  context {
    let headings-font = get-headings-font()
    text(
      size: 10pt,
      weight: "bold",
      font: headings-font,
      fill: colours.darktext,
      content
    )
  }
}

#let duration(content) = text(
  size: 8pt,
  style: "italic",
  fill: colours.graytext,
  content
)

#let project(content) = {
  context {
    let headings-font = get-headings-font()
    text(
      size: 10pt,
      weight: "bold",
      font: headings-font,
      fill: colours.darktext,
      content
    )
  }
}

#let date(content) = text(
  size: 8pt,
  style: "italic",
  fill: colours.graytext,
  content
)

#let description(content) = text(
  size: 9pt,
  fill: colours.text,
  content
)

#let table-header(content) = text(
  size: 9pt,
  weight: "bold",
  fill: colours.text,
  content
)

#let workstream(content) = {
  context {
    let headings-font = get-headings-font()
    text(
      weight: "bold",
      font: headings-font,
      fill: colours.black,
      content
    )
  }
}
