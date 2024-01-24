# `wordometer`

[![Manual](https://img.shields.io/badge/docs-manual.pdf-green)](https://github.com/Jollywatt/typst-wordometer/raw/master/docs/manual.pdf)
![Version](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fgithub.com%2FJollywatt%2Ftypst-wordometer%2Fraw%2Fmaster%2Ftypst.toml&query=package.version&label=version)



Basic word counts and document statistics.


## Basic usage

```typ
#import "@preview/wordometer:0.1.0": word-count, total-words

#show: word-count

In this document, there are #total-words words all up.

#word-count(total => [
  The number of words in this block is #total.words
  and there are #total.characters letters.
])
```

## Excluding elements by type or label

```typ
#show: word-count.with(exclude: ("heading", "strike"))

= This Heading Doesn’t Count

In this document #strike[(excluding me)], there are #total-words words all up.

#word-count(total => [
  One, two, three, four.
  #[That was #total.words, excluding this sentence!] <no-wc>
], exclude: <no-wc>)
```

