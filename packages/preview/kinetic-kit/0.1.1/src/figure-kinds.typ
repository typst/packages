// Figure kind registry
//
// Typst keeps a separate counter and supplement per figure `kind`, but only
// styles the kinds it knows about. This module records what a document's own
// kinds are called and whether each gets a list page in the back matter.
//
// Two things are deliberately *not* handled here:
//   - Per-chapter counter resets. `setup-headings` derives those from the figures
//     actually present, so every kind restarts each chapter, declared or not.
//   - The built-in kinds' list pages. Those are governed by the `show-lo*`
//     booleans, so a declaration and a boolean can never disagree about one.

#import "translations.typ": t

// Fields an entry may carry. Anything else is a typo and is rejected outright,
// since a misspelled field would otherwise fail silently.
#let _entry-fields = ("kind", "supplement", "list-title", "show-list")

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
// vocabulary. No `show-list` field: the `show-lo*` booleans decide that.
#let _builtin-kinds = (
    figure: (
        kind: image,
        supplement: _localized("figure"),
        list-title: _localized("lof"),
    ),
    table: (kind: table, supplement: _localized("table"), list-title: _localized("lot")),
    listing: (
        kind: raw,
        supplement: _localized("listing"),
        list-title: _localized("lol"),
    ),
)

#let _builtin-kind-values = _builtin-kinds.values().map(builtin => builtin.kind)

/// Pick the variant of a per-language value that matches a language.
///
/// Values may be plain content or a dictionary keyed by language code. A plain
/// value is used for every language; a dictionary is looked up by `lang`, then
/// by `fallback`, and fails loudly if neither is present.
///
/// - value (content | str | dict): Plain value, or one variant per language code.
/// - lang (str): Language to look up first — usually `text.lang` at the use site.
/// - fallback (str | none): Language to fall back to, usually the document language.
/// - kind (function | str | none): Figure kind, used in the error message only.
/// - field (str): Field name, used in the error message only.
/// -> content | str
#let resolve-localized(value, lang, fallback: none, kind: none, field: "value") = {
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
            + " is a built-in figure kind and cannot be redeclared. Use show-lof, "
            + "show-lot or show-lol to control its list page.",
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
    if "show-list" in entry {
        assert(
            type(entry.show-list) == bool,
            message: "figure kind "
                + repr(entry.kind)
                + ": show-list must be a boolean, found "
                + repr(entry.show-list),
        )
        assert(
            not entry.show-list or "list-title" in entry,
            message: "figure kind "
                + repr(entry.kind)
                + " has show-list: true but no list-title, e.g. "
                + "list-title: (de: [Satzverzeichnis], en: [List of Theorems]).",
        )
    }
}

/// Resolve the document's figure kinds into one ordered list.
///
/// The built-in kinds come first, in the canonical order of their list pages, with
/// visibility taken from the three booleans. Kinds the document declares follow, in
/// declaration order. Declaring a built-in kind is an error.
///
/// - figure-kinds (array): Entries declared by the document.
/// - show-lof (bool): Whether the list of figures is printed.
/// - show-lot (bool): Whether the list of tables is printed.
/// - show-lol (bool): Whether the list of listings is printed.
/// -> array
#let resolve-figure-kinds(
    figure-kinds,
    show-lof: true,
    show-lot: true,
    show-lol: false,
) = {
    assert(
        type(figure-kinds) == array,
        message: "figure-kinds must be an array of dictionaries, found "
            + repr(type(figure-kinds)),
    )

    let resolved = (
        (.._builtin-kinds.figure, show-list: show-lof),
        (.._builtin-kinds.table, show-list: show-lot),
        (.._builtin-kinds.listing, show-list: show-lol),
    )

    let declared = ()
    for entry in figure-kinds {
        _check-entry(entry, declared)
        declared.push(entry.kind)
        resolved.push((list-title: none, show-list: false, ..entry))
    }

    resolved
}
