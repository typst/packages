#import "@preview/min-writing:0.1.0": writing, boxed, mermaid, figure

#set document(
  title: "Minimal Writings",
  author: "mayconfmelo",
  description: [
    This example is in quick-note mode, where all content appears on a single, narrow page.
    It can also be set to classic paginated mode.
  ],
)

#show: writing

[TOC]


= Syntax

|= Unnumbered level 1

|== Unnumbered level 2

|=== Unnumbered level 3

|==== Unnumbered level 4

|===== Unnumbered level 5

|====== Unnumbered level 6

*Strong*
_Emphasis_
`Monospaced`
=Marked=
::Boxed::
:::Underline:::
~~Strikethrough~~
[^This is a footnote]

This is an """inline quotation""".

> This is a block quotation.
> --- Attribution

| *Centered* | *Left*    | *Right* | *None* |
| :--------: | :-------- | ------: | ------ |
| AAAA       | AAAA      | AAAA    | AAAA   |
| AAA        | AAA       | AAA     | AAA    |

This is a paragraph. \\\\ This is another paragraph. \\\\\\ This is in another page (when paged)

```mermaid
graph TD
    A[Start] --> B[Finish]
```

-----

- [ ] Item
- [X] Item
- [/] Item
- [-] Item
- [!] Item


= Commands

#boxed[Boxed]

#mermaid(```
  graph TD
    A[Start] --> B[End]
```)

#figure(
  caption: "Caption",
  source: "Source",
  rect(),
)

#pagebreak() // turns into #divider in #writing(paged) mode