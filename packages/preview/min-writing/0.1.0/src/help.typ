#import "@preview/min-manual:0.3.0"
#import "cmd.typ"
#import "util.typ": syntax-init

#set page(
  height: auto,
  width: 15cm,
  header: align(right)[_`min-writing` help_]
)
#set par(spacing: 3em)

// Visualize code and evaluate result
#show raw.where(lang: "eg"): it => {
  import "@preview/min-manual:0.3.0": example
  set text(font: "libertinus serif")
  example(
    scope: dictionary(cmd) + (writing: syntax-init),
    "#show: writing\n\n" + it.text
  )
}


= Sintaxe

```eg
|= Level 1

|== Level 2

|=== Level 3

|==== Level 4

|===== Level 5

|====== Level 6
```

```eg
Lorem """ipsum""" dolor sit amet.

> Lorem ipsum.
> — Attribution
```

```eg
One paragraph. \\\\ Another paragraph.
\\\\\\
Paragraph on a new page\
or after divider in paged mode
```

```eg
=Highlight=
​::Boxed::
​:::Underline:::
~~Strikethrough~~
[^This is a footnote]
```

```eg
- [ ] Item
- [X] Item
- [/] Item
- [-] Item
- [!] Item
```

```eg
Content

----

Content
```

```eg
Content

[TOC]

Content
```

```eg
| *Header* | *Header* | *Header* |
| :------: | :------- | -------: |
| Cell     | Cell     | Cell     |
| Cell     | Cell     | \<       |
```

````eg
```mermaid
graph TD
    A[Start] --> B[Finish]
```
````


= Commands

```eg
#boxed[Boxed]
```

````eg
#mermaid(```
graph TD
    A[Start] --> B[Finish]
```)
````

```eg
#figure(
  caption: "Caption",
  source: "Source",
  rect(),
)
```