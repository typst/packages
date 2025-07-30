#import "../styles/heading.typ": none-heading
#import "../styles/fonts.typ": fontsize

#let bibliography-page(
  bibfunc: none,
  full: true,
) = {
  pagebreak(weak: true)
  show: none-heading
  set text(size: fontsize.五号)
  set par(leading: .1em, spacing: .65em)
  
  set bibliography(
    title: "参考文献",
    style: "gb-7714-2015-numeric",
    full: full,
  )

  show selector(bibliography): it => {
    show regex("\\[(\\d+|[A-Za-z]|等|著|译|[A-Za-z]/[A-Za-z]+)\\]"): num => context {
      let text_t = num.text
      text(fill: rgb("c00000"))[#text_t]
    }
    set par(justify: true)
    it
  }
  bibfunc
  pagebreak(weak: true)
}
