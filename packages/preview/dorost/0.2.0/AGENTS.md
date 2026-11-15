# Repository guidance

- Keep Dorost independent of document use cases and institutions.
- Treat `lib.typ` as the public API boundary; export names explicitly.
- Prefer native Typst features over parallel component systems.
- Keep language, direction, fonts, and numeral formatting independently configurable.
- `document(direction:)` accepts `"ltr"` or `"rtl"`; `ltr` and `rtl` are content wrappers.
- Persian digit conversion must be explicit; never mutate code, URLs, math, or arbitrary content.
- Add a focused fixture before changing behavior; run `./scripts/check.sh`.
- Keep font binaries limited to documented test fixtures under `tests/fonts/`; the Typst package excludes tests. Preserve upstream licenses and provenance.
- Keep the package pure Typst; avoid adding a Rust runtime or unrelated dependencies.
