#import "src/lib.typ": *

#set page(height: auto)

#let (example, feature, variant, syntax) = make-frames(
  "core-frames",
  feature: ("Feature",),
  variant: ("Feature Variant",),
  example: ("Example", gray),
  syntax: ("Syntax",),
)

= Introduction
#link("https://github.com/marc-thieme/frame-it", text(blue)[Frame-It]) offers a straightforward way to define and use custom environments in your documents. Its syntax is designed to integrate seamlessly with your source code.

Two predefined styles are included by default. You can also create custom styling functions that use the same user-facing API while giving you complete control over the Typst elements in your document.

#feature[Distinct Highlight][Best for occasional use][More noticeable][
  The default style, `styles.boxy`, is eye-catching and intended to stand out from the surrounding text.
]

In contrast:

#feature(style: styles.hint)[Unobtrusive Style][Ideal for frequent use][Blends into text flow][
  The alternative style `styles.hint` highlights text with a subtle colored line along the side, preserving the document's flow.
]

#example[A different frame kind][
  You can define different classes or types of frames, which alter the substitute and the frame's color. As shown here, this is an example frame.
  You can create as many different kinds as you want.

  As long as all kinds use the same identifier with `make-frames`, they share a common counter.
]

= Quick Start
Import and define your desired frames:

```typst
#import "@preview/frame-it:1.0.0"

#let (example, feature, variant, syntax) = make-frames(
  // This identifies the counter used for all theorems in this definition
  "counter-id",
  theorem: ("Theorem",),
  // For each frame kind, you have to provide its supplement title to be displayed
  definition: ("Definition",),
  // You can provide a color or leave it out and it will be generated
  example: ("Example", gray),
  // You can add as many as you want
  corollary: ("Corollary",),
)
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

#let layout-features(style) = [
  #let (example, feature, variant) = (
    example.with(style: style),
    variant.with(style: style),
    feature.with(style: style),
  )

  #feature[Element with Title and Content][
    The simplest way to create an element is by providing a title as the first argument and content as the second.
  ]

  #variant[Element with Tags][Customizable Tags][!][
    Elements can include multiple tags placed between the title and the content.
  ]

  #feature[][
    If you don’t require a custom title but still want to display the element type, use `[]` as the title placeholder.
  ]

  #variant[][Single Tag][
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

The following features are demonstrated in both predefined styles.

== Style Blending into Text Flow
#layout-features(styles.hint)
== Boxy Style
#layout-features(styles.boxy)

#feature[References][
  Elements can be referenced as usual with `<... tag ...>`.
] <reference-tag>

For example: @reference-tag.

= Syntax
You define one or more styles by using the `make-frames` function:

#syntax[Initialization][
  ```typst
  #let (example, feature, variant, syntax) = make-frames(
    "core-frames",
    feature: ("Feature",),
    variant: ("Feature Variant",),
    example: ("Example", gray),
    syntax: ("Syntax",),
  )
  ```
]

And use them like this:

#syntax[
  ```typst
  #feature[Distinct Highlight][Best for occasional use][More noticeable][
    The default style, `styles.boxy`, is eye-catching and intended to stand out from the surrounding text.
  ]
  ```
]

Or using an explicit styling function:

#syntax[
  ```typst
  #variant(style: styles.boxy)[
    To skip the header entirely, leave the title parameter blank.
  ]
  ```
  This styling function can be provided as default for all frame kinds:
  ```typst
  #let (example, feature, variant, syntax) = make-frames(
    style: styles.hint,
    "core-frames",
    feature: ("Feature",),
    variant: ("Feature Variant",),
    example: ("Example", gray),
    syntax: ("Syntax",),
  )
  ```
  Note that this only affects those defined in the same call to `make-frames`.
]

#syntax[Custom Styling Function][
  When defining your own styling function, it has to have the following signature:
  ```typst
  let factory(title: content, tags: (content), body: content, supplement: string or content, number, args) = …
  ```
  The content it returns will be placed into the document without modifications.
]

#syntax[Styling Dividers][
  If your custom styling function shall support dividers, it must include a show rule in its body:
  ```typst
  show: styling.dividers-as(object-which-will-be-used-as-divider)
  ```
]

For more information on how to define your own styling function, please look into the `styling` module.

= Edge Cases

Here are a few edge cases.

#example[Test][Long content example without space for additional elements][
  #lorem(20)
]

#example[Example][Tags of various sizes][$sum_sum^sum$][Extra vertical space: #v(1cm)][
  #lorem(20)
]

#example[][
  #example[][
    #example(style: styles.hint)[][
      When nested, counters increment from outer to inner elements.
    ]
  ]
]

#example[][
  Counters continue incrementing sequentially in non-nested elements.
]

