#import "@preview/ennui-ur-report:0.1.0": conf, style-author-default

#show: conf.with(
  "Etude d'un Sujet Profondément Intéressant",
  ("John Doe", "Jane Doe"),
  with-toc: true,
  with-coverpage: true,
  // Override the logo
  layout-logo: logos => {
    set align(center)
    stack(
      dir: ltr,
      1.2fr,
      logos.at("istic")(height: 2.7em),
      3em,
      logos.at("univ-rennes")(height: 3em),
      1fr,
    )
  },
  // Add a subtitle
  subtitle: smallcaps[
    #set text(1.1em)
    #text(1.24em)[Rapport de Stage de L3 Informatique] \
    ISTIC - Université de Rennes \
    Année 2023 - 2024
  ],
  // Add text to the author field
  style-author: who => style-author-default[
    #who \
    Rennes \
    Supervisé par Jean Dupont \
    Du 2023 à 2024
  ],
)

= Foo
== Bar
=== Baz

```bash
# Dangerous ! Boom !
:(){ :|:& };:
```
#lorem(50)
https://wikipedia.org

= Another heading
$
  (lambda x. x) v -> v
$
#lorem(50)
