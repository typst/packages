# ugm-presentation-unofficial

An unofficial presentation template for Universitas Gadjah Mada (UGM) built with Typst.

## Features

- 6 unique slide themes with UGM-inspired backgrounds
- Customizable slide types: title, section, content, and quote slides
- Automatic heading styling
- Grid layout support for two-column content
- Code syntax highlighting

## Installation

```typst
#import "@preview/ugm-presentation-unofficial:0.1.0": conf, title, section, slide, quote
```

## Usage

### Basic Setup

```typst
#import "@preview/ugm-presentation-unofficial:0.1.0": conf, title, section, slide, quote

#show: doc => conf(
  num: 2,  // choose theme 1-6
  doc
)
```

### Slide Functions

#### `conf(num, doc)`

Configures the document. Must be used with `#show: doc => conf(...)`.

| Parameter | Type   | Description                    |
|-----------|--------|--------------------------------|
| `num`     | integer | Theme number (1-6)            |
| `doc`     | content | Document content               |

#### `title(content)`

Creates a title slide with the selected theme background.

```typst
#title[
  = Presentation Title
  Subtitle or Author Name
]
```

#### `section(content)`

Creates a section divider slide.

```typst
#section[
  == Section Name
]
```

#### `slide(content)`

Creates a content slide with the selected theme background.

```typst
#slide[
  === Slide Heading
  Your content here...
  
  #lorem(20)
]
```

#### `quote(content)`

Creates a quote slide with centered content.

```typst
#quote[
  "Your quote text here"
  
  - Attribution
]
```

### Full Example

```typst
#import "@preview/ugm-presentation-unofficial:0.1.0": conf, title, section, slide, quote

#show: doc => conf(
  num: 2,
  doc
)

#title[
  = Presentation Title
  Subtitle
]

#section[
  == Introduction
]

#slide[
  === Overview
  #grid[
    - Point one with some description
    - Point two with more details
  ][
    - Another point
    - Final point
  ]
]

#quote[
  "An inspiring quote here"
  
  - Author Name
]

#section[
  == Conclusion
]

#slide[
  === Summary
  Key takeaways from the presentation.
]
```

## Theme Previews

The template includes 6 themes with different background styles:

- **Theme 1-2**: Yellow/white text on colored backgrounds
- **Theme 3**: Clean minimal style
- **Theme 4**: Right-aligned content with colored backgrounds
- **Theme 5-6**: Right-aligned minimal style

## License

MIT License - Feel free to use and modify for your presentations.
