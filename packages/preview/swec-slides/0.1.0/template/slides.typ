#import "@preview/polylux:0.4.0" as pl
#import "@preview/swec-slides:0.1.0" as swec: *

#set text(lang: "en")
#show: swec-template.with(
  title: [SWEC],
  subtitle: [We beg to Differ],
  authors: (
    ("Manu Musterperson", "manu.musterperson@domain.example"),
    ("Manu Musterperson", "manu.musterperson@domain.example"),
  ),
)

#title-slide()


#slide(
  title: [Slide Title],
)[
  Some Text

  ```py
  def foo():
      pass
  ```

]
