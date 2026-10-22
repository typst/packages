# ls3-uni-stuttgart-dissertation

Doctoral dissertation template of the Department of Stochastic
Simulation and Safety Research for Hydrosystems, LS3, at the Institute
for Modelling Hydraulic and Environmental Systems, University of
Stuttgart. It follows the Promotionsordnung der Universität Stuttgart of
1 March 2019 with its Merkblatt and the layout of the IWS
Mitteilungshefte 286 to 319. English or German, two-sided, with title
page per Anlage 1, front matter, appendix, Lebenslauf, and the VLB page
for the printed Heft.

## Start a dissertation

In the typst.app web app, choose "Start from template" and search for
`ls3-uni-stuttgart-dissertation`. On your own machine, run

```bash
typst init @preview/ls3-uni-stuttgart-dissertation:0.1.0 my-dissertation
```

Then open `main.typ`, fill in your metadata, and write your chapters in
`chapters/`.

## Manuscript and print

`paper: "a4"` sets the manuscript you submit to the faculty, with 12pt
text and roughly 1.5 line spacing. `paper: "a5"` sets the layout of the
printed Mitteilungsheft. Everything else stays the same, so one source
gives both versions.

Keep `status: "submitted"` until the Promotionsausschuss accepts the
dissertation. The title page then reads "eingereichte Abhandlung"
without the exam date, and the Lebenslauf is included. With
`status: "accepted"` it reads "genehmigte Abhandlung" with the date of
the oral exam, and the Lebenslauf is left out, as in the published
Hefte.

For the printed Heft, set `vlb` with the Heft number and ISBN from the
institute. The template then leaves a blank verso after the title page
and a blank recto for the series title page from the institute's Word
template, followed by the VLB/D93 page.

```typst
#show: dissertation.with(
  paper: "a5",
  status: "accepted",
  vlb: (heft: "320", isbn: "978-3-910293-00-0", printer: "..."),
  // ...
)
```

## Font

The template uses TeX Gyre Heros, a free Helvetica clone. The typst.app
web app has it built in. On your own machine, install it from
[CTAN](https://ctan.org/pkg/tex-gyre-heros). `body-font: "serif"` sets
the body in New Computer Modern, which ships with Typst, and keeps the
headings in sans.

## Parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `title` | `[]` | Dissertation title, may use `\` for line breaks |
| `author` | `""` | Your full name |
| `birthplace` | `""` | Shown as "aus ..." on the title page |
| `year` | `""` | Year of publication |
| `language` | `"english"` | `"english"` or `"german"` |
| `paper` | `"a4"` | `"a4"` for the manuscript, `"a5"` for the print |
| `status` | `"submitted"` | `"submitted"` or `"accepted"` |
| `degree` | `"dr-ing-male"` | `"dr-ing-male"`, `"dr-ing-female"`, `"dr-rer-nat-male"`, or `"dr-rer-nat-female"` |
| `degree-phrase`, `awarded-by` | `auto` | Replace the degree wording or the whole awarding phrase |
| `faculty` | `auto` | Bau- und Umweltingenieurwissenschaften, or your own string |
| `institute` | `auto` | IWS, or your own string |
| `simtech` | `false` | `true` adds the Stuttgart Center for Simulation Science |
| `hauptberichter` | `""` | Name of the main referee |
| `mitberichter` | `()` | Array of co-referee names |
| `exam-date` | `""` | Date of the oral exam, shown once `status` is `"accepted"` |
| `abstract-en`, `abstract-de` | `none` | English Abstract and German Zusammenfassung, both required |
| `summary`, `zusammenfassung` | `none` | Optional extended summaries |
| `danksagung` | `none` | Optional acknowledgements |
| `declaration` | `false` | `true` adds the Erklärung per § 6 (2) |
| `abbreviations`, `notation` | `none` | Optional front matter chapters |
| `bib` | `none` | A `bibliography(...)` element |
| `appendix` | `none` | Chapters lettered A, B, ... after the bibliography |
| `lebenslauf` | `none` | One page at most, printed only while `status` is `"submitted"` |
| `vlb` | `none` | Dictionary with `heft`, `isbn`, `printer` and optionally `series`, `author-sort`, `publisher` |
| `body-font` | `"sans"` | `"sans"`, or `"serif"` for a LaTeX-like body |
| `heading-rule` | `false` | `true` draws a thin blue rule below every chapter heading |

## Check with the faculty

Two points follow common practice rather than a written rule. Ask the
Fakultät 2 office if in doubt.

- The submitted title page reads "Bei der Fakultät ... eingereichte
  Abhandlung", from the old LaTeX template. The faculty's own title page
  template only shows "Von der Fakultät ... genehmigte Abhandlung".
  Pass `awarded-by` to use other wording.
- Fakultät 2 asks for a German and an English summary of two to four
  pages each. The template treats the two abstracts as these summaries,
  as all IWS Hefte from 286 to 319 do. `summary` and `zusammenfassung`
  add extended summaries if you need them.

## License

The package is MIT licensed, see `LICENSE`. Source, issues, and pull
requests live at
[LS3-university-of-stuttgart/ls3-typst-templates-public](https://github.com/LS3-university-of-stuttgart/ls3-typst-templates-public). The files in `template/`,
which `typst init` copies into your project, are under MIT-0, so your
dissertation carries no license obligations.

## Changelog

### 0.1.0

First release on Typst Universe. A4 manuscript and A5 print from one
source, title page per Anlage 1 of the Promotionsordnung, and the
VLB/D93 page for the printed Heft. Page layout, running header, title
page, and front matter order follow the IWS Mitteilungshefte. Code listings use codly 2.0.0, so the template needs
Typst 0.15.0 or newer.
