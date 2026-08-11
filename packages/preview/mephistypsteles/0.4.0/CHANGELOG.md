# 0.4.0
Breaking changes:
- There was a huge rewrite, so there have probably been some minor breaking
  behavior changes here and there.
- All `kind` fields now use kebab-case values instead of the previous PascalCase.
- Updated the parser to Typst 0.14.0. Some AST nodes changed their `kind`s (beyond becoming kebab-case):
	- `List`, `Enum` and `Term` are now `list-item`, `enum-item`, `term-item`
	- `Code` and `Content` are now `code-block` and `content-block`
	- `Let` is now `let-binding`
	- `DestructAssign` is now `destruct-assignment`
	- `Set` and `Show` are now `set-rule` and `show-rule`
	- `While` and `For` are now `while-loop` and `for-loop`
	- `Import` and `Include` are now `module-import` and `module-include`
	- `Break` and `Continue` are now `loop-break` and `loop-continue`
	- `Return` is now `func-return`
- Renamed the `flat` parameter of `parse` to `concrete`.
Additions:
- An explicit output schema for all three functions (see the README)
- `bare-name` field for `module-import` expressions
- New `public-api` function

# 0.3.0
Fixes:
- Decoupled parsed Typst version from Typst version used to run mephistypsteles.
	See the README for the new version compatibility table.
Breaking changes:
- Updated the parser to Typst 0.13.0
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
