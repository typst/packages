# The `notionly` Package

A Typst package for obtaining the Notion look.

## Context
This package is meant to be used alongside the npm package [`notion2typst`](https://www.npmjs.com/package/@nast/notion2typst) which is a wrapper over a set of npm packages under the [nast](https://www.npmjs.com/org/nast) scope. The npm package generates the Typst code (content) given a Notion page and this Typst package gives it the Notion look by setting some custom functions (callout, bookmark, toggle...), overriding default ones (quote, code...), setting some variables (notion color palette), enabling by default some styling (Inter font, margins, leading par space, etc.) and other stylistic choices. 

The goal is that by simply importing the package and using a show rule one can properly show the Typst content to look as if it were Notion. Obviously one can also use the configuration options in the show rule to tweak some parts of the look and one can always override set rules (like font, font-size, links color, etc.).

## Getting Started

To get up and running you just need to add this at the beginning of your page:

```typ
#import "@preview/notionly:0.1.0": *

#show: notionly
```

## Usage

If you want to see a more comprehensive example and configuration options use the [`./tests/showcase/showcase.typ`](https://github.com/Mapaor/notionly/blob/6e7dea270df8c662864018627063e75ae1fbe666/tests/showcase/showcase.typ), which generates the following document:

<img width="300" height="424" alt="Example visual output for checklists, code blocks and callouts" src="https://github.com/user-attachments/assets/914257ef-574f-4b31-9412-c7428903e311" />
<img width="300" height="424" alt="Example visual output for callouts, quotes and auto-sizeable equations" src="https://github.com/user-attachments/assets/1013a182-135d-45d3-8405-96e3d6c03167" />
<img width="300" height="424" alt="Example visual output for links and bookmarks" src="https://github.com/user-attachments/assets/c80d49ea-8b80-4580-b32a-6c164ad966e9" />
<img width="300" height="424" alt="Example visual output for tables and toggles" src="https://github.com/user-attachments/assets/37c6f0b2-042b-4fe7-8f91-e7899e289fae" />

# Docs
It is not complicated, each new function is named like the notion type (`callout`,  `bookmark`, `toggle`, `file`, etc.) the rest are overrides of already existing functions in Typst.

Here's is an example of a callout:
```typ
#callout(icon: "📘", bg: notion.blue_bg)[
  This is a callout with blue background and a book icon. Both are optional.
  === A callout can contain more than one block like a heading
  And of course the text can be *rich* text.
]
```

And here is an example of a bookmark:
```typ
#bookmark(
  title: "This is a bookmark",
  preview-image: "2257.jpg",
  description: "This is a long description which corresponds to the open graph meta tag `description`. All parameters in a callout are optional except the URL",
  url: "https://examplewebsite.com/"
)
```

See the [showcase](https://github.com/Mapaor/notionly/blob/6e7dea270df8c662864018627063e75ae1fbe666/tests/showcase/showcase.typ) example for a more detailed example on how to use the package.

## FAQs
No one has asked me any question yet. For inquiries, proposals or help using notionly contact me at [pardo.marti@gmail.com](mailto:pardo.marti@gmail.com)

## License
[MIT](https://github.com/Mapaor/notionly/blob/6e7dea270df8c662864018627063e75ae1fbe666/LICENSE)
