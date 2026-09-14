// DEPRECATED. This file is deprecated. Use `layout.typ` instead.
// The implementation in `layout.typ` is simpler and more robust.
#let encode-caption-id(
  kind,
  title,
  tags,
  body,
  supplement,
  custom-arg,
) = [
  Uniquely identify this to make the `show figure`-clause as specific as possible.
  #(
    (
      kind,
      title,
      tags,
      body,
      supplement,
      custom-arg,
    )
      .map(repr)
      .join(", ")
  )
]

#let spawn-bundled-frame(
  style,
  kind,
  title,
  tags,
  body,
  supplement,
  custom-arg,
) = figure(
  kind: kind + "-wrapper",
  supplement: supplement,
  outlined: false,
  {
    let caption-id = encode-caption-id(
      kind,
      title,
      tags,
      body,
      supplement,
      custom-arg,
    )
    // Offset the counter because our outer helper figure has the same kind.
    // The outer figure must have the same kind as the inner because the user might rely
    // on the outer one having the kind he knows when he's writing rules for references
    // NOTE I don't know the performance impact of this
    // Inject the customized styling into the caption.
    // We use the caption because we have access to the supplement and the numbering there.
    show figure.caption.where(body: caption-id): caption => (
      context {
        let number = caption.counter.display(caption.numbering)
        style(title, tags, body, supplement, number, custom-arg)
      }
    )

    // Make figure breakable.
    // In order to use this, you also need to explicitly use the show rule defined in the layout package.
    // We recommend scoping this show rule if you do not want it to apply for every frame.
    // The alternative possibility is in turn to wrap a single frame into an unbreakable block.
    // See: https://typst.app/docs/reference/model/figure/#figure-behaviour
    // See: https://github.com/marc-thieme/frame-it/issues/1
    show figure.where(kind: kind, supplement: none): set block(breakable: true)

    figure(caption: caption-id, supplement: none, gap: 0pt, kind: kind, none)
  },
)

// Wrap it in a second figure because of three facts:
// 1. We need to return a type figure to make it labellable
// 2. We need to specify rules (set and show) to modify caption styling
// 3. If we specify rules in the block which is returned, a type 'styled' is returned instead of the figure
#let bundled-factory(style, supplement, kind, custom-arg) = (
  (..title-and-tags, body, style: style, arg: custom-arg) => {
    let title = none
    let tags = ()
    if title-and-tags.pos() != () {
      (title, ..tags) = title-and-tags.pos()
    }
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
)

// DEPRECATED
#let breakable-frames(kind, breakable: true) = (
  it => {
    show figure.where(kind: kind): set block(breakable: breakable)
    it
  }
)
