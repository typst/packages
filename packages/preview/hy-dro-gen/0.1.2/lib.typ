#import plugin("/assets/hypher.wasm") as hypher

/// Check if a code corresponds to a language that has *builtin* patterns.
/// It does not (yet) take into account dynamically loaded languages.
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

/// Dictionary of builtin codes and languages, in the format:
/// ```typc
/// (en: "English", fr: "French", ...)
/// ```
///
/// This dictionary is expected but not guaranteed to be in sync with
/// @cmd:hy:exists, because they are fetched through different means.
/// (@cmd:hy:exists queries the actual WASM module, while #var[languages] is
/// generated from the source code of #github("typst/hypher").
/// If they are out of sync, this is a bug and @cmd:hy:exists is the authority
/// for which languages are actually supported by @cmd:hy:syllables.
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

/// Fetch hyphenation patterns from a file.
/// Depending on the arguments, can load either precompiled bytes,
/// or to-be-compiled patterns.
/// #property(since: version(0, 1, 2))
/// Typically an invocation will look like one of:
/// #codesnippet[```typ
/// #let trie_fr = hy.trie(
///   bin: read("tries/fr.bin", encoding: none),
///   bounds: (2, 3),
///  )
/// #let trie_en = hy.trie(
///   tex: read("patterns/hyph-en.tex"),
///   bounds: (2, 3),
/// )
/// ```]
/// -> trie
#let trie(
  /// Bytes read from a `.bin` precompiled trie.
  ///
  /// Exactly one of #arg[bin] or #arg[tex] must be specified.
  /// -> bytes
  bin: none,
  /// String read from a `.tex` pattern file.
  ///
  /// Exactly one of #arg[bin] or #arg[tex] must be specified.
  /// -> str
  tex: none,
  /// (left,right)-hyphenmin as specified by #link("www.hyphenation.org")[hyphenation.org]
  /// -> (int, int)
  bounds: none,
  /// A heuristic panics if you give to #arg[tex] data that looks like a filename,
  /// because it means you probably meant to #typ.read it first.
  /// You can silence the warning in question by setting this to #typ.v.true.
  /// -> bool
  force: false,
) = {
  // Validate the bounds
  if type(bounds) != array or bounds.len() != 2 {
    panic("bounds should be an array of 2 integers. See www.hyphenation.org, column (left,right)--hyphenmin")
  }
  let (lmin, rmin) = bounds
  if not (0 <= lmin and lmin <= 255) { panic("lmin for " + iso + " out of range") }
  if not (0 <= rmin and rmin <= 255) { panic("rmin for " + iso + " out of range") }
  // Validate the data
  if (bin == none and tex == none) or (bin != none and tex != none) {
    panic("must specify exactly one of 'bin' or 'tex'")
  }
  let data = if bin != none {
    if type(bin) != bytes {
        panic("data passed as 'bin' should be raw bytes")
    }
    bin
  } else {
    if type(tex) != str {
      panic("data passed as 'tex' should be a string")
    }
    if (not force) and tex.len() < 100 {
      panic("tex: '" + tex + "' seems too short to be a pattern file. Make sure you pass the contents of the file, not its name. Use force: true to silence this error.")
    }
    let trie = hypher.build_trie(bytes(tex))
    trie
  }
  bytes(bounds) + data
}

#let _dyn-languages = state("dyn-languages", (:))

/// Load new patterns dynamically.
/// #property(since: version(0, 1, 2))
/// -> content
#let load-patterns(
  /// One or more pairs of language iso code and its trie.
  /// This function expects objects of type @type:trie,
  /// see @cmd:hy:trie for how to construct them.
  ///
  /// #codesnippet[```typ
  /// #let trie_fr = hy.trie(..)
  /// #let trie_en = hy.trie(..)
  /// #load-patterns(
  ///   fr: trie_fr,
  ///   en: trie_en,
  /// )
  /// ```]
  /// -> dictionary
  ..args
) = {
  _dyn-languages.update(langs => {
    for (iso, data) in args.named() {
      langs.insert(iso, data)
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
  /// Either an @iso code, or a @type:trie built by @cmd:hy:trie.
  /// -> iso | trie
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
  /// Setting this to true will also make the function contextual.
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

