# touying-flow

Discard irrelevant decorative elements, aiming to better immerse the audience into a state of flow.

Inspired by [Dewdrop](https://github.com/touying-typ/touying.git), made by [OrangeX4](https://github.com/OrangeX4)

A [Typst](https://github.com/typst/typst) template created based on [Touying](https://github.com/touying-typ/touying), designed for academic presentations in university settings.

## Example

See [content/example/main.pdf](content/example/main.pdf) for a sample PDF output. While the project is already complete, the example content is still under development.

## Installation

These steps assume that you already have [Typst](https://typst.app/) installed and running. If not, please refer to [github.com/typst/typst/releases/](https://github.com/typst/typst/releases/) for installation instructions.Alternatively, you can use VS Code for editing by installing the Tinymist Typst extension (*recommended*).

### Import from Typst Universe

```typst
#import "@preview/touying-flow:1.0.0":*

#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.title,
  footer-alt: self => self.info.subtitle,
  navigation: "mini-slides",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Quaternijkon],
    date: datetime.today(),
    institution: [USTC],
  ),
)

#let primary= rgb("#004098")

#show :show-cn-fakebold
#show outline.entry.where(
  level: 1
): it => {
  v(1em, weak: true)
  text(primary, it.body)
}
#show emph: it => {  
  underline(stroke: (thickness: 1em, paint: primary.transparentize(95%), cap: "round"),offset: -7pt,background: true,evade: false,extent: -8pt,text(primary, it.body))
}

#title-slide()

= Example Section Title

== Example Page Title
```
