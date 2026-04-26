# Mephistypsteles
Typst currently doesn't have reflection natively (using typst code to look at other typst code in a structured way).

But, Typst supports plugins compiled to WebAssembly.
And Typst itself is written in Rust, a language that can compile to WebAssembly.

> "So," the devil whispers in your ear, "why not compile a part of typst itself to a plugin and run it inside typst?"
> [The _Inception_ soundtrack plays...]

Yes, it is very inefficient. Wasteful, even. But it works, and that is what counts.

## Versioning

There are _two_ typst versions that are relevant:
1. The version of the typst code being parsed.
2. The version of typst that is used to run mephistypsteles.

| Mephistypsteles Version | Parses Typst Version | Runs with Typst Version |
|-------------------------|----------------------|-------------------------|
| 0.1.0                   | 0.12.0               | only 0.12.0             |
| 0.2.0                   | 0.12.0               | only 0.12.0             |
| 0.3.0                   | 0.13.0               | >= 0.12.0               |

## API
This package exposes two functions:
- `parse(str, flat: bool)`: Produce a representation of typst syntax (*markup mode*).
	- The output with `flat: false` (the default) is more structured and thus probably more useful.
	- The output with `flat: true` is simpler, but also more direct, including e.g. comments.
- `operator-info(str)`: Get arity, precedence and associativity information for an operator.

I haven't taken the effort to explicitly document the output format of `parse`,
but you can use the following information:
- For `flat: true`, it's a really simple tree and all nodes have the same form:
	`(kind: str, span: (start: int, end: int), text: str, children: array[node])`.
- For `flat: false`, whenever fields of a node are only sometimes present, there will also be a `kind` (or `let-kind`) field, indicating an enum.
	Otherwise, every field is always there for that type of node (abscence will be indicated by a `none` value).
	If you need more info than that, you can try around and see what outputs you can get,
	or, if you really want to be sure, read `rust-plugin/src/lib.rs`.

## Example
![example](examples/self.png)