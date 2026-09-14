#import "@preview/typsy:0.2.1": safe-counter

//
// Referable enums
// Adapted from https://github.com/typst/typst/issues/779#issuecomment-2595880447
//

#let _state-referable-enum = state("254062f63911459cb0ff8f4d1bd47553", none)
#let _counter-referable-enum = safe-counter(() => {})
// Both arguments assumed to be strings.
#let _get-greatest-suffix(sample1, sample2) = {
    let suffix = ("",)
    for (c1, c2) in sample1.rev().split("").zip(sample2.rev().split("")) {
        if c1 == c2 {
            suffix.push(c1)
        } else {
            break
        }
    }
    suffix.rev().join("")
}
#let _remove-suffix(x, suffix) = {
    assert(x.ends-with(suffix))
    x.slice(0, x.len() - suffix.len())
}

/// *Example:*
///
/// ```typst
/// #show: enable-referable-enums
///
/// #set enum(numbering: "a.", full: true)
/// #referable-enum("Step")[
/// + foo
/// + bar <baz>
/// ]
///
/// @baz  // Renders as 'Step b'
/// ```
///
/// - supplement (str): The name to use when referencing this enum, e.g. the 'Step' in 'Step 1'.
/// - doc (content): Content
/// -> content
#let referable-enum(supplement, doc) = context {
    let current-numbering = enum.numbering
    assert(enum.full, message: "Only `enum.full = true` is supported right now. Add `#set enum(full: true)`.")
    let wrap-numbering(..it) = {
        _counter-referable-enum.update(it.pos())
        numbering(current-numbering, ..it)
    }
    set enum(numbering: wrap-numbering)

    let sample1 = numbering(current-numbering, 1)
    let sample2 = numbering(current-numbering, 2)
    let suffix = _get-greatest-suffix(sample1, sample2)

    _state-referable-enum.update((supplement, suffix, current-numbering))
    doc
}


/// Referable enums.
/// Use as e.g. `#show: enable-referable-enums`
#let enable-referable-enums(doc) = {
    show ref: it => {
        let el = it.element
        if el != none and el.func() == text and _state-referable-enum.at(el.location()) != none {
            let loc = el.location()
            let (supplement, suffix, current-numbering) = _state-referable-enum.at(loc)
            let numbers = numbering(current-numbering, .._counter-referable-enum.at(loc))
            // Override enum references.
            link(loc, supplement + [~] + _remove-suffix(numbers, suffix))
        } else {
            // Other references as usual.
            it
        }
    }
    doc
}
