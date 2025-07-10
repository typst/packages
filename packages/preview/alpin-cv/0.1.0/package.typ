#let default-theme = (
  margin: 28pt,

  col-width-side: 5.5cm,
  col-width-separator: 0.5cm,
  col-width-main: 1fr,

  image-radius: 4cm,
  image-zoom: 1,
  image-border: 0.15em,

  h1-font: "Roboto Slab",
  font: "Lato",

  font-size: 10pt,
  h1-size:15pt,
  h2-size:11pt,
  contact-h1-size:25pt,
  contact-h2-size:12pt,
  contact-font-size: 10pt,

  body-color: rgb("222"),
  body-alt-color: rgb("00a"),
  h1-color: rgb("00a"),
  icon-color: rgb("#000000"),
  icon-caption-color: rgb("222"),

  border-stroke-width: 0.2em,
  border-color: black,

  contact-h1-color: none, // inherit
  contact-h2-color: none, // inherit
  contact-body-color: none, // inherit

  main-h1-color: none, // inherit
  main-body-color: none, // inherit

  aside-h1-color: none, // inherit
  aside-body-color: none, // inherit
  
  table-inside: (x:6pt, y:3pt),

  h2-above: 0.5em,
  contact-h2-above: 0.8em,
  contact-h1-below: 0.2em,

  text-margin-top: 1em,
  text-margin-bottom: 0.8em,

  h1-border-offset: 0.4em,
)

#let cv(
  photo: "",
  theme: (),
  aside: [],
  contact: [],
  main,
) = {
  // Function to pick a key from the theme, or a default if not provided.
  let th(key, default: none) = {
    return if key in theme and theme.at(key) != none {
      theme.at(key)
    } else if default != none and default in theme and theme.at(default) != none {
      theme.at(default)
    } else if default != none {
      default-theme.at(default)
    } else {
      default-theme.at(key)
    }
  }

  set page(
    margin: (
      top: th("margin"),
      bottom: th("margin"),
      left: th("margin"),
      right: th("margin"),
    ),
  )

  set text(fill: th("body-color"))

  show heading.where(level: 1): set text(
    size: th("h1-size"),
    font: th("h1-font")
  )
  show heading.where(level: 2): set text(size: th("h2-size"))

  show emph: set text(fill: th("body-alt-color"))

  set text(
    font: th("font"),
    size: th("contact-font-size")
  )

  show heading.where(level: 1): set par(leading: th("h1-border-offset"))
  set block(above: th("text-margin-top"), below: th("text-margin-bottom"))

  grid(
    columns: (th("col-width-side"), th("col-width-separator"), th("col-width-main")),
    {
      box(clip: true, stroke: th("image-border") + th("border-color"), radius: th("image-radius"),
      width: th("image-radius"), height:th("image-radius"),
      image(photo,height: th("image-zoom")*th("image-radius")))
    },
    {},
    {
      show heading.where(level: 1): h1 => [
        #set text(size: th("contact-h1-size"))
        #set text(fill: th("contact-h1-color", default: "h1-color"))
        #set block(below: th("contact-h1-below"))
        #h1
      ]

      show heading.where(level: 2): h2 => [
        #set block(above: th("contact-h2-above"))
        #set text(size: th("contact-h2-size"), weight: "bold")
        #set text(fill: th("contact-h2-color", default: "body-alt-color"))
        #h2
      ]
      
      set text(fill: th("contact-body-color", default: "body-color"))

      align(horizon, contact)
    }
  )

  set text( size: th("font-size"))

  show heading.where(level: 1): it => {
    set text(size: th("h1-size"))
    it.body
    box(width:100%,height: th("border-stroke-width"),fill:th("border-color"))
  }

  show heading.where(level: 2): h2 => [
    #set text(size: th("h2-size"))
    #set block(above: th("h2-above"))
    #h2
  ] 

  show table.where(label:<langs>): set table(
    stroke:none,
    columns: 2,
    inset: th("table-inside")
    
  )

  show table.where(label:<langs>): it => {
    show table.cell.where(x:0): set text(fill: th("table-gutter-color",default:"body-color"))
    show table.cell.where(x:1): set text(fill: th("table-body-color",default: "body-alt-color"))
    strong(it)
  }

  grid(
    columns: (th("col-width-side"), th("col-width-separator"), th("col-width-main")),

    // Aside.
    {
      show heading.where(level: 1): set text(fill: th("aside-h1-color", default: "h1-color"))
      show heading.where(level: 2): set text(fill: th("aside-body-color", default: "body-color"))
      set text(fill: th("aside-body-color", default: "body-color"))

      aside
    },

    // Empty space.
    {},

    // Content.
    {
      show heading.where(level: 1): set text(fill: th("main-h1-color", default: "h1-color"))
      show heading.where(level: 2): set text(fill: th("main-body-color", default: "body-color"))
      set text(fill: th("main-body-color", default: "body-color"))

      main
    },
  )
}
