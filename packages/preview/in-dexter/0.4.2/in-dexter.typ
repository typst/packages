// Copyright 2023, 2024 Rolf Bremer, Jutta Klebe
// Use of this code is governed by the License in the LICENSE.txt file.
// For a 'how to use this package', see the accompanying .md, .pdf + .typ documents.

// Adds a new entry to the index
// @param fmt: function: content -> content
// @param initial: "letter" to sort entries under - otherwise first letter of entry is used,
//    useful for indexing umlauts or accented letters with their unaccented versions or
//    symbols under a common "Symbols" headline
// @param index: Name of the index to add the entry to. Default is "Default".
// @param display: If given, this will be the displayed content in the index page (instead of the key entry).
// @param ..entry, variable argument to nest index entries (left to right). Only the last, rightmost
// entry is the key for the entry. The others are used for grouping.
#let index(fmt: it => it, initial: none, index: "Default", display: auto, ..entry) = locate(loc => [
    #metadata((
        fmt: fmt,
        initial: initial,
        index-name: index,
        location: loc.position(),
        page-counter: counter(page).display(),
        entry: entry,
        display: display,
    ))<jkrb_index>
])

// Default function to semantically mark main entries in the index
#let index-main = index.with(fmt:strong)

#let as-text(input) = {
  let t = type(input)
  if input == none or input == auto {
      ""
  } else if t == str {
      input
  } else if t == label {
      repr(input)
  } else if t == int {
      str(input)
  } else if t == content {
    if input.has("text") {
        input.text
    } else if input.has("children") {
        if input.children.len() == 0 {
          ""
        } else {
            input.children.map(child => as-text(child)).join("")
        }
    } else if input.has("body") {
        as-text(input.body)
    } else {
        " "
    }
  } else {
    panic("Unexpected entry type " + t + " of " + repr(input))
  }
}

// Internal function to set plain and nested entries
#let make-entries(entries, page-link, reg-entry, use-bang-grouping) = {
    // Handling LaTeX nested entry syntax (only if it is the last entry)

    if use-bang-grouping and entries.len() == 1 {
        let entry = entries.at(0)
        if type(entry.key) == str and entry.key.len()>0 {
            let disp = entry.display
            entries = entry.key.split("!").map(e => {
                let d = if type(disp) == str and disp.contains(regex("!\w+")) {
                    e
                } else {
                    disp
                }
                (display: d, key: e)
            })

            if entries.last().key == "" {
                let emptyKeyIndex = entries.position(e => e.key == "")
                let bangCount = 0
                if emptyKeyIndex != none {
                    bangCount = entries.len() - emptyKeyIndex
                }
                entries = entries.filter(e => e.key != "")
                entries.last() = (display: entries.last().display + "!" * bangCount, key: entries.last().key)
            }
        }
    }

    let (entry, ..rest) = entries

    if rest.len() > 0 {
        let nested-entries = reg-entry.at(entry.key, default: (:))
        let ref = make-entries(rest, page-link, nested-entries.at("nested", default: (:)), use-bang-grouping)
        nested-entries.insert("nested", ref)
        reg-entry.insert(entry.key, nested-entries)
    } else {
        let key = if type(entry.key) == str { entry.key } else { as-text(entry.key) }
        if type(key) == content { panic("Entry must be string compatible. Consider specifying as display parameter.") }
        let current-entry = reg-entry.at(key, default: (display: entry.display, "pages": ()))
        let pages = current-entry.at("pages", default: ())
        if not pages.contains(page-link) {
            pages.push(page-link)
        }
        current-entry.insert("pages", pages)
        reg-entry.insert(key, current-entry)
    }
    reg-entry
}

// Internal function to collect plain and nested entries into the index
#let references(loc, indexes, use-bang-grouping, sort-order) = {
    let register = (:)
    let initials = (:)
    for indexed in query(<jkrb_index>, loc) {
        let (fmt, initial, index-name, location, page-counter, entry, display) = indexed.value
        if (indexes != auto) and (not  indexes.contains(index-name)) { continue }

        // Handle tuple as (display, key)
        let entries = entry.pos().map(e => {
            let disp = if display == auto {
                e
            } else {
                display
            }

            let k = none
            if type(e) == array {
                if e.len() == 2 {
                    disp = e.at(0)
                    k = e.at(1)
                }
            } else {
                k = as-text(e)
            }
            (display: disp, key: k)
        })

        if entries.len() == 0 {
            panic("expected entry to have at least one entry to add to the index")
        } else {
            let initial-letter = if initial == none {
                let fe = sort-order(entries.first().at("key", default: "?"))
                let fe2 = if type(fe) == str { fe } else { as-text(fe) }
                if type(fe2) != str { panic("Content cannot be converted to string. Use `initial` or `display` parameter for the entry.") }
                let first-letter = fe2.first()
                initials.insert(first-letter, first-letter)
                first-letter
            } else {
                if (type(initial) == dictionary) {
                    let letter = sort-order(initial.at("letter"))
                    let sort-by = initial.at("sort-by", default: letter)
                    initials.insert(sort-by, letter)
                    letter
                } else if (type(initial) == str) {
                    let first-letter = sort-order(initial.first())
                    initials.insert(first-letter, first-letter)
                    first-letter
                } else {
                    panic("Expected initial to be either a 'string' or '(letter: <string>, sort-by: <none|string>)'")
                }

            }
            let reg-entry = register.at(initial-letter, default: (:))
            register.insert(initial-letter,
                            make-entries(entries,
                                         (page: location.page, fmt: fmt, page-counter: page-counter),
                                         reg-entry,
                                         use-bang-grouping))
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
    if type(entry) == str and entry.len() > 0 {
        upper(entry.first()) + entry.clusters().slice(1).join()
    }
}

#let apply-entry-casing(display, entry-casing) = {
    if type(display) == str {
        entry-casing(display)
    } else {
        let a = as-text(display)
        if type(a) == str { entry-casing(a) } else { a }
    }
}

// Internal function to format a plain or nested entry
#let render-entry(idx, entries, lvl, use-page-counter, sort-order, entry-casing) = {
    let pages = entries.at("pages", default: ())
    let display = entries.at("display", default: idx)
    let render-function = render-link.with(use-page-counter)
    let rendered-pages = [
        #box(width: lvl * 1em)#apply-entry-casing(display, entry-casing)#box(width: 1fr)#pages.map(render-function).join(", ") \
    ]
    let sub-entries = entries.at("nested", default: (:))
    let rendered-entries = if sub-entries.keys().len() > 0 [
        #for entry in sub-entries.keys().sorted(key: sort-order) [
            #render-entry(apply-entry-casing(entry, entry-casing), sub-entries.at(entry), lvl + 1, use-page-counter, sort-order, entry-casing)
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
// @param sort-order (default: upper) a function to control how the entry is sorted.
// @param entry-casing (default: first-letter-up) a function to control how the
//        entry key is displayed (when no display parameter is provided).
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
