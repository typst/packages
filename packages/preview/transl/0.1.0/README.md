# Translator

<center>

  Easy and simple translations for words and expressions, with support for localization  

  [![Tests](https://github.com/mayconfmelo/transl/actions/workflows/tests.yml/badge.svg)](https://github.com/mayconfmelo/transl/actions/workflows/tests.yml)
  [![Build](https://github.com/mayconfmelo/transl/actions/workflows/build.yml/badge.svg)](https://github.com/mayconfmelo/transl/actions/workflows/build.yml)

</center>


## Quick Start

```typ
#import "@preview/transl:0.1.0": transl
#transl(data: yaml("lang.yaml"))

#set text(lang: "es")
// Get "I love you" in Spanish:
#transl("I love you")

#set text(lang: "it")
// Translate every "love" to Italian:
#show: doc => transl("love", doc)
```


## Description

Get comprehensive and contextual translations, with support for regular
expressions and [Fluent](https://projectfluent.org/) localization. This package
have one main command, `#transl`, that receives one or more expression strings,
searches for each of them in its database and then returns the translation for
each one.

The expressions are the text to be translated, they can be simple words or longer
text excerpts, or can be also used as identifiers to obtain longer text blocks at
once. Regular expression patterns are supported when _transl_ is used in `#show`
rules.


## More Information

- [Official manual](https://raw.githubusercontent.com/mayconfmelo/transl/refs/tags/0.1.0/docs/manual.pdf)
- [Example PDF result](https://raw.githubusercontent.com/mayconfmelo/transl/refs/tags/0.1.0/docs/example.pdf)
- [Example Typst code](https://github.com/mayconfmelo/transl/blob/0.1.0/docs/example/main.typ)
- [Changelog](https://github.com/mayconfmelo/transl/blob/main/docs/changelog.md)
- [Development setup](https://github.com/mayconfmelo/transl/blob/main/docs/setup.md)


## Feature List

- Translate to custom language
- Translate to current `#text.lang`
- Translation of words and expressions
- Fluent support
- Simple `dictionary`-based translation database(YAML)
- Translation through `#show` rule
- Search for regular expression patterns
- Contextualized strings (workaround for `context()` value)
- Context-free strings


---------------

The Fluent support is a fork of a [linguify](https://github.com/typst-community/linguify/)
feature, and all the overall project concept was heavily inspired by this great
package.