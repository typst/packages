// linguify.typ
#import "utils.typ": *
#import "fluent.typ"

/// None or dictionary of the following structure:
///
/// - `conf`
///   - `data-type` (string): The type of data structure used for the database. If not specified, it
///     defaults to `dict` structure.
///   - `default-lang` (string): The default language to use as a fallback if the key in the
///     preferred language is not found.
///   - ...
/// - `lang`
///   - `en`: The English language section.
///   - ...
#let database = state("linguify-database", none)

/// A stack (array) of `location`s to use instead of `here()` when looking up the current database.
/// This is used internally to support looking up translations in e.g. outlines relative to a
/// heading's or figure's location, instead of the outline's.
///
/// When the stack is empty, the current location is used.
#let location-stack = state("linguify-location-stack", ())

/// Temporarily overrides the location at which the translation database is looked up.
/// This is typically used to change the lookup inside outlines. Consider this:
///
/// ```typ
/// #set-database(toml("a.toml"))
/// #outline()
/// = linguify("foo")
///
/// #set-database(toml("b.toml"))
/// = linguify("bar")
/// ```
///
/// In this example, the `foo` translation should be loaded from `a.toml` and `bar` from `b.toml`.
/// However, the outline is covered by `a.toml` -- including the entry for the `bar` heading!
///
/// Adding the following show rule at the beginning fixes this:
///
/// ```typ
/// #show outline.entry: it => database-at(it.element.location(), it)
/// ```
///
/// This will make linguify look up the translations for each outline entry at the location the
/// referenced element (heading) is located.
#let database-at(
  loc,
  body,
) = {
  location-stack.update(it => (..it, loc))
  body
  location-stack.update(((..it, _)) => it)
}

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
#let get-text(
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
  let lang-section = src.at(lang, default: none)
  if lang-section != none {
    if mode == "dict" {
      lang-section.at(key, default: none)
    } else if mode == "ftl" {
      fluent.get-message(lang-section, key, args: args, default: none)
    } else {
      none
    }
    // Support for other i18n solutions can be added here.
  } else {
    none
  }
}

/// fetch a string in the required lang. Returns a result with ("ok": value) if value was found and
/// ("error": error-message) if value was not found.
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
  let database = if-auto-then(from, () => {
    let location = location-stack.get().at(-1, default: here())
    database.at(location)
  })

  // check if database is not empty. Means no data dictionary was specified.
  if database == none { return error("linguify database is empty.") }
  let data-type = database.conf.at("data-type", default: "dict")

  // get selected language.
  let selected-lang = if-auto-then(lang, () => text.lang)
  let lang-not-found = not selected-lang in database.lang
  let fallback-lang = database.conf.at("default-lang", default: none)

  let args = if data-type == "ftl" {
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

  let value = get-text(database.lang, key, selected-lang, mode: data-type, args: args)

  if value != none {
    return ok(value)
  }

  let error-message = if lang-not-found {
    "Could not find language `" + selected-lang + "` in the linguify database."
  } else {
    "Could not find an entry for the key `" + key + "` in language `" + selected-lang + "` at the linguify database."
  }

  // Check if a fallback language is set
  if fallback-lang != none {
    let value = get-text(database.lang, key, fallback-lang, mode: data-type, args: args)

    // Use the fallback language if possible
    if value != none {
      return ok(value)
    }

    // if the key is not found in the fallback language

    error-message += " Also, the fallback language `" + fallback-lang + "` does not contain the key `" + key + "`."
  } else {
    // if no fallback language is set
    error-message += " Also, no fallback language is set."
  }

  return error(error-message)
}

/// fetch a string in the required language.
/// must have a context beforehand to access the global database/lang
///
/// -> content
#let linguify-raw(
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
  let result = _linguify(key, from: from, lang: lang, args: args)
  if is-ok(result) {
    result.ok
  } else {
    if-auto-then(default, () => panic(result.error))
  }
}

/// fetch a string in the required language.
/// provides context for `linguify-raw` function.
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
  context linguify-raw(key, from: from, lang: lang, default: default, args: args)
}
