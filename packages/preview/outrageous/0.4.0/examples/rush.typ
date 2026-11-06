//! This example replicates the outline of the paper on the rush programming language.
//! See https://paper.rush-lang.de

#import "@preview/outrageous:0.4.0"
#import "@preview/i-figured:0.2.4"

#set text(font: "New Computer Modern")
#set page(numbering: "1")

// only do numbering for the first three levels, in the style `1.`
// note: we have to set the style to `1.1` so that references don't
// include the trailing dot, and then manually add the dot back
// for headings and ToC entries
#set heading(numbering: (..nums) => {
  let nums = nums.pos()
  if nums.len() < 4 {
    numbering("1.1", ..nums)
  }
})
#show heading: it => block({
  // sans font for headings
  set text(font: "Noto Sans")
  if it.numbering != none {
    numbering(it.numbering, ..counter(heading).at(it.location()))
    // add the trailing dot here
    if it.level < 4 { [. ] }
  }
  it.body
})

// level 1 headings start new pages and have some vertical spacing
#show heading.where(level: 1): it => {
  set text(size: 25pt)
  pagebreak(weak: true)
  v(1cm)
  it
  v(1cm)
}

// references to level 1 headings should say 'Chapter'
#set heading(supplement: it => if it.depth == 1 { [Chapter] } else { [Section] })

// outlines are indented and only show the first four levels
#set outline(indent: auto, depth: 4)

#{
  // only for ToC: default outrageous-toc styling, but we have to add the trailing dot
  // to the numbering
  show outline.entry: outrageous.show-entry.with(prefix-transform: (lvl, prefix) => {
    if prefix != none and prefix.has("text") {
      [#prefix.]
    }
  })
  outline()
}

// figure numbering per chapter
#show heading: i-figured.reset-counters
#show figure: i-figured.show-figure

#show outline.entry: outrageous.show-entry.with(..outrageous.presets.outrageous-figures)
#i-figured.outline()
#{
  show outline.entry: outrageous.show-entry.with(
    ..outrageous.presets.outrageous-figures,
    prefix-transform: outrageous.presets.outrageous-figures.prefix-transform
  )
  // override the show rule to not insert a page break
  show heading.where(level: 1): it => {
    v(1.5cm)
    text(size: 25pt, font: "Noto Sans", it.body)
    v(1cm)
  }
  i-figured.outline(title: [List of Tables], target-kind: table)
}
#show outline.entry: outrageous.show-entry.with(
  ..outrageous.presets.outrageous-figures,
  prefix-transform: outrageous.presets.outrageous-figures.prefix-transform
)
#i-figured.outline(title: [List of Listings], target-kind: raw)

// don't allow newlines inside "RISC-V"
#show "RISC-V": box

