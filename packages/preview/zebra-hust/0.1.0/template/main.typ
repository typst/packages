#import "@preview/zebra-hust:0.1.0": report, references, appendix, img

// 配置部分

/*
#let cover_config = (
  title: [文档标题],
  course: [课程名称],
  class: [班级名称],
  student-id: [学号],
  name: [作者姓名],
  teacher: [指导老师],
  report-date: [报告完成日期],
  college: [学院名称],
)

#let outline_config = (
  depth: 3,
  font_sizes: (12pt, 12pt, 12pt),
)

*/

#show: report.with(
  preset: "course-report",
  /*
  cover: cover_config,
  outline: outline_config,
  */
)

// 正文开始

#align(center)[
  = 1. 图片示例
]

#img(path("images/go.png"), width: 20%, caption: "这是 Golang, 一个编程语言。")

== 1.1 子标题
123

图像识别相关研究见 @zhang2020，人工智能基础可参考 @zhao2019。

$limits(1) > 2$

= 2. 代码示例

```go
package main
import "fmt"
func main() {
    fmt.Println("Hello, World!")
}
```

= 3. 表格示例

实验结果如 @tab-results 所示。以下数值仅用于演示排版。

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    inset: 8pt,
    stroke: none,
    table.hline(stroke: 0.8pt),
    table.header([*数据组*], [*样本数量*], [*准确率*]),
    table.hline(stroke: 0.5pt),
    [训练集], [800], [96.5%],
    [验证集], [100], [94.0%],
    [测试集], [100], [93.0%],
    table.hline(stroke: 0.8pt),
  ),
  supplement: [表],
  caption: [实验结果汇总],
) <tab-results>

= 4. 文献引用示例

期刊论文可通过文献键引用，例如 @zhang2020；专著示例见 @zhao2019。
同一来源再次引用时沿用已有编号。多作者文献见 @sun2021，网络资源见 @li2022。

#references(source: path("references.bib"))

#appendix(title: [实验记录])[
  本附录展示补充说明的写法，标题自动编号为“附录 A”。

  == 运行步骤

  + 将正文中的 Go 代码保存为 `hello.go`。
  + 执行 `go run hello.go`。
  + 检查终端输出是否为 `Hello, World!`。
]

#appendix(title: [原始数据])[
  本附录展示代码块形式的原始数据，标题自动编号为“附录 B”。

  ```csv
  dataset,samples,accuracy
  train,800,0.965
  validation,100,0.940
  test,100,0.930
  ```
]
