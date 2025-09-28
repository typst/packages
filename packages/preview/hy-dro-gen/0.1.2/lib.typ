#import plugin("/assets/hypher.wasm") as hypher

/// Check if a code corresponds to a language that has registered patterns.
///
/// See the list of officially supported languages at
/// #link("https://github.com/typst/hypher/blob/main/src/lang.rs")[`github:typst/hypher`]
///
/// If this function returns #typ.v.true,
/// then an invocation of @cmd:hy:syllables with this language
/// is guaranteed to not raise an "Invalid language" failure.
///
/// -> bool
#let exists(
  /// 2-letter @iso code, e.g ```typc "en"```, ```typc "fr"```, ```typc "el"```, etc.
  /// -> iso
  iso,
) = {
  let exists = hypher.exists(
    bytes(iso),
  )
  exists.at(0) != 0
}

/// Dictionary of supported codes and languages, in the format:
/// ```typ
/// (en: "English", fr: "French", ...)
/// ```
///
/// This dictionary is expected but not guaranteed to be in sync with
/// `exists`, because they are fetched through different means.
/// (`exists` queries the actual WASM module, while `languages` is generated
/// automatically from the source code of `hypher`). If they are out of sync,
/// `exists` is the authority for which languages are actually supported
/// by `syllables`.
/// -> dictionary
#let languages = {
  let langs = (:)
  for line in read("/assets/languages.txt").split("\n") {
    if line != "" {
      langs.insert(..line.split(" "))
    }
  }
  langs
}


#let _dyn-languages = state("dyn-languages", (:))

/// Load new precompiled patterns.
/// If your patterns are not compiled yet, see @install-hypher and @compile-pats.
/// #property(since: version(0, 1, 2))
/// -> content
#let load-patterns(
  /// One or more pairs in the format `{iso}: {bytes}`,
  /// for example one could write:
  /// #codesnippet[```typ
  /// #load-patterns(
  ///   en: read("tries/en.bin", encoding: none),
  ///   fr: read("tries/fr.bin", encoding: none),
  /// )
  /// ```]
  /// -> dictionary
  ..args
) = {
  _dyn-languages.update(langs => {
    for (iso, trie) in args.named() {
      if type(trie) != bytes {
        panic("load-patterns expects bytes, received " + str(type(trie)))
      }
      langs.insert(iso, trie)
    }
    langs
  })
}

/// Splits a word into syllables according to available hyphenation patterns.
/// -> (..string,)
#let syllables(
  /// Word to split.
  /// -> string
  word,
  /// Either an @iso code, or bytes representing a trie.
  /// -> iso | bytes
  lang: "en",
  /// Determines the behavior in case `lang` is unsupported
  /// - #typ.v.none: panics with "Invalid language"
  /// - #typ.v.auto: the word is not split at all
  /// - @type:iso: use that instead
  /// -> none | auto | iso
  fallback: none,
  /// Look also in the dynamically loaded languages,
  /// i.e. valid values for #arg[lang] now include not just the builtin ones
  /// but also those declared via @cmd:hy:load-patterns.
  /// Setting this to true will also make the function contextual,
  /// #property(since: version(0, 1, 2))
  /// #property(requires-context: true)
  /// -> bool
  dyn: false
) = {
  if type(lang) == str {
    if dyn and lang in _dyn-languages.get() {
      lang = _dyn-languages.get().at(lang)
    } else if fallback != none and not exists(lang) {
      if fallback == auto {
        return (word,)
      } else {
        assert(exists(fallback))
        lang = fallback
      }
    }
  }
  let hyphenated = hypher.syllables(
    bytes(word),
    bytes(lang),
  )
  str(hyphenated).split("\u{0}")
}

/// Apply show rules to hyphenate the specified language.
/// The output is a #lambda(content, ret:content) that can be
/// used as ```typ #show``` rule for the rest of the document.
/// #property(since: version(0, 1, 2))
/// -> function
#let apply-patterns(
  /// @iso code of a language previously added by @cmd:hy:load-patterns.
  /// -> iso
  iso
) = cc => context {
  let trie = _dyn-languages.get().at(iso)
  show regex("\w+"): ww => context {
    if text.lang == iso {
      syllables(ww.text, lang: trie).join([-?])
    } else {
      ww
    }
  }
  cc
}

