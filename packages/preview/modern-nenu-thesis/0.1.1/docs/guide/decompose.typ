#import "../book.typ": *

#show: book-page.with(title: "多文件书写")
#show: checklist.with(fill: white.darken(20%), stroke: blue.lighten(20%))

#let page-self = "/guide/decompose.typ"

= 分章节进行书写

如果你的论文比较长，但是不想全放在 `thesis.typ` 一个文件中，那么可以新建其他 `typ` 文件来将论文的章节进行拆分，但记得将这些文件导入到 `thesis.typ` 中。

例如：

#myexample[
  ```typ
  // sample.typ
  = 测试用
  ```

  ```typ
  // thesis.typ
  ...
  #show: mainmatter
  #include "sample.typ"
  ```
]

注意，我们需要在合适的位置：

- `#show: mainmatter` 之后（为了保证你导入的内容能够适应论文正文的格式）
- `#show: appendix` 之前（除非你想添加附录的内容）

并按照章节的出现的顺序，依次 `#include` 上你需要导入的页面

#mynotify[
  注意，你并不需要在新建的 `.typ` 文件中写入任何格式相关的配置，这些我们已经为你配置完成。

  如果你需要使用其他包，导入即可
]


