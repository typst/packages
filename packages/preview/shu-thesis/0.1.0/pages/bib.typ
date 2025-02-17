#import "../style/heading.typ": none-heading

#let bibliography-page(
  bibfunc: none,
  full: true,
) = {
  pagebreak(weak: true)
  show: none-heading
  set bibliography(title: "参考文献", style: "gb-7714-2015-numeric", full: full)
  bibfunc
  pagebreak(weak: true)
}
