// Nomos - A nomenclature package for Typst
// Author: Eiglss

// State to track if a symbol has been displayed yet (for first-occurrence expansion)
#let _nomos-usage = state("nomos-usage", (:))

// Internal function to register metadata
#let _register(symb, description, value, unit, domain, sec) = [
    #metadata((
        symb: symb,
        description: description,
        value: value,
        unit: unit,
        domain: domain,
        section: sec,
    )) <nomos-entry>
]

// Internal helper to get data from the query system
#let _get-data(symb) = {
    // Notice: We removed the 'context' block from here!
    let entries = query(label("nomos-entry"))

    let match = entries.find(e => e.value.symb == symb)

    if match == none {
        panic("nomos: Key '" + repr(symb) + "' not found. Ensure you called #add-ncl() first.")
    }

    match.value
}

/// Registers a variable and displays it.
#let add-ncl(
    symb,
    description,
    value: none,
    unit: none,
    domain: none,
    sec: none,
    link_: true,
) = {
    box(_register(symb, description, value, unit, domain, sec)) // in box to avoid adding extra space in the function return
    if link_ {
        link(label("nomos-" + repr(symb)), symb)
    } else {
        symb
    }
}

/// Registers a variable without displaying anything in the text.
#let add-ncl-silent(
    symb,
    description,
    value: none,
    unit: none,
    domain: none,
    sec: none,
) = {
    box(_register(symb, description, value, unit, domain, sec)) // in box to avoid adding extra space in the function return
}

/// Standard Reference: Displays the symbol with a link to the nomenclature.
#let ncl(symb, link_: true) = [
    #if link_ {
        link(label("nomos-" + repr(symb)), symb)
    } else {
        symb
    }
]

/// Returns the description of the symbol.
#let ncl-d(symb) = context { _get-data(symb).description }

/// Returns the description of the symbol in lower case.
#let ncl-dl(symb) = context { lower(_get-data(symb).description) }


/// Returns the value of the symbol.
#let ncl-v(symb) = context { _get-data(symb).value }

/// Returns the unit of the symbol.
#let ncl-u(symb) = context { _get-data(symb).unit }

/// Returns the value with unit of the symbol.
#let ncl-vu(symb) = [#ncl-v(symb) #ncl-u(symb)]

/// Returns the domain of the symbol.
#let ncl-dm(symb) = context { _get-data(symb).domain }

/// Prints the Nomenclature table.
#let print-nomenclature(
    symb: true,
    description: true,
    value: true,
    unit: true,
    domain: true,
    title: "Nomenclature",
    depth: 1,
    numbering: none,
    outlined: false,
    sections: none
) = {
    if title != "" {
        heading(depth: depth, numbering: numbering, outlined: outlined)[#title]
    }
    context {
        let entries = query(label("nomos-entry"))
        let active-sections = if sections == none {
            entries.map(e => e.value.section).dedup()
        } else {
            sections
        }
        for section in active-sections {
            if section not in entries.map(e => e.value.section).dedup(){
                panic(section + " not registered.")
            }

        }

        // Filter columns based on user preferences
        let cols = ()
        if symb != false { cols.push(auto) }
        if description != false { cols.push(1fr) }
        if value != false { cols.push(auto) }
        if unit != false { cols.push(auto) }
        if domain != false { cols.push(auto) }

        // Generate Headers
        let headers = ()
        if symb != false { headers.push(if type(symb) == str { [*#symb*] } else { [*Symbol*] }) }
        if description != false {
            headers.push(if type(description) == str { [*#description*] } else { [*Description*] })
        }
        if value != false { headers.push(if type(value) == str { [*#value*] } else { [*Value*] }) }
        if unit != false { headers.push(if type(unit) == str { [*#unit*] } else { [*Unit*] }) }
        if domain != false { headers.push(if type(domain) == str { [*#domain*] } else { [*Domain*] }) }

        for section in active-sections [
            // 1. Draw the heading (if it's not 'none')
            #if section != none {
                heading(depth: depth + 1, numbering: none, outlined: false)[#section]
            }

            // 2. Filter the entries so this table only shows symbols for this section!
            #let section-entries = entries.filter(e => e.value.section == section)

            // 3. Draw the table
            #table(
                columns: cols,
                stroke: none,
                row-gutter: 0.6em,
                table.header(..headers),
                table.hline(),
                ..for entry in section-entries {
                    let d = entry.value
                    let row = ()
                    if symb != false {
                        row.push([#link(label("nomos-" + repr(d.symb)), d.symb) #label("nomos-" + repr(d.symb))])
                    }
                    if description != false { row.push([#d.description]) }
                    if value != false { row.push([#if d.value != none { d.value }]) }
                    if unit != false { row.push([#if d.unit != none { d.unit }]) }
                    if domain != false { row.push([#if d.domain != none { d.domain }]) }
                    row
                }
            )

            // Add a little bit of vertical space between the tables
            #v(1em)
        ]
    }
}
