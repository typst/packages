== 使用该模板

模板实例的目录结构如下：

```bash
.
├── assets
│   └── logo.svg
├── chapters
│   ├── 01-basic-syntax.typ
│   └── 02-user-guide.typ
├── main.typ
└── references.bib
```

其中，`main.typ` 是模板的入口文件，包含了论文的整体结构和内容组织；`chapters` 目录下的 `.typ` 文件分别对应论文的不同章节；`assets` 目录存放了论文中使用的图片等资源；`references.bib` 是论文的参考文献文件。

在 `main.typ` 的开头，你会看到以下代码：

```typ
#import "@preview/unofficial-ouc-bachelor-thesis:0.2.0": project

#show: project.with(
  title: (
    zh: ("城市空气质量时空分布特征", "及其影响因素分析"),
    en: "The Practice of Dance Based on Singing, Dancing, Rapping and Basketball",
  ),
  author: (name: "蔡徐坤", id: "123456789"),
  advisor: "唱跳导师",
  college: "信息科学与工程学院",
  department: "计算机科学与技术2017级",
  abstract: (
    zh: [
      关于这个事，我简单说两句，你明白就行，总而言之这个事呢，现在就是这个情况，具体的呢，大家也都看得到，也得出来说那么几句，可能你听的不是很明白，但是意思就是那么个意思，不知道的你也不用去猜，这种事情见得多了，我只想说懂得都懂，不懂的我也不多解释，毕竟自己知道就好，细细品吧。
    ],
    en: [
      #lorem(100)
    ],
  ),
  keywords: (
    zh: ("关于这个事", "我简单说两句", "你明白就行"),
    en: ("lorem ipsum", "dolor sit amet", "consectetur adipiscing elit"),
  ),
  bibliography: read("references.bib"),
  acknowledgments: [
    在论文的最后我想向所有帮助支持过我的亲人、朋友、老师致以崇高的敬意和真诚的感谢，感谢你们在我的学习和科研中给予的生活和工作的支持。

    这段时光中，我要特别感谢指导老师在选题、研究方法和论文写作上的悉心指导；感谢同学和朋友在我碰到问题时给予帮助；最后特别感谢我的父母，感谢你们对我学习生涯的支持与鼓励。
  ],
  config: (
    fonts: (
      宋体: "SimSun",
      黑体: "SimHei",
      楷体: "KaiTi",
      仿宋: "FangSong",
      西文: "Times New Roman",
      等宽: ("Consolas", "Courier New", "SimSun"),
    ),
    numbering: (
      (figure.where(kind: raw), figure, "1-1"),
      (figure.where(kind: "algorithm"), figure, "1-1"),
    ),
  ),
)
```

相信聪明的你已经看出来了，这段代码是在使用 `project` 组件来构建论文的整体结构，并传入了论文的标题、作者信息、摘要、关键词、参考文献和致谢等内容。如果你不太熟悉 Typst 的语法，你可以直接修改这些字段的内容来适配你自己的论文。

在 `project` 的设计里：

- `title` 字段支持中英文两种语言的输入，其中中文（`zh`）可以是一个字符串或者一个字符串数组（如果标题需要分成几行显示的话，分割处会自动换行）；
- `author` 字段包含了作者的姓名和学号；
- `advisor`、`college` 和 `department` 分别对应指导教师、学院和专业信息；
- `abstract` 和 `keywords` 同样支持中英文输入，其中 `keywords` 的中文和英文部分都是字符串数组，表示多个关键词；
- `bibliography` 字段可以直接读取 `.bib` 文件，但一定不要忘记使用 `read()` 函数来读取文件内容，否则它会被当成普通字符串处理；
- `acknowledgments` 则是直接输入内容。
- `config` 字段用于集中覆盖模板的可配置项。当前支持 `fonts` 和 `numbering` 两部分：

  ```typ
  config: (
    fonts: (
      宋体: "SimSun",
      黑体: "SimHei",
      楷体: "KaiTi",
      仿宋: "FangSong",
      西文: "Times New Roman",
      等宽: ("Consolas", "Courier New", "SimSun"),
    ),
    numbering: (
      (figure.where(kind: raw), figure, "1-1"),
      (figure.where(kind: "algorithm"), figure, "1-1"),
    ),
  )
  ```

  其中 `config.fonts` 会覆盖默认字体映射，不传时继续使用模板内置配置；`config.numbering` 中的每一项都形如 `(选择器, 目标元素, 编号格式)`，只负责编号模式本身。如果你只想恢复默认行为，删掉对应子项即可。

在 `main.typ` 的后半部分，我们使用了 `#include` 指令来引入了两个章节的内容：

```typ
= 绪论

#include "chapters/01-basic-syntax.typ"

= 使用指南

#include "chapters/02-user-guide.typ"
```

每个章节都是一个独立的 `.typ` 文件，这样做的好处是可以让论文的结构更加清晰，内容也更容易管理和维护。你可以在这些章节文件中使用任何 Typst 支持的语法来编写你的论文内容，比如文本、图片、表格、公式等等。

当然，如果你不习惯使用 `#include` 来引入章节内容，你也可以直接把章节的内容写在 `main.typ` 中。

== 社区包示例

Typst Universe 里有很多现成的组件可以直接拿来扩展正文。例如 #link("https://typst.app/universe/package/lovelace/")[lovelace] 可以把嵌套列表排版成伪代码，很适合课程设计、算法描述和实验流程说明。

#figure(
  ````typ
  #import "@preview/lovelace:0.3.1": pseudocode-list

  #pseudocode-list[
    + *procedure* Merge-Sort(arr)
    + *if* len(arr) <= 1 *then*
      + *return* arr
    + *end*
    + mid := floor(len(arr) / 2)
    + left := Merge-Sort(arr[..mid])
    + right := Merge-Sort(arr[mid..])
    + *return* Merge(left, right)
  ]
  ````,
  caption: "使用 lovelace 编写伪代码",
) <lovelace-code>

#import "@preview/lovelace:0.3.1": pseudocode-list

#figure(
  kind: "algorithm",
  supplement: [算法],
  pseudocode-list[
    + *procedure* Merge-Sort(arr)
    + *if* len(arr) <= 1 *then*
      + *return* arr
    + *end*
    + mid := floor(len(arr) / 2)
    + left := Merge-Sort(arr[..mid])
    + right := Merge-Sort(arr[mid..])
    + *return* Merge(left, right)
  ],
  caption: "lovelace 渲染效果示例",
) <lovelace-example>

@lovelace-example 展示了渲染后的伪代码效果。这里使用的是 Typst Universe 页面截至 2026 年 4 月 26 日展示的 `0.3.1` 版本导入方式；如果后续版本升级，只要把 `#import` 里的版本号一起更新即可。
