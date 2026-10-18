#import "@preview/algorithmic:1.0.7"

#import "./figure.typ": labeled-figure
#import "./style.typ": as-math

#let _algorithm_kind = "a8e95559e94540e4b1ddaf2bdba11fc4"
#let _algorithm_counter(loc2) = {
    let x = counter(figure.where(kind: _algorithm_kind)).at(loc2)
    assert.eq(x.len(), 1)
    x.at(0)
}
#let _algorithm-show-state = state("8444c8b2f07542b697529bc3e603ac9c", false)
#let enable-referable-algorithms(doc) = {
    _algorithm-show-state.update(true)
    show ref: it => {
        let el = it.element
        if type(el) == content and el.func() == figure and el.kind == _algorithm_kind {
            link(el.location(), [Algorithm #_algorithm_counter(el.location()) (#el.supplement)])
        } else {
            it
        }
    }
    doc
}
#let algorithm(title, code, width: none, placement: none, clearance: 1em, label: none) = {
    assert.ne(width, none, message: "`width` is a required argument to `algorithm`")
    context assert(_algorithm-show-state.get(), message: "Please `#show: enable-referable-algorithms`")
    let algo = box(width: width, grid(
        columns: 1,
        stroke: none,
        inset: 0.5em,
        grid.hline(),
        align(start, [*Algorithm #context { _algorithm_counter(here()) }:* #title]),
        grid.hline(),
        align(start, algorithmic.algorithm(inset: 0.25em, indent: 1em, line-numbers: false, code)),
        grid.hline(),
    ))

    labeled-figure(algo, supplement: title, caption: none, kind: _algorithm_kind, placement: placement, clearance: clearance, label: label)
}
#let Input(doc) = algorithmic.Line([*input* #doc])
#let Output(doc) = algorithmic.Line([*output* #doc]) + algorithmic.Line[$quad$]
#let Sample(var, val) = algorithmic.Line([#var $~$ #val])
#let ForIn(x, xs, code) = algorithmic.For($#x #[*in*] #xs$, code)
#let Case(pattern, code) = (pattern: pattern, code: code)
#let Match(x, ..cases) = {
    if cases.named().len() > 0 {
        panic("`Match` takes only positional arguments.")
    }
    algorithmic.iflike(kw1: "match", kw2: "", kw3: "end", x, {
        for case in cases.pos() {
            if type(case) != dictionary or case.keys() != ("pattern", "code") {
                panic("`Match` should be called with `Case` arguments.")
            }
            algorithmic.iflike(kw1: "case", kw2: "then", kw3: "", case.pattern, case.code)
        }
    })
}
#let Loop(code) = algorithmic.iflike(kw1: "loop", kw3: "end", [], code)

// Fixed to print the comment symbol using the math font
#let CommentInline(c) = as-math(text(size: 0.8em, sym.triangle.stroked.r)) + " " + c
// Its wrappers
#let Comment(c) = (CommentInline(c),)
#let LineComment(l, c) = {
  let l = algorithmic.arraify(l).flatten()
  ([#l.first()#h(1fr)#CommentInline(c)], ..l.slice(1))
}
#let LastLineComment(l, c) = {
  let l = algorithmic.arraify(l).flatten()
  (..l.slice(0, l.len() - 1), [#l.last()#h(1fr)#CommentInline(c)])
}
