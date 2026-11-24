# satz

A Typst document class for everyday documents — letters, invoices, reports, journals, and grant proposals.

Inspired by KOMA-Script, **satz** provides a unified configuration system (`defaults.typ` + `class.typ`) with per-template wrapper functions, so all your documents share a consistent look without repeating yourself.

## Quick Usage

```typst
#import "@preview/satz:0.1.1": report
#show: report.with(config: (
  typography: (font: "Libertinus Serif"),
  lof: (compact: true), // List of Figures shows only "Figure 1 .... 5"
))

= My Report
...
```

```typst
#import "@preview/satz:0.1.1": journal-entry
#show: journal-entry.with(
  title: "Experiment 42",
  date: "2025-03-15",
  keywords: "synthesis, characterization",
)

...
```

## Templates

| Template | Function | Description |
|---|---|---|
| **letter** | `brief(absender, empfaenger, datum, betreff, lang:, body)` | DIN 5008 conform letter with fold/punch marks. Supports `lang: "de"` / `"en"` for localized labels. Structured recipient fields: `name`, `zusatz`, `strasse`, `plz_ort`, `land`. |
| **invoice** | `rechnung(absender, empfaenger, datum, posten, qr:, qr-betrag:, qr-verwendungszweck:, body)` | German invoice adapted from the letter template. Optional EPC QR code (GiroCode) — banking apps auto-fill transfer details. |
| **journal** | `journal-entry(..)`, `journal-index(..)` | Research diary with entries, keywords, and auto-generated monthly index |
| **report** | `report(body, config: (:))` | Scientific articles, protocols, thesis — numbered headings, auto TOC/LoF/LoT, two-sided layout, bibliography |
| **dfg-proposal** | `dfg-proposal(...)` | DFG form 53.01 (Sachbeihilfe) in German and English — **work in progress** |
| **legal-complaint** | `klageschrift(...)` | Formal complaint for submission to German courts (ZPO) — Rubrum, Streitwert, Anlagen |
| **gastspielvertrag** | `gastspielvertrag(...)` | Guest performance contract (§1–8, transport, buy-out, 3 doc modes) |
| **cover** | `cover-page(...)` | Composable cover page with logos/body/footer slots |

Stable: letter, invoice, journal, report, cover, legal-complaint, gastspielvertrag. Experimental: dfg-proposal, article mode.

### Letter — Internationalization

The `brief()` function accepts `lang: "de"` (default) or `"en"`:
- Labels for phone, email, date, attachments, page numbers switch language
- Text language is set accordingly for hyphenation rules

### Invoice — EPC QR Code

Set `qr: true` (default) to embed a scannable GiroCode:
- Encodes IBAN, BIC, amount (auto-calculated from line items or overridden via `qr-betrag`), and purpose (`qr-verwendungszweck`)
- Banking apps (e.g. N26, Sparkasse) auto-fill transfer details when scanned

## Structure

satz is built around the shared document class `class.typ:personal()`. It reads defaults from `defaults.typ` and accepts per-document overrides through a `config` dictionary (deep merge — nested dicts are merged, not overwritten).

```
lib.typ              ← public API
defaults.typ         ← unified defaults + merge()
class.typ            ← personal() + satz-figure
citation.typ         ← citepre() — author-year cite without parens
cover.typ            ← cover-page() — logos/body/footer slots
letter/              ← brief() — DIN 5008 letter, i18n (de/en)
invoice/             ← rechnung() — German invoice, EPC QR code
journal/             ← journal-entry / journal-index + remember/question
report/              ← report() — thin wrapper around personal(kind: "report")
dfg-proposal/        ← dfg-proposal — 53.01 (WIP)
legal-complaint/     ← klageschrift — ZPO
gastspielvertrag/    ← gastspielvertrag — guest performance contract
```

## Configuration

Override only what you need — everything else keeps its default:

```typst
#show: report.with(config: (
  typography: (font: "EB Garamond"),
  colors: (brand-primary: blue),
  lof: (compact: true), // hide caption text in List of Figures
))
```

Available sections (see `defaults.typ` for every key): `page`, `typography`, `headings`, `decorative`, `page-footer`, `links`, `tables`, `captions`, `toc`, `lof`, `lot`, `bibliography`, `colors`.

For long captions use `satz-figure` — long text under the figure, short title in the List of Figures (or `short-caption: []` for compact):

```typst
#import "@preview/satz:0.1.1": satz-figure
#satz-figure(image("plot.png"), caption: [Very long ...], short-caption: [Short title])
```

## License

MIT
