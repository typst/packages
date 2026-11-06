// Copyright 2023 Rolf Bremer, Jutta Klebe

// gls[term]: Marks a term in the document as referenced.
// gls(glossary-term)[term]: Marks a term in the document as referenced with a
// different expression ("glossary-term") in the glossary.

// To ensure that the marked entries are displayed properly, it is also required
// to use a show rule, like the following:
// #show figure.where(kind: "jkrb_glossary"): it => {it.body}

// We use a figure element to store the marked text and an optional
// reference to be used to map to the glossary. If the latter is empty, we use the body
// for the mapping.
#let gls(entry: none, display) = figure(display, caption: entry, numbering: none, kind: "jkrb_glossary")

// Add a keyword to the glossary, even if it is not in the documents content.
#let gls-add(entry) = figure([], caption: entry, numbering: none, kind: "jkrb_glossary")

// This function creates a glossary page with entries for every term
// in the document marked with `gls[term]`.
#let make-glossary(
    // Indicate missing entries.
    missing: text(fill: red, weight: "bold")[ No glossary entry ],

    // Function to format the Header of the entry.
    heading: it => { heading(level: 2, numbering: none, outlined: false, it)},

    // This array contains entry titles to exclude from the generated glossary page.
    excluded: (),

    // The glossary data.
    ..glossaries

    ) = {

    let figure-title(figure) = {
        let ct = ""
        if figure.caption == none {
            if figure.body.has("text") {
                ct = figure.body.text
            }
            else {
                for cc in figure.body.children {
                    if cc.has("text") {
                        ct += cc.text
                    }
                }
            }
        }
        else{
            ct = figure.caption.text
        }
        return ct
    }

    let lookup(key, glossaries) = {
        let entry = none
        for glossary in glossaries.pos() {
            if glossary.keys().contains(key) {
                let entry = glossary.at(key)
                return entry
            }
        }
        return entry
    }

    locate(loc => {
        let words = ()  //empty array

        // find all marked elements
        let all-elements = query(figure.where(kind: "jkrb_glossary"), loc)

        // only use the not hidden elements
        let elements = ()
        for e in all-elements {
            if figure-title(e) not in excluded {
                elements.push(e)
            }
        }

        // extract the titles
        let titles = elements.map(e => figure-title(e)).sorted()
        for t in titles {
            if words.contains(t) { continue }
            words.push(t)
            heading(t)
            let e = lookup(t, glossaries)
            if e != none {
                e.description
                if e.keys().contains("link") {
                    e.link
                }
            } else {
                missing
            }
        }
    })
}
