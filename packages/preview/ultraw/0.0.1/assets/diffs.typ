#import "../export/main.typ": *
#import "utils.typ": *

#show: format-doc

#source(width: 100%, indent-size: 2, ````typ
#set-uraw-diff(
  sep: black,
  old: (fill: orange.lighten(80%), numbers-fill: orange.lighten(40%), diff-marker: text(orange, "-")),
  new: (fill: blue.lighten(85%), numbers-fill: blue.lighten(50%), diff-marker: text(blue, "+")),
)

#uraw-diff(
  columns: (1fr, auto),
  ```py
  def greeting(name: str, polite: bool):
      if len(name) > 0 and name[0].isupper():
          if polite:
              print("Hello to you, " + name)
          else:
              print("Intense staring <•>_<•>")
      else:
          raise RuntimeError("Not a name.")
  ```,
  ```py
  def greeting(name: str, polite: bool):
      if len(name) > 0:
          if polite:
              print("Hello to you, " + name)
              print("Ready to Typst?")
          else:
              print("More intense staring (•)_(•)")
      else:
          raise RuntimeError("Not a name.")
  ```,
)
````)

#set-uraw-diff(
  sep: black,
  old: (
    fill: orange.lighten(80%),
    numbers-fill: orange.lighten(40%),
    diff-marker: text(orange, "-"),
  ),
  new: (
    fill: blue.lighten(85%),
    numbers-fill: blue.lighten(50%),
    diff-marker: text(blue, "+"),
  ),
)

#uraw-diff(
  columns: (1fr, auto),
  ```py
  def greeting(name: str, polite: bool):
      if len(name) > 0 and name[0].isupper():
          if polite:
              print("Hello to you, " + name)
          else:
              print("Intense staring <•>_<•>")
      else:
          raise RuntimeError("Not a name.")
  ```,
  ```py
  def greeting(name: str, polite: bool):
      if len(name) > 0:
          if polite:
              print("Hello to you, " + name)
              print("Ready to Typst?")
          else:
              print("More intense staring (•)_(•)")
      else:
          raise RuntimeError("Not a name.")
  ```,
)
