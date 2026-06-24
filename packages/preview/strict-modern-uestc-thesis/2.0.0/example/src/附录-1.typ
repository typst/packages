#import "../uestc-thesis-template/template/thesis.typ":*

= 电子科技大学参考网站
#block(width: 100%)[
  #set align(center + horizon)
  #set text(size: 10pt)
  #table(
    columns: 2,
    stroke: none,
    // 这是顶头的粗线
    table.hline(stroke: 1pt),
    table.header([名称], [网站]),
    // 这是中间的细线
    table.hline(stroke: 0.5pt),
    // 第一行
    [电子科技大学研究生学位论文撰写规范#linebreak()（2022年1月修订）],
    [#link("https://gr.uestc.edu.cn/xiazai/114/3917")],
    // 第二行
    [电子科技大学视觉形象],
    [#link("https://vi.uestc.edu.cn/")],
    // 第三行
    [Typst 模板地址],
    [#link("https://github.com/qujihan/uestc-thesis-typst-template")],
    // 这是下面的粗线
    table.hline(stroke: 1pt),
  )
]