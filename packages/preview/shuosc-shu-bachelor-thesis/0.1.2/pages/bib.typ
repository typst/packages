#import "../style/heading.typ": none-heading

#let bibliography-page(
  bibfunc: none,
  full: true,
) = {
  pagebreak(weak: true)
  show: none-heading
  set bibliography(
    title: "参考文献",
    // 复制自: https://github.com/citation-style-language/styles/blob/master/china-national-standard-gb-t-7714-2015-numeric.csl
    // 根据学校的模板，移除了427行的vertical-align="sup"
    style: "../assets/citation-style.csl",
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
