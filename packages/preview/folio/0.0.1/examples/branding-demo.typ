#import "@preview/folio:0.0.1": (
  badge, card, data-table, folio-init, metric, progress-bar,
)

#set page(height: auto, margin: 1cm)

= Branding Demo

#let demo-content() = {
  stack(
    dir: ttb,
    spacing: 1.5em,
    card(title: "Sample Card")[
      This is a card with some content. It should respect the brand's radius and colors.
    ],
    stack(
      dir: ltr,
      spacing: 0.5em,
      badge("Success", intent: "success"),
      badge("Warning", intent: "warning"),
      badge("Danger", intent: "danger"),
      badge("Neutral", intent: "neutral"),
    ),
    data-table(
      headers: ("Task", "Status", "Owner"),
      rows: (
        ("Design", badge("Done", intent: "success"), "Alice"),
        ("Build", badge("In Progress", intent: "warning"), "Bob"),
        ("Test", badge("Pending", intent: "neutral"), "Charlie"),
      ),
    ),
    stack(
      dir: ltr,
      spacing: 2em,
      metric("Grand Total", "$125,000", intent: "success"),
      metric("Budget Spend", "65%"),
    ),
    progress-bar(65, intent: "primary"),
  )
}

== 1. Minimal (Typst defaults)
#folio-init(brand: (preset: "minimal"))[
  #demo-content()
]

#v(4em)
#line(length: 100%, stroke: 0.5pt + luma(200))
#v(2em)

== 2. Corporate (Default)
#folio-init(brand: (preset: "corporate"))[
  #demo-content()
]

#v(4em)
#line(length: 100%, stroke: 0.5pt + luma(200))
#v(2em)

== 3. Academic (01-inspired classic)
#folio-init(brand: (preset: "academic"))[
  #demo-content()
]

#v(4em)
#line(length: 100%, stroke: 0.5pt + luma(200))
#v(2em)

== 4. Corporate + User Override (Teal)
#folio-init(brand: (preset: "corporate", palette: (primary: rgb("#0d9488"))))[
  #demo-content()
]

#v(4em)
#line(length: 100%, stroke: 0.5pt + luma(200))
#v(2em)

== 5. Academic + User Override (Deep Red)
#folio-init(brand: (preset: "academic", palette: (primary: rgb("#7a1f1f"))))[
  #demo-content()
]
