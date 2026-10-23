# beam-bnl

Community letterhead for Brookhaven National Laboratory, by Mark P. M. Dean.
This is a community template, not an institutionally endorsed template.
Requires Typst 0.14.0 or later. Code and starter files are licensed MIT-0.

## Quick start

After publication:

```sh
typst init @preview/beam-bnl:0.1.0 my-letter
cd my-letter
typst compile main.typ
```

Edit the starter's sender details and letter text. You must supply the logo yourself
using the instructions below; no BNL logo is distributed. The starter compiles
without a logo, signature, or bibliography. Arial is preferred, with Liberation
Sans as a fallback; fonts are not bundled.

## Options

Import `bnl-letter` from `@preview/beam-bnl:0.1.0` and apply it with
`#show: bnl-letter.with(...)`.

| Option | Default / behavior |
| --- | --- |
| `department` | Example department content |
| `address` | Example sender address content |
| `info` | Example name, title, group, and institution content |
| `comment` | `none`; optional subject or other content before the letter |
| `logo` | `none`; supply `image("bnl-logo.svg", width: 2.13in)` from your project |
| `signature` | `none`; caller-created content after the letter |
| `fontsize` | `10pt` |
| `headerfontsize` | `7pt` |
| `date` | `none` uses today; a `datetime` uses ordinal day formatting; custom content is displayed directly |
| `references` | `none`; caller-created bibliography content after sender information |
| `body` | Positional letter content, supplied by the show rule |

The layout uses US Letter paper, justified paragraphs, and current/total page
numbers. The department, logo, and address appear at the start of the letter.
Size supplied logo artwork to 2.13 inches wide and signatures to 1 inch wide:

```typ
#show: bnl-letter.with(
  logo: image("bnl-logo.svg", width: 2.13in),
  signature: image("my-signature.svg", width: 1in),
  references: bibliography("references.bib",
    style: "american-physics-society", title: "References"),
)
```

These expressions are evaluated in your project, so paths resolve to your files.
The bibliography file must contain entries corresponding to any citations used.

## Supply the logo

The package does not include or download a BNL logo. To add one:

1. Open the [BNL Brand Center logo page](https://www.bnl.gov/brandcenter/logo.php).
2. Under **Download RGB Color Logos**, download the **Horizontal RGB Logo (.svg)** (the page may label it “RBG”).
3. Save it as `bnl-logo.svg` beside your project's `main.typ`. In the Typst web app, upload the SVG into that project.
4. Uncomment the starter's logo line inside `bnl-letter.with(...)`:

```typ
logo: image("bnl-logo.svg", width: 2.13in),
```

The image is evaluated in your project, so its path resolves to your file.
Use the exact filename you saved. Leave `logo` unset (or set `logo: none`) to
compile without a logo. A missing file produces Typst's normal file-not-found
error when the image line is enabled.

Follow the [BNL logo use policy](https://www.bnl.gov/brandcenter/logo-policy.php)
and obtain any required approval. MIT-0 covers this package's code and starter;
it grants no rights to BNL branding or artwork you supply. No personal signature
is included. Replace example contact details before sending a letter.
