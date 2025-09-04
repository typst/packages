#import "/src/libs.typ": bullseye, fontawesome.fa-icon

#import "paged.typ"
#import "htmlx.typ"

/// Enables or disables the removal of ```html <p class="c4l-spacer"></p>``` elements from the
/// output when exporting to HTML. By default, these elements are rendered to be consistent with the
/// C4L editor moodle plugins (for Atto and TinyMCE), but this looks bad according to my testing on
/// a clean Moodle install; see also https://github.com/reskit/moodle-tiny_c4l/issues/20.
///
/// The default of this setting can be overridden by compiling with `--input moodular-remove-spacer=true`.
///
///  -> content
#let remove-spacer(
  /// whether to remove spacer elements or not.
  /// -> bool
  value,
) = htmlx.remove-spacer(value)

= Contextual components

/// See https://componentsforlearning.org/components/key-concept/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.key-concept[#lorem(20)]
/// ```)
///
/// -> content
#let key-concept(
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      width: if full-width { 100% } else { 75% },
      padding: (top: 24pt, right: 36pt, bottom: 30pt, left: 36pt),
      fill: rgb("#f1f5fe"),
      left-bar: rgb("#387af1"),
    )

    body
  },
  html: {
    show: htmlx.container.with(
      "keyconcept",
      "Key concept",
      full-width: full-width,
    )

    body
  },
)

/// See https://componentsforlearning.org/components/tip/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.tip[#lorem(20)]
/// ```)
///
/// -> content
#let tip(
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      width: if full-width { 99% } else { 75% },
      padding: (top: 24pt, right: 48pt, bottom: 30pt, left: 36pt),
      fill: rgb("#fbeffa"),
      left-bar: rgb("#b00ca9"),
      top-right-float: (dx: 3pt, dy: 6pt, body: paged.icon-flag(rgb("#b00ca9"), "lightbulb")),
    )

    body
  },
  html: {
    show: htmlx.container.with(
      "tip",
      "Tip",
      full-width: full-width,
    )

    body
  },
)

/// See https://componentsforlearning.org/components/reminder/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.reminder[#lorem(20)]
/// ```)
///
/// -> content
#let reminder(
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      width: if full-width { 99% } else { 75% },
      padding: (top: 24pt, right: 48pt, bottom: 30pt, left: 36pt),
      fill: rgb("#eff8fd"),
      left-bar: rgb("#16b9ff"),
      top-right-float: (dx: 3pt, dy: 6pt, body: paged.icon-flag(rgb("#16b9ff"), "thumbtack")),
    )

    body
  },
  html: {
    show: htmlx.container.with(
      "reminder",
      "Reminder",
      full-width: full-width,
    )

    body
  },
)

/// See https://componentsforlearning.org/components/quote/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.quote[#lorem(20)]
/// ```)
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.quote(attribution: lorem(5))[#lorem(20)]
/// ```)
///
/// -> content
#let quote(
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
  /// the attribution associated with the quote
  /// -> content | none
  attribution: none,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      width: if full-width { 100% } else { 90% },
    )
    {
      show: paged.container.with(
        spacing: 24pt,
        padding: (left: 16pt, y: 4pt),
        left-bar: 4pt+rgb("#387af1"),
      )

      set text(font: "Liberation Serif")

      let qm(body) = {
        set text(1.2em, rgb("#387af1"), weight: "bold")
        box(height: 0.5em, body)
      }
      qm[“]
      h(2pt)
      text(style: "italic", body)
      h(2pt)
      qm[”]
    }
    if attribution != none {
      set align(right)

      attribution
    }
  },
  html: {
    show: htmlx.container.with(
      "quote",
      "Quote",
      full-width: full-width,
      quote: attribution != none,
    )
    {
      show: htmlx.div.with(class: "c4l-quote-body")
      htmlx.div(class: "c4l-quote-line", " ")
      show: htmlx.div.with(class: "c4l-quote-text")

      parbreak()
      body
    }
    if attribution != none {
      show: htmlx.div.with(class: "c4l-embedded-caption", aria-label: "Caption")

      attribution
    }
  },
)

