/*************************************************************************************************/
// Type utils

#let is_none(x) = type(x) == "none"
#let is_not_none(x) = not is_none(x)
#let is_bool(x) = type(x) == "bool"
#let is_func(f) = type(f) == "function"

#let default_if_none(x, default) = if is_none(x) {default} else {x}

#let apply_if_func(f, x) = if is_func(f) {f(x)} else {f}

#let guard(x, ..tests, default: none) = {

    for (t, then) in tests.pos() {
        if (
            (is_func(t) and t(x)) 
            or (not is_bool(x) and is_bool(t) and t)
            or x == t
        ) { 
            then
        }
    }
    default
}

#let when_not_none(val, f) = if is_not_none(val) {f}

#let with_maybe(default: none, val, f) = {
    if is_none(val) {
        f(default)
    } else {
        f(val)
    }
}

#let from_none(val, default) = {
    if is_none(val) {default}
    else {val}
}

/*************************************************************************************************/
// Measurement utils

#let content_size(body, then_do) = style(styles => {
    let size = measure(body, styles)
    then_do(size)
})

#let maybe_content_size(m_body, then_do) = {
    if is_none(m_body) { 
        then_do(0pt) 
    } else { 
        content_size(m_body, then_do) 
    }
}

// Gets the sizes of contents
#let contents_size(..contents, then_do) = style(styles => {
    let sizes = contents.pos().map(c => measure(c, styles))
    then_do(sizes)
})

/// Typst doesn't let us use keyword arguments on function calls if the corresponding parameter
/// doesn't have a default value.
/// Some functions have many arguments with no defaults, so they are annoted with `__kw_arg`,
/// implementing a builder-like pattern.
#let __kw_arg = none
#let __check_kw_args(..args) = args.pos().map(is_not_none)

