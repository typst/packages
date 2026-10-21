//
// Referable enums
// Adapted from https://github.com/typst/typst/issues/779#issuecomment-2595880447
//

#let _state-referable-enum = state("71aaa466d3db44ad944003aceb989df3-copy", none)
#let _state-referable-enum-numbering = state("71aaa466d3db44ad944003aceb989df3-numbering", none)
#let _resolve(name, local, global) = {
    if local == none {
        if global == none {
            panic-fmt("{} is not set in either `referable-enum` or `enable-referable-enums`", name)
        } else {
            global
        }
    } else {
        if global == none {
            local
        } else {
            panic-fmt("{} is set in both `referable-enum` and `enable-referable-enums`", name)
        }
    }
}
#let referable-enum(doc, supplement: none, display-numbering: none, reference-numbering: none) = context {
    assert(enum.full, message: "Only `enum.full = true` is supported right now. Add `#set enum(full: true)`.")
    let global-state = _state-referable-enum-numbering.get()
    assert.ne(global-state, none, message: "Must call `enable-referable-enums` before using `referable-enum`.")

    let (global-supplement, global-display-numbering, global-reference-numbering) = global-state

    let wrap-numbering(..it) = {
        let supplement = _resolve("supplement", supplement, global-supplement)
        let display-numbering = _resolve("display-numbering", display-numbering, global-display-numbering)
        let reference-numbering = _resolve("reference-numbering", reference-numbering, global-reference-numbering)
        _state-referable-enum.update(supplement + [~] + numbering(reference-numbering, ..it))
        numbering(display-numbering, ..it)
    }
    set enum(numbering: wrap-numbering)

    doc
    _state-referable-enum.update(none)
}
#let enable-referable-enums(doc, supplement: none, display-numbering: none, reference-numbering: none) = {
    _state-referable-enum-numbering.update((supplement, display-numbering, reference-numbering))
    show ref: it => {
        let el = it.element
        if el != none and el.func() == text and _state-referable-enum.at(el.location()) != none {
            let loc = el.location()
            let numbers = _state-referable-enum.at(loc)
            link(loc, numbers)
        } else {
            // Other references as usual.
            it
        }
    }
    doc
}