/// See https://componentsforlearning.org/components/do-dont-cards/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.do-dont[#lorem(20)][#lorem(20)]
/// ```)
///
/// -> content
#let do-dont(
  /// the body to wrap in the component's "do" block
  /// -> content
  do,
  /// the body to wrap in the component's "don't" block
  /// -> content
  dont,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    let icon(fill, icon) = {
      show: block.with(
        inset: (x: 12pt, y: 8pt),
      )

      fa-icon(icon, 1.5em, fill, solid: true)
    }

    {
      show: paged.container.with(
        spacing: 24pt,
        width: if full-width { 100% } else { 90% },
        padding: (top: 24pt, right: 48pt, bottom: 30pt, left: 36pt),
        fill: rgb("#f1fbf5"),
        radius: 10pt,
        top-right-float: icon(green, "check-circle"),
      )

      do
    }
    {
      show: paged.container.with(
        spacing: 24pt,
        width: if full-width { 100% } else { 90% },
        padding: (top: 24pt, right: 48pt, bottom: 30pt, left: 36pt),
        fill: rgb("#ffefef"),
        radius: 10pt,
        top-right-float: icon(red, "xmark-circle"),
      )

      dont
    }
  },
  html: {
    show: htmlx.container.with(
      "dodontcards",
      "Do/don't cards",
      full-width: full-width,
    )
    htmlx.div(
      class: "c4l-dodontcards-do",
      aria-label: "Do card",
      do
    )
    htmlx.div(
      class: "c4l-dodontcards-dont",
      aria-label: "Don't card",
      dont
    )
  },
)

/// See https://componentsforlearning.org/components/reading-context/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example(pad: (x: 1pt, y: 30pt))
/// c4l.reading-context(comfort-reading: true)[#lorem(20)]
/// ```)
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example(pad: (x: 1pt, y: 30pt))
/// c4l.reading-context(attribution: lorem(5))[#lorem(20)]
/// ```)
///
/// -> content
#let reading-context(
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
  /// the attribution associated with the quote
  /// -> content | none
  attribution: none,
  /// whether to display the context in a serif font
  /// -> bool
  comfort-reading: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      width: if full-width { 94% } else { 88% },
      padding: (top: 30pt, right: 40pt, bottom: 32pt, left: 40pt),
      shadow: true,
    )

    set text(font: "Liberation Serif") if comfort-reading

    body

    if attribution != none {
      set align(right)
      set text(style: "italic")

      attribution
    }
  },
  html: {
    show: htmlx.container.with(
      "readingcontext",
      "Key Reading context",
      full-width: full-width,
      quote: attribution != none,
      comfort-reading: comfort-reading,
    )

    parbreak()
    body

    if attribution != none {
      show: htmlx.div.with(class: "c4l-embedded-caption", aria-label: "Caption")

      attribution
    }
  },
)

/// See https://componentsforlearning.org/components/example/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example(pad: (x: 1pt, y: 30pt))
/// c4l.example[Title][#lorem(20)]
/// ```)
///
/// -> content
#let example(
  /// the example's title
  /// -> content
  title,
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      width: if full-width { 94% } else { 88% },
      padding: (y: 36pt, x: 48pt),
      shadow: true,
    )

    {
      set text(0.9em, rgb("#3171e3"), weight: "bold")
      show: block.with(
        stroke: (bottom: 2pt+rgb("#3171e3")),
        inset: (bottom: 5pt),
      )

      upper(title)
    }

    body
  },
  html: {
    show: htmlx.container.with(
      "example",
      "Example",
      full-width: full-width,
    )
    htmlx.elem("h1", title)

    body
  },
)

