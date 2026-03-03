# Blindex: index-making of Biblical literature citations in Typst

Blindex (`blindex:0.3.0`) is a Typst package specifically designed for the generation of indices
of Biblical literature citations in documents. Target audience includes theologians and authors
of documents that frequently cite biblical literature.

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
French             | Œcuménique (TOB)  | Ecumenical in French       | `fr-TOB`

Additional language-variations can be added to the `lang.typ` source file by the author and/or
by pull requests to the `dev` branch of the (UNFORKED!) development repository
`https://github.com/cnaak/blindex.typ`.

## Low-Level Indexing Command

The `blindex` library has a low-level index entry marking function `#blindex(abrv, lang,
entry)`, whose arguments are (abbreviation, language, entry), as in:

```typst
"the citation..." #blindex("1Thess", "en", [1.1--3])
```

Following the usual index making strategy in Typst, this use of the `#blindex` command only adds
the index-marking `#metadata` in the document, without producing any visible typeset output.

Biblical literature index listings can be generated (typeset) in arbitrary amounts and locations
throughout the document, just by calling the user `#mk-index` command:

```typst
#mk-index()
```

Optional arguments control style and sorting convention parameters, as exemplified below.

## Higher-Level Quoting-Indexing Commands

The library also offers higher-level functions to assemble the entire (i) quote typesetting,
(ii) index entry, (iii) citation typesetting, and (iv) bibliography entrying of the passage.
Styling options are relatively abundant, giving the user a working level of control over the
output formatting, as well as allows for document-wide standardization through `function`
redefinitions through `with`, according to `typst` documentation.

Higher-level quoting-indexing functions are `#iq(...)`, `#bq(...)`, respectively for **inline**
and **block** quoting of Biblical literature, with automatic indexing and bibliography citation.
There's also a helper `#ver(...)` for convenient verse number formatting, mostly aimed at being
used within block quotes.

Mandatory arguments are identical for either command:

```typst
paragraph text...
#iq(body, abrv, lang, pssg)
more text...

// Displayed block quote of Biblical literature:
#bq(body, abrv, lang, pssg)
```

In which:

- `body` (`content`) is the quoted biblical literature text;
- `abrv` (`string`) is the book abbreviation according to the
- `lang` (`string`) language-variant (see above);
- `pssg` (`content`) is the quoted text passage --- usually chapter and verses --- as they will
  appear in the text and in the biblical literature index;

Common optional (named) arguments include:

- `version` (`string` or `content`) is a translation identifier, such as `"LXX"`, or `[KJV]`; and
- `cited` (`content`) is the corresponding bibliography entry label, which can be constructed
  through: `[@KJV]`.

## Examples

The [thumbnail.typ](https://github.com/cnaak/blindex.typ/blob/release-0.3.0/thumbnail.typ)
briefly showcases likely common package workflows. It renders as

![thumbnail](https://raw.githubusercontent.com/cnaak/blindex.typ/b81e91e58e63f1b77a2540b7f21693b1cb7a9bf1/thumbnail.png)

Moreover, the `test` directory in the [development
repository](https://github.com/cnaak/blindex.typ/tree/main/test) contains a couple of
tests/examples that showcase in greater detail the package's possiblities.

## Brief Release Summary

- `0.1.0` - initial release
- `0.2.0` - improved usability and configurability
- `0.3.0` - breaking re-casing (to camel-case) of user-facing definitions

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
  version: 0.3.0
  date: 2026-02
```

