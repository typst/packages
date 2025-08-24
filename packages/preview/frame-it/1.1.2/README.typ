#import "@preview/frame-it:1.1.2": *
#import "src/utils/html.typ": *

#let base-color-arg = (:)
#let text-color = black
#let background-color = white
#if sys.inputs.at("theme", default: "light") == "dark" {
  text-color = rgb(240, 246, 252)
  background-color = rgb("#0d1117")
  base-color-arg.base-color = blue.darken(40%).desaturate(25%)
}
#let example-color = text-color.mix((text-color.negate(), 590%)).mix(gray)

#let (example, feature, variant, syntax) = frames(
  ..base-color-arg,
  feature: "Feature",
  variant: ("Feature Variant",),
  example: ("Example", example-color),
  syntax: ("Syntax",),
)

#set text(text-color)
#set text(17pt)

#let wants-svg-frames = sys.inputs.at("svg-frames", default: "false") != "false"
#show figure.where(kind: "frame"): it => context if (
  wants-html() and wants-svg-frames
) {
  html.frame({
    v(2mm)
    block(width: 24cm, it)
    v(2mm)
  })
} else { it }
#show: it => context if wants-html() and not wants-svg-frames {
  show raw.where(lang: "typst"): html.elem.with(
    "code",
    attrs: (class: "language-typst"),
  )
  it
} else if not wants-html() {
  set page(fill: background-color)
  set page(height: auto, margin: 4mm)
  it
} else { it }

#show: frame-style(styles.boxy)

= Introduction
#link("https://github.com/marc-thieme/frame-it", text(blue)[Frame-It]) offers a straightforward way to define and use custom environments in your documents. Its syntax is designed to integrate seamlessly with your source code.

Two predefined styles are included by default. You can also create custom styling functions that use the same user-facing API while giving you complete control over the Typst elements in your document.

#feature[Distinct Highlight][Best for occasional use][More noticeable][
  The default style, `styles.boxy`, is eye-catching and intended to stand out from the surrounding text.
]

In contrast:

#feature(
  style: styles.hint,
)[Unobtrusive Style][Ideal for frequent use][Blends into text flow][
  The alternative style `styles.hint` highlights text with a subtle colored line along the side, preserving the document's flow.
]

The default styles are merely functions with the correct signature.
If they don't appeal to you, you have complete freedom to define custom styling functions yourself.

#example[A different frame kind][
  You can define different classes or types of frames, which alter the substitute and the frame's color. As shown here, this is an example frame.
  You can create as many different kinds as you want.

  As long as all kinds use the same identifier with `frames`, they share a common counter.
]

= Quick Start
Import and define your desired frames:

```typst
#import "@preview/frame-it:1.1.2": *

#let (example, feature, variant, syntax) = frames(
  feature: ("Feature",),
  // For each frame kind, you have to provide its supplement title to be displayed
  variant: ("Variant",),
  // You can provide a color or leave it out and it will be generated
  example: ("Example", gray),
  // You can add as many as you want
  syntax: ("Syntax",),
)
// This is necessary. Don't forget this!
#show: frame-style(styles.boxy)
```

How to use it is explained below. Here is a quick example:
```typst
#example[Title][Optional Tag][
  Body, i.e. large content block for the frame.
]
```
which yields
#example[Title][Optional Tag][
  Body, i.e. large content block for the frame.
]

= Feature List

#let layout-features() = [
  #feature[Element with Title and Content][
    The simplest way to create an element is by providing a title as the first argument and content as the second.
  ]

  #variant[Element with Tags][Customizable Tags][Multiple][
    Elements can include multiple tags placed between the title and the content.
  ]

  #feature[][
    If you don’t require a custom title but still want to display the element type, use `[]` as the title placeholder.
  ]

  #variant[][Single Tag][Next tag][
    You can include tags even when no title is provided.
  ]

  #variant[
    To omit the header entirely, leave the title parameter empty.
  ]

  #feature[Element without Content][Optional Tags Only][]
  For brief elements, use [] as the body to omit the content.

  #feature[Element with Divider][
    Insert `divide()` to add a divider within your content for a visual break:
    #divide()
    And then continue with your text below the divider.
  ]
]

The following features are demonstrated in all predefined styles.

== Seamlessly hightight parts of your document
#[
  #show: frame-style(styles.hint)
  #layout-features()
]
== Highlight parts distinctively
#[
  #show: frame-style(styles.boxy)
  #layout-features()
]
== A third Alternative
#[
  #show: frame-style(styles.thmbox)
  We recently a third style, namely `styles.thmbox`:
  #layout-features()
]
== Miscellaneous
=== HTML
We were one of the first packages to add support for html!
This means you can use our frames for example if you're writing an html wiki or blog in typst
or using typst to get a headstart writing your website.
#feature[HTML export][
  Due to the currently experimental nature of the feature, you need to pass two CLI–flags when
  compiling your document with the frames to html:
  ```
  typst compile --features html --input html-frames=true --format html FILE.typ
  ```
]

=== General
Internally, every frame is just a `figure` where the `kind` is set to `"frame"` (or a different custom value).
As such, most things that can be done to a figure can be done with a frame as well.
Whenever you would like to do something custom but don't know if it is supported,
try achieving it with a normal figure first and then apply the same show rule to your frames.
Here is a list of examples:

#variant[Labels and References][
  Elements can be referenced as expected by appending `<label>` and referencing it:
  ```typst
  #syntax[Labels and References] <labels-and-refs>
  Referencing with @labels-and-refs.
  ```
] <reference-tag>
// For example: @reference-tag.

