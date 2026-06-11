# ITU Thesis Template (Typst) · `community-itu-thesis`

A Typst template for graduate (master's and doctoral) theses at Istanbul
Technical University (İTÜ), ported from the official LaTeX class (`itutez.cls`
v1.7.1, January 2025). The thesis output itself is in Turkish (with optional
English language mode), since that is the intended audience.

> ⚠️ **Unofficial community port.** This package is not officially endorsed by
> Istanbul Technical University; it is an independent, volunteer adaptation of
> the official LaTeX class. Always verify the output against the current
> official ITU thesis guidelines before submitting your thesis.

## Quick start

```bash
typst init @preview/community-itu-thesis:0.1.0 my-thesis
cd my-thesis
typst watch main.typ
```

This creates a working sample project. Edit the information in `main.typ` to
match your own thesis.

## Features

- Outer cover + Turkish inner cover + English inner cover
- Jury approval / signature page
- Dedication, Foreword, Table of Contents, Abbreviations, Symbols
- List of Tables and List of Figures (automatic)
- Özet / Summary (Turkish and English abstracts)
- Roman page numbers (i, ii, …) in front matter, Arabic (1, 2, …) in the body
- Numbered chapters (“1. …”, with subheadings “1.1”, “1.1.1”) and unnumbered
  front/back-matter headings
- Appendices (with an "EKLER" cover page) and Curriculum Vitae
- NUM (numeric/IEEE) and APA citation styles — see `main.typ` and `main-apa.typ`
- Turkish and English language support (`dil: "tr"` / `dil: "en"`)

## Usage

The main parameters of the `#show: thesis.with(...)` call (parameter names are
in Turkish, matching the template API):

| Parameter | Description |
| --- | --- |
| `ad`, `soyad`, `ogrenci-no` | Student name, surname, and ID |
| `tez-basligi`, `thesis-title` | TR/EN title (up to 3 lines, as an array) |
| `anabilim-dali-tr/-en`, `program-tr/-en` | Academic department / program |
| `enstitu` | `"lisansustu"`, `"bilisim"`, `"fenbilimleri"`, `"sosyalbilimler"`, `"enerji"`, `"avrasya"` |
| `danisman`, `danisman-en`, `es-danisman*` | Advisor / co-advisor (TR & EN) |
| `juri` | Array of `(ad: "...", univ: "...")` dictionaries |
| `dil` | `"tr"` or `"en"` |
| `derece` | `"yukseklisans"` (master's) or `"doktora"` (doctorate) |
| `cilt` | `"bez"` (hardbound) or `"karton"` (softbound) |
| `ithaf`, `onsoz`, `kisaltmalar`, `semboller`, `ozet`, `summary`, `ekler`, `ozgecmis` | Front/back-matter content |
| `kaynakca` | `bibliography("refs.bib", style: "ieee", title: "Kaynaklar")` |

Body chapters (`= Giriş`, `== Alt başlık`, …) are written as ordinary Typst
headings after the `#show` call; they are numbered automatically.

### Citations and bibliography

Add BibTeX records to `refs.bib` and cite them in the text with `@key`. Choose
the style via the `kaynakca` parameter: `style: "ieee"` (numeric) or
`style: "apa"`.

## Notes

- The template targets the `Times New Roman` font; if it is not installed, it
  falls back to alternatives such as `TeX Gyre Termes` / `Libertinus Serif`.
  Installing Times New Roman is recommended for a faithful look.
- Typst does not support EPS; add figures as PNG/PDF/SVG.

## License

MIT — see [LICENSE](LICENSE).

Adapted from the official LaTeX thesis class prepared by the ITU Informatics
Institute.
