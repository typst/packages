// Math symbols in the forms used by Chinese school textbooks.
//
// Import them into math with `#import symbols: *`; they then replace the
// built-in symbols of the same name (`$A B parallel C D$` gives ⫽). The
// originals stay available as `sym.parallel` and so on.

#import "config.typ": exam-state

#let _rel(body) = math.class("relation", body)
#let _not(body) = _rel(math.cancel(body, length: 90%, angle: 30deg))

#let parallel = _rel("⫽")
#let nparallel = _not("⫽")
// 平行且相等. `symbols.paralleleq-type: "perpendicular"` stacks ∥ instead of ⫽.
#let paralleleq = context {
    let top = if exam-state.get().symbols.paralleleq-type == "perpendicular" { "∥" } else { "⫽" }
    _rel(math.attach(math.limits("="), t: text(size: 1.25em, top)))
}
#let parallelogram = "▱"
// 相似 and 全等.
#let sim = _rel("∽")
#let nsim = _not("∽")
#let cong = _rel("≌")
#let ncong = _not("≌")
// 真子集 with the doubled bar.
#let subsetneqq = _rel("⫋")
#let nsubsetneqq = _not("⫋")
#let supsetneqq = _rel("⫌")
#let nsupsetneqq = _not("⫌")
#let varnothing = "∅"