#variant[Break frames across pages][
  If you want to make your frames breakable across pages,
  you have to use the show rule known from the official typst docs:
  ```typst
  #show figure.where(kind: "frame"): set block(breakable: true)
  ```
  To turn off breakability, you can use the corresponding show rule
  ```typst
  #show figure.where(kind: "frame"): set block(breakable: false)
  ```
]

#feature[Per–frame custom figure parameters][Frame outline][
  All named parameters passed to a frame–function like `example[][]` are going to be passed
  to the figure function which places the frame in the document.
]

For example, you can create an outline which only contains some intentional of your frames like so.
The `figure` function includes a parameter for including a figure in the outline.
```typst
// By default, don't include frames in outlines by default
#show figure.where(kind: "frame"): set figure(outlined: false)
// Create the outline
#outline(target: figure.where(kind: "frame"))
// Explicitly include a frame in the outline with the `outlined` parameter.
#example(outlined: true)[Important frame][For the outline]
```

#variant[Different numbering][
  Numbering in figures is a bit of a mess.
  Natively, you are limited to one number and a format suffix/prefix.
  With that, you can do the following.
  ```typst
  #show figure.where(kind: "frame"): set figure(numbering: "a)")
  ```
  If you want to do more advanced and nested numbering, you can look into external packages for that.
  When trying to make a system apply to the frames, remember that they are just figures with a specific kind.

  In the background, there are also some show rules doing the styling for the frames.
  However, these should only get in the way when you are doing some esoteric manipulation of the figure captions.
]

#syntax[Different kind][for the underlying figures][
  When you have multiple different groups of frames you need to style independently,
  you can provide an arbitrary `kind` to the `frames` function.

  ```typst
  #let (syntax,) = frames(
    syntax: ("Syntax",),
  )
  #let (note,) = frames(
    kind: "other-kind"
    note: ("Note",),
  )
  #show: frame-style(styles.boxy)
  #show: frame-style(kind: "other-kind", styles.hint)
  ```
]

#syntax[Change the styling][
  To use a different styling function for just one frame, you can provide `style: styles.hint` as an extra argument:
  ```typst
  #variant(style: styles.hint)[
    To skip the header entirely, leave the title parameter blank.
  ]
  ```
]
Beware that internally, this has to create two distinct figures for technical reason.
In general, this approach will be less robust than using the `show: frame-style()` function.

When you want to change the styling used for a passage of your document,
you can just add more `show: frame-style()` rules:
```typst
#show: frame-style(styles.boxy)
#example[In boxy style][]
#show: frame-style(styles.hint)
#example[In hint Style][]
```

I usually define the abbreviations for the show rule:
```typst
// Define once
#let boxy(document) = {show: frame-style(styles.boxy); document}
#let hint(document) = {show: frame-style(styles.hint); document}

// Use changing the style used
#show: boxy
#example[In boxy style]
#example[Also in boxy style]
#show: hint
#example[In hint style]
```

= Custom Styling
Internally, there is nothing special about the predefined styles.
The only requirement for any styling function is to adhere to the following
function signature interface:


#syntax[Interface for custom styling function][
  ```typst
  #let custom-styling(title, tags, body, supplement, number, arg)
  ```
]
where `arg` is going to be the value passed behind the supplement for each frame variant in the `frames` function.
For the predefined styles, this is the color of the frames.
When defining your own styling function, it has to have the following signature:

The content returned will be placed as–is in the document.

#syntax[Styling Dividers][
  If your custom styling function shall support dividers, it must include a show rule in its body:
  ```typst
  #show: styling.dividers-as(object-which-will-be-used-as-divider)
  ```
]

For more information on how to define your own styling function, please look into the `styling` module.

= Experimentl APIs
These APIs are still experimental and subject to change. Use sparingly.

#syntax[Retrieving information of a frame][Experimental][
  When you want to do more intricate styling for your frames, sometimes it is necessary to
  obtain all the information which.

  For this, use the `inspect.lookup-frame-info(figure)` function.
  Given a figure (which represents a frame), it returns a dictionary with the entries
  `title`, `tags`, `body`, `supplement`, `color`.

  When the provided figure is not a frame, this function throws an error.
]
For example, you can use this to color the entries in a outline according to the color of the frame:
```typst
#show outline.entry: it => {
  let color = inspect.lookup-frame-info(it.element).color
  text(fill: color.saturate(70%), it)
}
#outline(target: figure.where(kind: "frame"))
```

#syntax[Checking whether a figure is a frame][Experimental][
  In order to test whether a figure is a frame, use the `inspect.is-frame(figure)` function.
]
Whenever possible, try to discern it using the figures kind instead of this function.

= Edge Cases

Here are a few edge cases.

#example[Test][Long tag example without space for the supplement][notice the number moves up][
  #lorem(20)
]

#example[Example][Tags of various sizes][$sum_sum^sum$][Extra vertical space: #v(1cm)][
  (Leads to formatting errors in html export because support is missing)\
  #lorem(20)
]

#example[Nested][
  #example[][
    #example(style: styles.hint)[][
      When nested, counters increment from outer to inner elements.
    ]
  ]
]

#example[][
  Counters continue incrementing sequentially in non-nested elements.
]

// Tests
#context {
  let frames = query(figure.where(kind: "frame"))
  for frame in query(figure.where(kind: "frame")) {
    assert(inspect.is-frame(frame), message: repr(frame))
    assert(type(inspect.lookup-frame-info(frame).color) == color)
  }
}
