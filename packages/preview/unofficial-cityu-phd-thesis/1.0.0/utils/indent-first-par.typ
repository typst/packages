// Source from: https://github.com/nju-lug/modern-nju-thesis

#let empty-par = par[#box()]
#let fake-par = context empty-par + v(-measure(empty-par + empty-par).height)
#let indent-first-par(s) = {
  show heading: it => {
    it

    fake-par
  }
  s
}
