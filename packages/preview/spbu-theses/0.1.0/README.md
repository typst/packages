# spbu-theses

Typst package for research reports (НИР) and theses at Saint Petersburg State
University, formatted according to GOST 7.32-2017 and the SPbU AMath checklist.

Page margins (20/20/30/15 mm), centered page numbers (hidden on the title
page), 14 pt type, 1.5 line spacing, paragraph indent, «СОДЕРЖАНИЕ» with dot
leaders, «Рисунок 1 – …» / «Таблица 1 – …» captions, numbered formulas with
«где» explanations, footnotes, GOST-style bibliography, and Russian-alphabet
appendices (ПРИЛОЖЕНИЕ А with А.1 numbering) are all set up for you.

## Usage

Start a new document from the template:

```bash
typst init @preview/spbu-theses:0.1.0
cd spbu-theses
typst compile main.typ
```

Or use it directly as a package:

```typst
#import "@preview/spbu-theses:0.1.0": template, special-section

#show: template.with(
  title: [Тема научно-исследовательской работы],
  author: "Иванов Иван Иванович, группа 00.Б00-ПУ",
  supervisor: "Петров Пётр Петрович",
  supervisor-degree: "доцент",
  city: "Санкт-Петербург",
  year: "2026",
)

#special-section[ВВЕДЕНИЕ]
...
```

## API

- `template(...)` — main entry point; sets pages, text, headings, figures,
  tables, equations, footnotes and prints the title page and contents.
- `special-section[ВВЕДЕНИЕ]` — unnumbered centered structural heading
  (ВВЕДЕНИЕ, ЗАКЛЮЧЕНИЕ, СПИСОК ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ, ...).
- `toc()` — «СОДЕРЖАНИЕ».
- `appendix("А", "Заголовок")[...]` — appendix with Russian-alphabet numbering
  for figures, tables and equations inside.
- `glossary("НИР", падеж: "твор")` — acronym handling with Russian grammatical
  cases; in headings acronyms expand to their full form automatically.
- `init-acronyms(...)` — define acronyms with `long`, `short`, `long-pl`,
  `short-pl` and custom case forms (e.g. `твор`, `род`).

## License

MIT
