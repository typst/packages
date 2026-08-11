
/// State variable conataining all acronyms.
/// The keys `short` and `long` must be provided for each language. Their plural forms are optional. \
/// Use the structure as shown in the example here:
/// ```example
/// #let my-acronyms = (
///   key: (
///     language1: (
///       short: [short version],
///       long: [long version],
///       short-pl: "short plural",
///       long-pl: [long plural]
///     ),
///     language2: (
///       short: [second language short],
///       long: [second language long],
///       short-pl: [2nd lang short plural],
///       long-pl: [2nd lang long plural]
///     )
///   ),
///   LED: (
///    en: (
///      short: [LED],
///      short-pl: [LEDs],
///      long: [Light Emitting Diode],
///    ),
///    de: (
///      short: "LED",
///      long: "Leuchtdiode",
///      long-pl: "Leuchtdioden",
///    ),
///  ),
/// )
/// #my-acronyms
/// ```
/// -> dictionary
#let _acronyms = state("_acronyms", none)

/// State variable containing languages and their written form being used in @ac when two languages are displayed.
/// ```example
/// #let language-mapping = (
///   en: [english],
///   de: [german],
///   fr: "french",
/// )
/// #language-mapping
/// ```
#let _language-display = state("_language-display", (:))

/// State variable, what the default second language is to be used on acronyms. Use "none" to disable this feature. This variable is context aware. Exmaple: "en", "de", "fr" -> string
#let _default-second-lang = state("_default-second-lang", none)

/// State variable, what the default language is to be used with acronyms. This is context aware. Exmaple: "en", "de", "fr" -> string
#let _default-lang = state("_default-lang", none)

/// State variable, if links and labels should be generated.
/// If this is true @print-acronyms must be used. Alternatively you can create the labels yourself. See @printCustomAcronymTable. \
/// Only the final value will be used. -> bool
#let _always-link = state("_always-link", true)

/// Prefix of label keys. Used to link acronyms to the printed acronym list. -> string
#let LABEL_KEY = "acronymlinks-"


/// Initialize the acronyms and the default settings.
/// -> none
#let init-acronyms(
  /// Dictionary containing all the defined acronyms.
  /// -> dictionary
  acronyms,
  /// Set the default language. For exmaple "en", "de", "fr". You can change this later using @update-acro-lang -> string
  default-lang,
  /// Set the default second language. For exmaple "en", "de", "fr". You can change this later using @update-acro-second-lang -> string
  default-second-lang: none,
  /// Languages and their written form being used in @ac when two languages are displayed. Use "none" if this is not requiered. -> dictionary
  language-display: none,
  /// Controls if labels and links will be generated. The label will point to @print-acronyms, the link will be created on the displayed acronym.
  always-link: true,
) = {
  _default-lang.update(default-lang)
  _default-second-lang.update(default-second-lang)
  _always-link.update(always-link)
  _language-display.update(language-display)

  let data = (:)
  for (key, value) in acronyms {
    // map key to its value (lang and short/long; used; long-shown)
    data.insert(key, (value: value, used: false, long-shown: false))
  }

  _acronyms.update(data)
}

/// Update the current default language used for acronyms. Useful when writing a bilingual document. -> none
#let update-acro-lang(
  /// Language to be displayed. Examples: "en", "de", "fr" -> string | none
  lang,
) = {
  _default-lang.update(lang)
}

/// Update the current default second language used for acronyms. -> none
#let update-acro-second-lang(
  /// Language to be displayed. Examples: "en", "de", "fr" -> string | none
  lang,
) = {
  _default-second-lang.update(lang)
}

/// Display text with a link, when desired.
/// The link will use @LABEL_KEY with the key paramter to generate the label.
/// The label will all point to the acronyms in @print-acronyms.
/// -> content
#let display-text(
  /// Text to be printed -> content | string
  text,
  /// Key used for label generation with @LABEL_KEY. Only required when "do-link" is true. -> string
  key: none,
  /// Generate a link to the printed aconyms from @print-acronyms. -> bool
  do-link: false,
) = {
  if do-link {
    link(label(LABEL_KEY + key), text)
  } else {
    text
  }
}