/// See https://componentsforlearning.org/components/figure/ for details and examples rendered in HTML.
///
/// This is rendered as a regular figure in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// >>> set figure(numbering: none)
/// c4l.figure(rect())
/// ```)
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// >>> set figure(numbering: none)
/// c4l.figure(rect(), caption: lorem(5))
/// ```)
///
/// -> content
#let figure(
  /// the arguments accepted by Typst' built-in #link("https://typst.app/docs/reference/model/figure/")[`figure()`]
  /// -> arguments
  ..args,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: std.figure(..args),
  html: {
    assert.eq(args.pos().len(), 1)
    let ((body,), args) = (args.pos(), args.named())

    show: htmlx.container.with(
      element: "figure",
      "figure",
      "Figure",
      full-width: full-width,
    )

    body
    if "caption" in args {
      show: htmlx.elem.with("figcaption")
      show: htmlx.elem.with("em", class: "c4l-figure-footer")
      args.caption
    }
  },
)

// TODO Tag
// TODO Inline tag

= Procedural components

/// See https://componentsforlearning.org/components/attention/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.attention[#lorem(20)]
/// ```)
///
/// -> content
#let attention(
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      width: if full-width { 99% } else { 75% },
      padding: (top: 24pt, right: 48pt, bottom: 30pt, left: 36pt),
      fill: rgb("#fef6ed"),
      left-bar: rgb("#f88923"),
      top-right-float: (dx: 3pt, dy: 6pt, body: paged.icon-flag(rgb("#f88923"), "circle-exclamation")),
    )

    body
  },
  html: {
    show: htmlx.container.with(
      "attention",
      "Attention",
      full-width: full-width,
    )

    body
  },
)

// TODO Estimated Time
// TODO Due Date

/// See https://componentsforlearning.org/components/procedural-context/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.procedural-context[#lorem(20)]
/// ```)
///
/// -> content
#let procedural-context(
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(spacing: 24pt)
    set text(rgb("#3a56af"), style: "italic")

    body
  },
  html: {
    show: htmlx.container.with(
      element: "p",
      "proceduralcontext",
      "Procedural context",
      full-width: full-width,
    )

    body
  },
)

/// See https://componentsforlearning.org/components/learning-outcomes/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.learning-outcomes[Title][
///   - #lorem(5)
///   - #lorem(10)
/// ]
/// ```)
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.learning-outcomes[Title][
///   + #lorem(5)
///   + #lorem(10)
/// ]
/// ```)
///
/// -> content
#let learning-outcomes(
  /// the block's title
  /// -> content
  title,
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      width: if full-width { 100% } else { 75% },
      padding: (top: 24pt, right: 48pt, bottom: 30pt, left: 36pt),
      fill: rgb("#f2f5fd"),
      top-left-float: (dx: -3pt, dy: 6pt, body: {
        show: block.with(
          inset: (x: 7pt, y: 4pt),
          radius: (top-right: 3pt, bottom-right: 3pt),
          fill: rgb("#497ae9"),
        )
        set text(0.8em, white, weight: "bold")

        upper(title)
      }),
    )
    set list(
      spacing: 21pt,
      marker: {
        show: box.with(height: 0.65em)
        set text(1.5em, rgb("#497ae9"))
        set align(horizon)
        v(-0.18em)
        sym.triangle.r.filled
      },
    )
    set enum(
      spacing: 21pt,
      numbering: n => {
        set text(rgb("#497ae9"), weight: "bold")
        numbering("1.", n)
      },
    )

    v(24pt)

    body
  },
  html: {
    let ordered-list = {
      let sequence = [].func()
      // the body is content (not e.g. a string) and either
      type(body) == content and (
        // an enumerated list
        body.func() == enum or (
          // or a sequence
          body.func() == sequence and
          // containing an enum or enum item
          body.children.any(it => type(it) == content and it.func() in (enum, enum.item))
        )
      )
    }

    show: htmlx.container.with(
      "learningoutcomes",
      "Learning outcomes",
      full-width: full-width,
      ordered-list: ordered-list,
    )

    let c4l-list(it) = {
      show: htmlx.elem.with("ul", class: "c4l-learningoutcomes-list")

      for elem in it.children {
        htmlx.elem("li", elem.body)
      }
    }

    htmlx.elem(
      "h6",
      class: "c4l-learningoutcomes-title",
      title,
    )

    show list: c4l-list
    show enum: c4l-list

    body
  },
)