#counter(page).update(1)
= Introduction
#counter(page).update(1)
See @my-chapter, @my-section, @my-subsection, @fig:my-figure, @tbl:my-table, and @lst:my-listing.
== Stages of Compilation
#pagebreak()
#figure([a], caption: [Steps of compilation.])
#figure([a], caption: [Steps of compilation. (altered)])
#pagebreak()
== The rush Programming Language
#figure([```rush fn fib(n: int) -> int {}```], caption: [Generating Fibonacci numbers using rush.]) <my-listing>
=== Features
#pagebreak()
#figure(table(), caption: [Lines of code of the project's components in commit '`f8b9b9a`'.])
#pagebreak()
#figure(table(), caption: [Most important features of the rush programming language.])
#figure(table(), caption: [Data types in the rush programming language.]) <my-table>
#pagebreak()
= Analyzing the Source <my-chapter>
== Lexical and Syntactical Analysis <my-section>
=== Formal Syntactical Definition by a Grammer <my-subsection>
#figure([```rust fn main() {}```], caption: [Grammar for basic arithmetic in EBNF notation.])
=== Grouping Characters Into Tokens
#pagebreak()
#figure([```rust fn main() {}```], caption: [The rush '`Lexer`' struct definition.])
#figure(table(), caption: [Advancing window of a lexer.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Simplified '`Token`' struct definition.])
=== Constructing a Tree
#figure([a], caption: [Abstract syntax tree for '`1+2**3`'.]) <my-figure>
#pagebreak()
#figure(table(), caption: [Mapping from EBNF grammar to Rust type definitions.])
==== Operator Precedence
#figure([```rust fn main() {}```], caption: [Example language a traditional LL(1) parser cannot parse.])
#pagebreak()
==== Pratt Parsing
#figure([a], caption: [Abstract syntax tree for '`1+2**3`' using Pratt parsing.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Pratt-parser: Implementation for token precedences.])
#figure([```rust fn main() {}```], caption: [Pratt-parser: Implementation for expressions.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Pratt-parser: Implementation for grouped expressions.])
#figure([```rust fn main() {}```], caption: [Pratt-parser: Implementation for infix-expressions.])
#figure([a], caption: [Token precedences for the input '`(1+2*3)/4**5`'.])
#pagebreak()
==== Parser Generators
== Semantic Analysis
=== Defining the Semantics of a Programming Language
=== The Semantic Analyzer
#pagebreak()
#figure([```rust fn main() {}```], caption: [A rush program which adds two integers.])
==== Implementation
#pagebreak()
#figure([```rust fn main() {}```], caption: [Fields of the '`Analyzer`' struct.])
#figure([```rust fn main() {}```], caption: [Output when compiling an invalid rush program.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Analyzer: Validation of the '`main`' function's signature.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Analyzer: The '`let_stmt`' method.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Analyzer: Analysis of expressions during semantic analysis.])
#figure([```rust fn main() {}```], caption: [Analyzer: Obtaining the type of expressions.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Analyzer: Validation of argument type compatibility.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Analyzer: Determining whether an expression is constant.])
==== Early Optimizations
#figure([```rust fn main() {}```], caption: [Redundant '`while`' loop inside a rush program.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Analyzer: Loop optimization.])
#figure([a], caption: [How semantic analysis affects the abstract syntax tree.])
#pagebreak()
= Interpreting the Program
== Tree-Walking Interpreters
#figure([```rust fn main() {}```], caption: [Tree-walking interpreter: Type definitions.])
#pagebreak()
=== Implementation
#figure([```rust fn main() {}```], caption: [Tree-walking interpreter: '`Value`' and '`InterruptKind`' definitions.])
=== How the Interpreter Executes a Program
#figure([a], caption: [Call stack at the point of processing the '`return`' statement.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Tree-walking interpreter: Beginning of execution.])
#figure([```rust fn main() {}```], caption: [Tree-walking interpreter: Calling of functions.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Example rush program.])
=== Supporting Pointers
#pagebreak()
== Using a Virtual Machine
=== Defining a Virtual Machine
#pagebreak()
#figure([```rust fn main() {}```], caption: [Struct definition of the VM.])
=== Register-Based and Stack-Based Machines
=== The rush Virtual Machine
#pagebreak()
#figure([```rust fn main() {}```], caption: [Minimal pointer example in rush.])
#figure([a], caption: [Linear memory of the rush VM.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [VM instructions for the minimal pointer example.])
=== How the Virtual Machine Executes a rush Program
#figure([```rust fn main() {}```], caption: [A recursive rush program.]) <recursive-rush-program>
#figure([```rust fn main() {}```], caption: [Struct definition of a '`CallFrame`'.])
#pagebreak()
#figure([a], caption: [Example call stack of the rush VM.])
#figure([```rust fn main() {}```], caption: [VM instructions matching the AST in @fig:ast-and-vm-instructions.])
#pagebreak()
=== Fetch-Decode-Execute Cycle of the VM
#figure([```rust fn main() {}```], caption: [The '`run`' method of the rush VM.])
#pagebreak()
#figure([```rust fn main() {}```], caption: [Parts of the '`run_instruction`' method of the rush VM.])
#pagebreak()
=== Comparing the VM to the Tree-Walking Interpreter
#figure([a], caption: [AST and VM instructions of the recursive rush program in @lst:recursive-rush-program.]) <ast-and-vm-instructions>
#pagebreak()
#pagebreak()
= Compiling to High-Level Targets
== How a Compiler Translates the AST
#figure([a], caption: [Abstract syntax tree for '`1 + 2 < 4`'.])
#pagebreak()
== The Compiler Targeting the rush VM
#pagebreak()
#pagebreak()
#pagebreak()
#pagebreak()
== Compilation to WebAssembly
=== WebAssembly Modules
#pagebreak()
#pagebreak()
=== The WebAssembly System Interface
#pagebreak()
=== Implementation
#pagebreak()
==== Function Calls
==== Logical Operators
#pagebreak()
=== Considering an Example rush Program
#pagebreak()
#pagebreak()
== Using LLVM for Code Generation
=== The Role of LLVM in a Compiler
#figure([a], caption: [Steps of compilation when using LLVM.])
=== The LLVM Intermediate Representation
#pagebreak()
==== Structure of a Compiled rush Program
#pagebreak()
#pagebreak()
=== The rush Compiler Using LLVM
#pagebreak()
#pagebreak()
#pagebreak()
#pagebreak()
#pagebreak()
=== Final Code Generation: The Linker
#figure([a], caption: [The linking process.])
#pagebreak()
=== Conclusions
#pagebreak()
== Transpilers
#pagebreak()
= Compiling to Low-Level Targets
== Low-Level Programming Concepts
=== Sections of an ELF File
=== Assemblers and Assembly Language
#pagebreak()
#figure([a], caption: [Level of abstraction provided by assembly.])
=== Registers
#pagebreak()
#figure([a], caption: [Relationship between registers, memory, and the CPU.])
#pagebreak()
=== Using Memory: The Stack
==== Alignment
#figure([a], caption: [Examples of memory alignment.])
#pagebreak()
=== Calling Conventions
#pagebreak()
=== Referencing Variables Using Pointers
#pagebreak()
#pagebreak()
== RISC-V: Compiling to a RISC Architecture
#figure(table(), caption: [Registers of the RISC-V architecture.])
=== Register Layout
#pagebreak()
=== Memory Access Through the Stack
#figure([a], caption: [Stack layout of the RISC-V architecture.])
=== Calling Convention
#pagebreak()
=== The Core Library
#pagebreak()
=== RISC-V Assembly
#pagebreak()
#pagebreak()
=== Supporting Pointers
=== Implementation
==== Struct Fields
#pagebreak()
#pagebreak()
==== Data Flow and Register Allocation
#pagebreak()
#figure([a], caption: [Simplified integer register pool of the RISC-V rush compiler.])
#pagebreak()
#pagebreak()
#pagebreak()
==== Functions
#pagebreak()
==== Let Statements
#pagebreak()
==== Function Calls and Returns
#pagebreak()
#pagebreak()
#pagebreak()
==== Loops
#pagebreak()
#pagebreak()
== x86_64: Compiling to a CISC Architecture
=== x64 Assembly
#pagebreak()
=== Registers
#pagebreak()
#figure(table(), caption: [General purpose registers of the x64 architecture.])
#pagebreak()
=== Stack Layout and Calling Convention
#figure([a], caption: [Stack layout of the x64 architecture.])
=== Implementation
#pagebreak()
==== Struct Fields
#pagebreak()
==== Memory Management
==== Register Allocation
#pagebreak()
==== Functions
#pagebreak()
==== Function Calls
==== Control Flow
#figure([a], caption: [Structure of if-expressions in assembly.])
#pagebreak()
#pagebreak()
==== Integer Division and Float Comparisons
#pagebreak()
#pagebreak()
==== Pointers
#pagebreak()
== Conclusion: RISC vs. CISC Architectures
#pagebreak()
= Final Thoughts and Conclusions
#pagebreak()
#pagebreak()
#set heading(numbering: none)
= List of Figures
= List of Tables
#pagebreak()
= List of Listings
#pagebreak()
#pagebreak()
#pagebreak()
= Bibliography
