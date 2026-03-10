#import "@preview/modern-hfut-report:0.1.0": *

#show: doc => hfut-report(
  title: "模板使用指南",
  department: "填写你的学院",
  major: "填写你的专业",
  class: "填写你的班级",
  author: "填写你的名字",
  student-id: "填写你的学号",
  supervisor: "填写你的导师",
  date: "today",
  show-abstract: true,
  show-contents: true,
  abstract: [
    本文档是合肥工业大学课程设计报告模板的使用指南。本模板基于 Typst 构建，提供了完整的课程设计报告格式，包括封面、摘要、目录、正文、参考文献和附录等部分。

    模板采用分层的标题样式设计，一级标题使用黑体加粗，二级和三级标题使用宋体加粗，确保视觉层次清晰。同时提供了自动编号、灵活的日期设置、代码块美化等实用功能。

    建议用户在使用前完整阅读本指南，以充分了解模板的功能和使用方法。
  ],
  keywords: ("Typst", "课程设计", "报告模板", "合肥工业大学"),
  doc
)

= 使用说明

== 环境配置

首先，需要配置好 Typst 环境。推荐以下两种方式：

=== 在线编辑

Typst Web App#footnote[https://typst.app，Typst App官网] 提供在线编辑和编译功能，适合不想在本地安装软件的用户。

只需在Web App Templates#footnote[https://typst.app/universe/search/?kind=templates，Typst模板市场]中搜索「modern-hfut-report」即可进入详情页，点击「Create project in app」即可在线编辑。

=== 本地编辑

这一部分可具体参考小蓝书#footnote[https://typst-doc-cn.github.io/tutorial，Typst中文教程]。

+ 首先安装Typst环境：
  + *Windows用户*：推荐使用Winget安装（终端）
    ```powershell
    winget install --id Typst.Typst
    ```
  
  + *macOS用户*：推荐使用Homebrew安装（终端）
    ```bash
    brew install typst
    ```
  
  + *Linux用户*：大多数发行版的包管理器都已收录Typst
    ```bash
    # Ubuntu/Debian
    sudo apt install typst
    
    # Arch Linux
    sudo pacman -S typst
    
    # Fedora
    sudo dnf install typst
    ```

+ 推荐使用 VSCode + Tinymist 插件进行本地编辑：
  + 在官网#footnote[https://code.visualstudio.com/download，VSCode下载链接] 下载安装 VSCode
  + 在扩展市场中搜索并安装 Tinymist 插件
  + 用VSCode打开项目即可本地编辑

== 快速开始

=== 创建新项目

```bash
typst init @preview/modern-hfut-report:0.1.0
cd modern-hfut-report
```

=== 编辑配置

编辑 `main.typ` 文件，修改个人信息：

```typst
#show: doc => hfut-report(
  title: "数据结构与算法",        // 课程名称
  department: "计算机与信息学院", // 学院
  major: "计算机科学与技术",      // 专业
  class: "计算机2023-1班",       // 班级
  author: "张三",                // 姓名
  student-id: "2023114514",     // 学号
  supervisor: "李四",           // 指导教师
  date: "today",               // 日期
  // ... 其他配置
  doc
)
```

=== 编译输出

- *在线编辑*：点击「Share」按钮右侧的下载图标导出PDF
- *本地编辑*：在 VSCode 文件顶部选择「预览」和「导出PDF」可以实现对应功能（需要Tinymist插件）

= 模板功能

== 参数配置

模板提供了丰富的配置参数：

=== 必填参数
- `title`: 课程名称
- `department`: 学院名称
- `major`: 专业名称  
- `class`: 班级
- `author`: 学生姓名
- `student-id`: 学号
- `supervisor`: 指导教师

=== 可选参数
- `date`: 日期设置
  - `"today"`: 自动使用今天日期（推荐）
  - `"2025年6月25日"`: 手动指定具体日期
- `abstract`: 摘要内容
- `keywords`: 关键词数组

