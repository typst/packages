#import "../setup/macros.typ": *
= Scripting

Generally, the #link("https://typst.app/docs/")[docs] are really great.
For scripting specifically, see https://typst.app/docs/reference/scripting/

There is also a #link("https://typst.app/docs/guides/table-guide/")[table guide] as they are really extendible.

== Loading Data

Typst can also read files and put them in the document.
It even includes parsers for a few data-file formats, including CSV, JSON, TOML and YAML#footnote[https://typst.app/docs/reference/data-loading/].

If you are not limited by the amount of files in your project, you can use this to load your data-findings directly into a table or figure.

#figure(
  ```typ
  #let results = csv("example.csv")

  #table(
    columns: 2,
    [*Condition*], [*Result*],
    ..results.flatten(),
  )
  ```,
  caption: [Loading arbitrary data into a table.],
)

The glossary package also supports this type of loading, if you would like to manage your glossary in an external file.
#todo[Oh yeah and a single backslash is a shorthand for the ```typ #linebreak()``` function (but it does not indent).] \
```typ #show: init-glossary.with(yaml("glossary.yaml"))```
