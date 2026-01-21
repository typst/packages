#let spawn-frame(
  style,
  kind,
  title,
  tags,
  body,
  supplement,
  custom-arg,
) = figure(
  kind: kind,
  supplement: supplement,
  {
    let caption-id = [
      Uniquely identify this to make the `show figure`-clause as specific as possible.
      #(
        style,
        kind,
        title,
        tags,
        body,
        supplement,
        custom-arg,
      ).map(repr).join(", ")
    ]
    // Offset the counter because our outer helper figure has the same kind.
    // The outer figure must have the same kind as the inner because the user might rely
    // on the outer one having the kind he knows when he's writing rules for references
    counter(figure.where(kind: kind)).update(old => old - 1)
    // NOTE I don't know the performance impact of this
    // Inject the customized styling into the caption.
    // We use the caption because we have access to the supplement and the numbering there.
    show figure.caption.where(body: caption-id): caption => (
      context {
        let number = caption.counter.display(caption.numbering)
        style(title, tags, body, supplement, number, custom-arg)
      }
    )

    figure(caption: caption-id, supplement: none, gap: 0pt, kind: kind, none)
  },
)

// Wrap it in a second figure because of three facts:
// 1. We need to return a type figure to make it labellable
// 2. We need to specify rules (set and show) to modify caption styling
// 3. If we specify rules in the block which is returned, a type 'styled' is returned instead of the figure
#let factory(style, supplement, kind, custom-arg) = (
  (..title-and-tags, body, style: style, arg: custom-arg) => {
    assert(
      title-and-tags.named() == (:),
      message: "You provided named arguments which are not supported: " + repr(
        title-and-tags.named(),
      ),
    )
    let title = none
    let tags = ()
    if title-and-tags.pos() != () {
      (title, ..tags) = title-and-tags.pos()
    }
    spawn-frame(style, kind, title, tags, body, supplement, arg)
  }
)

#let DIVIDE-IDENTIFIER = "__MAKEFRAMES_DIVIDE-IDENTIFIER"
#let divide() = figure(kind: DIVIDE-IDENTIFIER, supplement: none)[
  `Error: Dividers not supported by this styling function.`
]
