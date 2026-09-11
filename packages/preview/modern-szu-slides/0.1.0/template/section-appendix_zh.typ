// 示例：附录 (中文)
// `freeze-slide-counter: true` 配置防止附录页计入幻灯片总页数

#import "@preview/touying:0.7.4": slide, config-page, config-store, config-common

#let appendix-config = config-page(
  margin: (top: 2.0em, bottom: 1.2em, x: 1.6em),
) + config-store(
  footer-progress: false,
) + config-common(
  freeze-slide-counter: true,
)

#let appendix-section = [
  #slide(config: appendix-config)[
    = 附录

    补充材料、参考文献列表或额外实验细节。

    #v(1em)
    如果需要多个附录页，可以创建额外的 `#slide(config: appendix-config)[...]` 块。
  ]
]
