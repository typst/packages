#import "utils/encode.typ": (
  code-has-info-attached, encode-title-and-info, retrieve-info-from-code,
)

#let assert-kind(kind) = assert(
  type(kind) == str,
  message: "Kind must be a string, was " + repr(type(kind)),
)

#let spawn-frame(
  kind,
  title,
  tags,
  body,
  supplement,
  custom-arg,
  style,
  ..figure-params,
) = {
  figure(
    caption: encode-title-and-info(
      kind,
      title,
      tags,
      body,
      supplement,
      custom-arg,
      style,
    ),
    supplement: supplement,
    kind: kind,
    ..figure-params,
    none,
  )
}

#let frame-style(kind, style) = {
  assert-kind(kind)
  assert(
    type(style) == function,
    message: "Style must be a styling function, was " + repr(type(style)),
  )

  document => {
    // Don't restrict to correct kind. We already discern between frames and user–figures
    // inspecting the metadata. This way, the user can manipulate the kind if desired.
    show figure.caption: caption => {
      let code = caption.body
      if (
        not code-has-info-attached(code)
          or retrieve-info-from-code(code).kind != kind
      ) {
        caption
      } else {
        let number = if caption.numbering != none {
          context caption.counter.display(caption.numbering)
        }
        let (
          title,
          tags,
          body,
          supplement,
          custom-arg,
          style: bundled-style,
        ) = retrieve-info-from-code(code)
        let actual-style = if bundled-style != auto { bundled-style } else {
          style
        }
        actual-style(title, tags, body, supplement, number, custom-arg)
      }
    }
    import "styling/html.typ": wants-html
    show figure
      .where(kind: kind)
      .or(figure.where(kind: kind + "-wrapper")): it => {
      // Necessary because html-figure unfortunately inserts padding we don't want.
      // The style sits inside the div so the div is the first element and gets the label's id.
      // If not html, this is just `it`
      if wants-html() {
        html.div(class: "frame-it-wrapper", {
          html.style(
            ".frame-it-wrapper > figure { margin-left: 0; margin-right: 0 }",
          )
          it
        })
      } else {
        it
      }
    }
    document
  }
}

#let frame-factory(kind, supplement, custom-arg) = {
  assert-kind(kind)
  assert(
    type(supplement) in (content, str),
    message: "Supplement must be content or a string, was "
      + repr(type(supplement)),
  )

  (..title-and-tags, body, style: auto, arg: custom-arg) => {
    assert(
      style == auto or type(style) == function,
      message: "Style must be a styling function or auto (style inherited), was "
        + repr(type(style)),
    )
    assert(
      body == none or type(body) in (content, str),
      message: "Body must be content or a string, was " + repr(type(body)),
    )

    // The title is optional and may be `none`, the tags must be content or strings
    let pos = title-and-tags.pos()
    if pos != () {
      assert(
        pos.first() == none or type(pos.first()) in (content, str),
        message: "Title must be content, a string or none, was "
          + repr(type(pos.first())),
      )
      for tag in pos.slice(1) {
        assert(
          type(tag) in (content, str),
          message: "Tags must be content or strings, was " + repr(type(tag)),
        )
      }
    }

    let title = none
    let tags = ()
    if pos != () {
      (title, ..tags) = pos
    }
    spawn-frame(
      kind,
      title,
      tags,
      body,
      supplement,
      arg,
      style,
      ..title-and-tags.named(),
    )
  }
}
