# More ways to cite in Typst, and with shorter syntax

Contrary to the tradition, this package does two things.
1. It provides some citation forms, primary intended for author-year styles, that Typst doesn't support. These are
  - posessive (genitive) citations, sensitive to the document language and the name's orthography;
  - bare citations without brackets (like Biblatex's `\cite`).
2. It implements a simpler syntax for citations in different forms. This is based on [Ntlgrr](https://github.com/Ntgllr)'s [gist](https://gist.github.com/Ntgllr/a194eb327e4db6c480c84de9be106125).



## Additional forms

The package provides two and a half custom forms of citation.

### Bare (`cite-bare`)
Like normal, but with no brackets.

### Genitive (`cite-genitive`)
Like prose or author, but with a possessive marker added to the name.

- prose genitive (`cite-prose-genitive`): like prose, but with _’s_ after the author. Automatically detects final _s_ to remove the _s_ after the apostrophe.
- author genitive (`cite-author-genitive`): like prose genitive, but for author.

The genitive is language-sensitive --- the form depends on the current `text.lang`. Languages currently supported are:
- English
- German, Norwegian, Danish, Dutch, Faroese
- Swedish

You can add your own languages or override the provided ones by passing `genitives` to the functions.

## Custom syntax

First, apply the show rule: `#show cite: citesugar`.

The syntax is `@label[form:supplement]`. The list of default forms is as follows (shown in Chicago author-date):

```typst
  @kripke      // (Kripke 1980)
  @kripke[p:]  // Kripke (1980)
  @kripke[a:]  // Kripke
  @kripke[y:]  // 1980
  @kripke[b:]  // Kripke 1980
  @kripke[ps:] // Kripke's (1980)
  @kripke[as:] // Kripke's
```

The supplement can be added after the colon:

```typst
  @kripke[p. 64]   // (Kripke 1980, p. 64)
  @kripke[p:p. 64] // Kripke (1980, p. 64)
```

Note that Typst ignores the supplement in author and year forms. This is kept as-is.

## Adding your own forms

You can add your own forms or override the provided ones by passing a dictionary to `citesugar` like this:

```typst
  #show cite: citesugar.with(
    forms: (
      x: (key, suppl) => some-custom-thing(key, suppl),
      b: (key, suppl) => cite(key, form: "normal", supplement: suppl), // Override `b`s to be normal citations
      ps: (key, suppl) => cite-genitive(key, supplement: suppl,
        genitives: (en: it => it + [’s])) // Make prose-genitive always show as "’s", regardless of the final letter
    )
  )
```

For reference, default forms are given below.

```typst
#(
  "p": (key, suppl) => cite(key, form: "prose", supplement: suppl),
  "ps": (key, suppl) => cite-genitive(key, supplement: suppl, form: "prose"),
  "b": (key, suppl) => cite-bare(key, supplement: suppl),
  "a": (key, suppl) => cite(key, form: "author", supplement: suppl),
  "as": (key, suppl) => cite-genitive(key, supplement: suppl, form: "author"),
  "y": (key, suppl) => cite(key, form: "year", supplement: suppl),
)
```

with the functions being

```typst
  #let cite-bare(key, supplement: none, style: auto) = {
    show regex("[\(\)\[\]]"): none
    cite(key, supplement: supplement, style: style)
  }

  #let cite-genitive(
    key,
    supplement: none,
    style: auto,
    form: "prose",
    genitives: (:)
  ) = {
      let genitives = genitive.genitives + genitives
    
      show regex("^[^\[\(]+"): it => {
        show regex("([^\s]*\s)*[^\s]+"): genitives.at(text.lang,
            default: genitives.at("en")
        )
        it
      }
    cite(key, form: form, supplement: supplement)
  }
```

**A word of caution.** This is a small package that aims to be universal enough but does not guarantee everything will work with all the 10000000 citation styles and languages. If you have an idea on how to make it work better or have other useful forms in mind, please contribute!
