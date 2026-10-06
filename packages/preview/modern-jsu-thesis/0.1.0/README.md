# modern-jsu-thesis

江苏大学本科毕业设计（论文）Typst 模板 | Typst Template for Jiangsu University Undergraduate Thesis

:warning: **注意事项：该模板用于江苏大学本科毕业论文（非官方，只是按照学校给出的word模板复刻，存在不被认可的风险）。**

## 功能特性

- 封面（校徽 + 校名标 + 中英文题目 + 学院 / 班级 / 姓名 / 学号 / 指导教师 / 职称 / 年月）
- 原创性声明页
- 中文摘要（含关键词）
- 英文摘要（ABSTRACT + KEY WORDS）
- 自动目录（三级标题，点线填充）
- 正文（中文章节编号 第X章 / 1.1 / 1.1.1）
- 页眉页脚自动切换（前置部分罗马数字，正文阿拉伯数字）
- 中英文混排字体方案（宋体 / 黑体 / 楷体 / Times New Roman）
- 图表环境（`img` / `tbl`，自动编号与交叉引用）
- 公式、代码块（Consolas）
- GB/T 7714-2015 参考文献（numeric 样式）
- 致谢、附录

## 获取模板

### 方式一：从 Typst Universe 创建（推荐）

```bash
typst init @preview/modern-jsu-thesis:0.1.0 my-thesis
cd my-thesis
```

这会在 `my-thesis` 目录下创建一个干净的项目：

```text
my-thesis/
├── main.typ        # 论文入口：填写信息、撰写正文
├── refs.bib        # BibTeX 参考文献库
└── figures/        # 插图目录
```

模板逻辑与字体全部由 `@preview` 包提供，`main.typ` 中的 `#import` 语句会在创建时自动写入。

### 方式二：克隆 GitHub 仓库

```bash
git clone https://github.com/han0126/modern-jsu-thesis.git
cd modern-jsu-thesis
```

如果需要完整源代码对论文模板进行更多定制，可以选择克隆仓库。其中，控制论文格式的源代码是根目录下的 `template.typ`，随包分发的资源在`sources/`。

## 仓库结构

本模板参照 Typst Universe 的通行做法，将**包入口**与**用户侧入口**分离：

```text
modern-jsu-thesis/
├── typst.toml          # 包清单
├── template.typ        # 包入口（模板核心逻辑，用户通过 @preview 导入）
├── thumbnail.png       # Typst Universe 缩略图
├── sources/            # 封面图片（校徽、校名标）
│   ├── logo.png
│   └── jsu.png
└── template/           # 用户侧入口目录（init 时复制给用户）
    ├── main.typ        # 用户项目入口
    ├── refs.bib        # 参考文献库
    └── figures/        # 插图目录
```

## 使用说明

在 `main.typ` 中通过 `jsu-thesis` 函数配置论文信息，各参数以命名参数传入：

```typst
#import "@preview/modern-jsu-thesis:0.1.0": *		// 导入样式
#import "@preview/modern-jsu-thesis:0.1.0": template as jsu-thesis

#show: jsu-thesis.with(
  zh_title: "中文论文题目",
  zh_keywords: ("关键词1", "关键词2", "关键词3"),
  zh_abstract: [摘要内容……],

  en_title: "English Title",
  en_keywords: ("Keyword 1", "Keyword 2", "Keyword 3"),
  en_abstract: [English abstract……],

  college: [XX学院],
  class: [XX班],
  author: [XX],
  number: [XXXX],
  instructor: [XX],
  post: [XX],
  year: [20XX],
  month: [X],
)
```

| 参数 | 类型 | 说明 | 默认值 |
| --- | --- | --- | --- |
| `zh_abstract` | content | 中文摘要正文 | `[中文摘要]` |
| `zh_title` | str | 中文论文题目 | `"中文论文题目"` |
| `zh_keywords` | array | 中文关键词（3–5 个） | `([key1], [key2], [key3])` |
| `en_abstract` | content | 英文摘要正文 | `[English abstract]` |
| `en_title` | str | 英文论文题目 | `"English title"` |
| `en_keywords` | array | 英文关键词 | `([key1], [key2], [key3])` |
| `college` | content | 学院名称 | `[学院]` |
| `class` | content | 专业班级 | `[班级]` |
| `author` | content | 学生姓名 | `[姓名]` |
| `number` | content | 学号 | `[学号]` |
| `instructor` | content | 指导教师姓名 | `[指导教师姓名]` |
| `post` | content | 指导教师职称 | `[职称]` |
| `year` | content | 年份 | `[2026]` |
| `month` | content | 月份 | `[10]` |

### 添加章节

直接使用 Typst 标准标题语法，一级标题会自动分页并居中排版：

```typst
= 绪论

正文内容……

== 研究背景

=== 国内现状
```

> :warning:注意事项
>
> **引言**、**参考文献**、**致谢**、**附录**四个部分由于涉及特殊格式，即没有数字标号，所以需要使用下述方式作为一级标题
>
> ```typst
> #heading(numbering: none)[引言]
> ```

### 插入图片

模板提供 `img` 函数，自动处理编号与图名：

