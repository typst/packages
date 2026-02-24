# Minimal articles

<center>
  Simple and easy way to write ABNT-compliant articles
</center>


## Quick Start

```typst
#import "@preview/min-article:0.1.0": article
#show: article.with(
  title: "Main Title",
  subtitle: "Complementary subtitle",
  foreign-title: "Título Principal",
  foreign-subtitle: "Subtítulo complementar",
  authors: (
    ("Main Author", "PhD in Procrastination, etc."),
    ("Main Collaborator", "Degree in Doing Nothing, etc."),
    ("Collaborator", "Procrastination Student, etc.")
  ),
  lang-foreign: "pt"
)
```


## Description

Generate authentic, structured, and standardized articles, compliant with the
requirements of the Brazilian Association of Technical Standards (ABNT, in
Portuguese). The main advantage of this package, apart from the ABNT standard,
is being able to manage, all by itself, almost all the mind-frying document
structure and its rules: just input the data anywhere and _min-article_ will
find where it belongs, and will put it there.


## More Information

- [Official manual](https://raw.githubusercontent.com/mayconfmelo/min-article/refs/tags/0.1.0/docs/pdf/manual.pdf)
- [Official manual (Portuguese)](https://raw.githubusercontent.com/mayconfmelo/min-article/refs/tags/0.1.0/docs/pdf/manual-pt.pdf)
- [Example PDF result](https://raw.githubusercontent.com/mayconfmelo/min-article/refs/tags/0.1.0/docs/pdf/example.pdf)
- [Example Typst code](https://github.com/mayconfmelo/min-article/blob/0.1.0/template/main.typ)
- [Changelog](https://github.com/mayconfmelo/min-article/blob/main/CHANGELOG.md)