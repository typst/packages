#import plugin("/assets/hypher.wasm") as hypher

/// Check if a code corresponds to a language that has registered patterns.
///
/// See the list of officially supported languages at
/// #link("https://github.com/typst/hypher/blob/main/src/lang.rs")[`github:typst/hypher`]
///
/// If this function returns `true`,
/// then an invocation of `syllables` with this language
/// is guaranteed to not raise a "Invalid language" failure.
///
/// -> bool
#let exists(
  /// 2-letter language code.
  /// -> str
  lang,
) = {
  let exists = hypher.exists(
    bytes(lang),
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

/// Splits a word into syllables according to hyphenation patterns.
///
/// -> (..string,)
#let syllables(
  /// Word to split.
  /// -> string
  word,
  /// Language 2-letter code.
  /// -> str
  lang: "en",
  /// Determines the behavior in case `lang` is unsupported
  /// - `none`: panics with "Invalid language"
  /// - `auto`: the word is not split at all
  /// - valid 2-letter code: use that instead
  /// -> str | auto | none
  fallback: none,
) = {
  if fallback != none and not exists(lang) {
    if fallback == auto {
      return (word,)
    } else {
      assert(exists(fallback))
      lang = fallback
    }
  }
  let hyphenated = hypher.syllables(
    bytes(word),
    bytes(lang),
  )
  str(hyphenated).split("\u{0}")
}

