#import "@preview/shadowed:0.3.0": shadow
#import "@preview/computer-framer:1.0.0": *
#let shadow = shadow.with(fill: black.transparentize(85%), radius: 5pt, blur: 20pt, dy: 10pt)
#set page(width: auto, height: auto, margin: 30pt)


#let themes = (
  "Retro": retro-theme(),
  "Purple": purple-theme(),
  "Minimalistic": minimalistic-theme(),
  "Neutral": neutral-theme(light-theme: false),
  "Modern": modern-theme(),
  "Generic": rounded-window-theme(),
)
#let contents = [
  #block(inset: 1em, [
    ```typst
    This is a simple test
    These windows are created with:
    #desktop-window-frame(contents, title, theme)
    ```
  ])]

#grid(columns: 2, inset: 5mm, ..(
    for (title, theme) in themes {
      (shadow(desktop-window-frame(contents, title, theme)),)
    }
  ))

#pagebreak()

#let theme = minimalistic-theme()
#set text(font: "Noto Sans")
#shadow(desktop-window-frame(
  [
    #block(inset: 1em, width: 100%, [
      #set text(10pt)
      This is a more complex example, showing how additional bars can be used to make the result look nicer.

      A couple functions are included for typical assets:
      - ```typst #browser-bar()``` is used to create a browser bar.
      - ```typst #minimalistic-tabs-bar()``` is used to create some tabs.

      They can be passed as additional bars for easy use, or used freely.

      There is also a ```typst #input()``` function that creates a simple input box, used for example in the browser bar:

      #align(center, input())

    ])
  ],
  width: 10cm,
  additional-bars: (
    text(0.8em, box(inset: 2mm, browser-bar())),
    minimalistic-tabs-bar(
      ("Tab 1", "Tab 2", "Tab 3"),
      active-tab-fill: theme.content-color,
      active-tab-stroke: theme.stroke,
      tab-height: 1.25em,
      include-separators: true,
      include-close-button: true,
      include-new-tab-button: true,
    ),
  ),
  "A more complex example",
  theme,
))

#pagebreak()

#phone-frame([
  As a small extra, this phone frame is also included
])
