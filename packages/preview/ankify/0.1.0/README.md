> **Warning**: `ankify` is in alpha and under active development. Expect bugs,
> rough edges, and breaking changes between releases.

`ankify` lets you mark up [Anki](https://apps.ankiweb.net) flashcards inline as
you write Typst. Its companion **`ankify` command-line tool** then renders each
card and syncs it to Anki. Take your notes once, in Typst, and get
spaced-repetition flashcards out of them with very little extra effort.

> **Important** — this Typst package only *records* flashcards, as document
> metadata; on its own it produces no visible output. The
> [`ankify` CLI](https://github.com/nvlang/ankify) does the actual rendering and
> syncing — you need both.

## Usage

```typ
#import "@preview/ankify:0.1.0": note, configure

#configure(defaults: (deck: "My Course"))

#note(
  "pythagoras",
  data: (Front: "What is the Pythagorean theorem?", Back: [$a^2 + b^2 = c^2$]),
)
```

Then run `ankify notes.typ` with the CLI to push the cards to Anki.

### The helper pattern

`note()` produces no visible output, so it shines when called from a helper
that *also* typesets the item — then every use of that helper becomes a card:

```typ
#let definition(label, term, body) = {
  note(label, data: (Front: [Define: #term], Back: body))
  block(inset: 8pt, stroke: 0.5pt)[*Definition (#term).* #body]
}

#definition("def-continuity", "continuity")[
  A function $f$ is continuous at $a$ if $lim_(x -> a) f(x) = f(a)$.
]
```

Write your notes as usual; each `definition(...)` both typesets the definition
*and* yields a flashcard.

## API

### `note(label, ..)`

| Parameter | Meaning | Default |
|---|---|---|
| `label` *(positional)* | Unique identifier; the card's sync key. | — |
| `data` | Dictionary of Anki field name → content or string. | — |
| `deck` | Target Anki deck. | `"Default"` |
| `model` | Anki note type. | `"Basic"` |
| `tags` | Array of tag strings. | `()` |
| `format` | `"svg"`, `"png"`, or `"plain"` — how the fields render. | `"svg"` |
| `other` | Extra metadata passed through to AnkiConnect. | `none` |
| `render` | Function transforming each field before it is rendered (advanced). | identity |

A field's value may be a string, Typst content, or a `(value, format)`
dictionary that overrides the format for that one field. `svg` cards are
rendered as scalable, theme-aware images; `plain` fields are sent as text.

### `configure(..)`

Optional document-wide settings — call it once near the top of the document:

```typ
#configure(
  scale: 1.5,
  defaults: (deck: "My Course", tags: ("lecture",), format: "svg"),
)
```

`scale` enlarges every rendered card image; `defaults` supplies the fallback
`deck`, `model`, `tags`, and `format` used by every `note()` that does not set
its own.

### `basic` and `cloze`

Shorthands for the two most common card shapes:

```typ
#basic("fr-capital", "Capital of France?", "Paris")
#cloze("jp-capital", "The capital of Japan is {{c1::Tokyo}}.")
```

## The full workflow

Installing the CLI, setting up the [AnkiConnect](https://foosoft.net/projects/anki-connect/)
add-on, and the incremental sync workflow are all described in the
[project README](https://github.com/nvlang/ankify).

## License

MIT — see [LICENSE](LICENSE).

## Trademarks

Anki is a trademark of Ankitects Pty Ltd. `ankify` is an independent project,
not affiliated with, endorsed by, or sponsored by Ankitects Pty Ltd.
