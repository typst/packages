# Tree List

<a href="https://github.com/8LWXpg/typst-tree-list/tags">
  <img alt="GitHub manifest version (path)" src="https://img.shields.io/github/v/tag/8LWXpg/typst-tree-list">
</a>
<a href="https://github.com/8LWXpg/typst-tree-list">
  <img src="https://img.shields.io/github/stars/8LWXpg/typst-tree-list?style=flat" alt="GitHub Repo stars">
</a>
<a href="https://github.com/8LWXpg/typst-tree-list/blob/master/LICENSE">
  <img alt="GitHub" src="https://img.shields.io/github/license/8LWXpg/typst-tree-list">
</a>
<a href="https://github.com/typst/packages/tree/main/packages/preview/tree-list">
  <img alt="typst package" src="https://img.shields.io/badge/typst-package-239dad">
</a>

render tree list easily in Typst

contribution is welcomed!

## Usage

```typst
#import "@preview/tree-list:0.1.0": *

#tree-list(
  marker:       content,
  last-marker:  content,
  indent:       content,
  empty-indent: content,
  marker-font:  string,
  content,
)
```

### Parameters

- `marker` - the marker of the tree list, default is `[├─ ]`
- `last-marker` - the marker of the last item of the tree list, default is `[└─ ]`
- `indent` - the indent after `marker`, default is `[│#h(1em)]`
- `empty-indent` - the indent after `last-marker`, default is `[#h(1.5em)]` (same width as indent)
- `marker-font` - the font of the marker, default is `"Cascadia Code"`
- `content` - the content of the tree list, includes at least a list

## Demo

see [demo.typ](https://github.com/8LWXpg/typst-tree-list/blob/master/test/demo.typ) [demo.pdf](https://github.com/8LWXpg/typst-tree-list/blob/master/test/demo.pdf)

### Default style

```typst
#tree-list[
  - 1
    - 1.1
      - 1.1.1
    - 1.2
      - 1.2.1
      - 1.2.2
        - 1.2.2.1
  - 2
  - 3
    - 3.1
      - 3.1.1
    - 3.2
]
```

![1.png](https://github.com/8LWXpg/typst-tree-list/blob/master/img/1.png)

### Custom style

```typst
#text(red, tree-list(
  marker: text(blue)[├── ],
  last-marker: text(aqua)[└── ],
  indent: text(teal)[│#h(1.5em)],
  empty-indent: h(2em),
)[
  - 1
    - 1.1
      - 1.1.1
    - 1.2
      - 1.2.1
      - 1.2.2
        - 1.2.2.1
  - 2
  - 3
    - 3.1
      - 3.1.1
    - 3.2
])
```

![2.png](https://github.com/8LWXpg/typst-tree-list/blob/master/img/2.png)

### Using show rule

```typst
#show list: tree-list
#set text(font: "DejaVu Sans Mono")

root_folder\
- sub-folder
  - 1-1
    - 1.1.1 -
  - 1.2
    - 1.2.1
    - 1.2.2
- 2
```

![3.png](https://github.com/8LWXpg/typst-tree-list/blob/master/img/3.png)
