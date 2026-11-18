# kindling-packing-list

Print a one-page camping packing list from a plain-text `.camp` checklist. The
sheet shows a water estimate for your group, packed items ticked and struck
through, and blank lines for the things you think of at the last minute.

![A printed packing sheet: trip header, water estimate, six sections in two columns and blank "Also bring" lines](thumbnail.png)

## Quick start

Start a new project from the template. In the web app, click *Start from template*
and search for `kindling-packing-list`. With the CLI, run:

```
typst init @preview/kindling-packing-list:0.1.0 my-trip
```

Then edit `trip.camp`:

```text
# Fire
- [x] Stove
- [ ] Fuel (one more canister than you think you need)
# Water
- [ ] Water (about 1 gallon per person per day for drinking and washing, more in heat - Ready.gov)
```

A line that starts with `#` is a section. `- [ ] item` is still to pack, and
`- [x] item` is packed. `*` and `+` bullets work too, and you can indent items.
This is the same `.camp` format the CampChecklist editor packages use, so a list
you keep in VS Code, Sublime Text or Vim prints as it is.

## Use it in your own document

```typ
#import "@preview/kindling-packing-list:0.1.0": packing-sheet, starter-list

#packing-sheet(
  camp: read("trip.camp"), // or starter-list
  trip: "Lake weekend",
  dates: "Fri - Sun",
  people: 4,
  days: 2,
  hot: true,               // adds 50% to the water estimate
  extra: 6,                // rows of blank lines
  notes: [Check the campground's food storage and fire rules.],
)
```

| Parameter | Default | Meaning |
|---|---|---|
| `camp` | `starter-list` | `.camp` text |
| `trip`, `dates` | `"Camping trip"`, `none` | header |
| `people`, `days`, `hot` | `2`, `2`, `false` | water estimate: about 1 US gallon per person per day (Ready.gov), +50% when `hot` |
| `columns` | `2` | Whole sections are kept together and spread so the columns end at similar heights |
| `extra` | `0` | rows of blank checkbox lines under "Also bring" |
| `notes` | `none` | content shown in a box at the bottom |
| `accent` | dark green | colour for headers, boxes and rules |

The building blocks are exported too:

- `parse-camp(text)` gives an array of `(title, items)` sections.
- `progress(sections)` gives `(packed, total)`.
- `status-text(packed, total)` gives a line like "Packed 12/22 (55%)".
- `water-estimate(people:, days:, hot:)` gives gallons and liters.
- `checklist(sections, columns:)` draws the sections only, without the header.

## The starter list

`starter-list` is a car-camping kitchen list with 19 items in six sections:
Fire, Cold, Water, Prep, Clean and Store. Each number in it names its source:

- keep the cooler at 40F / 4C or below (USDA);
- about 1 gallon of water per person per day (Ready.gov);
- about 1 tablespoon of unscented bleach per gallon to sanitize (CDC);
- food storage in bear country (NPS).

Rules differ by park, so check your campground's rules before a trip. The list
follows the camp kitchen guides at [Camp Kitchen US](https://campkitchen.us/).

## License

MIT. Made by Camp Kitchen US with AI assistance (Claude). The parser is checked
by the assertions in `tests/test.typ`. The template was compiled and
checked visually with Typst 0.15.
