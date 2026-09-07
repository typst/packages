# procedure-checklist

A simple, dotted-leader checklist layout for aircraft (or other) procedure
checklists, built for Typst. Optimized for A4 and A5 paper, with optional
two-column layout, checkboxes, numbered steps, and highlighted
warning/caution boxes.

<img src="https://github.com/Dottellini/procedure-checklist/blob/main/thumbnail.png?raw=true" alt="Example image of the Template" style="width:50%; height:auto;">

## Usage

```typ
#import "@preview/procedure-checklist:0.1.0": *

#show: checklist.with(
  title: "Cessna 152 Checklist",
  subtitle: "For flight simulation use only",
  paper: "a4",       // or "a5"
  accent: rgb("#1b3a6b"),
)

#section("Before Starting Engine")[
  #item("Parking Brake", "SET")
  #item("Fuel Shutoff Valve", "ON")
]

#section("Engine Runup", keep-together: true)[
  #item("Magneto Check", "LEFT, RIGHT, BOTH")
  #sub[Verify max drop = 125 RPM & max diff = 50 RPM]
  #note[A short italic remark.]
  #warn[A highlighted note, e.g. a threshold to watch for.]
  #caution[A red-outlined warning for critical steps.]
]
```

Run `typst init @preview/procedure-checklist` to start a new project from
the bundled template.

## Reference

### `checklist(..)`

The page template. Wrap your document body with `#show: checklist.with(...)`.

| Argument    | Default      | Description |
|-------------|--------------|-------------|
| `title`     | `"Checklist"`| Document title, shown centered at the top. |
| `subtitle`  | `none`       | Small line under the title. |
| `paper`     | `"a4"`       | Any Typst paper size (e.g. `"a4"`, `"a5"`). |
| `cols`      | `auto`       | Column count; `auto` = 2 for A4, 1 for A5. |
| `landscape` | `false`      | Landscape orientation. |
| `accent`    | `black`      | Accent color for the title and rules. |
| `boxes`     | `false`      | Draw a checkbox before every item. |
| `base-size` | `auto`       | Base font size; `auto` scales with paper size. |
| `font`      | Arial/Helvetica/Liberation Sans/DejaVu Sans | Font fallback list. |
| `version`   | `none`       | Text shown bottom-left in the footer. |
| `footer`    | `none`       | Text shown bottom-center in the footer. |

### `section(title, ..)[body]`

A titled group of items.

- `numbered: true` numbers the items in this section (`1.`, `2.`, ...).
- `keep-together: true` prevents the section from splitting across
  columns or pages.
- `color:` overrides the heading color (e.g. red for an emergency section).
- `subtitle:` adds a small line under the section heading.

### `item(name, action)`

One checklist line: `name` on the left, a dotted leader, then `action` on
the right. Omit `action` for a plain line with no leader.

### `sub(body)`

An indented clarification line under an item.

### `note(body)`

A small italic remark.

### `warn(body)`

A highlighted note with a yellow background.

### `caution(body)`

A red-outlined warning box for critical steps.

## License

MIT