/// Update the status of "used" for a acronym from @_acronyms.
/// This may cause the error "label <acronymlinks-your_key> does not exist in the document" if you set used to false and do not call @ac to reset the state to true.
///  -> none
#let update-acronym-used(
  /// Key of the acronym, which will be updated. -> string
  key,
  /// New value for the "used" key of the selected acronym. -> bool
  used,
) = {
  _acronyms.update(data => {
    data.at(key).used = used
    data
  })
}

/// Update the status of "long-shown" for a acronym from @_acronyms. -> none
#let update-acronym-long-shown(
  /// Key of the acronym, which will be updated. -> string
  key,
  /// New value for the "long-shown" key of the selected acronym. -> bool
  long-shown,
) = {
  _acronyms.update(data => {
    data.at(key).long-shown = long-shown
    data
  })
}

/// Verfiy that an acronym, the requiered language, short and long term exist.
/// -> error
#let verfiy-acronym-exists(
  /// Key of the desired acronym. -> string
  key,
  /// Language to be tested. -> string
  lang,
) = {
  if key not in _acronyms.get() {
    panic("Key '" + key + "' does not exist!")
  }
  let selected-acro = _acronyms.get().at(key)

  if lang not in selected-acro.value {
    panic("Language '" + lang + "' does not exist for key '" + key + "'.")
  }

  let selected-acro-lang = selected-acro.value.at(lang)

  if "short" not in selected-acro-lang {
    panic("'short' definition does not exist for language '" + lang + "' with key '" + key + "'.")
  }

  if "long" not in selected-acro-lang {
    panic("'long' definition does not exist for language '" + lang + "' with key '" + key + "'.")
  }
}

