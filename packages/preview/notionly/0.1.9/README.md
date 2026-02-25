# The `notionly` Package

A Typst package for obtaining the Notion look. Primarly used in `notion2typst`.

## Context
This package is meant to be used alongside the npm package `notion2typst` ([link](https://www.npmjs.com/package/nast)) to properly render the Notion content transformed into Typst code. This package achieves the Notion look by setting some custom functions (callout, bookmark...), overriding default ones (like quote, code...), setting some variables (notion color palette), enabling by default some styling (Inter font, margins, leading par space, etc.) and other stylistic choices. 

The goal is that by simply importing tha package and using a show rule one can properly show the Typst content to look as if it were inside Notion. Obviously one can also use configuration in the show rule to tweak some parts of the look and one can always override set rules (like font, font-size, links color, etc.).

## Getting Started

To get up and running you just need to add this at the beginning of your page:

```typ
#import "@preview/notionly:0.1.0": *

#show: notionly.with(
  // notion-look: true
)
```

## Usage

If you want to see a more comprehensive example use the [`./tests/showcase/showcase.typ`](./tests/showcase/showcase.typ), which generates the following document:

<img width="300" height="1684" alt="notionly-1" src="https://github.com/user-attachments/assets/20d5469e-fd87-4999-8579-c431fc3521f9" />

<img width="300" height="1684" alt="notionly-2" src="https://github.com/user-attachments/assets/01e5c7ce-4f18-433c-9c04-3b023e5a98ce" />

<img width="300" height="1684" alt="notionly-3" src="https://github.com/user-attachments/assets/fd5d06f6-93c8-4754-9206-97923b6f1a44" />

# Docs
It is not complicated, the only new functions are `callout` and  `bookmark`, the rest are overrides of existing functions.

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
  previewImage: "2257.jpg",
  description: "This is a long description which corresponds to the open graph meta tag `description`. All parameters in a callout are optional except the URL",
  url: "https://examplewebsite.com/"
)
```

## FAQs
No one has asked me any question yet. For inquiries, proposals or help using notionly contact me at [pardo.marti@gmail.com](mailto:pardo.marti@gmail.com)

## License
MIT