== 字体系统

模板采用分层的字体设计，符合学术规范：

=== 一级标题
- *字体*: 黑体加粗 + 18pt
- *用途*: 主要章节标题（如"引言"、"结论"）
- *特点*: 视觉突出，居中显示

=== 二级/三级标题
- *字体*: 宋体加粗 + 15pt/13pt
- *用途*: 章节子标题
- *特点*: 通过 zh-format 库实现加粗效果

=== 正文与标签
- *正文*: 宋体 12pt
- *重要标签*: 宋体加粗（如"关键词："）

== 自动功能

=== 自动编号
标题支持多级自动编号：
- 一级标题: 1, 2, 3...
- 二级标题: 1.1, 1.2, 2.1...  
- 三级标题: 1.1.1, 1.1.2...

=== 自动生成
- 目录自动生成，支持3级标题
- 页眉页脚自动添加
- 页码自动编号

= 使用示例

== 标题层次

```typst
= 一级标题
== 二级标题  
=== 三级标题
```

效果演示：

= 一级标题示例

== 二级标题示例

=== 三级标题示例

这里是正文内容，使用宋体 12pt 字号。

== 段落缩进

模板默认*不启用全局段落首行缩进*，需要缩进时手动添加 `#h(2em)` 即可。

=== 不缩进的段落（默认）

```typst
这是一段普通文本，段首不会自动缩进。
```

效果：

这是一段普通文本，段首不会自动缩进。

=== 缩进的段落（手动添加）

```typst
#h(2em)这是一段需要缩进的文本，使用 #h(2em) 手动添加两个字符的缩进。
```

效果：

#h(2em)这是一段需要缩进的文本，使用 #h(2em) 手动添加两个字符的缩进。

=== 混合使用

```typst
第一段不缩进，直接书写即可。

#h(2em)第二段需要缩进，在段首添加这个。

第三段又不缩进了。
```

效果：

第一段不缩进，直接书写即可。

#h(2em)第二段需要缩进，在段首添加这个。

第三段又不缩进了。

== 列表

=== 有序列表

+ 第一项
+ 第二项
  + 子项目一
  + 子项目二

=== 无序列表  

- 无序项目一
- 无序项目二
  - 无序子项目

=== 术语列表

/ Typst: 现代化的排版系统
/ 模板: 预定义的文档格式

== 图表

引用图表时需要添加相应前缀：图片用 `@fig:`，表格用 `@tbl:`。

#figure(
  table(
    columns: 3,
    stroke: 0.5pt,
    [项目], [描述], [状态],
    [封面], [自动生成], [✓],
    [目录], [自动生成], [✓], 
    [编号], [自动编号], [✓],
  ),
  caption: "模板功能列表"
) <tbl:功能列表>

如@tbl:功能列表 所示，模板提供了完整的自动化功能。

=== 插入图片

使用 `image()` 函数插入图片，支持设置宽度、高度等参数：

```typst
#figure(
  image("assets/HFUT_badge_zh&en_Vertical.svg", width: 60%),
  caption: "合肥工业大学校徽"
) <fig:校徽>
```
// 使用pagebreak强制换页
#pagebreak()

效果：

#figure(
  image("assets/HFUT_badge_zh&en_Vertical.svg", width: 60%),
  caption: "合肥工业大学校徽"
) <fig:校徽>

引用图片：如@fig:校徽 所示，这是合肥工业大学的校徽标识。

=== 数学绘图

一般建议将绘图部分放在 Python 或 MATLAB 等软件中完成，然后导入生成的图像。不过 Typst 也提供了一些绘图包，如 lilaq#footnote[https://typst.app/universe/package/lilaq] 包，可以直接在文档中绘制函数图像。

以下是 $sin x$ 的函数图像示例：

