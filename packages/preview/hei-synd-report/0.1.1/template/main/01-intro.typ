#import "@preview/hei-synd-report:0.1.1": *
#import "/metadata.typ": *
#pagebreak()

= Introduction

#option-style(type:option.type)[
  This chapter provides an overview of the project, including its background, motivation, and objectives. It should clearly state the problem being addressed and why it is relevant.

  Key elements:
  - *Introduce the goal* – What do you want to achieve with the project?
  - *Provide context* – Why is this project relevant? What problem does it solve?
  - *Define the scope* – What are the boundaries and limitations of your project?
  - *Outline the structure* – How is this report organized?

  Always place yourself in the point of view of the reader. For who is the report intended? What do they need to know to understand the project? Create and follow a red thread that guides the reader through the report.
]

#infobox()[Welcome to the template’s introductory chapter! Instead of boring you with lorem ipsum, here’s a quick guide to what you can do in Typst and, more specifically, in this template.

  Need more? Check out the #link("https://github.com/hei-templates/hei-synd-report/blob/main/guide-to-typst.pdf")[Guide to Typst].]

== Basic markup

Typst lets you create bold, italic, or monospaced text with ease. You can also sprinkle in equations like $e^(i pi) + 1 = 0$ or even inline code like #raw(lang:"rust", "fn main() { println!(\"Hello, World!\") }"). And because life is better in color: #text(fill:hei-pink)[pink], #text(fill:hei-blue)[blue], #text(fill:hei-yellow)[yellow], #text(fill:hei-orange)[orange], #text(fill:hei-green)[green], and more! #text(fill:color-fire)[Boldly colorize!]

You can also write numbered or unnumbered lists:
- First item
- Second item
  + First Subitem
  + Second Subitem
- Third item

Need equations? Sure! They look great as blocks too:

#figure(
  [$ sin(x) = x - x^3/(3!) + x^5/(5!) - ... = sum_(n=0)^infinity (-1)^n/((2n+1)!)x^(2n+1) $]
)

== Images

As they say, a picture is worth a thousand words. Let’s add one:

#figure(
  image("/resources/img/project-logo.svg", width:3cm),
  caption: "Project logo"
)

== Tables

Tables are great for organizing data. From simple to complex, Typst handles them all:

#figure(
  table(
    columns: 3,
    stroke:none,
    align:(left+horizon),
    table.header([*Name*], [*Age*], [*City*]),
    [Albert Einstein], [25], [Bern],
    [Marie Curie], [22], [Paris],
    [Isaac Newton], [30], [London],
  ),
  caption: "Simple table"
)

#figure(
  table(
    columns: 8,
    stroke: none,
    align: center,
    inset: 3pt,
    table.vline(x:0, start:1, end:2, stroke:0.5pt),
    table.vline(x:1, start:1, end:2, stroke:0.5pt),
    table.vline(x:2, start:1, end:2, stroke:0.5pt),
    table.vline(x:3, start:1, end:2, stroke:0.5pt),
    table.vline(x:4, start:1, end:2, stroke:0.5pt),
    table.vline(x:5, start:1, end:2, stroke:0.5pt),
    table.vline(x:6, start:1, end:2, stroke:0.5pt),
    table.vline(x:7, start:1, end:2, stroke:0.5pt),
    table.vline(x:8, start:1, end:2, stroke:0.5pt),
    [\[31:27\]], [], [], [\[24:20\]], [\[19:15\]], [\[14:12\]], [\[11:7\]], [\[6:0\]], table.hline(stroke:0.5pt),
    [funct5], [aq], [rl], [rs2], [rs1], [funct3], [rd], [opcode], table.hline(stroke:0.5pt),
    [#align(center)[5]], [], [], [#align(center)[5]], [#align(center)[5]], [#align(center)[3]], [#align(center)[5]], [#align(center)[7]],
  ),
  caption: [Complex table]
)

== Boxes

Highlight key points with these fun boxes (and more):

#table(
  columns: 2,
  stroke: none,
  [ #infobox()[Infobox: For highlighting information.] ],
  [ #ideabox()[Ideabox: Share a brilliant idea.] ],
  [ #warningbox()[Warningbox: Proceed with caution!] ],
  [ #firebox()[Firebox: This is 🔥!] ],
  [ #rocketbox()[Rocketbox: Shoot for the moon!] ],
  [ #todobox()[Todobox: Just do it!] ],
  )

== Citations, Acronyms and Glossary

Add citations with `@` like @zahnoDynamicProjectPlanning2023 (stored in `/tail/bibliography.bib`).

Acronym terms like #gls("it") expand on first use and abbreviate after #gls("it"). Glossary items such as #gls("rust") can also be used to show their description as such: #gls-description("rust"). Acronyms and glossary entries auto-generate at the document’s end (defined in `/tail/glossary.typ`).

#pagebreak()

== Code

Besides writing inline code as such #raw(lang:"rust", "fn main() { println!(\"Hello World\") }") you can also write code blocks like this:

#figure(
  sourcecode()[
    ```rust
fn main() {
  let ship = Starship::new("USS Rustacean", (0.0, 0.0, 0.0));
  let destination = (42.0, 13.0, 7.0);
  let warp = ship.optimal_warp(ship.distance_to(destination));

  println!("🖖 {} traveling to {:?} at Warp {:.2}", ship.name, destination, warp);
  if warp <= 9.0 {
    println!("✨ Warp engaged!");
  } else {
    println!("⚠️ Warp failed!");
  }
}
```],
  caption:"First part of the USS-Rustacean code",
)
or directly from a file
#let code_sample = read("/resources/code/uss-rustacean.rs")
#figure(
  sourcecode()[
    #raw(code_sample, lang: "rust")
  ],
caption: [Second part of the USS-Rustacean code from `/resources/code/uss-rustacean.rs`]
)
