# Elegant Paper Typst Template

一个用于创建优雅学术论文风格文档的 Typst 模板。

灵感来源于一个充满想象力的示例项目：[The Mahiro Papers](https://github.com/xyber-nova/the-mahiro-papers)。

## ✨ 特性

*   **自动化标题页**: 自动生成包含标题、多作者（含机构、备注、邮箱）、摘要和关键词的专业标题页。
*   **可定制目录**: 支持一键生成文档目录 (`enable-outline: true`)。
*   **优雅的预设样式**: 预设了适合学术论文的字体大小、段落间距、标题编号和样式。
*   **引用与参考文献**: 完美支持 Typst 的引用 (`@label`) 和参考文献 (`#bibliography`) 功能。
*   **图表与表格**: 轻松插入和格式化图表 (`#figure`, `#image`) 与表格 (`#table`)。
*   **配置灵活**: 可自定义纸张大小 (`paper`) 和基础字体大小 (`font-size`)。
*   **中文优化**: 集成了 `zh-kit`，对中文排版提供良好支持。

## 🚀 使用方法

### 1. 导入模板

你可以通过以下两种方式导入此模板：

**方式一：使用 Typst 包管理器 (推荐)**

如果你的项目使用 Typst CLI，可以直接通过包管理器导入 `@preview/elegant-paper`：

```typst
// main.typ
#import "@preview/elegant-paper:0.1.0": elegant-paper
// 请将 0.1.0 替换为最新的版本号
```

**方式二：本地导入**

将 [`lib.typ`](lib.typ:1) 文件复制到你的项目目录下，然后在你的 Typst 文件顶部导入 `elegant-paper` 函数：

```typst
// main.typ
#import "lib.typ": elegant-paper
```

*(请确保路径正确)*

### 2. 调用 `elegant-paper` 函数

使用 `#show` 规则将 `elegant-paper` 函数应用于你的文档，并通过 `.with()` 方法配置参数：

```typst
// main.typ
#import "lib.typ": elegant-paper

#show: elegant-paper.with(
  // --- 基础配置 ---
  paper: "a4",             // 纸张大小 (默认 "a4")
  enable-outline: true,    // 是否生成目录 (默认 false)

  // --- 字体配置 ---
  font: (
    font-size: 10pt        // 基础字体大小 (默认 10pt)
  ),

  // --- 标题页信息 ---
  title: (
    title: "你的论文标题",
    authors: (
      (
        name: "作者一 (名字)",
        institution: "作者一的机构",
        email: "author1@example.com" // 邮箱可选
      ),
      (
        name: "作者二 (名字)",
        institution: "作者二的机构",
        note: "通讯作者" // 备注可选 (如通讯作者)
      ),
      // 可以添加更多作者...
    ),
    date: "2024年5月28日", // 日期可选 (示例模板中有)
    abstract: """
      这里是你的论文摘要。它可以是较长的文本块。
      摘要内容会自动处理缩进和排版。
      """,
    keywords: ("关键词一", "关键词二", "Typst模板") // 关键词元组
  ),

  // --- 参考文献 ---
  // 注意：参考文献需要在文档末尾显式调用 bibliography 函数
  // bibliography-path: "references.bib" // 这是一个示例，实际在下方调用
)

// --- 正文内容 ---

= 引言 <sec:intro>

欢迎使用 Elegant Paper Typst 模板！这里是你的论文正文内容。

你可以使用标准的 Typst 语法编写，例如：

== 研究背景

这里是研究背景部分。你可以添加引用 @example_ref。

*   这是一个列表项。
*   这是另一个列表项。

=== 更深层次的小节

支持多级标题。

#figure(
  rect(width: 60%, height: 2cm, fill: blue.lighten(80%)), // 用矩形代替图片
  caption: [这是一个图表示例。]
) <fig:example>

如图 @fig:example 所示...

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: center,
    table.header([ID], [名称], [值]),
    [1], [项目A], [100],
    [2], [项目B], [200],
  ),
  caption: [这是一个表示例。]
) <tbl:example>

如表 @tbl:example 所示...

= 结论 <sec:conclusion>

这里是结论部分。

// --- 参考文献 ---
// 在文档末尾调用 bibliography 函数
#bibliography("references.bib", title: "参考文献", style: "gb-7714-2015-author-date")

```

### 3. 编写正文

在 `#show` 规则之后，使用标准的 Typst 标记语言编写你的论文内容，包括各级标题 (`=`, `==`, `===`)、段落、列表、图表、表格和引用等。

### 4. 处理参考文献

1.  创建一个 BibTeX 文件（例如 `references.bib`）。
2.  在你的 Typst 文档中需要引用的地方使用 `@key` 语法，其中 `key` 是 BibTeX 文件中对应的条目键名。
3.  在文档的末尾（通常是正文之后）使用 `#bibliography` 函数来生成参考文献列表，指定 `.bib` 文件的路径和可选的标题及样式。

```typst
// references.bib (示例)
@article{example_ref,
  author  = {作者姓, 作者名},
  title   = {示例文献标题},
  journal = {虚拟期刊},
  year    = {2024},
  volume  = {1},
  number  = {1},
  pages   = {1-10}
}

// main.typ (末尾)
#bibliography("references.bib", title: "参考文献", style: "ieee") // 可选不同样式
```

## 📜 许可证

本项目采用 [GNU Lesser General Public License v3.0 (LGPL-3.0)](https://www.gnu.org/licenses/lgpl-3.0.html) 许可证。这意味着：

*   **您可以自由地：**
    *   **使用 (Use):** 在您的任何 Typst 项目（无论是开源还是闭源）中使用本模板。
    *   **分发 (Distribute):** 分发本模板的原始版本或您修改后的版本。
    *   **修改 (Modify):** 修改本模板的源代码。
*   **在以下条件下：**
    *   **共享修改 (Share Alike for Modifications to the Library):** 如果您修改了本模板的源代码 (`lib.typ` 或其他核心文件)，并且您选择分发这个修改后的版本，那么这个修改后的版本也必须在 LGPL-3.0 或 GPL-3.0 许可下提供。
    *   **声明和版权 (Notice and Copyright):** 您必须保留原始的版权声明和许可证文本。
    *   **提供源码 (Source Code Provision):** 如果您分发包含本模板（或其修改版）的二进制或编译形式（例如，作为一个更大的应用程序的一部分），您需要提供一种方式让接收者能够获取模板的源代码。对于 Typst 模板，这通常意味着分发 `.typ` 文件本身即可满足要求。
*   **请注意：**
    *   **链接不“传染” (No "Viral" Effect on Your Project):** 仅仅在您的 Typst 文档或项目中通过 `#import` 使用本模板，并**不会**强制要求您的整个文档或项目也必须采用 LGPL-3.0 许可证。您可以为您的最终文档（例如生成的 PDF）或包含您文档的项目选择任何您希望的许可证。

原始示例 [`template/main.typ`](template/main.typ:1) 及其相关资源可能遵循其原始仓库 [The Mahiro Papers](https://github.com/xyber-nova/the-mahiro-papers) 的许可（CC BY-NC-SA 4.0）。
