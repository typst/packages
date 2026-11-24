# NEPO renderer

A growing set of Open Roberta Calliope/micro:bit beginner blocks rendered by
Blockst, plus the material for judging the geometry of the original reference
set.

```bash
./examples/nepo/comparisons/build.sh          # regenerate everything
open examples/nepo/comparisons/index.html     # side by side + overlay
```

The comparison page needs to be served rather than opened from disk if the
geometry table is to load — `python3 -m http.server` from the repository root,
then open `/examples/nepo/comparisons/index.html`. The block images work
either way.

## Files

| Path | What it is |
|---|---|
| `calliope-prototype.typ` | The original visual reference set, plus empty sockets |
| `beispielprogramme.typ` | Programme collection: every block and every nesting the renderer knows, from one line to full lessons |
| `conditions-reference.typ` / `inline-sockets-reference.typ` | Focused fixtures for nested conditions and inline sockets |
| `fehler-comparison.typ` | Six lesson examples, each beside its Open-Roberta screenshot (requires the local lesson assets) |
| `mixed-document.typ` | Scratch and NEPO in one document |
| `comparisons/index.html` | Reference \| Blockst \| overlay, per block |
| `comparisons/blocks.typ` | One block per page, source for the candidate SVGs |
| `comparisons/build.sh` | Regenerates candidates, reference data and the sheet |
| `references/blockly-reference.mjs` | Independent JS transcription of Blockly's renderer |
| `references/fixtures.json` | Stipulated text widths, shared by both sides |

## The reference column

The page ships with the Open Roberta column empty, because a faithful
reference has to come out of Open Roberta Lab itself. To fill it:

1. Open <https://lab.open-roberta.org> and pick **Calliope mini**.
2. Build the block — the German wordings the prototype uses are Open Roberta's
   own, so the toolbox entry is named exactly as the page's row heading.
3. Screenshot the block, or export the program and screenshot from the SVG.
4. Drag the image into the row's left cell. It appears in the overlay
   immediately and is remembered in the browser.

Then use the toolbar: **Skalierung** matches the screenshot's zoom to the
Blockst rendering, **Versatz** aligns the top-left corners, and **Deckkraft**
fades between them. Notches and baselines are where differences show first.

## What can be checked without a reference

The geometry table on the page compares the prototype's layout against an
independent transcription of `core/block_render_svg.js`. That catches a wrong
notch position or a mis-sized mouth without needing Open Roberta open, and it
runs automatically in `scripts/nepo-wasm/tests/test_geometry.rs`.

What it cannot catch is text width: the fixtures stipulate widths so that a
failure can only be geometric. Real widths depend on the reader's font, and
those are what the overlay is for.
