# <img src="./assets/logo.svg" alt="The logo of Babel: an icon of the Tower of Babel in a turquoise square" width="48px" /> <span style="font-variant: small-caps; color: #239dad">Babel</span>: Redact text by replacing it with random characters in Typst

<a href="https://typst.app/universe/package/babel"><img alt="Package on the Typst Universe" src="https://img.shields.io/badge/Typst_Universe-fdfdfd?logo=typst" /></a>
<a href="https://codeberg.org/afiaith/babel"><img alt="Babel’s Git repository" src="https://img.shields.io/badge/Git_repo-fdfdfd?logo=codeberg" /></a>
<a href="https://codeberg.org/afiaith/babel/releases/download/0.1.0/manual.pdf"><img alt="manual.pdf" src="https://img.shields.io/badge/%F0%9F%93%96%20manual-.pdf-239dad?labelColor=fdfdfd" /></a>
<a href="./LICENSE"><img alt="Licence: CC0" src="https://img.shields.io/badge/licence-CC0-239dad?labelColor=fdfdfd" /></a>
<a href="https://codeberg.org/afiaith/babel/releases/tag/0.1.0/"><img alt="Codeberg release" src="https://img.shields.io/gitea/v/release/afiaith/babel?gitea_url=https%3A%2F%2Fcodeberg.org&labelColor=fdfdfd&color=239dad" /></a>
<a href="https://codeberg.org/afiaith/babel/stars"><img alt="Codeberg stars" src="https://img.shields.io/gitea/stars/afiaith/babel?gitea_url=https%3A%2F%2Fcodeberg.org&labelColor=fdfdfd&color=fdfdfd&logo=codeberg" /></a>

This package provides functions that replace actual text with random characters, which is useful for redacting confidential information or sharing the design and structure of an existing document without disclosing the content itself.
A variety of ready-made sets of characters for replacement are available (75 in total; termed *alphabets*), representing diverse writing systems, codes, notations and symbols.
Some of these are more conservative (such as emulating redaction using a wide black pen) and many are more whimsical, as demonstrated by the following example:

```typ
#baffle(alphabet: "welsh")[Hello]. My #tippex[name] is #baffle(alphabet: "underscore")[Inigo Montoya]. You #baffle(alphabet: "alchemy")[killed] my #baffle(alphabet: "shavian")[father]. Prepare to #redact[die].

Using show rules strings, regular expressions and other selectors can be redacted automatically:

#show "jan Maja": baffle.with(alphabet: "sitelen-pona")
#show regex("[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*"): baffle.with(alphabet: "maze-3") 

I’m jan Maja, and my email is `foo@digitalwords.net`.
```

<img src="./assets/example.webp" alt="The output of the above Typst code" style="max-width: 100%" />

## 📖 The manual

Using <span style="font-variant: small-caps; color: #239dad">Babel</span> is quite straightforward.
[**A comprehensive manual**](https://codeberg.org/afiaith/babel/releases/download/0.1.0/manual.pdf) covers:

- Introductory background.
- How to use the provided functions (`baffle()`, `redact()` and `tippex()`).
- A list of the provided alphabets, each demonstrated by a line of random text.

## 🗼 The Tower of <span style="font-variant: small-caps; color: #239dad">Babel</span>

A poster demonstrating the provided alphabets:

<a href="./assets/poster.webp"><img src="./assets/poster.webp" alt="A demonstration of the provided alphabets in the shape of the Tower of Babel" style="max-width: 100%; border-radius: 3em" /></a>

## 🔨 Complementary tools

If you wish to share the Typst source files of your document, not just the precompiled output, a tool called [_Typst Mutilate_](https://github.com/frozolotl/typst-mutilate) might be useful for you.
Unlike <span style="font-variant: small-caps; color: #239dad">Babel</span>, it is not a Typst package but an external tool, written in Rust.
It replaces the content of a Typst document with random words selected from a wordlist or random characters (similarly to <span style="font-variant: small-caps; color: #239dad">Babel</span>), changing the document in place (so make sure to run it on a *copy*!).
As a package for Typst, <span style="font-variant: small-caps; color: #239dad">Babel</span> cannot change your source files.
