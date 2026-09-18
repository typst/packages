# tables — canonical correspondence data

`cnice` is a facade over two deterministic correspondence libraries.
Each keeps its canonical table and contract in its own subdirectory:

- `greet/` — German salutations (was the `cgreet` repo, `tables/de.json`).
  See `greet/README.md` for the schema and normative token normalization.
- `farewell/` — locale-specific valedictions (was the `cfarewell` repo,
  `tables/closing.json`). See `farewell/README.md` for the resolution rule.

`tests/vectors/` is the executable form of both contracts: a port is done
when every vector (131 total) passes.
