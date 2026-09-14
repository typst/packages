#import "@preview/gb7714-bilingual:0.2.3": gb7714-bibliography
#import "@preview/pointless-size:0.1.2": zh

#let bibliography(..args) = gb7714-bibliography(
  title: [#heading(level: 1, numbering: none)[#text(size: zh(-4))[参考文献]]],
  full-control: entries => {
    context {
      if entries.len() == 0 {
        return
      }

      let max-width = measure([[#{ entries.len() }]]).width

      let spacing = 0.5em
      let uniform-hanging = max-width + spacing

      for e in entries {
        let num-content = [[#e.order]] // 带方括号
        let num-width = measure(num-content).width
        par(
          hanging-indent: uniform-hanging,
          first-line-indent: 0pt,
        )[
          #set text(size: zh(5))
          #box(width: max-width)[#align(right)[#num-content]]#h(spacing)#e.labeled-rendered
        ]
        v(0.2em)
      }
    }
  },
  ..args,
)
