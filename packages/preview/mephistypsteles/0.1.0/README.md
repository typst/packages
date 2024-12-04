# Mephistypsteles
Typst currently doesn't have reflection natively (using typst code to look at other typst code in a structured way).

But, Typst supports plugins compiled to WebAssembly.
And Typst itself is written in Rust, a language that can compile to WebAssembly.

> "So," the devil whispers in your ear, "why not compile a part of typst itself to a plugin and run it inside typst?"
> [The _Inception_ soundtrack plays...]

Yes, it is very inefficient. Wasteful, even. But it works, and that is what counts.

## API
This package exposes three functions:
- `parse-flat(str)`: Produce a basic representation of typst syntax
- `parse-markup(str)`: Produce a rich representation of typst markup (like the contents of a `.typ` file)
- `operator-info(str)`: Get arity, precedence and associativity information for an operator.

## Example
![example](example.png)