#figure(
  {
    import "@preview/lilaq:0.3.0" as lq
    let x = lq.linspace(0, 10)
    lq.diagram(
      title: [$sin x$ 的函数图像],
      xlabel: $x$,
      ylabel: $y$,

      lq.plot(x, x.map(x => calc.sin(x))),
    )
  },
  caption: "数学绘图示例"
) <fig:数学绘图>

=== 流程图绘制

对于复杂的图形，建议使用「所见即所得」式的绘图工具绘制。Typst 也有专门的绘图包：
- *cetz*#footnote[https://typst.app/universe/package/cetz]：基础绘图包，类似 LaTeX 的 tikz
- *fletcher*#footnote[https://typst.app/universe/package/fletcher]：专注于流程图和图表绘制

以下使用 fletcher 包绘制数学图表：

#figure(
  {
    import "@preview/fletcher:0.5.8": diagram, node, edge
    diagram(
      cell-size: 15mm,
      $
        G edge(f, ->) edge("d", pi, ->>) & im(f) \
        G slash ker(f) edge("ur", tilde(f), "hook-->")
      $,
    )
  },
  caption: "数学图表示例"
) <fig:数学图表>

更实用的流程图示例（横向）：

#figure(
  {
    import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
    diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      node((0,0), [开始], corner-radius: 5pt, extrude: (0, 3)),
      edge("-|>"),
      node((1,0), [输入数据], corner-radius: 2pt),
      edge("-|>"),
      node((2,0), [处理], corner-radius: 2pt),
      edge("-|>"),
      node((3,0), [输出结果], corner-radius: 2pt),
      edge("-|>"),
      node((4,0), [结束], corner-radius: 5pt, extrude: (0, 3)),
    )
  },
  caption: "横向流程图示例"
) <fig:横向流程图>

纵向流程图示例（带分支判断）：

#figure(
  {
    import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
    diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      spacing: (15mm, 10mm),
      
      // 开始
      node((1, 0), [开始], corner-radius: 5pt, extrude: (0, 3)),
      edge("-|>"),
      
      // 输入
      node((1, 1), [输入数据], corner-radius: 2pt),
      edge("-|>"),
      
      // 第一个判断条件
      node((1, 2), [数据有效?], shape: fletcher.shapes.diamond),
      
      // 左分支：无效
      edge((1, 2), (0, 3), "-|>", [否], label-side: left),
      node((0, 3), [错误处理], corner-radius: 2pt),
      edge((0, 3), (1, 6), "-|>"),
      
      // 右分支：有效
      edge((1, 2), (2, 3), "-|>", [是], label-side: right),
      node((2, 3), [数据处理], corner-radius: 2pt),
      edge((2, 3), (2, 4), "-|>"),
      
      // 第二个判断
      node((2, 4), [需要保存?], shape: fletcher.shapes.diamond),
      
      // 保存分支：是
      edge((2, 4), (3, 5), "-|>", [是], label-side: right),
      node((3, 5), [保存结果], corner-radius: 2pt),
      edge((3, 5), (1, 6), "-|>"),
      
      // 不保存分支：否
      edge((2, 4), (1, 6), "-|>", [否], label-side: left),
      
      // 所有分支汇合到输出结果
      node((1, 6), [输出结果], corner-radius: 2pt),
      edge("-|>"),
      
      // 结束
      node((1, 7), [结束], corner-radius: 5pt, extrude: (0, 3)),
    )
  },
  caption: "纵向流程图示例"
) <fig:纵向流程图>


== 数学公式

=== 行内公式
可以在文中插入行内公式，如 $E = m c^2$。

=== 行间公式
带编号的行间公式：
// <>中无需写eqt:
$ sum_(i=1)^n i = (n(n+1))/2 $ <求和公式>

引用公式 @eqt:求和公式，我们可以得到...

不带编号的公式：
// 后面加上 <->
$ integral_0^1 x^2 dif x = 1/3 $ <->

== 文本格式

=== 加粗

对于中文，模板通过 zh-format 库实现加粗效果。

使用 `*文本*` 创建加粗效果：

```typst
这是*加粗文本*的示例。
```

