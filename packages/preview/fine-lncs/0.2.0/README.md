# fine-lncs

**fine-lncs** is a [Typst](https://typst.app) template that tries to closely replicate the look and structure of the official [Springer LNCS (Lecture Notes in Computer Science)](https://www.overleaf.com/latex/templates/springer-lecture-notes-in-computer-science/kzwwpvhwnvfj#.WuA4JS5uZpi) LaTeX template.

## Usage

```typst
#import "@preview/fine-lncs:0.2.0": lncs, institute, author, theorem, proof

#let inst_princ = institute("Princeton University", 
  addr: "Princeton NJ 08544, USA"
)
#let inst_springer = institute("Springer Heidelberg", 
  addr: "Tiergartenstr. 17, 69121 Heidelberg, Germany", 
  email: "lncs@springer.com",
  url: "http://www.springer.com/gp/computer-science/lncs"
)
#let inst_abc = institute("ABC Institute", 
  addr: "Rupert-Karls-University Heidelberg, Heidelberg, Germany", 
  email: "{abc,lncs}@uni-heidelberg.de"
)

#show: lncs.with(
  title: "Contribution Title",
  thanks: "Supported by organization x.",
  authors: (
    author("First Author", 
      insts: (inst_princ),
      oicd: "0000-1111-2222-3333",
    ),
    author("Second Author", 
      insts: (inst_springer, inst_abc),
      oicd: "1111-2222-3333-4444",
    ),
    author("Third Author", 
      insts: (inst_abc),
      oicd: "2222-3333-4444-5555",
    ),
  ),
  abstract: [
    The abstract should briefly summarize the contents of the paper in
    15--250 words.
  ],
  keywords: ("First keyword", "Second keyword", "Another keyword"),
  bibliography: bibliography("refs.bib")
)

# First Section

My awesome paper ...
```

### Local Usage

If you want to use this template locally, clone it and use [Typship](https://github.com/sjfhsjfh/typship) to install it using
```
typship install local
```
This allows you to import the template using 
```
#import "@local/fine-lncs:0.1.0": lncs, institute, author, theorem, proof
```

## Development

To work on this template locally, use [Typship](https://github.com/sjfhsjfh/typship) to simplify development.
Use `typship dev` to setup a symlink of this library in the local preview package directory.

For testing, the project uses [tytanic](https://github.com/tingerrr/tytanic).  
After installing `tytanic`, you can run all tests with:

```bash
tt run
```