/// Show the acronym. If it is first shown, the long version with the short will be displayed. \
/// This will mark the acronym as used.
/// -> content
#let ac(
  /// Key of the desired acronym. -> string
  key,
  /// Language to be displayed. none will use the default language -> string | none
  lang: none,
  /// Second langauge to be displayed. If "auto" is passed, @_default-second-lang will be used. -> string | none
  second-lang: auto,
) = {
  context {
    let selected-lang = if lang == none { _default-lang.get() } else { lang }
    verfiy-acronym-exists(key, selected-lang)
    let selected-acro = _acronyms.get().at(key)
    let text

    // Auto is the default, so we extraxt the default language.
    let selected-second-lang = if second-lang == auto {
      _default-second-lang.get()
    } else { second-lang }
    let x = selected-second-lang

    if selected-acro.long-shown {
      text = selected-acro.value.at(selected-lang).short
    } else {
      // Long was not shown before
      if selected-second-lang != none {
        // second language was provided and long form not shown before
        // so we must display both languages.
        verfiy-acronym-exists(key, selected-second-lang)

        let second-lang-display = _language-display.final().at(selected-second-lang)

        text = [#selected-acro.value.at(selected-lang).long (#selected-acro.value.at(selected-lang).short, #second-lang-display: #selected-acro.value.at(selected-second-lang).long)]
      } else {
        text = [#selected-acro.value.at(selected-lang).long (#selected-acro.value.at(selected-lang).short)]
      }

      update-acronym-long-shown(key, true)
    }


    update-acronym-used(key, true)
    display-text(text, key: key, do-link: _always-link.final())
  }
}

/// Display the plural form an acronym. If it is first shown, the long version with the short will be displayed. Also if no plural form was defined, "s" will be appended. \
/// This will mark the acronym as used.
/// -> content
#let acp(
  /// Key of the desired acronym. -> string
  key,
  /// Language to be displayed. none will use the default language -> string | none
  lang: none,
) = {
  context {
    let selected-lang = if lang == none { _default-lang.get() } else { lang }
    verfiy-acronym-exists(key, selected-lang)
    let selected-acro = _acronyms.get().at(key)

    // First get the short-pl form, append "s" if none was defined.
    // Do this first, since it is needed either way
    let short-pl-text = if "short-pl" in selected-acro.value.at(selected-lang) {
      selected-acro.value.at(selected-lang).short-pl
    } else {
      // short-pl was not defined
      selected-acro.value.at(selected-lang).short + "s"
    }

    let text

    if selected-acro.long-shown {
      text = short-pl-text
    } else {
      let long-pl-text = if "long-pl" in selected-acro.value.at(selected-lang) {
        selected-acro.value.at(selected-lang).long-pl
      } else {
        // short-pl was not defined
        selected-acro.value.at(selected-lang).long + "s"
      }
      text = [#long-pl-text (#short-pl-text)]
      update-acronym-long-shown(key, true)
    }

    update-acronym-used(key, true)
    display-text(text, key: key, do-link: _always-link.final())
  }
}

/// Show the acronym in the short form. This will mark the acronym as used.
///
/// -> content
#let acs(
  /// Key of the desired acronym. -> string
  key,
  /// Language to be displayed. none will use the default language -> string | none
  lang: none,
) = {
  context {
    let selected-lang = if lang == none { _default-lang.get() } else { lang }
    verfiy-acronym-exists(key, selected-lang)
    let selected-acro = _acronyms.get().at(key)
    let text = selected-acro.value.at(selected-lang).short

    update-acronym-used(key, true)
    display-text(text, key: key, do-link: _always-link.final())
  }
}

/// Show the acronym in the short plural form. If no short plural form was defined, "s" will be appended. \
/// This will mark the acronym as used.
/// -> content
#let acsp(
  /// Key of the desired acronym. -> string
  key,
  /// Language to be displayed. none will use the default language -> string | none
  lang: none,
) = {
  context {
    let selected-lang = if lang == none { _default-lang.get() } else { lang }
    verfiy-acronym-exists(key, selected-lang)
    let selected-acro = _acronyms.get().at(key)
    let text

    if "short-pl" in selected-acro.value.at(selected-lang) {
      text = selected-acro.value.at(selected-lang).short-pl
    } else {
      // short-pl was not defined
      text = selected-acro.value.at(selected-lang).short + "s"
    }

    update-acronym-used(key, true)
    display-text(text, key: key, do-link: _always-link.final())
  }
}

/// Display the long form of an acronym. This will not set "long-shown" or "used" to true (since the short version is not displayed with it)
/// -> content
#let acl(
  /// Key of the desired acronym. -> string
  key,
  /// Language to be displayed. none will use the default language -> string | none
  lang: none,
) = {
  context {
    let selected-lang = if lang == none { _default-lang.get() } else { lang }
    verfiy-acronym-exists(key, selected-lang)
    let selected-acro = _acronyms.get().at(key)
    let text = selected-acro.value.at(selected-lang).long

    display-text(text, key: key, do-link: _always-link.final())
  }
}

/// Display the long plural form of an acronym. If no plural form was defined, "s" will be appended. This will not set "long-shown" to true (since the short version is not displayed with it)
/// -> content
#let aclp(
  /// Key of the desired acronym. -> string
  key,
  /// Language to be displayed. none will use the default language -> string | none
  lang: none,
) = {
  context {
    let selected-lang = if lang == none { _default-lang.get() } else { lang }
    verfiy-acronym-exists(key, selected-lang)
    let selected-acro = _acronyms.get().at(key)
    let text

    if "long-pl" in selected-acro.value.at(selected-lang) {
      text = selected-acro.value.at(selected-lang).long-pl
    } else {
      text = selected-acro.value.at(selected-lang).long + "s"
    }

    display-text(text, key: key, do-link: _always-link.final())
  }
}

