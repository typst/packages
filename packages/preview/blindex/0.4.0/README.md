# Blindex: index-making of Biblical literature citations in Typst

Blindex (`blindex:0.4.0`) is an index-generating Typst package taylored to some specific needs
of biblical literature (i) quoting, (ii) referencing, and (iii) indexing. Target audience
includes authors of any area of knowledge that make frequent use of biblical literature
citations in their work, including theologians, historians, philosophers, and classic linguists
alike.

Blindex user-facing functions are highly-customizable. Check the [API documentation](https://github.com/cnaak/blindex.typ/blob/release-0.4.0/api.pdf) for details.

## Index Sorting Options

The generated indices are gathered and sorted by Biblical literature books, which can be ordered
according to various Biblical literature book ordering conventions, including:

- `"code"` -- All registered Biblical literature books.
- `"USX"` -- Unified Scripture XML: All registered Biblical literature books. Default.
- `"LXX"` -- The Septuagint;
- `"Greek-Bible"` -- Septuagint + New Testament (King James);
- `"Hebrew-Tanakh"` -- The Hebrew (Torah + Neviim + Ketuvim);
- `"Hebrew-Bible"` -- The Hebrew Tanakh + New Testament (King James);
- `"Protestant-Bible"` -- The Protestant Old + New Testaments;
- `"Catholic-Bible"` -- The Catholic Old + New Testaments;
- `"Orthodox-Bible"` -- The Orthodox Old + New Testaments;
- `"Oecumenic-Bible"` -- The Jewish Tanakh + Old Testament Deuterocanonical + New Testament;

## Biblical Literature Abbrevations

It is common practice in biblical literature referencing to refer to biblical literature books
by their _abbreviations_ rather than through standard bibliographical methods, since biblical
literature commonly gathers books within a larger book. Practice shows that abbreviation
conventions are language- and tradition- dependent. Therefore, `blindex` usage reflects this
fact, while offering a way to input arbitrary language-tradition abbreviations, by extending the
`lang/` source tree.

### Language and Traditions (Variants)

The `blindex` implementation generalizes the concept of __tradition__ (in the context of
biblical literature book abbreviation bookkeeping) as language **variants**, since the software
can have things such as a "default" of "n-char" variants.

As of the current release, supported languages include the following few ones:

Language           | Variant           | Description                | Name
---                | ---               | ---                        | ---
English            | USX               | USX abbreviations          | `en-USX`
English            | 3-char            | A 3-char abbreviations     | `en-3`
English            | Logos             | Used in `logos.com`        | `en-logos`
Portuguese (BR)    | Protestant        | Protestant for Brazil      | `br-pro`
Portuguese (BR)    | Catholic          | Catholic for Brazil        | `br-cat`
French             | Œcuménique (TOB)  | Ecumenical in French       | `fr-TOB`

Additional language-variations can be added to the `lang/` source tree by the author and/or by
pull requests to the `dev` branch of the development repository
`https://github.com/cnaak/blindex.typ`, i.e., not the Typst packages one.

## Low-Level Indexing Command

The `blindex` library has a low-level index entry marking function `#blindex(abrv, lang,
entry)`, whose arguments are (abbreviation, language, entry), as in:

```typst
"the citation..." #blindex("1Thess", "en-logos", [1.1--3])
```

Following the usual index making strategy in Typst, this use of the `#blindex` command only adds
the index-marking `#metadata` in the document, without producing any visible typeset output.

Biblical literature index listings can be generated (typeset) in arbitrary amounts and locations
throughout the document, just by calling the user `#mk-index` command:

```typst
#mk-index()
```

Optional arguments control style and sorting convention parameters, as explained in the API.

## Higher-Level Quoting-Indexing Commands

The library also offers higher-level functions to assemble the entire (i) quote typesetting,
(ii) reference typesetting, optional (iii) bibliography, and (iv) indexing entrying of the
passage.  Styling options offer maximum control over the output formatting, as well as allows
for document-wide standardization through `function` redefinitions through `with`, according to
`typst` documentation.

Higher-level quoting-referencing-indexing functions are `#ind-inl(...)`, `#ind-blk(...)`,
respectively for **inline** and **block** quoting of Biblical literature, with automatic
indexing and optional bibliography citation.  There's also a helper `#ver[...]` function for
convenient verse number formatting, mostly aimed at being used within block quotes.

Check the [API documentation](https://github.com/cnaak/blindex.typ/blob/release-0.4.0/api.pdf)
for details.

## Examples

The [thumbnail.typ](https://github.com/cnaak/blindex.typ/blob/release-0.4.0/thumbnail.typ)
briefly showcases likely common package workflows. It renders as

![thumbnail](https://raw.githubusercontent.com/cnaak/blindex.typ/refs/heads/release-0.4.0/thumbnail.png)

## Brief Release Summary

- `0.1.0` - initial release
- `0.2.0` - improved usability and configurability
- `0.3.0` - breaking re-casing (to camel-case) of user-facing definitions
- `0.4.0` - Full API refactoring and documentation

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
  version: 0.4.0
  date: 2026-03
```

