#import "@preview/xwysyy:0.3.0": *

#show: xwysyy-pre.with(
  theme: "sky",
  config-info(
    title: [xwysyy Starter Deck],
    subtitle: [Academic slides in Typst],
    author: " ",
    date: datetime.today(),
    institution: " ",
  ),
)

#title-slide()

#outline-slide()

= Motivation

== One Minute Setup

Use `typst init @preview/xwysyy:0.3.0` to create this deck, then edit `main.typ`.

#textbox(
  [*Reusable components*

  `textbox`, #red[red highlights], #yellow[yellow highlights], tables, code blocks, and touying animations share one theme.],

  [*Theme control*

  Switch built-in themes with `theme: "sunset"` or pass a custom color dictionary directly.],
)

#end-slide(
  title: [Thank You!],
  body: [Questions?],
)
