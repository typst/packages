#import "@preview/algo:0.3.4":*
#import "@preview/algo:0.3.4":*
#import "@preview/modern-bnu-thesis:0.0.1": indent,字体, 字号
= 图表示例

== 插图

图片通常在 ```typ #figure``` 环境中使用 ```typ #image ``` 插入，如@fig:bnu-logo 的源代码。 建议矢量图片使用 SVG 格式，比如数据可视化的绘图； 照片应使用 JPG 格式；
其他的栅格图应使用无损的 PNG 格式。 注意，Typst 不支持 PDF 格式，需要转为 SVG 格式使用（这是因为Rust重新实现的PDF渲染器会对实时编译不友好，并且无法在生成PNG/SVG等格式时。。。后面什么来着忘了）

#figure(caption: [示例图片标题])[
  #image("../images/bnu-emblem.svg", width: 50%)
  #set text(size: 字号.五号)
  #set par(leading: 1em)
  #align(left)[
    国外的期刊习惯将图表的标题和说明文字写成一段，需要改写为标题只含图表的名称，其他说明文字以注释方式写在图表下方，或者写在正文中。
  ]
]<bnu-logo>

// #{parbreak()+""}
// #repr(parbreak())
// #""


#indent 图应有编号。由“图”和从“1”开始的阿拉伯数字组成，例如“图
1”等，图较多时，可分章编号。图应有图题，图题即图的名称，置于图的编号之后。图的编号和图题应置于图下方。若图或表中有附注，采用英文小写字母顺序编号，附注写在图或表的下方。国外的期刊习惯将图表的标题和说明文字写成一段，需要改写为标题只含图表的名称，其他说明文字以注释方式写在图表下方，或者写在正文中。

#figure(caption: [多个分图的示例])[
  #set text(size: 字号.五号)
  #set par(leading: 1em)
  #grid(columns: (15em, 15em), [
    #image("../images/bnu-emblem.svg", width: 100%)
    (a) 分图A
  ], [
    #image("../images/bnu-emblem.svg", width: 100%)
    (b) 分图B
  ], [
    #image("../images/bnu-emblem.svg", width: 100%)
    (a) 分图A
  ], [
    #image("../images/bnu-emblem.svg", width: 100%)
    (b) 分图B
  ])
   
   
   
]
#pagebreak(weak: true)

== 表格

表应具有自明性。为使表格简洁易读，尽可能采用三线表，如@tbl:timing-tlt1。 三条线可以使用```typ #table.hline() ```命令生成。

#figure(table(
  columns: 4,
  stroke: none,
  table.hline(),
  [t],
  [1],
  [2],
  [3],
  table.hline(stroke: .5pt),
  [y],
  [0.3s],
  [0.4s],
  [0.8s],
  table.hline(),
), caption: [三线表]) <timing-tlt1>


#indent 表应有编号。由“表”和从“1”开始的阿拉伯数字组成，例如“表1”等，表较多时，可分章编号。


表应有表题，表题即表的名称，置于表的编号之后。表的编号和表题应置于表上方。 表格如果有附注，尤其是需要在表格中进行标注时，可以使用 \pkg{threeparttable} 宏包。

#figure([#{
    let t = table(
      columns: 2,
      stroke: none,
      table.hline(),
      table.hline(),
      [文件名],
      [描述],
      table.hline(),
      [bnuthesis.dtx#super([a])],
      [模板的源文件，包括文档和注释],
      [bnuthesis.cls#super([b])],
      [模板文件],
      [bnuthesis-\*.bst],
      [BibTeX 参考文献表样式文件],
      table.hline(),
    )
    t
    let b = body=>context {
      set text(size: 字号.五号)
      set par(leading: 1em)
      block(width: measure(t).width, body)
    }
    b([#super("a") 可以通过 xelatex 编译生成模板的使用说明文档；使用 xetex 编译 bnuthesis.ins 时则会从 .dtx 中去除掉文档和注释，得到精简的 .cls 文件])
     
    b([#super("b") 可以通过 xelatex 编译生成模板的使用说明文档；使用 xetex 编译 bnuthesis.ins 时则会从 .dtx 中去除掉文档和注释，得到精简的 .cls 文件])
  }
   
], caption: [三线表带附注])<tlt-2>


如某个表需要转页接排，可以使用 \pkg{longtable} 宏包，需要在随后的各页上重复表的编号。 编号后跟表题（可省略）和“（续）”，置于表上方。续表均应重复表头。

#show figure: set block(breakable: true)
#figure([
  #table(
    columns: 2,
    stroke: none,
    table.hline(),
    [Row 1 ],
    [ 123 ],
    table.hline(),
    [Row 2 ],
    [ 123 ],
    [ Row 3 ],
    [ 123 ],
    [Row 4 ],
    [ 123 ],
    [Row 5 ],
    [ 123 ],
    [Row 6 ],
    [ 123 ],
    [Row 7 ],
    [ 123 ],
    [Row 8 ],
    [ 123 ],
    [Row 9 ],
    [ 123 ],
    [Row 10],
    [ 123 ],
    table.hline(),
  )
], caption: [三线表截断])<tlt-3>



== 算法

算法环境可以使用 ```typ #figure(kind: "algo")[...]```来激活。

#figure([if $n < 0$:#i\
            return null#d\
          if $n = 0$ or $n = 1$:#i\
            return $n$#d\
          \
          let $x <- 0$\
          let $y <- 1$\
          for $i <- 2$ to $n-1$:#i #comment[so dynamic!]\
            let $z <- x+y$\
            $x <- y$\
            $y <- z$#d\
            \
          return $x+y$],
           kind: "algo", 
           supplement: [算法], 
           caption: [计算贺凯鑫的#text(font: ("Segoe UI Emoji"), fill: red,"🐎")数]
           )
#figure([
#text(font: 字体.宋体,size:12pt, weight: "bold")[输入:] $n #sym.gt.eq.slant 0$\
#text(font: 字体.宋体,size:12pt, weight: "bold")[输出:] $y = x^2$ #i \
$y <- 1  $  \ // 等于 y #sym.arrow.l 1 
$X <- x$ \
$N <- n$ \
while $N != 0$  do #i\
if $N$ is even then #i\


], kind: "algo", supplement: [算法], caption: [Calculate $y = x^n$])






```typ 
#figure(image())
```


```py
  def add(x, y):
    return x + y

```