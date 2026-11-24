#import "genitive.typ" as genitive

/// Cite without parentheses.
///
/// See standard `cite` for arguments.
///
/// == Examples
/// - `cite-bare(<kripke1980>)` -> Kripke 1980
/// - `cite-bare(<kripke1980>, supplement: [p. 64])` -> Kripke 1980, p. 64
#let cite-bare(key, supplement: none, style: auto) = {
  show regex("[\(\)\[\]]"): none
  cite(key, supplement: supplement, style: style)
}

/// Cite with the author name in genitive (possessive).
/// Sensitive to current `text.lang`. 
///
/// `genitives` can be passed to define genitive forms for your own languages.
/// The form is determined in the order:
/// 1. `genitives.at(text.lang)`
/// 2. default for `text.lang`
/// 3. `genitives.at("en")`
/// 4. default for `"en"`
///
/// See standard `cite` for arguments.
/// Supported forms are "prose" and "author".
///
/// == Examples
/// - `cite-genitive(<kripke1980>)` -> Kripke's (1980)
/// - `cite-genitive(<kripke1980>, form: "author")` -> Kripke's
/// - `set text.lang("de"); cite-genitive(<kripke1980>)` -> Kripkes (1980)
/// Make names ending with "s" have "’s" added.
/// - `cite-genitive(<lewis1986>, genitives: (en: it => it + [’s]))` -> Lewis's (1986)
///
/// - genitives (dictionary): Custom languages in addition to or overriding the default ones.
///   Values ar `content -> content` functions from author's name to posessive form.
///   See `genitive.genitives` for more info.
#let cite-genitive(
  key,
  supplement: none,
  style: auto,
  form: "prose",
  genitives: (:)
) = {
    let genitives = genitive.genitives + genitives
    
    show regex("^[^\[\(]+"): it => {
      show regex("([^\s]*\s)*[^\s]+"): genitives.at(text.lang,
          default: genitives.at("en")
      )
      it
    }
  cite(key, form: form, supplement: supplement)
}

/// Same as `cite-genitive.with(form: "prose")`. 
/// For compatibility purposes.
#let cite-prose-genitive = cite-genitive.with(form: "prose")
/// Same as `cite-genitive.with(form: "author")`. 
/// For compatibility purposes.
#let cite-author-genitive = cite-genitive.with(form: "author")


/// The default abbreviations.
/// Keys are prefixes, values are functions of type
/// `(target :: label, supplement :: content) => content`.
///
/// == Values
/// - p: prose --- Kripke (1980)
/// - ps: genitive prose (language-sensitive) --- Kripke's (1980) / Lewis' (1986)
/// - b: bare --- Kripke 1980
/// - a: author --- Kripke
/// - as: genitive author (language-sensitive) --- Kripke's / Lewis'
/// - y: year --- 1980
///
/// Prose, author, and year are standard Typst forms, the rest are custom.
#let base-forms = (
    // Kripke (1980)
    "p": (key, suppl) => cite(key, form: "prose", supplement: suppl),
    // Kripke's (1980), Lewis' (1986)
    "ps": (key, suppl) => cite-genitive(key, supplement: suppl, form: "prose"),
    // Kripke 1980
    "b": (key, suppl) => cite-bare(key, supplement: suppl),
    // Kripke
    "a": (key, suppl) => cite(key, form: "author", supplement: suppl),
    // Kripke's (1980), Lewis' (1986)
    "as": (key, suppl) => cite-genitive(key, supplement: suppl, form: "author"),
    // 1980
    "y": (key, suppl) => cite(key, form: "year", supplement: suppl),
)

/// This function should be used in a show rule as `show cite: citesugar`.
/// It parses the citation's supplement and styles the citation accordingly.
///
/// The syntax for supplements is `form:actual-supplement`.
///
/// See `base-forms` for what the default abbreviations are.
///
/// == Examples
/// (after applying the show rule)
/// - `@kripke1980[p:]` -> Kripke (1980)
/// - `@kripke1980[p:p. 64]` -> Kripke (1980: p. 64)
///
/// - forms (dictionary): Custom forms in addition to or overriding the default ones.
///   Accepts a dictionary where keys are prefixes
///   and values are functions of type
///   `(target :: label, supplement :: content) => content`.
#let citesugar(
  it,
  forms: (: )
) = {
  let forms = base-forms + forms
  let suppl = it.supplement

  if (
    suppl not in (none, auto, []) 
    and suppl.has("children")
    and suppl.at("children").at(1) == [:]
  ) {
    let children = suppl.at("children")
    let abbr = (children.at(0).text)
    let supplement = children.slice(2).join()

    if abbr in forms {
      forms.at(abbr)(it.key, supplement)
    } else {
      cite(it.key, supplement: supplement)
    }

  } else {
    it
  }
}
