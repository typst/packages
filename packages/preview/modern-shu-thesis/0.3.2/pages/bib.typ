#import "../style/heading.typ": none-heading

#let bibliography-page(
  bibfunc: none,
  full: true,
) = {
  pagebreak(weak: true)
  show: none-heading
  set bibliography(
    title: "参考文献",
    style: "gb-7714-2015-numeric",
    full: full,
  )

  show selector(bibliography): it => {
    show regex("\[\d+\]"): num => context {
      let text = num.text
      text + h(1.27cm - measure(text).width)
    }
    set par(justify: true)
    it
  }
  bibfunc
  pagebreak(weak: true)
}
