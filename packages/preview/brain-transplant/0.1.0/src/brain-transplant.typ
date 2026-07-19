/// Transpile a Brainfuck program to Typst.
///
/// -> string
#let brain-transplant(
  /// The Brainfuck code.
  /// All characters save `+-<>[].,#`, including line breaks, are ignored and thus can be used as comments.
  /// `#` (a non-standard instruction) prints debug information: the position of the pointer, the value it indicates, the position in the input and the values of the ten (at most) first cells.
  /// ```example
  /// #raw(brain-transplant(",>,>,#", input: "Hi!"))
  /// ```
  /// -> string
  code,

  /// #let link(..args) = [#std.link(..args)#text(fill: rgb("#993333"))[°]] // an ugly workaround for an ugly problem
  /// The input read by the program.
  /// In order to input specific numbers, use `\u{…}`; for example, for programs which reads `0`-terminated input, end the input with `\u{0}`.
  /// Note that the numbers are written in hexadecimal basis.
  /// For more information #link("https://typst.app/docs/reference/syntax/#escapes")[read Typst’s documentation].
  /// -> string
  input: "",

  /// The size of the one-dimensional array for the use of the program.
  /// -> int
  memsize: 30000,

  /// #let link(..args) = [#std.link(..args)#text(fill: rgb("#993333"))[°]]
  /// Whether to evaluate (run) the transpiled program and return its output (default, #value(true)) or output the transpiled program without evaluating it (the output can be saved into a variable and evaluated later using the `eval()` function.).
  ///
  /// Consider this simple program that outputs ‘`Hi Mom!`’.
  /// When #arg("evaluate") is set to #value(true) (or left unset), it behaves like this:
  /// ```example
  /// #raw(brain-transplant("+++++++[->,.<]", input: "Hi Mom!", evaluate: true))
  /// ```
  /// However, when it is set to #value(false), it behaves like this:
  /// ```example
  /// #raw(brain-transplant("+++++++[->,.<]", input: "Hi Mom!", evaluate: false))
  /// ```
  /// The first part of the code is a preamble that #link("https://typst.app/docs/reference/scripting/#bindings")[binds] required variables, and after it the commands are transpiled one after the other, with added `assert()` functions which are triggered by #arg("unsafe") being set to #value(false) by default, following Rust’s behaviour.
  /// -> bool
  evaluate: true,

  /// If set to #value("false"), safeguards limiting the pointer from exceeding its minimum and maximum values are provided.
  /// Otherwise, the behaviour is unpredictable in such cases.
  /// Compare this:
  /// ```example
  /// #raw(brain-transplant("><", evaluate: false, unsafe: true))
  /// ```
  /// with this:
  /// ```example
  /// #raw(brain-transplant("><", evaluate: false, unsafe: false))
  /// ```
  /// -> bool
  unsafe: false,

  /// #let link(..args) = [#std.link(..args)#text(fill: rgb("#993333"))[°]]
  /// Named after #link("https://numpy.org/")[NumPy], this option breaks the limit of one byte ($0$ to $2^8-1$) per cell and unlocks larger numbers as well as negative numbers.
  /// It also changes the output to show as numbers, not ASCII characters.
  /// ```side-by-side
  /// #raw(brain-transplant("-.", numbf: true))
  /// ```
  /// ```side-by-side
  /// #raw(brain-transplant(",+.", numbf: true, input: "\u{51F}"))
  /// ```
  /// -> bool
  numbf: false,
) = {
  let typstpiled = "let mem = array(range(0, " + str(memsize) + ")).map(a => 0)\nlet p = 0\nlet input = \"" + input + "\"\nlet input-pos = 0\n"
  for command in code {
    if command == ">" {
      typstpiled += "p += 1\n"
      if not unsafe {typstpiled += "assert(p < " + str(memsize) + ", message: \"🧟 BRAIN TRANSPLANT REJECTED: the data pointer of brain-transplant exceeded its maximum value (" + str(memsize - 1) + ")\")\n"}
    }
    else if command == "<" {
      typstpiled += "p -= 1\n"
      if not unsafe {typstpiled += "assert(p >= 0, message: \"🧟 BRAIN TRANSPLANT REJECTED: the data pointer of brain-transplant its exceeded minimum value (0)\")\n"}
    }
    else if command == "+" {
      if numbf {typstpiled += "mem.at(p) += 1\n"}
      else {typstpiled += "mem.at(p) = calc.rem-euclid(mem.at(p) + 1, 256)\n"}
    }
    else if command == "-" {
      if numbf {typstpiled += "mem.at(p) -= 1\n"}
      else {typstpiled += "mem.at(p) = calc.rem-euclid(mem.at(p) - 1, 256)\n"}
    }
    else if command == "." {
      if numbf {typstpiled += "str(mem.at(p))\n"}
      else {typstpiled += "str.from-unicode(calc.rem-euclid(mem.at(p), 256))\n"}
    }
    else if command == "," {
      if not unsafe {typstpiled += "assert(input-pos < " + str(input.len()) + ", message: \"🧟 BRAIN TRANSPLANT REJECTED: tried to read more input than what was provided\")\n"}
      if numbf {typstpiled += "mem.at(p) = str.to-unicode(input.at(input-pos))\n"}
      else {typstpiled += "mem.at(p) = calc.rem-euclid(str.to-unicode(input.at(input-pos)), 256)\n"}
      typstpiled += "input-pos += 1\n"
    }
    else if command == "[" {typstpiled += "while (mem.at(p) != 0) {\n"}
    else if command == "]" {typstpiled += "}\n"}
    else if command == "#"  { // non-standard command for printing debug information
      typstpiled += "\"p      = \"\nstr(p)\n\"\n\"\n"
      typstpiled += "\"mem[p] = \"\nstr(mem.at(p))\n\"\n\"\n"
      typstpiled += "\"in-pos = \"\nstr(input-pos)\n\"\n\"\n"
      for i in range(0, calc.min(10, memsize)) {
        typstpiled += "\"mem[" + str(i) + "] = \"\nstr(mem.at(" + str(i) + "))\n\"\n\"\n"
      }
    }
    else if command == "?"  { // Code-readers can have an Easter egg, as a treat (https://github.com/theresnotime/as-a-treat)
      typstpiled += "\"42\"\n"
    }
  }
  if evaluate {eval(typstpiled) + ""} // Add an empty string so programs with no output still output a string, as opposed to #none.
  else {typstpiled.trim()}
}
