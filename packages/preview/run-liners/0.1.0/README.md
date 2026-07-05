# run-liners

A Typst package for creating run-in lists, enumerations, and more following Chicago Manual of Style guidelines.

## Features

- **Run-in Enumerations**: Create numbered lists like "(1) apple, (2) banana, and (3) cherry"
- **Run-in Bullet Lists**: Make bullet-point lists flow in a single line
- **Run-in Term Definitions**: Format term-definition pairs inline
- **Run-in Verse**: Join poetry lines with custom separators
- **Smart Separator Detection**: Automatically switches between commas and semicolons based on content
- **Flexible Coordination**: Use "and", "or", "and/or", or no coordinator between the last two items

## Usage

```typst
#import "@preview/run-liners:0.1.0": *

// Basic enumeration
#run-in-enum([Apple], [Banana], [Cherry])
// Output: (1) Apple, (2) Banana, and (3) Cherry

// Bullet list with custom marker
#run-in-list(
  marker: [#sym.ballot.check],
  [First],
  [Second],
  [Third]
)
// Output: ✓ First, ✓ Second, and ✓ Third

// Term definitions
#run-in-terms(
  ([Term 1], [Definition 1]),
  ([Term 2], [Definition 2])
)
// Output: Term 1: Definition 1, and Term 2: Definition 2

// Poetry lines
#run-in-verse(
  [Line 1],
  [Line 2],
  [Line 3]
)
// Output: Line 1 / Line 2 / Line 3
```

## Configuration Options

- `separator`: Use "auto" for smart detection or specify like ", " or "; "
- `coordinator`: "and", "or", "and/or", or none
- `numbering-pattern`: "(1)", "(A)", etc. for enumerations
- `marker`: Customize bullet points
- `term-formatter`: Style your terms (bold by default)

## Documentation

See the [manual](docs/manual.pdf) for detailed examples and usage guidelines.

## License

[MIT License](LICENSE)