= Evaluative components

// TODO Grading Value

/// See https://componentsforlearning.org/components/expected-feedback/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example(pad: (x: 1pt, y: 30pt))
/// c4l.expected-feedback[#lorem(20)]
/// ```)
///
/// -> content
#let expected-feedback(
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      spacing: 48pt,
      width: if full-width { 94% } else { 75% },
      padding: (top: 24pt, right: 36pt, bottom: 30pt, left: 36pt),
      shadow: true,
      radius: 8pt,
      bottom-right-float: (dx: 3pt, dy: -6pt, body: {
        show: scale.with(x: -100%)
        paged.icon-flag(rgb("#497ae9"), "repeat")
      }),
    )
    set text(style: "italic")

    body
  },
  html: {
    show: htmlx.container.with(
      "expectedfeedback",
      "Expected feedback",
      full-width: full-width,
    )

    parbreak()
    body
  },
)

= Helper components

/// See https://componentsforlearning.org/components/all-purpose-card/ for details and examples rendered in HTML.
///
/// This is how the component looks in PDF preview:
///
/// #example(dir: ttb, scale-preview: 100%, ```typc
/// >>> show: c4l-example()
/// c4l.card[#lorem(20)]
/// ```)
///
/// -> content
#let card(
  /// the body to wrap in the component
  /// -> content
  body,
  /// whether the component should take up the full text width
  /// -> bool
  full-width: false,
) = context bullseye.on-target(
  paged: {
    show: paged.container.with(
      width: if full-width { 100% } else { 75% },
      padding: (top: 24pt, right: 48pt, bottom: 30pt, left: 36pt),
      fill: rgb("#f1f5fe"),
      radius: 10pt,
    )

    body
  },
  html: {
    show: htmlx.container.with(
      "allpurposecard",
      "All-purpose card",
      full-width: full-width,
    )

    parbreak()
    body
  },
)

= show rules

/// An optional show rule that transforms all regular Typst blockquotes into C4L quotes:
///
/// #example(dir: ttb, scale-preview: 100%, ```typ
/// >>> #show: c4l-example()
/// #quote(block: true)[before ...]
/// #show: c4l.blockquotes-as-c4l()
/// #quote(block: true)[... after]
/// ```)
///
/// -> function
#let blockquotes-as-c4l(
  /// whether blockquotes should take up the full text width
  /// -> bool
  full-width: false,
) = body => {
  show std.quote.where(block: true): it => {
    quote(it.body, attribution: it.attribution, full-width: full-width)
  }

  body
}

/// An optional show rule that transforms all regular Typst figures into C4L figures:
///
/// ```typ
/// #figure(image("example.png"), caption: [before ...])
/// #show: c4l.figures-as-c4l()
/// #figure(image("example.png"), caption: [... after])
/// ```
///
/// Note that C4L figures are displayed as regular figures when exporting to PDF,
/// so there is no difference to show here.
/// The generated HTML would look roughly like this:
///
/// // work around Tidy's treatment of @@
/// #show "PLUGINFILE": it => "@@" + it + "@@"
///
/// ```html
/// <figure>
///   <img src="PLUGINFILE/example.png" class="img-fluid">
///   <figcaption>Figure 1: before …</figcaption>
/// </figure>
/// <p class="c4l-spacer"></p>
/// <figure class="c4lv-figure" aria-label="Figure">
///   <img src="PLUGINFILE/example.png" class="img-fluid">
///   <figcaption><em class="c4l-figure-footer">Figure 2: … after</em></figcaption>
/// </figure>
/// ```
///
/// -> function
#let figures-as-c4l(
  /// whether figures should take up the full text width
  /// -> bool
  full-width: false,
) = body => {
  show std.figure: bullseye.show-target(html: it => {
    let caption = if it.caption != none {
      let supplement = it.supplement
      let it = it.caption
      [#supplement #context it.counter.display(it.numbering)]
      it.separator
      it.body
    }
    figure(it.body, caption: caption, full-width: full-width)
  })

  body
}
