#import "/utils/states.typ": heh-config

#let thanks-page() = context {
  let config = heh-config.get()
  box(
    width: 60%,
    text(style: "italic", { config.document.thanks }),
  )
  pagebreak()
}
