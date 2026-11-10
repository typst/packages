# ott-ng

Parse Ott snippets and render them as Typst math through a WASM plugin.

## Features

- Render grammar and inference rules from an `.ott` spec (`#render(...)`).
- Parse object-language snippets with Ott grammar and pretty-print using `{{ typst ... }}` hom templates.
- Works in normal text and math contexts.

## Usage

```typst
#import "@preview/ott-ng:0.1.0": render, ott-file

// Optional: render the full spec (grammar + rules)
#render(read("spec.ott"))

// Build a snippet parser/printer from the spec
#let ott = ott-file(read("spec.ott"), root: "t")

#ott["x"]
$ #ott[`\x.x`] $
```

## Writing `typst` homs in Ott

Use `{{ typst ... }}` in metavars and grammar productions.

```ott
metavar termvar, x ::= {{ lex alphanum }} {{ typst [[termvar]] }}

grammar

t :: Tm ::= 
  | x       :: :: Var {{ typst [[x]] }}
  | \ x . t :: :: Abs {{ typst lambda [[x]]. [[t]] }}
```

Use Typst math symbols/operators (e.g. `tack.r`, `mapsto`, `lambda`, `arrow.r`) instead of LaTeX commands.

## License

BSD-2-Clause.
