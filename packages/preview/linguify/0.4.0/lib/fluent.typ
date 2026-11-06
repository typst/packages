#let ftl = plugin("./linguify_fluent_rs/linguify_fluent_rs.wasm")

/// returns a bool
#let has_message(ftl_str, msg_id) = {
  str(ftl.has_id(bytes(ftl_str), bytes(msg_id))) == "true"
}

/// Returns the message from the ftl file
/// - `ftl_str` (str): the content of the ftl file
/// - `msg_id` (str): the identifier of the message
/// - `args` (dict): the arguments to pass to the message
/// - `default` (str): the default value to return if the message is not found
///
#let get_message(ftl_str, msg_id, args: none, default: none) = {
  if args == none {
    args = (:)
  }
  if not has_message(ftl_str, msg_id) {
    return default
  }
  return str(
    ftl.get_message(bytes(ftl_str), bytes(msg_id), bytes(json.encode(args, pretty: false)))
  )
}

/// Constructs the data dict needed in `linguify.typ`
/// - `path` (str): the path to the directory containing the ftl files
/// - `languages` (array): the list of languages to load
///
/// Returns a `str`, use `eval` to convert it to a dict
///
/// ## Example:
/// ```typst
/// eval(load_ftl_data("path/to/ftl", ("en", "fr")))
/// ```
#let load_ftl_data(
  path,
  languages
) = {
  assert.eq(type(path), str, message: "expected path to be a string, found " + type(path))
  assert.eq(type(languages), array, message: "expected languages to be an array, found " + type(languages))

  ```Typst
  let import_ftl(path, langs) = {
    let data = (
      conf: (
        data_type: "ftl",
        ftl: (
          languages: langs
        ),
      ),
      lang: (:)
    )
    for lang in langs {
      data.lang.insert(lang, str(read(path + "/" + lang + ".ftl")))
    }
    data
  }
  import_ftl(
    "```.text + path + ```",
    (```.text + (languages.map((x) => {"\"" + str(x) + "\", "}).sum()).trim(" ") + ```)
  )
  ```.text
}

