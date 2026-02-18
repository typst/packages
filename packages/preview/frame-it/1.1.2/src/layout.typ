#import "styling.typ"
#import "utils/encode.typ": (
  encode-title-and-info,
  retrieve-info-from-code,
  code-has-info-attached,
)

#let spawn-frame(
  kind,
  title,
  tags,
  body,
  supplement,
  custom-arg,
  ..figure-params,
) = {
  let frame-info = (
    title,
    tags,
    body,
    supplement,
    custom-arg,
  )
  figure(
    caption: encode-title-and-info(title, frame-info),
    supplement: supplement,
    kind: kind,
    ..figure-params,
    none,
  )
}

#let __frame-id-counter-state = state("__frame-it_frame-id-state", 1)

#let frame-style(
  kind,
  style,
) = document => {
  // Don't restrict to correct kind. We already discern between framees and user–figures
  // inspecting the metadata. This way, the user can manipulate the kind if desired.
  show figure.caption: caption => {
    let code = caption.body
    if not code-has-info-attached(code) {
      caption
    } else {
      let number = context caption.counter.display(caption.numbering)
      let (
        title,
        tags,
        body,
        supplement,
        custom-arg,
      ) = retrieve-info-from-code(code)
      style(title, tags, body, supplement, number, custom-arg)
    }
  }
  show: styling.dividers-as[
    `Error: Dividers not supported by this styling function.`
  ]

  import "utils/html.typ": elem-ident, elem-ignore
  show figure
    .where(kind: kind)
    .or(figure.where(kind: kind + "-wrapper")): it => {
    // Necessary because html-figure unfortunately inserts padding we don't want
    let id = __frame-id-counter-state.get()
    __frame-id-counter-state.update(it => it + 1)
    let figure-id = "frame-wrapper-" + str(id)
    let style-code = {
      "#" + figure-id + " > figure {"
      "  margin-left: 0px;"
      "  margin-right: 0px;"
      "}"
    }
    // If not html, this will just equate to { it }
    elem-ignore("style", style-code)
    elem-ident("div", id: figure-id, it)
  }
  document
}

#let frame-factory(kind, supplement, custom-arg) = (
  (..title-and-tags, body, style: auto, arg: custom-arg) => {
    let title = none
    let tags = ()
    if title-and-tags.pos() != () {
      (title, ..tags) = title-and-tags.pos()
    }
    if style == auto {
      spawn-frame(
        kind,
        title,
        tags,
        body,
        supplement,
        arg,
        ..title-and-tags.named(),
      )
    } else {
      figure(
        kind: kind + "-wrapper",
        supplement: supplement,
        outlined: false,
        {
          show: frame-style(kind, style)
          spawn-frame(
            kind,
            title,
            tags,
            body,
            supplement,
            custom-arg,
            ..title-and-tags.named(),
          )
        },
      )
    }
  }
)
