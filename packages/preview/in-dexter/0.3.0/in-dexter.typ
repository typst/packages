// Copyright 2023, 2024 Rolf Bremer, Jutta Klebe
// Use of this code is governed by the License in the LICENSE.txt file.
// For a 'how to use this package', see the accompanying .md, .pdf + .typ documents.

// Adds a new entry to the index
// @param fmt: function: content -> content
// @param initial: "letter" to sort entries under - otherwise first letter of entry is used,
//    useful for indexing umlauts or accented letters with their unaccented versions or
//    symbols under a common "Symbols" headline
// @param index: Name of the index to add the entry to. Default is "Default".
// @param ..entry, variable argument to nest index entries (left to right)
#let index(fmt: it => it, initial: none, index: "Default", ..entry) = locate(loc => [
    #metadata((
        fmt: fmt,
        initial: initial,
        index-name: index,
        location: loc.position(),
        page-counter: counter(page).display(),
        entry: entry,
    ))<jkrb_index>
])

// Default function to semantically mark main entries in the index
#let index-main = index.with(fmt:strong)

// Extracts (nested) content or text to content
#let as-text(input) = {
    if type(input) == str {
        input
    } else if type(input) == content {
        if input.has("text") {
            input.text
        } else if input.has("children") {
            input.children.map(child => as-text(child)).join("")
        } else if input.has("body") {
            as-text(input.body)
        } else {
            panic("Encountered content without 'text' or 'children' field: " + repr(input))
        }
    } else {
        panic("Unexpected entry type " + type(input) + " of " + repr(input))
    }
}


// Internal function to set plain and nested entries
#let make-entries(entries, page-link, reg-entry, use-bang-grouping) = {
    // Handling LaTeX nested entry syntax
    if use-bang-grouping and entries.len() == 1 {
        let entry = entries.at(0)
        if entry.len()>0 {
            entries = entry.split("!")
            if entries.last() == "" {
                let x = entries.position(e => e == "")
                let xx = 0
                if x != none {
                    xx = entries.len() - x
                }
                entries = entries.filter(e => e != "")
                entries.last() = entries.last() + "!" * xx
            }
        }
    }

    let (entry, ..rest) = entries

    if rest.len() > 0 {
        let nested-entries = reg-entry.at(entry, default: (:))
        let ref = make-entries(rest, page-link, nested-entries.at("nested", default: (:)), use-bang-grouping)
        nested-entries.insert("nested", ref)
        reg-entry.insert(entry, nested-entries)
    } else {
        let pages = reg-entry.at(entry, default: (:)).at("pages", default: ())
        if not pages.contains(page-link) {
            pages.push(page-link)
            reg-entry.insert(entry, ("pages": pages))
        }
    }
    reg-entry
}

// Internal function to collect plain and nested entries into the index
#let references(loc, indexes, use-bang-grouping, sort-order) = {
    let register = (:)
    let initials = (:)
    for indexed in query(<jkrb_index>, loc) {
        let (entry, fmt, initial, index-name, location, page-counter) = indexed.value
        if (indexes != auto) and (not  indexes.contains(index-name)) { continue }

        let entries = entry.pos().map(as-text)
        if entries.len() == 0 {
            panic("expected entry to have at least one entry to add to the index")
        } else {
            let initial-letter = if initial == none {
                let first-letter = sort-order(entries.first().first())
                initials.insert(first-letter, first-letter)
                first-letter
            } else {
                if (type(initial) == dictionary) {
                    let letter = sort-order(initial.at("letter"))
                    let sort-by = initial.at("sort-by", default: letter)
                    initials.insert(sort-by, letter)
                    letter
                } else if (type(initial) == string) {
                    let first-letter = sort-order(initial.first())
                    initials.insert(first-letter, first-letter)

                } else {
                    panic("Expected initial to be either a 'string' or '(letter: <string>, sort-by: <none|string>)'")
                }

            }
            let reg-entry = register.at(initial-letter, default: (:))
            register.insert(initial-letter, make-entries(entries, (page: location.page, fmt: fmt, page-counter: page-counter), reg-entry, use-bang-grouping))
        }
    }
    (register: register, initials: initials)
}


// Internal function to format a page link
#let render-link(use-page-counter, (page, fmt, page-counter)) = {
    link((page: page, x: 0pt, y: 0pt), fmt[#if use-page-counter { page-counter } else { page }])
}


// First letter casing
#let first-letter-up(entry) = {
    if entry.len() > 0 {
        upper(entry.first()) + entry.clusters().slice(1).join()
    }
}

// Internal function to format a plain or nested entry
#let render-entry(idx, entries, lvl, use-page-counter, sort-order, entry-casing) = {
    let pages = entries.at("pages", default: ())
    let render-function = render-link.with(use-page-counter)
    let rendered-pages = [
        #box(width: lvl * 1em)#entry-casing(idx)#box(width: 1fr)#pages.map(render-function).join(", ") \
    ]
    let sub-entries = entries.at("nested", default: (:))
    let rendered-entries = if sub-entries.keys().len() > 0 [
        #for entry in sub-entries.keys().sorted(key: sort-order) [
            #render-entry(entry-casing(entry), sub-entries.at(entry), lvl + 1, use-page-counter, sort-order, entry-casing)
        ]
    ]
    [
        #rendered-pages
        #rendered-entries
    ]
}


// Inserts the index into the document
// @param title (default: none) sets the title of the index to use.
// @param outlined (default: false) if index is shown in outline (table of contents).
// @param use-page-counter (default: false) use the value of the page counter for page number text.
// @param use-bang-grouping (default: false) support the LaTeX bang grouping syntax.
// @param indexes (default: auto) optional name(s) of the index(es) to use. Auto uses all indexes.
#let make-index(title: none,
                outlined: false,
                use-page-counter: false,
                use-bang-grouping: false,
                sort-order: k => upper(k),
                entry-casing: k => first-letter-up(k),
                indexes: auto) = locate(loc => {

    let (register, initials) = references(loc, indexes, use-bang-grouping, sort-order)

    if title != none {
        heading(
            outlined: outlined,
            numbering: none,
            title
        )
    }

    for initial in initials.keys().sorted() {
        let letter = initials.at(initial)
        heading(level: 2, numbering: none, outlined: false, letter)
        let entry = register.at(letter)
        // sort entries
        for idx in entry.keys().sorted(key: sort-order) {
            render-entry(idx, entry.at(idx), 0, use-page-counter, sort-order, entry-casing)
        }
    }
})