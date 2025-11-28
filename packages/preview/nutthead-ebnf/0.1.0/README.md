# nutthead-ebnf

A Typst package for rendering Extended Backus-Naur Form (EBNF) grammars with customizable fonts and color schemes.

![Rust grammar example](examples/rust.svg)

## Usage

```typst
#import "@preview/nutthead-ebnf:0.1.0": *

#ebnf(
  mono-font: "JetBrains Mono",
  body-font: "DejaVu Serif",
  Prod(
    N[Expression],
    {
      Or[#N[Term] #Rep[#T[+] #N[Term]]][arithmetic expression]
    },
  ),
  Prod(
    N[Term],
    {
      Or[#N[Factor] #Rep[#T[*] #N[Factor]]][multiplication]
    },
  ),
)
```

## API Reference

### `ebnf()`

Renders an EBNF grammar as a formatted grid.

| Parameter            | Type            | Default           | Description                              |
| -------------------- | --------------- | ----------------- | ---------------------------------------- |
| `mono-font`          | `str` or `none` | `none`            | Font for grammar symbols                 |
| `body-font`          | `str` or `none` | `none`            | Font for annotations                     |
| `colors`             | `dict`          | `colors-colorful` | Color scheme                             |
| `production-spacing` | `length`        | `0.5em`           | Extra vertical space between productions |
| `column-gap`         | `length`        | `0.75em`          | Horizontal spacing between columns       |
| `row-gap`            | `length`        | `0.5em`           | Vertical spacing between rows            |
| `..body`             | `Prod()`        | —                 | Production rules                         |

### `Prod()`

Defines a production rule.

```typst
Prod(
  N[NonTerminal],        // Left-hand side
  annot: "description",  // Optional production annotation
  delim: "::=",          // Optional custom delimiter (default: auto)
  {
    Or[...][annotation]  // One or more alternatives
  },
)
```

### `Or()`

Defines an alternative in a production's right-hand side.

```typst
Or[#T[terminal] #N[NonTerminal]][optional annotation]
```

### Symbol Functions

| Function    | Description                      | Example                 |
| ----------- | -------------------------------- | ----------------------- |
| `T[...]`    | Terminal symbol                  | `T[if]`                 |
| `N[...]`    | Non-terminal reference (italic)  | `N[Expr]`               |
| `NT[...]`   | Non-terminal with angle brackets | `NT[digit]` → ⟨_digit_⟩ |
| `Opt[...]`  | Optional: `[content]`            | `Opt[#T[else]]`         |
| `Rep[...]`  | Zero or more: `{content}`        | `Rep[#N[Stmt]]`         |
| `Rep1[...]` | One or more: `{content}+`        | `Rep1[#T[a]]`           |
| `Grp[...]`  | Grouping: `(content)`            | `Grp[#T[a] #T[b]]`      |

## Color Schemes

Two built-in color schemes are provided:

### `colors-colorful` (default)

Distinct colors for each element type:

- **LHS**: Blue (`#1a5fb4`)
- **Non-terminal**: Purple (`#613583`)
- **Terminal**: Green (`#26a269`)
- **Operator**: Red (`#a51d2d`)
- **Delimiter**: Gray (`#5e5c64`)
- **Annotation**: Brown (`#986a44`)

### `colors-plain`

No colors applied (all elements use default text color).

### Custom Colors

```typst
#let my-colors = (
  lhs: rgb("#000000"),
  nonterminal: rgb("#0000ff"),
  terminal: rgb("#008000"),
  operator: rgb("#ff0000"),
  delim: rgb("#808080"),
  annot: rgb("#666666"),
)

#ebnf(colors: my-colors, ...)
```

## Annotation Behavior

Annotations are displayed based on context:

- **Single alternative**: Annotation appears above the production rule
- **Multiple alternatives with annotations**: Each annotation appears in a dedicated column

This approach optimizes horizontal space while maintaining readability.

## Examples

### Rust Function Grammar

```typst
#import "@preview/nutthead-ebnf:0.1.0": *

#ebnf(
  mono-font: "JetBrains Mono",
  body-font: "DejaVu Serif",
  Prod(
    N[Function],
    {
      Or[#Opt[#T[pub]] #T[fn] #N[Ident] #T[\(] #Opt[#N[Params]] #T[\)] #N[Block]][function definition]
    },
  ),
  Prod(
    N[Type],
    {
      Or[#N[Ident] #Opt[#N[Generics]]][named type]
      Or[#T[&] #Opt[#N[Lifetime]] #Opt[#T[mut]] #N[Type]][reference type]
      Or[#T[\[] #N[Type] #T[\]]][slice type]
    },
  ),
)
```

### Java Class Grammar

```typst
#import "@preview/nutthead-ebnf:0.1.0": *

#ebnf(
  mono-font: "Fira Mono",
  body-font: "IBM Plex Serif",
  Prod(
    N[ClassDecl],
    {
      Or[#Opt[#N[Modifier]] #T[class] #N[Ident] #Opt[#T[extends] #N[Type]] #N[ClassBody]][class declaration]
    },
  ),
  Prod(
    N[Modifier],
    {
      Or[#T[public]][access modifier]
      Or[#T[private]][]
      Or[#T[protected]][]
      Or[#T[static]][other modifiers]
      Or[#T[final]][]
    },
  ),
)
```

## License

MIT
