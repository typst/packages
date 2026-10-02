// Figure kind registry
//
// Typst keeps a separate counter and supplement per figure `kind`, but only
// styles the kinds it knows about. This module records what a document's own
// kinds are called so their figures get a proper caption supplement.
//
// Per-chapter counter resets are deliberately not handled here. `setup-headings`
// derives those from the figures actually present, so every kind restarts each
// chapter, declared or not.

#import "translations.typ": t

// Fields an entry may carry. Anything else is a typo and is rejected outright,
// since a misspelled field would otherwise fail silently.
#let _entry-fields = ("kind", "supplement")

// Lift one of the template's own strings into the per-language shape that entries
// use, covering every language `t` defines rather than a fixed de/en pair.
#let _localized(key) = {
    let variants = (:)
    for lang in t.keys() {
        variants.insert(lang, t.at(lang).at(key))
    }
    variants
}

// Typst's built-in kinds. These are the only ones the template carries strings
// for, because their names are template chrome rather than the document's own
// vocabulary.
#let _builtin-kinds = (
    figure: (kind: image, supplement: _localized("figure")),
    table: (kind: table, supplement: _localized("table")),
    listing: (kind: raw, supplement: _localized("listing")),
)

#let _builtin-kind-values = _builtin-kinds.values().map(builtin => builtin.kind)

/// Pick the variant of a per-language value that matches a language.
///
/// Values may be plain content or a dictionary keyed by language code. A plain
/// value is used for every language; a dictionary is looked up by `lang`, then
/// by `fallback`, and fails loudly if neither is present.
///
/// -> content | str
#let resolve-localized(
    /// Plain value, or one variant per language code.
    /// -> content | str | dictionary
    value,

    /// Language to look up first — usually `text.lang` at the use site.
    /// -> str
    lang,

    /// Language to fall back to, usually the document language.
    /// -> str | none
    fallback: none,

    /// Figure kind, used in the error message only.
    /// -> function | str | none
    kind: none,

    /// Field name, used in the error message only.
    /// -> str
    field: "value",
) = {
    if type(value) != dictionary { return value }
    if lang in value { return value.at(lang) }
    if fallback != none and fallback in value { return value.at(fallback) }
    panic(
        "figure kind "
            + repr(kind)
            + ": "
            + field
            + " has no entry for language "
            + repr(lang)
            + " (available: "
            + value.keys().map(repr).join(", ")
            + ")",
    )
}

// Validate one declaration. `declared` holds the kinds already taken by earlier
// entries, so that a repeat is reported as such rather than silently winning.
#let _check-entry(entry, declared) = {
    assert(
        type(entry) == dictionary,
        message: "figure-kinds entries must be dictionaries, found " + repr(type(entry)),
    )
    assert(
        "kind" in entry,
        message: "figure-kinds entry is missing the \"kind\" field: " + repr(entry),
    )
    assert(
        type(entry.kind) in (str, function),
        message: "figure kind must be a string (e.g. \"algorithm\") or an element "
            + "function (e.g. image), found "
            + repr(entry.kind),
    )
    for field in entry.keys() {
        assert(
            field in _entry-fields,
            message: "figure kind "
                + repr(entry.kind)
                + ": unknown field "
                + repr(field)
                + " (expected one of "
                + _entry-fields.map(repr).join(", ")
                + ")",
        )
    }
    assert(
        entry.kind not in _builtin-kind-values,
        message: repr(entry.kind)
            + " is a built-in figure kind and cannot be redeclared.",
    )
    assert(
        entry.kind not in declared,
        message: "figure kind " + repr(entry.kind) + " is declared twice in figure-kinds",
    )
    assert(
        "supplement" in entry,
        message: "figure kind "
            + repr(entry.kind)
            + " needs a supplement, e.g. supplement: (de: [Satz], en: [Theorem]). "
            + "Without one its figures would be captioned like ordinary images.",
    )
}

/// Resolve the document's figure kinds into one ordered list: the built-in kinds
/// first, then the document's own in declaration order. Declaring a built-in kind
/// is an error.
///
/// -> array
#let resolve-figure-kinds(
    /// Entries declared by the document.
    /// -> array
    figure-kinds,
) = {
    assert(
        type(figure-kinds) == array,
        message: "figure-kinds must be an array of dictionaries, found "
            + repr(type(figure-kinds)),
    )

    let resolved = _builtin-kinds.values()

    let declared = ()
    for entry in figure-kinds {
        _check-entry(entry, declared)
        declared.push(entry.kind)
        resolved.push(entry)
    }

    resolved
}
