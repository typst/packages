// linguify

#let __lang_setting = state("lang-setting", auto);
#let __lang_dict = state("lang-dict", (default-lang: "en"));
#let __lang_fallback = state("lang-fallback", true);

#let linguify_config(data: auto, lang: auto, fallback: true, content) = {
  //deprecated: set language 
  if lang != auto {
    assert.eq(type(lang), str, message: "The lang parameter needs to be a string")
  }
  __lang_setting.update(lang);

  // set language data dictionary
  if data != auto {
    assert.eq(type(data), dictionary, message: "The data parameter needs to be of type dict.")
    __lang_dict.update(data);
  }

  // set fallback mode.
  assert.eq(type(fallback), bool, message: "fallback can only be [true] or [false]")
  __lang_fallback.update(fallback)
  content
}

#let _get_default_lang(data) = {
  let default_lang = data.at("default-lang", default: "en")
  assert(default_lang in data, message: "No entry for the `default-lang` (" + default_lang + ") could be found in the lang data.")
  default_lang
}

#let linguify(key) = {
  context {
    // get current state.
    let selected_lang = if (__lang_setting.get() == auto) { text.lang } else { __lang_setting.get() }   //   __lang_setting.at(loc)
    let data = __lang_dict.get()
    let should-fallback = __lang_fallback.get()
    // process.
    if (should-fallback) {
      let default_lang = _get_default_lang(data);
      if (not selected_lang in data) {selected_lang = default_lang}
      return data.at(selected_lang).at(key, default: data.at(default_lang).at(key))
    } else {
      assert(data.at(selected_lang, default: none) != none, message: "the language data file does not contain an entry for \"" + selected_lang + "\"")
      assert(data.at(selected_lang).at(key, default: none) != none, message: "the section for the language \"" + selected_lang + "\" does not contain an entry for \"" + key + "\"")
      return data.at(selected_lang).at(key)
    }
  }
}
