#import "@preview/ultraw:0.0.1": raw-themes, style, uraw
#import "utils.typ": *

#show: format-doc

#source(
  indent-size: 2,
  width: 100%,
  ````typ
  #uraw(
    code: (theme: raw-themes.github-light, fill: style.zebra(even: luma(240))),
    numbers: (format: "1:", start: 3, color: style.focus(6, 8, 10)),
    header: (content: [Greetings in Python!], fill: luma(240), code-aligned: true, sep: none),
    footer: raw(">>> greeting(\"Typster\", polite=True)\nHello to you, Typster"),
    frame-stroke: gray,
    lang-tag: (name: "Python", placement: "header", fill: blue.transparentize(80%)),
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
  )

  ````,
)

#place(bottom + right, uraw(
  code: (theme: raw-themes.github-light, fill: style.zebra(even: luma(240))),
  numbers: (format: "1:", start: 3, color: style.focus(6, 8, 10)),
  header: (
    content: [Greetings in Python!],
    fill: luma(240),
    code-aligned: true,
    sep: none,
  ),
  footer: raw(
    ">>> greeting(\"Typster\", polite=True)\nHello to you, Typster",
  ),
  frame-stroke: gray,
  lang-tag: (
    name: "Python",
    placement: "header",
    fill: blue.transparentize(80%),
  ),
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
))
