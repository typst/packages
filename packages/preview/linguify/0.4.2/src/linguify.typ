// linguify.typ
#import "utils.typ": *
#import "fluent.typ"

/// None or dictionary of the following structure:
///
/// - `conf`
///   - `data_type` (string): The type of data structure used for the database. If not specified, it
///     defaults to `dict` structure.
///   - `default-lang` (string): The default language to use as a fallback if the key in the
///     preferred language is not found.
///   - ...
/// - `lang`
///   - `en`: The English language section.
///   - ...
#let database = state("linguify-database", none)

/// Set the default linguify database
///
/// The data must contain at least a lang section like described at @@database.
///
/// -> content (state-update)
#let set-database(
  /// the database which will be set to @@database
  /// -> dictionary
  data,
) = {
  assert.eq(type(data), dictionary, message: "expected data to be a dictionary, found " + str(type(data)))
  if data.at("conf", default: none) == none {
    data.insert("conf", (:))
  }
  // assert.ne(data.at("conf", default: none), none, message: "missing conf section")
  assert.ne(data.at("lang", default: none), none, message: "missing lang section")

  database.update(data)
}

/// Clear current database
///
/// -> content (state-update)
#let reset-database() = {
  database.update(none)
}

/// Get a value from a L10n data dictionary. If the key does not exist, `none` is returned.
#let get_text(
  /// The dictionary to get the value from.
  /// -> dictionary
  src,
  /// The key to get the value for.
  /// -> string
  key,
  /// The language to get the value for.
  /// -> string
  lang,
  /// The data structure of src
  /// -> string
  mode: "dict",
  args: none,
) = {
  assert.eq(type(src), dictionary, message: "expected src to be a dictionary, found " + str(type(src)))
  let lang_section = src.at(lang, default: none)
  if lang_section != none {
    if mode == "dict" {
      lang_section.at(key, default: none)
    } else if mode == "ftl" {
      fluent.get_message(lang_section, key, args: args, default: none)
    } else {
      none
    }
    // Support for other i18n solutions can be added here.
  } else {
    none
  }
}

/// fetch a string in the required lang. Returns a result with ("ok": value) if value was found and
/// ("error": error_message) if value was not found.
///
/// -> dictionary

#let _linguify(
  /// The key at which to retrieve the item.
  /// -> string
  key,
  /// database to fetch the item from.
  /// -> dictionary
  from: auto,
  /// the language to look for, if auto use `context text.lang` (default)
  /// -> string
  lang: auto,
  args: auto,
) = {
  let database = if-auto-then(from, () => database.get())

  // check if database is not empty. Means no data dictionary was specified.
  if database == none { return error("linguify database is empty.") }
  let data_type = database.conf.at("data_type", default: "dict")

  // get selected language.
  let selected_lang = if-auto-then(lang, () => text.lang)
  let lang_not_found = not selected_lang in database.lang
  let fallback_lang = database.conf.at("default-lang", default: none)

  let args = if data_type == "ftl" {
    if-auto-then(args, {
      let args = database.at("ftl", default: (:)).at("args", default: (:))
      if type(args) != dictionary {
        return error("expected args to be dictionary, found " + str(type(args)))
      }
      args
    })
  } else {
    if args != auto {
      return error("args not supported in dict mode")
    }
    (:)
  }

  let value = get_text(database.lang, key, selected_lang, mode: data_type, args: args)

  if value != none {
    return ok(value)
  }

  let error_message = if lang_not_found {
    "Could not find language `" + selected_lang + "` in the linguify database."
  } else {
    "Could not find an entry for the key `" + key + "` in language `" + selected_lang + "` at the linguify database."
  }

  // Check if a fallback language is set
  if fallback_lang != none {
    let value = get_text(database.lang, key, fallback_lang, mode: data_type, args: args)

    // Use the fallback language if possible
    if value != none {
      return ok(value)
    }

    // if the key is not found in the fallback language

    error_message = error_message + " Also, the fallback language `" + fallback_lang + "` does not contain the key `" + key + "`."

  } else {
    // if no fallback language is set
    error_message = error_message + " Also, no fallback language is set."
  }

  return error(error_message)
}


/// fetch a string in the required language.
/// provides context for `_linguify` function which implements the logic part.
///
/// -> content
#let linguify(
  /// The key at which to retrieve the item.
  /// -> string
  key,
  /// database to fetch the item from. If auto linguify's global database will used.
  /// -> dictionary
  from: auto,
  /// the language to look for, if auto use `context text.lang` (default)
  /// -> string
  lang: auto,
  /// A default value to return if the key is not part of the database.
  /// -> any
  default: auto,
  args: auto,
) = {
  let impl() = {
    let result = _linguify(key, from: from, lang: lang, args: args)
    if is-ok(result) {
      result.ok
    } else {
      if-auto-then(default, () => panic(result.error))
    }
  }

  if from == auto or lang == auto {
    // context is needed to use the default database or current language
    context impl()
  } else {
    impl()
  }
}
