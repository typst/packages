#import "template.typ": *

== Card visualization
This section provides a comprehensive overview of the DECKZ package's *card visualization* capabilities. It presents the available formats and how to use them effectively.
#show-module("view/format")
#show-module("view/back", show-outline: false)

#pagebreak()
== Group visualization
This section covers the *group visualization* features of the DECKZ package, i.e. all functions that allow you to visualize groups of cards, such as hands, decks, and heaps.

_(More functions and options will be added in the future)._
#show-module("view/group")

#pagebreak()
== Data
This section provides an overview of the data structures used in the DECKZ package, including suits, ranks, and cards. It explains how these data structures are organized and how to access them.
#show-module("data/suit")
#show-module("data/rank")
//#show-module("data/style")
#show-module("model/structs")

#pagebreak()
== Language-aware card symbols

DECKZ automatically adapts the rendering of card rank symbols based on the document's language. This process is seamless: users only need to set the desired language using the `text` command, and DECKZ will adjust the symbols accordingly. No additional configuration is required.

This feature is powered by the #link("https://typst.app/universe/package/linguify")[linguify] package.

Currently supported languages and their rank symbols:
- *English*: `A`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `J`, `Q`, `K`
- *Italian*: `A`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `J`, `Q`, `K`
- *French*: `A`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `V`, `D`, `R`

```side-by-side
#let seq = ("10C", "JH", "QS", "KD", "AC")

#set text(lang: "en")
#stack(dir: ltr, spacing: 5mm, ..seq.map(deckz.small))

#set text(lang: "it")
#stack(dir: ltr, spacing: 5mm, ..seq.map(deckz.small))

#set text(lang: "fr")
#stack(dir: ltr, spacing: 5mm, ..seq.map(deckz.small))
```