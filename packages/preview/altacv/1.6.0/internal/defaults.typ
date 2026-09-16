// Default labels — sourced from `labels-en.toml` so translators can
// edit a plain resource file rather than Typst source. The TOML is
// parsed at compile time and merged with caller overrides in `alta()`;
// unknown keys panic (`internal/validation.typ#_strict_merge`).

#let _default_labels = toml("labels-en.toml")
