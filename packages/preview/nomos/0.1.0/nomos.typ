// -----------------------------------------------------------------------------
// Nomos
// A robust and customizable nomenclature package for Typst.
//
// Author:  Enzo Iglesis
// Version: 0.1.0
// Link:    https://github.com/eiglss/nomos
// -----------------------------------------------------------------------------

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
///
/// - symb (str, content): The symbol used for the variable (e.g., `"v"` or `$a$`).
/// - description (str, content): A brief explanation of what the variable represents.
/// - value (none, str, content, int, float): The specific value of the symbol, if applicable. Defaults to `none`.
/// - unit (none, str, content): The unit of measurement for the symbol. Defaults to `none`.
/// - domain (none, str, content): The domain of definition for the symbol (e.g., `"$RR^+$"`). Defaults to `none`.
/// - sec (none, str): The section name used to categorize the variable in the printed nomenclature. For example, setting this to `"Latin"` will group the variable under a `"Latin"` heading. If set to `none` (default), the variable will be listed without a specific section header.
/// - clickable (bool): Creates a clickable link to the nomenclature index if `clickable` is set to `true`. Defaults to `true`.
#let add-ncl(
    symb,
    description,
    value: none,
    unit: none,
    domain: none,
    sec: none,
    clickable: true,
) = {
    box(_register(symb, description, value, unit, domain, sec)) // in box to avoid adding extra space in the function return
    if clickable {
        link(label("nomos-" + repr(symb)), symb)
    } else {
        symb
    }
}

/// Registers a variable without displaying anything in the text.
///
/// - symb (str, content): The symbol used for the variable (e.g., `"v"` or `$a$`).
/// - description (str, content): A brief explanation of what the variable represents.
/// - value (none, str, content, int, float): The specific value of the symbol, if applicable. Defaults to `none`.
/// - unit (none, str, content): The unit of measurement for the symbol. Defaults to `none`.
/// - domain (none, str, content): The domain of definition for the symbol (e.g., `"$RR^+$"`). Defaults to `none`.
/// - sec (none, str): The section name used to categorize the variable in the printed nomenclature. For example, setting this to `"Latin"` will group the variable under a `"Latin"` heading. If set to `none` (default), the variable will be listed without a specific section header.
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

/// Standard Reference: Displays the symbol and creates a clickable link to the nomenclature index if `clickable` is set to `true`.
///
/// - symb (str, content): The registered symbol.
/// - clickable (bool): Set to `true` (default) to make the symbol a hyperlink to the table.
#let ncl(symb, clickable: true) = box([
    #if clickable {
        link(label("nomos-" + repr(symb)), symb)
    } else {
        symb
    }
])

/// Returns the **description** of the symbol.
///
/// - symb (str, content): The registered symbol.
#let ncl-d(symb) = context { _get-data(symb).description }

/// Returns the **description** of the symbol in lower case.
///
/// - symb (str, content): The registered symbol.
#let ncl-dl(symb) = context { lower(_get-data(symb).description) }

/// Returns the **value** associated with the symbol.
///
/// - symb (str, content): The registered symbol.
#let ncl-v(symb) = context { _get-data(symb).value }

/// Returns the **unit** of the symbol.
///
/// - symb (str, content): The registered symbol.
#let ncl-u(symb) = context { _get-data(symb).unit }

/// Returns the **value** and the **unit** associated with the symbol.
///
/// - symb (str, content): The registered symbol.
#let ncl-vu(symb) = [#ncl-v(symb) #ncl-u(symb)]

/// Returns the **domain** of definition for the symbol.
///
/// - symb (str, content): The registered symbol.
#let ncl-dm(symb) = context { _get-data(symb).domain }


/// Generates a table containing all the variables registered with `#add-ncl` or `#add-ncl-silent`.
/// You can toggle specific columns on or off, or provide custom header names.
///
/// - symb (bool, str): Set to `true` (default) to display the symbol column, or `false` to hide it. Alternatively, provide a `str` to use as a custom column header (e.g., `"Symbols"`).
/// - description (bool, str): Set to `true` (default) to display descriptions, or `false` to hide them. You can also provide a `str` for a custom header (e.g., `"Designation"`).
/// - value (bool, str): Set to `true` (default) to display values, or `false` to hide them. You can also provide a `str` for a custom header (e.g., `"Typical Value"`).
/// - unit (bool, str): Set to `true` (default) to display units, or `false` to hide them. You can also provide a `str` for a custom header (e.g., `"SI Units"`).
/// - domain (bool, str): Set to `true` (default) to display the domain of definition, or `false` to hide it. You can also provide a `str` for a custom header (e.g., `"Range"`).
/// - title (str, content): A `str` or content block that defines the title of the nomenclature section (default is "Nomenclature").
/// - depth (int): An `int` specifying the relative nesting depth of the heading, starting from 1.
/// - numbering (str, none): Defines the numbering style for the heading (e.g., `"1.1"`). Set to none (default) for an unnumbered heading.
/// - outlined (bool): Set to `true` to include the nomenclature heading in the document's table of contents (outline), or `false` (default) to exclude it.
/// - sections (array, none): An `array` of strings defining which sections to print and in what order (e.g., `("Latin", "Greek")`). You can include `none` in the array to specify exactly where un-sectioned variables should appear. If set to `none` (default), the package will automatically detect and print all unique sections found in the document.
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
    sections: none,
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
            if section not in entries.map(e => e.value.section).dedup() {
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
