#import "@preview/clean-hwr:0.1.2": *

// These packages are used to displaying the acronyms and glossaries
// They need to be imported here so you can use #acr / #gls
// to reference them
#import "@preview/acrostiche:0.6.0": *
#import "@preview/glossarium:0.5.8": *

// Count words automatically
#import "@preview/wordometer:0.1.4": word-count, total-words
#show: word-count

#show: hwr.with(
  metadata: (
    title: [HWR PTB Template],
    student-id: "12345678910",
    authors: ("Alice Becker", "Bob Klein"),
    field-of-study: "Computer Science",
    company: "Example Company",
    enrollment-year: "2024",
    semester: "2",
    company-supervisor: "Prof. Dr. Schwarz",
  ),
  custom-entries: (
    (key: "GitHub", value: "aliceb-quantum", index: 0),
    (key: "LinkedIn", value: "Alice Becker", index: 1),
  ),
  acronyms: (
    entries: (
      "QPU": ("Quantum Processing Unit", "Quantum Processing Units"),
    ),
  ),
  glossary: (
    entries: (
      (
        key: "quantum_superposition",
        short: "Superposition",
        long: "Quantum Superposition",
        description: "A fundamental principle of quantum mechanics where a particle can exist in multiple states simultaneously.",
      ),
    ),
  ),
  bibliography-object: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true, title: "Index of Code Snippets"),
  word-count: total-words,
)

= Introduction to Quantum Computing
Quantum computing leverages the principles of quantum mechanics to process information. Unlike classical bits, which are binary, quantum bits — or #gls("quantum_superposition") — can exist in a *superposition* of states.
#lorem(100)

In this report, we explore how #acr("QPU")s are used in real-world applications.

#pagebreak()

= Practical Implementation at IBM <IBM>
IBM Quantum offers access to real #acr("QPU")s over the cloud. This has enabled researchers and students to experiment with real quantum algorithms#footnote[cf. @Feynman82].

== Core Concepts
After we talked about IBM in @IBM we will continue with #lorem(150)

#let unit(u) = math.display(math.upright(u))
#let si-table = table(
  columns: 3,
  table.header[Quantity][Symbol][Unit],
  [Length], [$l$], [#unit("m")],
  [Mass], [$m$], [#unit("kg")],
  [Time], [$t$], [#unit("s")],
  [Electric Current], [$I$], [#unit("A")],
  [Temperature], [$T$], [#unit("K")],
  [Substance Amount], [$n$], [#unit("mol")],
  [Luminous Intensity], [$I_v$], [#unit("cd")],
)
#[
  #set table(inset: 5pt, stroke: 1pt + black)
  #show table.cell.where(y: 0): it => {
    v(0.5em)
    h(0.5em) + it.body.text + h(0.5em)
    v(0.5em)
  }
  #figure(caption: ["SI Base Units"], si-table)
]

== Code Example
#show raw: set text(font: "Fira Mono")
Below is an example of tuple usage in Rust:

#figure(caption: ["Rust code using tuples"])[
```rust
fn main() {
    let user = ("Alice", 29);
    println!("User {} is {} years old", user.0, user.1);

    let employee = (("Alice", 29), "IBM Quantum");
    println!("{} is {} and works for {}", employee.0.0, employee.0.1, employee.1);
}
```
]
#figure(image("images/header_logo.png", width: 80%), caption: "Logo of the Berlin School of Economics and Law")<HWR>

== Visualization
#lorem(233)

== Subchapter: Outlook
#lorem(60)
