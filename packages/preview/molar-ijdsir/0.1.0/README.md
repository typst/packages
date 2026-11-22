# molar-ijdsir

Unofficial Typst template for manuscripts submitted to the
**International Journal of Dental Science and Innovative Research (IJDSIR)**.
It reproduces the journal's Word template layout: US Letter, Times New Roman 11 pt, 1.5 line
spacing, two columns, the coloured masthead, footers and rotated page numbers. Lines break the way
Microsoft Word breaks them. A matching covering letter with the Annexure-I reviewer list is included.

This template is not affiliated with or endorsed by IJDSIR. Check the journal's current author
instructions before you submit.

## Usage

```sh
typst init @preview/molar-ijdsir:0.1.0
```

or in an existing document:

```typst
#import "@preview/molar-ijdsir:0.1.0": manuscript

#show: manuscript.with(
  title: [Title of Your Paper],
  authors: ((name: "First Author", aff: 1), (name: "Second Author", aff: 2)),
  affiliations: ("Department, College, City, Country", "Department, College, City, Country"),
  email: "first.author@example.com",
  corresponding: (name: "First Author", address: "…", phone: "…", email: "…"),
  conflicts: "Nil",
  keywords: ("First keyword", "Second keyword"),
  abstract: [Abstract text.],
)

= Introduction
Body text…
```

### Manuscript options

| Option | Description |
| --- | --- |
| `title`, `abstract` | Content |
| `authors` | `((name: "...", aff: 1), ...)`; superscripts are the author's position |
| `affiliations` | Array of strings; each is prefixed with the numbers of its authors |
| `email` | E-mail line under the affiliations |
| `corresponding` | `(name:, address:, phone:, email:)` |
| `conflicts` | Conflicts of interest (default `"Nil"`) |
| `keywords` | Array of strings |
| `running-author` | Page 2+ header name (default: first author) |
| `volume`, `issue`, `period`, `pages`, `year` | Masthead and footer details |
| `paper` | `"us-letter"` (default, as the journal's PDF) or `"a4"` |
| `logo` | Optional masthead logo, e.g. `image("logo.png")` |

Headings: `=` gives numbered sections ("1.", "2." …) and `==` gives lettered subsections. Figure captions read
"Fig. 1:", table captions go above the table, and `#bibliography` uses Vancouver style with
bracketed citations.

### Covering letter

```typst
#import "@preview/molar-ijdsir:0.1.0": covering-letter

#covering-letter(
  article-type: "Research Paper",
  manuscript-title: "Title of Your Paper",
  research-area: "Endodontics",
  support: "Self",
  conflicts: "Nil",
  author: (name: "First Author", institution: "...", country: "India",
           contact: "...", mobile: "...", email: "..."),
  place: "City", date: "1 January 2026",
  reviewers: ((name: "...", designation: "Professor", institution: "...",
               area: "...", contact: "...", email: "..."),),
)
```

Any field you leave out prints the journal's dotted blank. The journal's header artwork is not
included. To reproduce it exactly, pass `logo: image(...)` and `banner: image(...)`, and set
`title-font: "AR JULIAN"` and `contact-font: "Lucida Calligraphy"` if those fonts are installed.
Without them, the header uses Times New Roman.

## Fonts

Times New Roman (comes with Windows and macOS; on Linux install `ttf-mscorefonts`). In the
Typst web app, upload `times.ttf` and its bold/italic variants to your project. Otherwise the template
falls back to Times.

## Limitations

Typst can't give one page a different bottom margin from the others, so page 1 uses the same
bottom margin as later pages and holds one line fewer than the journal's Word file.

## License

MIT
