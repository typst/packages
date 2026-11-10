# ugm-presentation-unofficial

An unofficial presentation template for Universitas Gadjah Mada (UGM) built with Typst.

## Installation

```typst
#import "@preview/ugm-presentation-unofficial:0.1.0": conf, title, section, slide, quote
```

## Usage

```typst
#show: doc => conf(
  num: 2,  // choose theme 1-6
  doc
)
```

## Functions

- `conf(num, doc)` - Configure document with theme
- `title(content)` - Title slide
- `section(content)` - Section divider
- `slide(content)` - Content slide
- `quote(content)` - Quote slide

## Theme Previews

| Theme | Preview |
|-------|---------|
| 1 | ![Theme 1](src/previews/preview-1.png) |
| 2 | ![Theme 2](src/previews/preview-2.png) |
| 3 | ![Theme 3](src/previews/preview-3.png) |
| 4 | ![Theme 4](src/previews/preview-4.png) |
| 5 | ![Theme 5](src/previews/preview-5.png) |
| 6 | ![Theme 6](src/previews/preview-6.png) |

## License

MIT License
