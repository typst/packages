# Blindex: Index-making of Biblical literature citations in Typst

Blindex (`blindex:0.1.0`) is a Typst package specifically designed for the generation of
indices of Biblical literature citations in documents. Target audience includes theologians and
authors of documents that frequently cite biblical literature.

## Index Sorting Options

The generated indices are gathered and sorted by Biblical literature books, which can be ordered
according to various Biblical literature book ordering conventions, including:

- `"LXX"` -- The Septuagint;
- `"Greek-Bible"` -- Septuagint + New Testament (King James);
- `"Hebrew-Tanakh"` -- The Hebrew (Torah + Neviim + Ketuvim);
- `"Hebrew-Bible"` -- The Hebrew Tanakh + New Testament (King James);
- `"Protestant-Bible"` -- The Protestant Old + New Testaments;
- `"Catholic-Bible"` -- The Catholic Old + New Testaments;
- `"Orthodox-Bible"` -- The Orthodox Old + New Testaments;
- `"Oecumenic-Bible"` -- The Jewish Tanakh + Old Testament Deuterocanonical + New Testament;
- `"code"` -- All registered Biblical literature books: All Protestant + All Apocripha.

## Biblical Literature Abbrevations

It is common practice among theologians to refer to biblical literature books by their
abbreviations. Practice shows that abbreviation conventions are language- and tradition-
dependent. Therefore, `blindex` usage reflects this fact, while offering a way to input
arbitrary language-tradition abbreviations, in the `lang.typ` source file.

### Language and Traditions (Variants)

The `blindex` implementation generalizes the concept of __tradition__ (in the context of
biblical literature book abbreviation bookkeeping) as language **variants**, since the software
can have things such as a "default" of "n-char" variants.

As of the current release, supported languages include the following few ones:

Language           | Variant           | Description                | Name
---                | ---               | ---                        | ---
English            | 3-char            | A 3-char abbreviations     | `en-3`
English            | Logos             | Used in `logos.com`        | `en-logos`
Portuguese (BR)    | Protestant        | Protestant for Brazil      | `br-pro`
Portuguese (BR)    | Catholic          | Catholic for Brazil        | `br-cat`

Additional language-variations can be added to the `lang.typ` source file by the author and/or
by pull requests to the `dev` branch of the (UNFORKED!) development repository
`https://github.com/cnaak/blindex.typ`.

## Low-Level Indexing Command

The `blindex` library has a low-level, index entry marking function `#blindex(abrv, lang,
entry)`, whose arguments are (abbreviation, language, entry), as in:

```typst
"the citation..." #blindex("1Thess", "en", [1.1--3]) citation's typesetting...
```

Following the usual index making strategy in Typst, this user `#blindex` command only adds the
index-marking `#metadata` in the document, without producing any visible typeset output.

Biblical literature index listings can be generated (typeset) in arbitrary amounts and locations
throughout the document, just by calling the user `#mkIndex` command:

```typst
#mkIndex()
```

Optional arguments control style and sorting convention parameters, as exemplified below.

## Higher-Level Quoting-Indexing Commands

The library also offers higher-level functions to assemble the entire (i) citation typesetting,
(ii) index entry, (iii) citation typesetting, and (iv) bibliography entrying (with some
typesetting (styling) options), of the passage.  Such commands are `#iQuot(...)` and
`#bQuot(...)`, respectively for **inline** and **block** quoting of Biblical literature, with
automatic indexing and bibliography citation. Mandatory arguments are identical for either
command:

```typst
paragraph text...
#iQuot(body, abrv, lang, pssg, version, cited)
more text...

// Displayed block quote of Biblical literature:
#bQuot(body, abrv, lang, pssg, version, cited)
```

In which:

- `body` (`content`) is the quoted biblical literature text;
- `abrv` (`string`) is the book abbreviation according to the
- `lang` (`string`) language-variant (see above);
- `pssg` (`content`) is the quoted text passage --- usually chapter and verses --- as they will
  appear in the text and in the biblical literature index;
- `version` (`string`) is a translation identifier, such as `"LXX"`, or `"KJV"`; and
- `cited` (`label`) is the corresponding bibliography entry label, which can be constructed
  through:

`label("bib-key")`, where `bib-key` is the bibliographic entry key, in the bibliography database
--- whether `bibTeX` or `Hayagriva`.

## Higher-Level Example

```typst
#set page(paper: "a7", fill: rgb("#eec"))
#import "@preview/blindex:0.1.0": *

The Septuagint (LXX) starts with #iQuot([ΕΝ ἀρχῇ ἐποίησεν ὁ Θεὸς τὸν οὐρανὸν καὶ τὴν γῆν.],
"Gen", "en", [1.1], "LXX", label("2012-LXX-SBB")).

#pagebreak()

Moreover, the book of Odes begins with: #iQuot([ᾠδὴ Μωυσέως ἐν τῇ ἐξόδῳ], "Ode", "en", [1.0],
"LXX", label("2012-LXX-SBB")).

#pagebreak()

= Biblical Citations
Books are sorted following the LXX ordering.

#mkIndex(cols: 1, sorting-tradition: "LXX")

#pagebreak()

#bibliography("test-01-readme.yml", title: "References", style: "ieee")
```

The listing of the bibliography file, `test-01-readme.yml`, as shown in the example, is:

```yml
2012-LXX-SBB:
  type: book
  title:
    value: "Septuaginta: Edição Acadêmica Capa dura – Edição de luxo"
    sentence-case: "Septuaginta: edição acadêmica capa dura – edição de luxo"
    short: Septuaginta
  publisher: Sociedade Bíblica do Brasil, SBB
  editor: Rahlfs, Alfred
  affiliated:
    - role: collaborator
      names: [ "Hanhart, Robert", ]
  pages: 2240
  date: 2012-01-11
  edition: 1
  ISBN: 978-3438052278
  language: el
```

This example results in a 4-page document like this one:

![Compiled Higher-Level
Example](https://github.com/cnaak/blindex.typ/blob/55d275e4fdab1f47c13e1fe01cbb2b397de5e0fb/thumbnail.png)

## Citing

This package can be cited with the following bibliography database entry:

```yml
blindex-package:
  type: Web
  author: Naaktgeboren, C.
  title:
    value: "Blindex: Index-making of Biblical literature citations in Typst"
    short: "Blindex: Index-making in Typst"
  url: https://github.com/cnaak/blindex.typ
  version: 0.1.0
  date: 2024-08
```

