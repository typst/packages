---
title: ucpc.utils
supports: ["0.1.0"]
---

```typst
#import "/lib/ucpc.typ": utils

utils.
```

This is a utility prepared to quickly create various formats. Using this utility, you can create cover words and descriptions.

## make-hero
```typst
make-hero(
  title: str | content,
  subtitle?: str | content,
  fgcolor?: color,
  bgcolor?: color,
  height?: relative,
  authors?: array<str>,
  datetime?: str | content,
)
```

Generates hero cover page.

## make-prob-meta
```typst
make-prob-meta(
  tags?: array<str>,
  difficulty?: str | content,
  authors?: array<str> | content,
  stat-open?: (
    submit-count: int,
    ac-count: int,
    ac-ratio: float,
    first-solver: str | content,
    first-solve-time: int,
  ),
  stat-onsite?: (
    submit-count: int,
    ac-count: int,
    ac-ratio: float,
    first-solver: str | content,
    first-solve-time: int,
  ),
  i18n?: i18n-dictionary.make-prob-meta
)
```

## make-prob-overview
```typst
make-prob-overview(
  font-size?: length,
  i18n?: i18n-directory.make-prob-overview,
  ..items,
)
```

## make-problem
```typst
make-problem(
  id: str,
  title: str,
  tags?: array<str>,
  difficulty?: str | content,
  authors?: array<str> | content,
  stat-open?: (
    submit-count: int,
    ac-count: int,
    ac-ratio: float,
    first-solver: str | content,
    first-solve-time: int,
  ),
  stat-onsite?: (
    submit-count: int,
    ac-count: int,
    ac-ratio: float,
    first-solver: str | content,
    first-solve-time: int,
  ),
  pallete?: (
    primary: color,
    secondary: color,
  ),
  i18n: i18n-dictionary.make-prob-meta,
  body
)
```
