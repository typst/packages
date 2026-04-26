# 0.3.0
Fixes:
- Decoupled parsed typst version from typst version used to run mephistypsteles.
	See the README for the new version compatibility table.
Breaking changes:
- Updated the parser to typst 0.13.0
- Fixed `parse` and `operator-info` not validating the type of their positional argument.
	They now panic when it isn't a `str`.
Additions:
- Added an example illustrating a new syntax node

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
