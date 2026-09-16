//
// Referable enums
// Adapted from https://github.com/typst/typst/issues/779#issuecomment-2595880447
//

#let _state-referable-enum = state("71aaa466d3db44ad944003aceb989df3", none)
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
    assert(enum.full, message: "Only `enum.full = true` is supported right now. Add `#set enum(full: true)`.")

    let current-numbering = enum.numbering
    let sample1 = numbering(current-numbering, 1)
    let sample2 = numbering(current-numbering, 2)
    let suffix = _get-greatest-suffix(sample1, sample2)
    let wrap-numbering(..it) = {
        let numbers = numbering(current-numbering, ..it)
        _state-referable-enum.update(supplement + [~] + _remove-suffix(numbers, suffix))
        numbers
    }
    set enum(numbering: wrap-numbering)

    doc
    _state-referable-enum.update(none)
}


/// Referable enums.
/// Use as e.g. `#show: enable-referable-enums`
#let enable-referable-enums(doc) = {
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
