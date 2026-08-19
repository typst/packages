//#import "@preview/abbrev:0.1.4": *
// or locally:
#import "./lib.typ": *

= How to use
Fist, define all abbreviations:
```typst
#define-abbreviations((
  "GPU": "Graphics Processing Unit",
  "XML": "Extensible Markup Language",
  "CPU": "Central Processing Unit",
))
```

Then use them:
- Short form:
  ```typst
  #abbr("GPU")
  ```

- Full form:
  ```typst
  #abbr("GPU", form: "full")
  ```

- With a suffix:
  ```typst
  #abbr("GPU", suffix: "s")
  ```

Display the abbreviation list (default title is "List of abbreviations"):
```typst
#abbreviation-outline(
  title: [Abbreviations],
)
```

= Exemple of use
#define-abbreviations((
  "GPU": "Graphics Processing Unit",
  "XML": "Extensible Markup Language",
  "CPU": "Central Processing Unit",
))

#abbreviation-outline(
  title: [Abbreviations],
)

= Text

The first #abbr("GPU", form: "full") call can use the full form.
Later mentions can use #abbr("GPU") only.

You can also print another form, such as #abbr("XML", form: "long"), or add a suffix like #abbr("CPU", suffix: "s").

This is page #context [#counter(page).display()].

#pagebreak()

More text can keep using #abbr("XML").

This is page #context [#counter(page).display()].

#pagebreak()

More text can keep using #abbr("GPU").

This is page #context [#counter(page).display()].

#pagebreak()

More text can keep using #abbr("GPU") and #abbr("XML").

This is page #context [#counter(page).display()].
