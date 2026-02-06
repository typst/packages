#import "bundled-layout.typ": spawn-bundled-frame

#let unique-frame-metadata-tag = "_THIS-IS-METADATA-USED-FOR-FRAME-IT-FRAMES"

// Encode info as invisible metadata so when rendered in outline, only the title is seen
#let encode-title-and-info(title, info) = (
  metadata(unique-frame-metadata-tag) + metadata(info) + title
)
#let retrieve-info-from-code(code) = code.children.at(1).value
#let code-has-info-attached(code) = (
  "children" in code.fields().keys()
    and code.children.first().fields().at("value", default: "")
      == unique-frame-metadata-tag
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

#let frame-style(
  kind,
  style,
) = document => {
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
      spawn-bundled-frame(
        style,
        kind,
        title,
        tags,
        body,
        supplement,
        arg,
        ..title-and-tags.named(),
      )
    }
  }
)
