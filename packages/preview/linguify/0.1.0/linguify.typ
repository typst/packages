// linguify

#let __lang_setting = state("lang-setting", "en");
#let __lang_dict = state("lang-dict", (default-lang: "en"));
#let __lang_fallback = state("lang-fallback", true);


#let linguify_config(data: auto, lang: "en", fallback: true, content) = {
  assert.eq(type(lang), str, message: "The lang parameter needs to be a string")
  __lang_setting.update(lang);
  if data != auto {
    assert.eq(type(data), dictionary, message: "The data parameter needs to be of type dict.")
    __lang_dict.update(data);
  }
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
  locate(loc => {
    // get current state.
    let selected_lang = __lang_setting.at(loc)
    let data = __lang_dict.at(loc)
    let fallback = __lang_fallback.at(loc)
    // process.
    if (fallback) {
      let default_lang = _get_default_lang(data);
      if (not selected_lang in data) {selected_lang = default_lang}
      return data.at(selected_lang).at(key, default: data.at(default_lang).at(key))
    } else {
      return data.at(selected_lang).at(key)
    }
  })
}
