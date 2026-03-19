# More ways to cite, and with shorter syntax

This tiny Typst package gives a shorter way to cite bibliography entries in various forms. It also provides some forms Typst doesn't currently support. It is based on [Ntlgrr](https://github.com/Ntgllr)'s [gist](https://gist.github.com/Ntgllr/a194eb327e4db6c480c84de9be106125).

## How to use it

First, apply the show rule: `#show cite: citesugar`.

The syntax is `@label[form:supplement]`. The list of supported forms is as follows (shown in Chicago author-date):

```typst
  @frege      // (Frege 1982)
  @frege[p:]  // Frege (1982)
  @frege[a:]  // Frege
  @frege[y:]  // 1982
  @frege[b:]  // Frege 1982
  @frege[ps:] // Frege's (1982)
  @frege[as:] // Frege's
```

The supplement can be added after the semicolon:

```typst
  @frege[p. 20]   // (Frege 1982, p. 20)
  @frege[p:p. 20] // Frege (1982, p. 20)
```

Note that Typst ignores the supplement in author and year forms. This is kept as-is.

## Additional forms

Shown above are several custom forms of citation.

- bare: like normal, but without the brackets.
- prose genitive: like prose, but with _'s_ after the author. Automatically detects final _s_ to remove the _s_ after the apostrophe.
- author genitive: like prose genitive, but for author.

In addition to the special syntax, you can use them directly by importing `cite-bare`, `cite-prose-genitive`, and `cite-author-genitive`.

**A word of caution.** This is a small package that aims to be universal enough but does not guarantee everything will work with all the 10000000 citation styles and languages. If you have an idea on how to make it work better or have other useful forms in mind, please contribute!

## Adding your own forms

You can add your own forms or override the provided ones by passing a dictionary to `citesugar` like this:

```typst
  #show cite: citesugar.with(
    forms: (
      x: (key, suppl) => some-custom-thing(key, suppl),
      b: (key, suppl) => cite(key, form: "normal" supplement: suppl) // Override `b`s to be normal citations
    )
  )
```

For reference, default forms are given below.

```typst
#(
  "p": (key, suppl) => cite(key, form: "prose", supplement: suppl),
  "a": (key, suppl) => cite(key, form: "author", supplement: suppl),
  "y": (key, suppl) => cite(key, form: "year", supplement: suppl),
  "b": (key, suppl) => cite-bare(key, supplement: suppl),
  "ps": (key, suppl) => cite-prose-genitive(key, supplement: suppl),
  "as": (key, suppl) => cite-author-genitive(key, supplement: suppl),
)
```

with the functions being

```typst
  #let cite-bare(key, supplement: none, style: auto) = {
    show regex("[\(\)\[\]]"): none
    cite(key, supplement: supplement, style: style)
  }

  #let cite-author-genitive(key, supplement: none, style: auto) = {
    show regex(".+$"): it => it + "'"
    show regex("[^s]'$"): it => it + "s"
    cite(key, form: "author", supplement: supplement)
  }

  #let cite-prose-genitive(key, supplement: none, style: auto) = {
    show regex(".\s[\[\(]"): it => {
      show regex("[^\s\[\(]"): it => it + "'"
      show regex("[^s]'"): it => it + "s"
      it
    }
    cite(key, form: "prose", supplement: supplement)
  }
```
