#let ftl = plugin("./linguify_fluent_rs.wasm")

/// Returns the message from the ftl file
/// -> string
#let get-message(
  /// the content of the ftl file
  /// -> string
  source,
  /// the identifier of the message
  /// -> string
  msg-id,
  /// the arguments to pass to the message
  /// -> dictionary
  args: none,
  /// the default value to return if the message is not found
  /// -> string
  default: none,
) = {
  // Typst 0.13: `cbor.decode` is deprecated, directly pass bytes to `cbor` instead
  let decode = if sys.version < version(0, 13, 0) { cbor.decode } else { cbor }

  let config = cbor.encode((source: source, msg-id: msg-id, args: args))
  let result = decode(ftl.get_message(config))
  if result == none {
    return default
  }

  result
}

/// Constructs the data dict needed in `linguify.typ`
///
/// Returns a `str`, use `eval` to convert it to a dict
///
/// Example:
/// ```typst
/// eval(load-ftl-data("path/to/ftl", ("en", "fr")))
/// ```
/// -> string
#let load-ftl-data(
  /// the path to the directory containing the ftl files
  /// -> string
  path,
  /// the list of languages to load
  /// -> array
  languages,
) = {
  assert.eq(type(path), str, message: "expected path to be a string, found " + str(type(path)))
  assert.eq(type(languages), array, message: "expected languages to be an array, found " + str(type(languages)))
  assert(languages.all(l => type(l) == str), message: "languages array can only contain string values")

  let script = ```typc
  let import-ftl(path, langs) = {
    let data = (
      conf: (
        data-type: "ftl",
        ftl: (
          languages: langs
        ),
      ),
      lang: langs.map(lang => {
        (lang, read(path + "/" + lang + ".ftl"))
      }).to-dict()
    )
    data
  }
  import-ftl(PATH, LANGS)
  ```.text

  let scope = (
    PATH: repr(path),
    LANGS: repr(languages),
  )

  script.replace(regex("\b(" + scope.keys().join("|") + ")\b"), m => scope.at(m.text))
}