/// Display an acronym with a suffix, hyphenated to it (e.g., acronym-suffix).
/// -> content
#let ac-suffix(
  /// Key of the desired acronym. -> string
  key,
  /// Suffix which whill be displayed after the acronym. -> string | content
  suffix,
  /// Language to be displayed. none will use the default language -> string | none
  lang: none,
  /// Show the plural form of the acrony. An "s" will be appended if the plural form ist not defined. -> bool
  plural: false,
) = {
  context {
    let selected-lang = if lang == none { _default-lang.get() } else { lang }
    verfiy-acronym-exists(key, selected-lang)
    let selected-acro = _acronyms.get().at(key)

    let short-word
    let long-word
    let text

    if plural {
      short-word = if "short-pl" in selected-acro.value.at(selected-lang) {
        selected-acro.value.at(selected-lang).short-pl
      } else { selected-acro.value.at(selected-lang).short + "s" }
      long-word = if "long-pl" in selected-acro.value.at(selected-lang) {
        selected-acro.value.at(selected-lang).long-pl
      } else { selected-acro.value.at(selected-lang).long + "s" }
    } else {
      // singular
      short-word = selected-acro.value.at(selected-lang).short
      long-word = selected-acro.value.at(selected-lang).long
    }

    if selected-acro.long-shown {
      text = [#(short-word)-#suffix]
    } else {
      text = [#(long-word)\(#short-word)-#suffix]
      update-acronym-long-shown(key, true)
    }

    update-acronym-used(key, true)
    display-text(text, key: key, do-link: _always-link.final())
  }
}

/// Display an acronym with custom short and long form. This is useful in case a custom ending or similar is needed once.
/// The acronym will be treated the same as using @ac. \
/// Note: Since the short and long form are custom, the language and suffix are omitted as parameters.
/// -> content
#let ac-custom(
  /// Key of the desired acronym. -> string
  key,
  /// Custom short form of the acronym. -> string | content
  short,
  /// Custom long form of the acronym. -> string | content
  long,
  /// Suffix which whill be displayed after the acronym. When none, suffix will be ignored -> string | content | none
  suffix: none,
) = {
  context {
    // Check if acronym exists. @verfiy-acronym-exists can't be used because lang is omitted. Also it is not important here, if the short/long forms are defined.
    if key not in _acronyms.get() {
      panic("Key '" + key + "' does not exist!")
    }
    let selected-acro = _acronyms.get().at(key)

    let text

    if suffix == none {
      if selected-acro.long-shown {
        text = short
      } else {
        text = [#long (#short)]
        update-acronym-long-shown(key, true)
      }
    } else {
      // Suffix is provided
      if selected-acro.long-shown {
        text = [#(short)-#suffix]
      } else {
        text = [#(long)\(#short)-#suffix]
        update-acronym-long-shown(key, true)
      }
    }

    update-acronym-used(key, true)
    display-text(text, key: key, do-link: _always-link.final())
  }
}

/// Print all used acronyms in a grid.
/// This will create labels, if @_always-link is set to true.
/// The list will be sorted by the acronym key. It is not possible to sort by content.
/// -> content
#let print-acronyms() = {
  context {
    let final-acronyms = _acronyms.final()
    let printable-acronyms = (:)
    let default-lang-final = _default-lang.get()

    for (key, (value, used, long-shown)) in final-acronyms {
      if used {
        // extract only used acronyms with their default-lang short and long form
        let short-long = (value.at(default-lang-final).short, value.at(default-lang-final).long)
        printable-acronyms.insert(str(key), short-long)
      }
    }

    // Sort by key, it is not possible to sort by content.
    printable-acronyms = printable-acronyms.pairs().sorted(key: it => it.at(0))

    grid(
      columns: (auto, 1fr),
      row-gutter: 1em,
      column-gutter: 2em,
      //fill: (green, blue), // great for debugging
      [*Acronym*], [*Definition*],
      ..{
        for (key, value) in printable-acronyms {
          (
            [#value.at(0) #if _always-link.final() { label(LABEL_KEY + key) }],
            [#value.at(1)],
          )
        }
      },
    )
  }
}
