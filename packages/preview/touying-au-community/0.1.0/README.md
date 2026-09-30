![Version](https://img.shields.io/badge/version-0.1.0-green)

# touying-au-community

A [Typst](https://typst.app/) package for creating presentation at Aarhus University,
built on top of [Touying](https://github.com/johannes-wolf/cetz).

```typ
#import "@preview/touying-au-community:0.1.0": *

#show: touying-au-community.with(
  aspect-ratio: "16-9",
  config-info(
    title: [A custom presentation theme for Aarhus University],
    subtitle: [Built with Touying],
    author: [John Doe],
    date: datetime.today(),
    institution: [Aarhus University],
    department: [Department of Engineering],
  ),
)
```

**Note:** For this package to work you need to provide it with the AU fonts. You can download these [here](https://medarbejdere.au.dk/en/administration/communication/guidelines/guidelinesforfonts/downloadfonts/). (You will need both the *AU Passata* and *AU Logo* font).

## Examples

<picture>
  <img src="docs/title-slide.png" alt="Example of the title slide">
</picture>

<picture>
  <img src="docs/slide.png" alt="Example of a simple slide">
</picture>

<picture>
  <img src="docs/end-slide.png" alt="Example of the end slide">
</picture>

## Change log

### 0.1.0

- Initial release
