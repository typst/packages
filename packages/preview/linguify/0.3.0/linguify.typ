// linguify

#let __linguify_lang_preferred = state("linguify-preferred-lang", auto);  // auto means detect from context text.lang 
#let __linguify_lang_database = state("linguify-database", none);  // none or dictionary 
#let __linguify_lang_fallback = state("linguify-fallback-lang", auto); // auto means to look in database.

/// wrapper to get linguify database
/// ! needs context
#let linguify_get_database() = {
  __linguify_lang_database.get()
}

/// set a data dictionary for linguify database
#let linguify_set_database(data) = {
  assert.eq(type(data), dictionary, message: "expected data to be a dictionary, found " + type(data))
  __linguify_lang_database.update(data);
}

/// check if database is not empty
/// ! needs context 
#let linguify_is_database_initialized() = {
  __linguify_lang_database.get() != none
}

/// add data to the current database
#let linguify_add_to_database(data) = {
  context {
    let database = __linguify_lang_database.get()
    for (key,value) in data.pairs() {
      database.insert(key, value)
    }
    __linguify_lang_database.update(database);
  }
}

/// set a fallback language
#let linguify_set_fallback_lang(lang) = {
  if lang != auto and lang != none {
    assert.eq(type(lang), str, message: "expected fallback lang to be a string, found " + type(lang))
  }
  __linguify_lang_fallback.update(lang)
}

/// set a preferred language.
///
/// ! warning: language from `set text(lang: "de")` is not detected if this is used.
/// you probably want this to stay auto
#let linguify_set_preferred_lang(lang) = {
  if lang != auto {
    assert.eq(type(lang), str, message: "expected overwrite lang to be a string, found " + type(lang))
  }
  __linguify_lang_preferred.update(lang);
}

/// update all settings at once
#let linguify_config(data: auto, lang: auto, fallback: auto) = {
  // set language data dictionary
  if data != auto {
    linguify_set_data(data)
  }

  // set fallback mode.
  linguify_set_fallback_lang(fallback)

  /// ! warning: language from `set text(lang: "de")` is not detected if this is used.
  /// you probably want this to stay auto
  linguify_set_preferred_lang(lang)
}

/// Helper function. 
/// if the value is auto "ret" is returned else the value self is returned
#let if-auto-then(val,ret) = {
  if (val == auto){
    ret
  } else { 
    val 
  }
}

/// fetch the string in the required lang.
#let linguify(key, default: auto, lang: auto) = {
  context {
    let database = __linguify_lang_database.get()
    // check if database is not empty. Means no data dictionary was specified.
    assert(database != none, message: "linguify database is empty.")
    // get selected language.
    let selected_lang = if-auto-then(lang, if-auto-then(__linguify_lang_preferred.get(), text.lang))
    let lang_not_found = not selected_lang in database
    let fallback_lang = if-auto-then(__linguify_lang_fallback.get(), database.at("default-lang", default: none) )

    // if available get the language section from the database if not try to get the fallback_lang entry.
    let lang_section = database.at(
      selected_lang,
      default: if (fallback_lang != none) { database.at(fallback_lang, default: none) } else { none }
    )

    // if lang_entry exists 
    if ( lang_section != none ) {
      // check if the value exits.
      let value = lang_section.at(key, default: none)
      if (value == none) {
        // info: fallback lang will not be used if given lang section exists but only a key is missing.
        // use this for a workaround: linguify("key", default: linguify("key", lang: "en", default: "key"));
        if (fallback_lang != none) {
          // check if fallback lang exists in database
          assert(database.at(fallback_lang, default: none) != none, message: "fallback lang (" + fallback_lang + ") does not exist in linguify database")
          // check if key exists in fallback lang.
          assert(database.at(fallback_lang).at(key, default: none) != none, message: "key (" +  key + ") does not exist in fallback lang section.")
          return database.at(fallback_lang).at(key)
        }
        if (default != auto) {
          return default
        } else {
          if lang_not_found {
            panic("Could not find an entry for the key (" +  key + ") in the fallback section (" + fallback_lang + ") at the linguify database.")
          } else {
            panic("Could not find an entry for the key (" +  key + ") in the section (" + selected_lang + ") at the linguify database.")
          }
        }
      } else {
        return value
      }
    } else {
      if fallback_lang == none or selected_lang == fallback_lang {
        panic("Could not find a section for the language (" + selected_lang + ") in the linguify database.")
      } else {
        panic("Could not find a section for the language (" + selected_lang + ") or fallback language (" + fallback_lang + ") in the linguify database.")
      }
    }
  }
}