效果：

这是*加粗文本*的示例。

=== 斜体与倾斜

对于中文，模板通过 zh-format 库实现倾斜效果。

使用 `_文本_` 创建倾斜效果：

```typst
英文斜体：_italic text_
中文倾斜：_这是倾斜的中文_
混合文本：_中英混合 mixed text_
```

效果：

英文斜体：_italic text_

中文倾斜：_这是倾斜的中文_

混合文本：_中英混合 mixed text_

=== 组合使用

可以组合使用加粗和斜体：

```typst
英文：*加粗* 和 _italic_ 以及 *_加粗斜体_*

中文：*加粗* 和 _倾斜_ 以及 *_加粗倾斜_*

混合：*Bold* 和 _斜体_ 以及 *_Bold斜体_*
```

效果：

英文：*加粗* 和 _italic_ 以及 *_加粗斜体_*

中文：*加粗* 和 _倾斜_ 以及 *_加粗倾斜_*

混合：*Bold* 和 _斜体_ 以及 *_Bold斜体_*

=== 其他文本样式

```typst
- 删除线：#strike[删除的文本]
- 下划线：#underline[重要内容]
- 下标：H#sub[2]O
- 上标：x#super[2]
```

效果：

- 删除线：#strike[删除的文本]
- 下划线：#underline[重要内容]
- 下标：H#sub[2]O
- 上标：x#super[2]

*下划线说明*：

本模板自动修正了中文字体下划线显示为虚线的问题。

1. *自动宽度下划线*：使用 `#underline[文本]`，下划线长度自动匹配文本宽度

```typst
#underline[中文下划线] 和 #underline[English underline]
```

效果：#underline[中文下划线] 和 #underline[English underline]

2. *自定义下划线*：使用 `#u(width: 长度, offset: 偏移量)[文本]` 自定义下划线宽度和位置

参数说明：
- `width`: 下划线的宽度（如 `10em`、`15em`）
- `offset`: 下划线向下的偏移量（如 `0.35em`、`0.4em`），数值越大，下划线越靠下

```typst
#u(width: 10em)[姓名]
#u(width: 15em, offset: 0.4em)[学号：2023114514]
```

效果：

#u(width: 10em)[姓名]

#u(width: 15em, offset: 0.4em)[学号：2023114514]

== 代码

=== 行内代码
使用 `python main.py` 命令执行代码。

=== 代码块

```python
def fibonacci(n):
    """计算斐波那契数列"""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# 使用示例
for i in range(10):
    print(f"F({i}) = {fibonacci(i)}")
```

代码块支持语法高亮，并有美化的边框和背景。

```typst  
// Typst 代码示例
#let greet(name) = [Hello, #name!]
#greet("World")
```

= 高级功能

== 自定义样式

如果需要自定义样式，可以：

+ *修改参数*: 通过模板参数调整基本设置
+ *扩展样式*: 在文档中添加自定义 `show` 规则
+ *Fork 模板*: 对于深度定制，建议 fork 模板仓库

== 常见问题

=== 字体问题
- 确保系统中安装了宋体和黑体
- zh-format 库会自动处理中文字体加粗、斜体和下划线

=== 编译问题  
- 检查 Typst 版本（推荐 0.11.0+）
- 确保网络连接正常（首次需要下载依赖）

=== 图片问题
- 图片文件需要放在正确的相对路径
- 支持 PNG、JPG、SVG 格式

== 依赖管理

模板使用的外部依赖：
- `zh-format`: 中文格式化支持
- `i-figured`: 公式和图表编号管理

所有依赖会在初始化时自动安装，无需手动配置。

= 贡献与反馈

欢迎贡献代码改进模板：
+ Fork 项目仓库
+ 创建功能分支
+ 提交 Pull Request

= 致谢

感谢 Typst 社区的支持，以及参考的各种优秀模板项目。

特别感谢：
- Typst 开发团队
- 所有第三方依赖库作者