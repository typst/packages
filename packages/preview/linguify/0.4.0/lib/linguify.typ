// linguify.typ
#import "utils.typ": *
#import "fluent.typ"

/// None or dictionary of the following structure:
///
/// - `conf`
///   - `data_type` (string): The type of data structure used for the database. If not specified, it defaults to `dict` structure.
///   - `default-lang` (string): The default language to use as a fallback if the key in the preferred language is not found.
///   - ...
/// - `lang`
///   - `en`: The English language section.
///   - ...
#let database = state("linguify-database", none)


/// Set the default linguify database
///
/// The data must contain at least a lang section like described at @@database.
///
/// - data (dictionary): the database which will be set to @@database
/// -> content (state-update)
#let set-database(data) = {
  assert.eq(type(data), dictionary, message: "expected data to be a dictionary, found " + type(data))
  if (data.at("conf", default: none) == none) {
    data.insert("conf", (:))
  }
  // assert(data.at("conf", default: none) != none, message: "missing conf section ")
  assert(data.at("lang", default: none) != none, message: "missing lang section ")

  database.update(data);
}

/// Clear current database
#let reset-database() = {
  database.update(none)
}


/// Get a value from a L10n data dictionary.
/// - src (dict): The dictionary to get the value from.
/// - key (str): The key to get the value for.
/// - lang (str): The language to get the value for.
/// - mode (str): The data structure of src
/// -> The value for the key in the dictionary. If the key does not exist, `none` is returned.
#let get_text(src, key, lang, mode: "dict", args: none) = {
  assert.eq(type(src), dictionary, message: "expected src to be a dictionary, found " + type(src))
  let lang_section = src.at(lang, default: none)
  if (lang_section != none) {
    if mode == "dict" {
      return lang_section.at(key, default: none)
    }
    else if mode == "ftl" {
      return fluent.get_message(lang_section, key, args: args, default: none)
    }
    // Support for other i18n solutions can be added here.
  }
  return none
}

/// fetch a string in the required lang.
///
/// - key (string): The key at which to retrieve the item.
/// - from (dictionary): database to fetch the item from.
/// - lang (string): the language to look for, if auto use `context text.lang` (default)
/// -> dictionary with ("ok":value) if value was found and ("error": error_message) if value was not found

#let _linguify(key, from: auto, lang: auto, args: auto) = {
  let database = if-auto-then(from,database.get())

  // check if database is not empty. Means no data dictionary was specified.
  if (database == none) { return error("linguify database is empty.") }
  let data_type = database.conf.at("data_type", default: "dict")

  // get selected language.
  let selected_lang = if-auto-then(lang, text.lang)
  let lang_not_found = not selected_lang in database.lang
  let fallback_lang = database.conf.at("default-lang", default: none)

  let args = if data_type == "ftl" {
     if-auto-then(args, {
      let args = database.at("ftl", default: (:)).at("args", default: (:))
      if ( type(args) != dictionary ) { return error("expected args to be dictionary, found " + type(args))}
      args
     })
  } else {
    if args != auto {
      return error("args not supported in dict mode")
    } else { (:) }
  }

  let value = get_text(database.lang, key, selected_lang, mode: data_type, args: args)
  
  if (value != none) {
    return ok(value)
  }
  
  let error_message = if lang_not_found {
    "Could not find language `" + selected_lang + "` in the linguify database."
  } else {
    "Could not find an entry for the key `" + key + "` in language `" + selected_lang + "` at the linguify database."
  }

  // Check if a fallback language is set
  if (fallback_lang != none) {
      let value = get_text(database.lang, key, fallback_lang, mode: data_type, args: args)

      // Use the fallback language if possible
      if (value != none) {
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
/// - key (string): The key at which to retrieve the item.
/// - from (dictionary): database to fetch the item from. If auto linguify's global database will used.
/// - lang (string): the language to look for, if auto use `context text.lang` (default)
/// - default (any): A default value to return if the key is not part of the database.
/// -> content
#let linguify(key, from: auto, lang: auto, default: auto, args: auto) = {
  context {
    let result = _linguify(key, from: from, lang: lang, args: args)
    if is-ok(result) {
      result.ok
    } else {
      if-auto-then(default, panic(result.error))
    }
  }
}
