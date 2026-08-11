#import "@preview/blindex:0.3.0": *

// Minimum bibliography data
#let bib = ```
LSG:
  type: book
  title: Louis Segond
KJV:
  type: book
  title: King James Version
```

// Document settings
#set page(paper: "a5", fill: color.mix((silver, 90%), (yellow, 10%)), footer: context [
    #set align(center)
    #set text(9pt)
    #counter(page).display("— 1 —")])
#set par(justify: true)
#show raw: set text(font: "Inconsolata", size: 1em, stretch: 90%)

// Document
= Description

Blindex is a Typst package specifically designed for the generation of indices of Biblical
literature citations in documents.

= Plain usage

The index can be generated anywhere in the text by calling the function

```typst
#mk-index()
```

Indices can be manually placed in the text with the `blindex` function; however, indexed
biblical literature quotations are facilitated through _inline_ and _block_ quoting functions,
which have the same mandatory (positional) arguments:

```typst
#iq(body, abrv, lang, pssg) // for indexed inline quotes
#bq(body, abrv, lang, pssg) // for indexed block (displayed) quotes
```

The
```typst #iq([…], "Psa", "en-3", [23:1])```
function call renders as #iq([The LORD is my shepherd; I shall not want.], "Psa",
"en-3", [23:1]) (book chapter:verse included), while the
```typst #iq([…], "1Ma", "en-3", [1:10])```
output renders as #bq([And there came out of them a wicked root Antiochus surnamed Epiphanes,
son of Antiochus the king, who had been an hostage at Rome, and he reigned in the hundred and
thirty and seventh year of the kingdom of the Greeks.], "1Ma", "en-3", [1:10])

= Common Options

In order to include the source version along with the quote, simply pass the optional `version:`
named argument to the quoting functions, while proper bibliography citation is facilitated by
the optional `cite` argument, as in #iq([For thus saith the #smallcaps[Lord] of hosts; Yet once,
it is a little while, and I will shake the heavens, and the earth, and the sea, and the dry
_land_;], "Hag", "en-3", [2:6], version: [KJV], cite: [@KJV]).

Source quote language is facilitated by the optional `qlang` argument, as in #iq([Au
acommencement, Dieu créa les cieux et la terre.], "Gen", "en-3", [1:1], cite: [@LSG], qlang:
"fr"). By default, `blindex` uses Typst `smartquotes`, which causes the quotes to adapt to the
passed `qlang: "fr"` argument.

Moreover, rendering of verse numbers in block quotes is facilitated by the `#ver()` function, as
in #bq([#ver(1)Adam, Sheth, Enosh, #ver(2)Kenan, Mahalaleel, Jered, #ver(3)Henoch, Methuselah,
Lamech, #ver(4)Noah, Shem, Ham, and Japheth.], "1Ch", "en-3", [1:1--4])

= Customizing

Document-wise customizations are best achieved by redefining the functions using the `with`
method in the document, i.e., outside the template. Customized functions can be generated (or
overwritten if given the same original names) as:

```typst
#let IQ = iq.with(
  quo: (bkg: none, opq: [], clq: [],
        fmt: (font: "Noto Sans", size: 0.8em, style: "italic", fill: olive)))
```
#let IQ = iq.with(
  quo: (bkg: none, opq: [], clq: [],
        fmt: (font: "Noto Sans", size: 0.8em, style: "italic", fill: olive)))

Then, the customized `IQ` function produces #IQ([And saying, Repent ye: for the kingdom of
heaven is at hand.], "Mat", "en-3", [3:2], version: [KJV]).  Moreover, with the following
definition:

```typst
#let BQ = bq.with(
  blk: (wid: 80%, ins: 4pt, bkg: rgb("aaaaaa40"), cit: rgb("aaaaaa40")))
```
#let BQ = bq.with(
  blk: (wid: 80%, ins: 4pt, bkg: rgb("aaaaaa40"), cit: rgb("aaaaaa40")))

the customized `BQ` function renders as

#BQ([Behold, I come quickly: blessed is he that keepeth the sayings of the prophecy of this
book.], "Rev", "en-3", [22:7])

#bibliography(bytes(bib.text), title: "References", style: "turabian-fullnote-8")

= Biblical Citations

Once all the biblical literature indexing have been made, either manually or aided by the
quoting functions, simply call the `mk-index` function, as in:

```typst
#block(width: 100%, height: 4cm)[
  #mk-index(lang: "en-3", cols: 2, sorting-tradition: "Oecumenic-Bible")
]
```

where the `block` is added as Typst doesn't yet provide automatic multicolumn balancing, which
renders as

#block(width: 100%, height: 4cm)[
  #mk-index(lang: "en-3", cols: 2, sorting-tradition: "Oecumenic-Bible")
]

