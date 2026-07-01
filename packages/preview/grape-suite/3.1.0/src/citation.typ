#let grape-suite-citation(body) = {
    set bibliography(style: "citation-style.csl")
    body
}

#let full-citation(key, prefix: none, supplement: none, postfix: none) = prefix + cite(if type(key) == str {
    label(key)
} else if type(key) == label {
    key
}, supplement: supplement) + postfix

#let ct-full(key, ..a) = {
    let a = a.pos()
    full-citation(key,
        supplement: if a.len() > 0 and a.first() != none { a.first() },
        prefix: if a.len() > 1 and a.last() != none { [#a.last() ] }
    )
}

#let ct(key, ..a) = {
    footnote(ct-full(key, ..a))
}

#let cf-full(key, ..a) = {
    ct-full(
        key,
        ..if a.pos().len() == 0 { (none,) } else { a.pos() },
        context if text.lang == "de" { [Vgl. ] } else { [Cf. ] }
    )
}

#let cf(key, ..a) = {
    let a = a.pos()
    footnote(cf-full(key,
        if a.len() > 0 { a.join[ ] },
    ))
}