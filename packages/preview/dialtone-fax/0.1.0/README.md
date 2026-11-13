<p align="center">
  <a href="https://faxforagents.com"><img src="https://faxforagents.com/brand/logo-512.png" width="88" alt="Fax for Agents"></a>
</p>

<h1 align="center">dialtone-fax</h1>

<p align="center">Typst pages that hold up on a fax machine: black on white, a cover block and a 10 pt floor under body text. From <a href="https://faxforagents.com">Fax for Agents</a>.</p>

<p align="center">
  <a href="https://faxforagents.com">Website</a> ·
  <a href="https://faxforagents.com/docs/">Docs</a> ·
  <a href="https://faxforagents.com/docs/send-fax/">Send a fax</a> ·
  <a href="https://faxforagents.com/pricing/">Pricing</a> ·
  <a href="https://faxforagents.com/changelog/">Changelog</a>
</p>

<div align="center">

[![MIT and MIT-0](https://img.shields.io/badge/licence-MIT%20%2F%20MIT--0-1f6feb)](LICENSE)

</div>

A fax page is a 1-bit image at 204 by 98 or 204 by 196 dots per inch. Grey turns to dots or disappears,
and small type breaks up. This template lays out a document with that in mind:

- a cover block with to, from, both fax numbers, the date, the page count and the subject
- black text on white, with no fills or tints by default
- a floor of 10 pt under text, footnotes and sub- and superscripts included (math and `scale` are not covered)
- margins for US Letter and A4
- a one-line footer with the page count and a link to faxforagents.com

It needs no network and no packages besides itself. It has been compiled with Typst 0.12.0, 0.13.1 and
0.15.1.

## Start a document

```sh
typst init @preview/dialtone-fax:0.1.0 my-fax
cd my-fax
typst compile main.typ
```

Or call it from your own file:

```typ
#import "@preview/dialtone-fax:0.1.0": fax

#show: fax.with(
  paper: "a4",
  to: [County Records Office],
  to-fax: [+1 202 555 0143],
  from: [Your name],
  from-fax: [+1 202 555 0188],
  subject: [Records request],
)

Dear records clerk,
```

## Options

| Option | Default | What it does |
|---|---|---|
| `to`, `to-fax`, `from`, `from-fax`, `subject` | `none` | Cover block fields. Empty fields stay blank. |
| `pages` | `auto` | Page count on the cover. `auto` counts the pages of this document, a cover page included. Pass a number if you add pages from elsewhere. |
| `date` | `auto` | `auto` is today as YYYY-MM-DD. Takes a `datetime` or any content. |
| `title` | `"Fax"` | The large word above the cover block. |
| `paper` | `"us-letter"` | `"us-letter"` or `"a4"`. Anything else stops the compile with a message. |
| `body-size` | `12pt` | Body text size. Below 10 pt stops the compile with a message. |
| `font` | `("Liberation Sans", "DejaVu Sans", "Noto Sans")` | Tried in order. Typst falls back to its own fonts when none is installed. |
| `cover` | `true` | `true` puts the block on page 1, `"page"` gives it a page of its own, `false` leaves it out. Anything else stops the compile. |
| `footer-link` | `true` | `false` keeps the page count and drops the faxforagents.com link. |

`cover-block` is exported on its own if you want the block without the page setup. `size-floor` is the
floor, 10 pt.

## Why 10 pt

We measured it. The [fax legibility bench](https://github.com/faxforagents/fax-legibility-bench) has
the code. It set one passage at 4 to 16 pt in four open fonts and read each page with OCR at both fax
resolutions. On 2026-11-08 every font read at 98% or better from 7 pt at standard resolution.

That was a clean simulation with no phone line, scanner or printer, so the floor sits 3 pt higher. The
post [The smallest font that survives a fax](https://faxforagents.com/blog/smallest-font-that-survives-a-fax/)
has the results and their limits.

Sub- and superscripts keep the full text size. Typst scales them after show rules run, so a smaller
size would slip under the floor. Two things are outside it: math, whose scripts Typst sizes on its own,
and anything inside `scale`. Keep both out of a fax page or check the result.

## What it does not do

A fill you pass directly to an element still applies. The template only sets the defaults to none.
Images are placed as you give them, so check a photo or a scan before you send it.

The template sends nothing. It makes a PDF.

The [send fax docs](https://faxforagents.com/docs/send-fax/) cover sending that PDF from code.
They show the upload, the quote and the send through the Fax for Agents API.

## Licence

The package is MIT. The files in `template/` are MIT-0, so a document you make from them carries no
notice. Both texts are in [LICENSE](LICENSE). Made by JSB Holdings LLC, the company behind
[Fax for Agents](https://faxforagents.com).
