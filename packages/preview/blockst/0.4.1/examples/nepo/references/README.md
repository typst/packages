# References

`blockly-reference.mjs` is a second, independent transcription of Open
Roberta's renderer — `core/renderCompute_`, `renderDrawTop_`,
`renderDrawRight_`, `renderDrawBottom_`, `renderDrawLeft_` from
[`core/block_render_svg.js`](https://github.com/OpenRoberta/blockly/blob/master/core/block_render_svg.js).

It exists so the Rust plugin has something to be wrong against. The two are
written in different languages from different descriptions of the same blocks:
the JavaScript builds its blocks from the official `blocks/*.js` definitions,
the Rust builds them from `scripts/nepo-wasm/data/blocks.toml`. Agreement
therefore also tests the catalog.

```bash
node examples/nepo/references/blockly-reference.mjs > reference.json
```

`fixtures.json` holds the source line for each case and a stipulated width for
every label. Both sides read it, so a difference in the results can only come
from geometry — never from a font.

This is not a substitute for comparing against Open Roberta Lab. It checks that
the transcription is consistent, not that the transcription is right. For that,
put a real screenshot into `../comparisons/index.html`.
