# unofficial-ukw-thesis

## English

Typst template for bachelor's and master's theses in **Game Studies and Design**
(Faculty of Cultural Studies, Kazimierz Wielki University in Bydgoszcz), compliant with
the *Diploma Regulations* approved by the College I Council on 27 January 2026.

### Quick start

```bash
typst init @preview/ukw-bipg-thesis:0.1.0 my-thesis
cd my-thesis
typst watch main.typ
```

### What the template handles automatically

| Regulation requirement | Implementation |
|---|---|
| §2(1) — Polish or English | `lang: "pl"` / `"en"` (also switches the names of the lists) |
| §2(2) — A4, Times New Roman 12 pt, 1.5 line spacing, 2.5 cm margins, justified | `page` / `text` / `par` settings |
| §2(3) — double-sided printing | two-sided layout; `draft: true` while writing |
| §2(4) — uniform pagination, continuous footnotes, chapters starting on odd pages | `heading` + `pagebreak(to: "odd")`, `footnote` with continuous numbering |
| §2(5)(a) — title page (Appendix 2) | generated from metadata |
| §2(5)(b) — table of contents | `outline` |
| §2(5)(d) — bibliography | `bibliography-file` (BibTeX/Hayagriva) |
| §2(5)(e) — lists of figures, tables and charts | `list-of-figures`, `list-of-tables` |
| §2(5)(f) — abstract and keywords (Appendix 3) | `abstract`, `keywords` + 1000-character counter |
| §2(5)(g) — author's declaration (Appendix 1) | generated from metadata |

Print control numbers (§2(3)(a)) come from the APD system — they are added to the file
downloaded from APD, not in Typst.

### `ukw-thesis` parameters

`title`, `subtitle`, `author`, `album`, `supervisor`, `field`, `study-type`,
`degree` (`"bachelor"` | `"master"`), `year`, `lang`, `abstract`, `keywords`,
`bibliography-file`, `bibliography-style`, `list-of-figures`, `list-of-tables`, `draft`.

### Practical notes

- **Font**: if Times New Roman is not available on your system, the template falls back to
  TeX Gyre Termes (metrically compatible). For printing, it is worth compiling with TNR
  installed: `typst compile --font-path ./fonts main.typ`.
- **Printing**: before submission, set `draft: false` so that chapters begin on odd pages
  and blank verso pages are inserted correctly.
- **AI**: the use of artificial intelligence tools is governed by separate KWU regulations
  (Order No. 34/2025/2026 of the KWU Rector) — the template takes no stance on this.
- **Appendices**: `#zalacznik(1, "Title")[content]`.

## Polish

Szablon Typst pracy licencjackiej i magisterskiej dla kierunku **Badanie i Projektowanie Gier**
(Wydział Nauk o Kulturze, Uniwersytet Kazimierza Wielkiego w Bydgoszczy), zgodny z
*Regulaminem dyplomowania* zatwierdzonym przez Radę Kolegium I 27 stycznia 2026 r.

### Szybki start

```bash
typst init @preview/ukw-bipg-thesis:0.1.0 moja-praca
cd moja-praca
typst watch main.typ
```

### Co szablon robi automatycznie

| Wymóg regulaminu | Realizacja |
|---|---|
| §2 ust. 1 — język polski albo angielski | `lang: "pl"` / `"en"` (przełącza też nazwy spisów) |
| §2 ust. 2 — A4, Times New Roman 12 pkt, interlinia 1½, marginesy 2,5 cm, justowanie | ustawienia `page` / `text` / `par` |
| §2 ust. 3 — wydruk dwustronny | układ dwustronny; `draft: true` na czas pisania |
| §2 ust. 4 — jednolita numeracja, ciągłe przypisy, rozdziały od strony nieparzystej | `heading` + `pagebreak(to: "odd")`, `footnote` z numeracją ciągłą |
| §2 ust. 5a — strona tytułowa (zał. 2) | generowana z metadanych |
| §2 ust. 5b — spis treści | `outline` |
| §2 ust. 5d — spis literatury | `bibliography-file` (BibTeX/Hayagriva) |
| §2 ust. 5e — spisy rysunków, tabel, wykresów | `list-of-figures`, `list-of-tables` |
| §2 ust. 5f — streszczenie i słowa kluczowe (zał. 3) | `abstract`, `keywords` + licznik 1000 znaków |
| §2 ust. 5g — oświadczenie autora (zał. 1) | generowane z metadanych |

Numery kontrolne wydruku (§2 ust. 3a) pochodzą z systemu APD — dodaje się je do pliku
pobranego z APD, a nie w Typście.

### Parametry `ukw-thesis`

`title`, `subtitle`, `author`, `album`, `supervisor`, `field`, `study-type`,
`degree` (`"bachelor"` | `"master"`), `year`, `lang`, `abstract`, `keywords`,
`bibliography-file`, `bibliography-style`, `list-of-figures`, `list-of-tables`, `draft`.

### Uwagi praktyczne

- **Czcionka**: jeśli w systemie nie ma Times New Roman, szablon użyje TeX Gyre Termes
  (metrycznie zgodny). Do wydruku warto skompilować z zainstalowanym TNR:
  `typst compile --font-path ./fonts main.typ`.
- **Wydruk**: przed oddaniem ustaw `draft: false`, aby rozdziały zaczynały się od strony
  nieparzystej, a puste strony wersa były poprawnie wstawione.
- **AI**: wykorzystanie narzędzi sztucznej inteligencji regulują odrębne przepisy UKW
  (Zarządzenie Nr 34/2025/2026 Rektora UKW) — szablon niczego tu nie przesądza.
- **Załączniki**: `#zalacznik(1, "Tytuł")[treść]`.

Licencja: MIT-0.
