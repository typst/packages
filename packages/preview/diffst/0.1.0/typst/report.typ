#let _engine = plugin("../plugin.wasm")

#let diffst-report(
  old,
  new,
  old-label: "old",
  new-label: "new",
  ignore-whitespace: false,
  show-whitespace: false,
  algorithm: "histogram",
  inline: "words",
  unicode: true,
  semantic-cleanup: true,
) = {
  let options = json.encode((
    ignore_whitespace: ignore-whitespace,
    show_whitespace: show-whitespace,
    algorithm: algorithm,
    inline: inline,
    unicode: unicode,
    semantic_cleanup: semantic-cleanup,
  ))
  let report = json(_engine.diff(bytes(old), bytes(new), bytes(options)))

  report + (
    old: old-label,
    new: new-label,
    labels: (
      old: old-label,
      new: new-label,
    ),
    options: (
      ignore-whitespace: ignore-whitespace,
      show-whitespace: show-whitespace,
      algorithm: algorithm,
      inline: inline,
      unicode: unicode,
      semantic-cleanup: semantic-cleanup,
    ),
  )
}
