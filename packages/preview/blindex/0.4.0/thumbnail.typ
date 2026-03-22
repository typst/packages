#import "@preview/blindex:0.4.0": *
//#import "blindex.typ": *

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
#set page(
  paper: "a5",
  fill: color.mix((silver, 90%), (yellow, 10%)),
  footer: context [
    #set align(center)
    #set text(9pt)
    #counter(page).display("— 1 —")],
  margin: 20mm,
)
#set par(justify: true)
#set text(font: "Crimson Pro", size: 11pt, lang: "en")
#show raw: set text(font: "Inconsolata", size: 1em, stretch: 90%)

// Document
= Description

Blindex is a Typst package specifically designed for the generation of indices of Biblical literature citations in documents.

= Plain usage

The index can be generated anywhere in the text by calling the function

```typst
#mk-index()
```

Indices can be manually placed in the text with the `blindex` function; however, indexed biblical literature quotations are facilitated through _inline_ and _block_ quoting functions, which have the same mandatory (positional) arguments:

```typst
#ind-inl(body, book-abbrev, passage) // for indexed inline quotes
#ind-blk(body, book-abbrev, passage) // for indexed block (displayed) quotes
```

The ```typst #ind-inl([The #smallcaps[Lord] is my...], "PSA", [23:1])``` function call renders as #ind-inl([The #smallcaps[Lord] is my shepherd; I shall not want.], "PSA", [23:1]) (book chapter:verse included), while the ```typst #ind-blk([And there...], "1MA", [1:10])``` output renders as #ind-blk([And there came out of them a wicked root Antiochus surnamed Epiphanes, son of Antiochus the king, [...] and he reigned in the hundred and thirty and seventh year of the kingdom of the Greeks.], "1MA", [1:10])

== Biblical Literature Abbreviations

The `book-abbrev` argument is an abbreviation used to uniquely define the biblical literature source.  In the first example, `"PSA"` resolved to the book of Psalms. Abbreviations vary with language and tradition, specified by the optional `language-tradition` parameter, whose default value is `"en-USX"`, which stands for the English-USX#footnote[USX is the Unified Scripture XML] language-tradition pair. The function `get-book-abbrevs(language-tradition)` returns an array of correspondingly valid `book-abbrev` values. For `"en-USX"`, one has:

#{
  set par(justify: false)
  set text(font: "Atkinson Hyperlegible Mono", size: 6pt)
  get-book-abbrevs("en-USX").join(", ")
}

= Common Options

In order to include a version reference along with the quote, simply pass the optional `version:` named argument to the quoting functions, while proper bibliography citation is facilitated by the optional `cite-label` argument, as in #ind-inl([For thus saith the #smallcaps[Lord] of hosts; Yet once, it is a little while, and I will shake the heavens, and the earth, and the sea, and the dry _land_;], "HAG", [2:6], version: [KJV], cite-label: <KJV>).

In order to offer _maximum customization options_, the library contents-producing functions take dictionary args that are simply passed to native Typst functions, such as `text()`, `block()`, etc. (check the API for details). Therefore, polyglot quotes can render as #ind-inl([Au commencement, Dieu créa les cieux et la terre.], "GEN", [1:1], cite-label: <LSG>, quo-text-pars: (lang: "fr")). By default, `blindex` uses Typst `smartquotes`, which causes the quotes to adapt to the passed `quo-text-pars: (lang: "fr")` argument of this paragraph's example.

Rendering of verse numbers is facilitated by the `ver` function, as in #ind-blk([#ver[1]Adam, Sheth, Enosh, #ver[2]Kenan, Mahalaleel, Jered, #ver[3]Henoch, Methuselah, Lamech, #ver[4]Noah, Shem, Ham, and Japheth.], "1CH", [1:1--4])

= Customizing

Document-wise customizations are best achieved by redefining the functions using the `with` method in the document, i.e., outside the template. Customized functions can be generated (or overwritten if given the same original names) as:

```typst
#let ii = ind-inl.with(
  oquot: [], cquot: [], quo-highlight-pars: (fill: none),
  quo-text-pars: (font: "Noto Sans", size: 0.8em, style: "italic", fill: olive),)
```
#let ii = ind-inl.with(
  oquot: [], cquot: [], quo-highlight-pars: (fill: none),
  quo-text-pars: (font: "Noto Sans", size: 0.8em, style: "italic", fill: olive),)

Then, the customized `ii` function produces #ii([And saying, Repent ye: for the kingdom of heaven is at hand.], "MAT", [3:2], version: [KJV]).  Moreover, with the following definition:

```typst
#let ib = ind-blk.with(
  quo-highlight-pars: (fill: none),
  quo-block-pars: (width: 80%, inset: 4pt, fill: silver),
  ref-block-pars: (width: 80%, inset: 4pt, fill: silver),)
```
#let ib = ind-blk.with(
  quo-highlight-pars: (fill: none),
  quo-block-pars: (width: 80%, inset: 4pt, fill: silver),
  ref-block-pars: (width: 80%, inset: 4pt, fill: silver),)

the customized `ib` function renders as

#ib([Behold, I come quickly: blessed is he that keepeth the sayings of the prophecy of this book.], "REV", [22:7])

#bibliography(bytes(bib.text), title: "References", style: "turabian-fullnote-8")

= Biblical Citations

Simply call the `mk-index` function in the location you want the index to be generated, as in:

```typst
#mk-index(language-tradition: "fr-TOB", sorting-tradition: "Oecumenic-Bible", cols: 3)
```

to generate an index with book names according to the #text(lang: "fr")[_Traduccion Œcuménique de la Bible_] French-based language-tradition, which renders as

#mk-index(language-tradition: "fr-TOB", sorting-tradition: "Oecumenic-Bible", cols: 3)

