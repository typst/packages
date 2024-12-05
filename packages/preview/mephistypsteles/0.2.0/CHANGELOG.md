# 0.2.0
Fixes:
- `let` no longer has two `kind` fields (which caused an error before).
Breaking changes:
- The structure of parsed `ImportItem`s was changed:
	- No more `original-name` (it's already given as part of `path`).
	- New `kind` (either `"simple"` or `"renamed"`)
	- `bound-name` is now only present when `kind: "renamed"`
- The `parse-flat` and `parse-markup` functions got unified into `parse`.
Additions:
- Expressions and flat nodes now have a `span` field describing their location in the source string.