```typst
#img(
  image("figures/your-image.png", width: 60%),
  caption: [图片说明],
)
```

### 插入表格

```typst
#tbl(
  table(
    columns: (1fr, 1fr),
    align: center + horizon,
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header()[*表头1*][*表头2*],
    table.hline(stroke: 0.8pt),
    [内容1], [内容2],
    table.hline(stroke: 1.5pt),
  ),
  caption: [三线表样例],
)
```

### 公式

```typst
#equation(
  $
    max {F({t_1},{t_2})} = sum^3_(i=1) sum^5_(j=1) T(i,j) dot x_(i j)
  $
)
```

:warning:**注意事项：如要使用`img`、`tbl`等图标、公式样式，需引用下述代码：**

```typst
#import "@preview/modern-jsu-thesis:0.1.0": *
```

### 参考文献

编辑 `refs.bib` 后，在正文中引用：

```typst
据研究显示#cite(<key>)
```

文末的参考文献列表已配置 GB/T 7714-2015 numeric 样式：

```typst
#bibliography("refs.bib", style: "gb-7714-2015-numeric", title: none)
```

## 字体配置

本模板所用到的字体族名如下：

| 用途 | 字体族名 |
| :-: | :-: |
| 宋体 | `SimSun` |
| 黑体 | `SimHei` |
| 楷体 | `KaiTi` |
| 英文 / 数字 | `Times New Roman` |

**字体从 `@preview` 创建的项目无需手动指定 `--font-path`。** 通过 `@preview` 导入时，Typst 会从包内解析字体资源。

> 若克隆仓库后在本地直接编译 `template/main.typ`，则需要额外指定字体路径。

## 编译文档

### 从 Universe 创建的项目

```bash
# 生成 PDF
typst compile main.typ

# 监听文件变化并自动重新编译
typst watch main.typ

# 指定输出文件名
typst compile main.typ thesis.pdf

# 导出为图片
typst compile main.typ "page-{p}.png"
```

### 从克隆的仓库

```bash
typst compile template/main.typ --font-path fonts
```

### 在 Typst Web App 中使用

点击模板页面上的 **Create project in app** 按钮，即可在网页端创建项目。

## 常见问题

**Q：编译时提示 `unknown font family: simsun` / `simhei` / `times new roman`？**

从克隆的仓库直接编译时会出现，因为字体路径未指定。加上 `--font-path fonts` 即可。从 `@preview` 创建的项目不会遇到此问题。

**Q：目录页、页码不对？**

页码分界点由 `template.typ` 中的 `#counter(page).update(1)` 控制（正文起始处）。如需调整前置部分与正文的分界，请修改该位置。

**Q：想修改页边距或行距？**

在 `template.typ` 中搜索 `set page(` 和 `set par(`，正文字号与行距在正文段的 `#set text(...)` / `#set par(leading: ...)` 处。

**Q：`refs.bib` 是空的，参考文献怎么办？**

从文献管理工具（Zotero、JabRef 等）导出 BibTeX 格式内容粘贴进去即可，或使用 Zotero 的 Better BibTeX 插件自动同步。

**Q：想自定义章节结构？**

用户项目的 `main.typ` 是自包含的，直接增删 `= 一级标题` 即可，无需依赖其他文件。若需要更细的拆分，可自行 `#include` 其他 `.typ`。

## 致谢

感谢 Typst 社区在中文排版方面的工作。

- `numbly`提供计数支持：[numbly](https://github.com/flaribbit/numbly)
- `cuti`提供宋体类word描边加粗：[cuti](https://github.com/csimide/cuti)
- `cumcm-muban`作为母版改进：[CUMCM-typst-template](https://github.com/a-kkiri/CUMCM-typst-template)

## 支持项目

如果这个模板对你有帮助，请：

- 给项目[点个 Star](https://github.com/han0126/modern-jsu-thesis)
- 提交 Bug 报告和功能建议
- Fork 并改进模板
- 分享给更多需要的同学

## 许可证（License）

本项目中的 Typst 模板源代码依据 MIT 许可证进行授权。

模板内置的校徽（`sources/logo.png`）和校名字标（`sources/jsu.png`）为江苏大学标识资源，属于受商标权、著作权保护的资源文件，不在 MIT 许可证授权范围内，其知识产权归相关权利人所有。上述资源仅限用于学位论文排版的学术、非商业用途，除法律法规另有规定或已获得相关授权外，不得对上述资源进行再分发、修改或用于其他用途。使用者需自行确认其对资源的使用符合江苏大学的有关规定及适用法律法规。

The Typst template source code is licensed under the MIT License.

The school logo (`sources/logo.png`) and school name (`sources/jsu.png`) built into the template are the logo resources of Jiangsu University, which are resource files protected by trademark rights and copyrights, and are not within the scope of MIT license authorization, and their intellectual property rights are owned by the relevant rights holders. The above resources are only used for academic and non-commercial purposes in typesetting dissertations, and shall not be redistributed, modified or used for other purposes unless otherwise stipulated by laws and regulations or authorized by relevant authorities. Users need to confirm that their use of resources conforms to the relevant regulations of Jiangsu University and applicable laws and regulations.
