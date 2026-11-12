# Changelog

## 0.2.1

- First version on Typst Universe.
- The template (`template/`) is under MIT-0 (`license = "MIT AND MIT-0"`), so
  decks made from it need no licence notice; the rest stays MIT.
- Needs Typst 0.15.1 or newer (`compiler = "0.15.1"`), the version it is
  tested with.
- The examples import `@preview/flipside`; the README and the manual link to
  the examples and the manual of this version on GitHub; development notes
  moved to `CONTRIBUTING.md`.

## 0.2.0

- **Both directions:** `dir: "forward"` (default), `"reverse"` or `"both"`, for
  the deck, a card, or the cards below an entry `(dir: …),`; `--input dir=…`.
  Cards have `c.direction`, `c.front-lang` and `c.back-lang` for the slots.
- **Several items on a side:** `all[…][…]` (as the question one card, as the
  answer all needed) and `any[…][…]` (as the question one card per item, as
  the answer any one right); `a: "all"` / `a: "any"` to mix. `count:` sets
  what the question shows when more than 2 items are needed.
- **Shown only as question or only as answer:** `[? …]` and `[! …]` as plain
  text, `#q-only[…]`, `#a-only[…]`; notes `#note[…]`, `#q-note[…]`,
  `#a-note[…]`.
- **Layout `"report"`** for the MyCards app: the cards as metadata
  `<flipside-cards>` and every picture on a page of its own.
- Card numbers, `only` and the list count the printed cards (after
  directions and items).
- Card content can no longer make its row taller when it is too large for the
  card (`fit: false`, Typst 0.15).
- CSV cells read as markup (`markup: true`) know the new functions.

## 0.1.0

First version: double-sided cards in DIN, US, business-card and custom
sizes on A4 or Letter; list, calibration sheet, `only`, CSV, header and
footer slots, stripes, `fit`.
