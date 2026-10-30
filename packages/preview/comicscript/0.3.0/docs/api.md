# API reference

[README](../README.md) · [User guide](manual.md)

Import `lib.typ` as `hq`. English aliases are listed first. Both APIs produce
the **same dictionaries and arrays**, with Portuguese field names. Aliases do
not create a second model or translate document content.

`content` below means a Typst content block or string. Single-item arrays need
a trailing comma: `(item,)`. Row and panel children are positional arguments.

## Constructors

### `page` / `pagina`

```typst
hq.page(number, title: none, objective: none, status: none, notes: (), ..rows)
hq.pagina(numero, titulo: none, objetivo: none, estado: none, notas: (), ..linhas)
```

`number` is a positive integer. Supply at least one row. `title`, `objective`,
and `status` accept optional content. Page status is free-form metadata, such
as `"draft"`; it is not a note status and is not translated. `notes` is an array
of notes. Returns `tipo: "pagina"` with children in `linhas`.

### `row` / `linha`

```typst
hq.row(weight: 1, id: none, notes: (), ..panels)
hq.linha(peso: 1, id: none, notas: (), ..quadros)
```

Supply at least one panel. `weight` is a finite positive number. `id` is an
optional nonempty string; `notes` is an array of notes. Returns `tipo: "linha"`
with children in `quadros`.

### `panel` / `quadro`

```typst
hq.panel(visual, id: none, weight: 1, shot: none, composition: none,
  texts: (), notes: (), references: ())
hq.quadro(visual, id: none, peso: 1, plano: none, composicao: none,
  textos: (), notas: (), referencias: ())
```

Write the description as the trailing content block:

```typst
hq.panel(shot: "wide shot")[The workshop fills the frame.]
```

`visual` accepts content, including empty content `[]`. `shot` and `composition`
are optional content. `weight` and `id` follow the row rules. `texts` is an
ordered array of speech, caption, and sound elements; `notes` is an array of
notes. `references` is an array of content, such as strings, links, or images
supplied by the caller. Returns `tipo: "quadro"`.

### `speech` / `fala`

```typst
hq.speech(character, body, mode: "normal")
hq.fala(personagem, corpo, modo: "normal")
```

`character` and `mode` are nonempty strings; `body` accepts content. The English
wrapper maps `thought` → `pensamento`, `off-panel` → `fora de campo`, and
`whisper` → `sussurro`. Other mode strings pass through unchanged.
Returns `tipo: "fala"`, with `personagem`, `corpo`, and `modo`.

### `caption` / `legenda`, `sound` / `som`

```typst
hq.caption[The next morning...]
hq.sound[CRASH!]
```

Each accepts one content argument. These direct aliases return `tipo: "legenda"`
and `tipo: "som"`. Use captions for narration or text appearing in the setting.

### `note` / `nota`

```typst
hq.note(category, body, status: "open", author: none)
hq.nota(categoria, corpo, estado: "aberta", autor: none)
```

`category` is a nonempty string; `body` accepts content. `author` is an optional
nonempty string. Returns `tipo: "nota"` with canonical Portuguese category and
status values where a translation exists.

| English status | Canonical status |
| --- | --- |
| `open` | `aberta` |
| `resolved` | `resolvida` |
| `discarded` | `descartada` |

Other statuses are rejected by the canonical constructor. Portuguese status
values also work with the English wrapper.

| English category | Canonical category |
| --- | --- |
| `problem` | `problema` |
| `idea` | `ideia` |
| `alternative` | `alternativa` |
| `continuity` | `continuidade` |
| `subtext` | `subtexto` |
| `clue` | `pista` |
| `reference` | `referencia` |
| `decision` | `decisao` |
| `composition` | `composicao` |
| `technical` | `tecnica` |

Custom categories pass through unchanged and use the neutral note style.
Production filtering uses canonical categories rather than inferred meaning.

## Validation and rendering

### `validate` / `validar`

```typst
hq.validate(pages)
hq.validar(paginas)
```

Accepts a single page or an array. Checks page element types and duplicate
explicit IDs across all rows and panels in that collection; returns an array.
Constructors perform local type and structure validation. Use constructors
rather than manually editing their dictionaries.

### `render` / `renderizar`

```typst
hq.render(pages, mode: "script",
  note-statuses: ("open", "resolved", "discarded"), word-limit: 60,
  layout-width: 140mm, layout-height: 180mm, layout-summaries: true)

hq.renderizar(paginas, modo: "roteiro",
  estados-notas: ("aberta", "resolvida", "descartada"), limite-palavras: 60,
  largura-esquema: 140mm, altura-esquema: 180mm, resumos-esquema: true)
```

Returns formatted content. Calls validation before rendering.

| English option | Portuguese option | Meaning |
| --- | --- | --- |
| `mode` | `modo` | `script`/`roteiro`, `editorial`, `layout`/`esquema`, `production`/`producao` |
| `note-statuses` | `estados-notas` | Array of note statuses shown in editorial view |
| `word-limit` | `limite-palavras` | Positive integer review threshold, or `none` to disable it |
| `layout-width` | `largura-esquema` | Positive absolute length |
| `layout-height` | `altura-esquema` | Positive absolute length |
| `layout-summaries` | `resumos-esquema` | Boolean controlling layout summaries |

The English wrapper accepts English or Portuguese mode/status values.
Portuguese commands retain their original parameter names and values.
Editorial options control note visibility and warnings; layout options control
geometry. Production always uses its own technical-note filter and omits
editorial warnings.

## Reports

All reports accept one page or an array, validate that collection, and return
formatted content with a report heading.

| English signature | Portuguese signature | Output |
| --- | --- | --- |
| `narrative-map(pages)` | `mapa-narrativo(paginas)` | Page number, panel count, title, objective, and status |
| `pending-notes(pages)` | `pendencias(paginas)` | Open notes at page, row, and panel levels |
| `dialogues(pages, character: none)` | `dialogos(paginas, personagem: none)` | Speeches, including thoughts; optional exact character-name filter |
| `text-report(pages, word-limit: 60)` | `relatorio-textos(paginas, limite-palavras: 60)` | Text-element and static-word counts per panel |

`character: none` includes all characters. Captions and sounds are excluded
from dialogue reports and included in text reports. `word-limit: none` keeps
counts without the review marker. See the guide for counting limitations.

## Mixing languages

```typst
#let p = hq.page(1, hq.row(hq.quadro[Uma porta.]))
#hq.renderizar(p, modo: "editorial")
```

Use the parameter names belonging to the function you call. Data fields remain
Portuguese, for example `p.linhas`, `row.quadros`, and `note.estado`; English
property aliases are not provided. Neither API translates the PDF interface.
