# Easy Typography for Typst

A Typst package that simplifies professional typography by providing sensible
defaults and easy customization options. Focus on your content while ensuring
beautiful, readable documents.

## Features

- 🎨 Precise heading scale with clear hierarchy
- 📏 Optimal line height and paragraph spacing
- 📖 Professional text justification and hyphenation
- ⚖️ Balanced vertical rhythm throughout
- ⚡ Simple configuration with reasonable defaults

## Usage

Basic usage with default settings:

```typst
#import "@preview/easy-typography:0.1.0": *
#show: easy-typography

= Your Document Title
Your content here...
```

Customized usage with specific fonts:

```typst
#show: easy-typography.with(
  fonts: (
    heading: "Source Sans Pro",
    body: "Source Serif Pro"
  ),
  body-size: 11pt,
  paper: "a4",
  margin: 2cm
)
```

## Configuration Options

- `body-size`: Base size for body text (default: 10pt)
- `fonts`: Dictionary specifying heading and body fonts
  - `heading`: Font for headings (default: "Libertinus Sans")
  - `body`: Font for body text (default: "Libertinus Serif")
- `paper`: Paper size setting (optional)
- `margin`: Page margin setting (optional)

## Example Output

The package automatically handles:

- Heading sizes with natural visual hierarchy (H1-H5)
- Optimal spacing between elements
- Professional text justification
- Smart hyphenation
- Consistent vertical rhythm

See the [example output](thumbnail.png) for more information and a complete
example.

## License

MIT License - See [LICENSE](LICENSE) for details.
