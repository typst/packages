#import "foundation/diagnostics.typ": _score-error
#import "foundation/parser.typ": _score-plugin
#import "score.typ": score

// MusicXML and ABC import through the WASM plugin.

#let _package-version = toml("../typst.toml").package.version

// Convert a MusicXML (.musicxml, .xml, compressed .mxl) or ABC file into
// typed-scores data. Pass the file's contents, preferably as bytes:
// `read-score(read("song.mxl", encoding: none))`.
//
// Returns a dictionary with
// - `arguments`: the `score()` arguments (staves, key, time, bars, ...),
// - `title`: the work title, or none,
// - `warnings`: notation that typed-scores could not reproduce,
// - `source`: an equivalent standalone Typst file to copy and edit.
#let read-score(source, format: auto, tune: none, name: none) = {
  let data = if type(source) == bytes { source } else if type(source) == str { bytes(source) } else {
    _score-error(
      "read-score",
      "source must be the file contents as bytes or a string",
      value: source,
      expected: "read(\"song.musicxml\", encoding: none)",
      fix: "pass the result of read() instead of the file path",
    )
  }
  let format = if format == auto { "auto" } else { format }
  if format not in ("auto", "musicxml", "abc") {
    _score-error(
      "read-score format",
      "unsupported import format",
      value: format,
      expected: "auto, \"musicxml\", or \"abc\"",
      fix: "omit format to detect it from the file contents",
    )
  }
  if tune != none and type(tune) not in (int, str) {
    _score-error(
      "read-score tune",
      "tune must be an ABC X: number",
      value: tune,
      expected: "an integer or string such as 12",
      fix: "pass the number that follows X: in the ABC file",
    )
  }
  if tune != none and (type(tune) == int and tune < 1 or type(tune) == str and tune.match(regex("^[0-9]+$")) == none) {
    _score-error("read-score tune", "tune must be a positive ABC X: number", value: tune, fix: "write a positive integer or its digits as a string")
  }
  if tune != none and format == "musicxml" {
    _score-error("read-score tune", "tune selection applies only to ABC", fix: "remove tune for a MusicXML score")
  }
  if name != none and type(name) != str {
    _score-error("read-score name", "name must be a string", value: name, fix: "pass the file name as text")
  }
  let options = (
    "format=" + format,
    "tune=" + if tune == none { "" } else if type(tune) == int { repr(tune) } else { tune },
    "package=@preview/typed-scores:" + _package-version,
    "source=" + if name == none { "" } else { name.replace("\n", " ") },
    "scale=0.7",
  ).join("\n")
  let response = json(_score-plugin.import_score(data, bytes(options)))
  if not response.at("ok", default: false) {
    _score-error(
      "read-score",
      response.at("error", default: "the importer failed without a message"),
      fix: "check the file in its notation program, or report the file if it opens correctly there",
    )
  }
  response.data
}

// Engrave a MusicXML or ABC file directly. Named arguments override the
// imported `score()` arguments, for example `scale`, `width`, or `theme`.
// The work title is centered above the score unless `title` is none.
#let import-score(source, format: auto, tune: none, title: auto, ..options) = {
  if options.pos().len() > 0 {
    _score-error(
      "import-score",
      "unexpected positional argument",
      value: options.pos().first(),
      fix: "pass score options by name, such as scale: 0.8",
    )
  }
  let imported = read-score(source, format: format, tune: tune)
  if imported.warnings.len() > 0 {
    _score-error(
      "import-score",
      "the source needs conversion changes: " + imported.warnings.join("; "),
      fix: "use read-score to inspect warnings and source, then explicitly render the reviewed arguments with score",
    )
  }
  let title = if title == auto { imported.title } else { title }
  if title != none and type(title) not in (str, content) {
    _score-error("import-score title", "title must be text, content, auto, or none", value: title, fix: "quote the title or use title: none")
  }
  if title != none {
    align(center, text(size: 1.6em, weight: "bold", title))
  }
  score(..imported.arguments, scale: 0.7, ..options.named())
}
