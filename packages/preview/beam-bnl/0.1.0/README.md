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

Edit the starter's sender details and letter text. The BNL logo is bundled and
displayed by default. No personal signature or external bibliography is needed. Arial is preferred, with Liberation Sans
as a fallback; fonts are not bundled.

## Options

Import `BNLletter` from `@preview/beam-bnl:0.1.0` and apply it with
`#show: BNLletter.with(...)`.

| Option | Default / behavior |
| --- | --- |
| `department` | Example department content |
| `address` | Example sender address content |
| `info` | Example name, title, group, and institution content |
| `comment` | `none`; optional subject or other content before the letter |
| `logo` | Bundled BNL logo; `none` hides it; custom content overrides it |
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
#show: BNLletter.with(
  logo: image("bnl-logo.svg", width: 2.13in),
  signature: image("my-signature.svg", width: 1in),
  references: bibliography("references.bib",
    style: "american-physics-society", title: "References"),
)
```

These expressions are evaluated in your project, so paths resolve to your files.
The bibliography file must contain entries corresponding to any citations used.

## Logo and institutional use

The bundled `assets/bnl_logo_horizontal_rgb.svg` is Brookhaven National
Laboratory artwork and is **not covered by MIT-0**. The thumbnail also depicts
that logo; MIT-0 does not grant rights to the depicted branding. No personal
signature is distributed.

Source: [BNL Brand Center](https://www.bnl.gov/brandcenter/logo.php).
Follow the [logo use policy](https://www.bnl.gov/brandcenter/logo-policy.php),
including appropriate approval. Download availability does not establish permission
to redistribute the logo. Redistribution permission for this public package still
needs to be documented before submission to Typst Universe. Its
[asset requirements](https://github.com/typst/packages/blob/9e740025a355c43453e5819ecf17c7e29487c84d/docs/licensing.md)
require a copyright-holder policy clearing distribution in the package.
The MIT-0 license applies to the template code and starter, and grants no rights
to BNL branding or supplied artwork. Do not send letters with example details.
 Local verification and submission
