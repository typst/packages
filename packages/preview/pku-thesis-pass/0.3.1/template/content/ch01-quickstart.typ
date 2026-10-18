#import "@preview/pku-thesis-pass:0.3.1": system-state, font-set, fakebold-rules, show-cn-fakebold, booktab, code-block

== 安装与环境配置

Typst 是一个现代化的排版系统，可以通过以下方式使用：

#strong[在线使用]：访问 typst.app，注册账号后即可在线编辑。在线版本无需安装，支持实时预览和协作编辑。

#strong[本地安装]：
- 从 #link("https://github.com/typst/typst/releases")[GitHub Releases] 下载对应平台的可执行文件
- 使用包管理器安装：`brew install typst`（macOS）或 `cargo install typst-cli`（通用），本模板需要 Typst 0.15.0 或更高版本。

  ```bash
  # 查看当前 Typst 版本
  typst --version
  ```

#strong[编辑器支持]：
- VS Code 和 Positron：安装 Tinymist 插件
- Neovim：使用 typst.vim 或 typst-preview.nvim
- 其他编辑器：大多数现代编辑器都有社区维护的 Typst 支持

== 获取模板

=== 方式一：从 Typst Universe 创建（推荐）

```bash
typst init @preview/pku-thesis-pass:0.3.1 my-thesis
cd my-thesis
```

这会在 `my-thesis` 目录下创建一个包含 `assets`、`content`、`ref.bib` 和 `thesis.typ` 的干净项目。

进入 `my-thesis` 目录后，使用以下命令编译文档：

```bash
typst compile thesis.typ
```

自带的 `thesis.typ` 文件渲染为 `thesis.pdf`，就是一份完整的论文示例文档和用户指南。

=== 方式二：克隆仓库

```bash
git clone https://github.com/chuxinyuan/pku-thesis-pass.git
cd pku-thesis-pass
```

如果需要完整的源代码对论文模板进行更多的定制，可以选择克隆仓库。其中，控制论文格式的源代码放在 `format` 目录下，模板放在 `template` 目录下。

进入 `pku-thesis-pass` 目录后，使用以下命令编译文档：

```bash
typst compile template/thesis.typ --root .
```

无论哪种方式，获取模板后，你都可以直接编辑对应位置的 `thesis.typ`（方式一：`thesis.typ`；方式二：`template/thesis.typ`）即可开始写作。

== 字体配置

本模板的字体配置在 `format/utils/font.typ` 中定义，模板为每个平台预定义了字体方案，通过 `system` 参数切换：`"windows"` / `"macos"` / `"linux"`，默认使用 Windows 系统字体方案。

#booktab(
  width: 100%,
  columns: (auto, 1fr),
  align: (left, left),
  caption: "Windows 系统字体方案",
  [*用途*],
  [*字体列表*],
  [仿宋],
  [Times New Roman, FangSong],
  [宋体],
  [Times New Roman, NSimSun],
  [黑体],
  [Times New Roman, SimHei],
  [楷体],
  [Times New Roman, KaiTi],
  [代码],
  [Consolas, NSimSun],
  [英文衬线],
  [Times New Roman],
  [英文无衬线],
  [Arial],
) <windows-font>

如果您使用的是 macOS 或者 Linux 系统，但是您希望渲染出和 Windows 系统下一样的字体效果，您也可以设置 `system: windows`，但是需要事先在系统里安装 @windows-font 所示的全部字体。

=== 字体族校验

下面按当前生效的字体方案实时渲染各字体族示例，请核对本机是否正确安装与渲染：

#context {
  let sys = system-state.get()
  let fonts = font-set.at(sys, default: font-set.windows)
  let bold = fakebold-rules.at(sys, default: fakebold-rules.windows)
  let lines = (
    ("仿宋", fonts.仿宋),
    ("宋体", fonts.宋体),
    ("黑体", fonts.黑体),
    ("楷体", fonts.楷体),
    ("代码", fonts.代码),
  )
  let fam-cell(fam, need-fakebold, normal-sample, bold-sample) = box(width: 100%, {
    set text(font: fam)
    normal-sample
    linebreak()
    if need-fakebold {
      show-cn-fakebold[#bold-sample]
    } else {
      bold-sample
    }
  })
  booktab(
      width: 100%,
      columns: (auto, 2fr, 1fr, 1fr),
      align: (left, left, left, left),
      [#strong[字体族]], [#strong[字体列表]], [#strong[中文字形]], [#strong[西文字形]],
      ..(for (name, fam) in lines {
        (
          [#strong[#name]],
          [#fam.join("、")],
          fam-cell(fam, bold.at(name, default: false), [为中华崛起而读书], [#text(weight: "bold")[为中华崛起而读书]]),
          fam-cell(fam, bold.at(name, default: false), [I love China.], [#text(weight: "bold")[I love China.]]),
        )
      }),
      caption: "当前生效的字体族渲染效果示例",
    )
  }

若某字体未安装，Typst 会在该字体族的列表内逐级 Fallback，直到命中已安装的字体；若列表中所有字体均缺失，编译时会报 `unknown font family` 警告，可参考下一节「字体警告」的处理方法。

=== 字体警告

如果编译时出现 `unknown font family` 警告，说明系统未安装对应字体。

*解决方案*：
- 使用 `--input system=macos`（macOS）或 `--input system=linux`（Linux）切换到对应平台的字体方案
- 下载对应字体（如思源宋体、思源黑体等）
  - 将字体安装到系统中
  - 或在编译时加上 `--font-path` 参数指定字体文件所在目录
- 开发者可以编辑 `format/utils/font.typ` 中的字体配置

== 基本结构

一个使用本模板的论文组件基本结构如下：

#code-block(
  ```typ
  #import "@preview/pku-thesis-pass:0.3.1": config, booktab, as-booktab, eq-block, code-block

  #let cfg = config(
    author-zh: "张三",
    title-zh: "论文中文题目",
  )

  #show: cfg.setup
  #(cfg.cover)()
  #(cfg.copyright)()

  #(cfg.abstract-zh)(keywords-zh: ("关键词1", "关键词2"))[中文摘要内容...]

  #(cfg.outline)()
  
  #show: cfg.body-wrap
  #show: cfg.bibliography

  = 第一章 绪论

  这里是正文内容...

  #(cfg.appendix)()

  = 附录 A 补充材料

  这里是附录内容...

  #(cfg.acknowledgements)[致谢内容...]
  #(cfg.declaration)()
  ```,
  caption: "论文组件基本结构",
)

模板采用 DI（依赖注入）模式：`config()` 返回一组闭包字典，用户通过 `cfg.xxx` 方式调用各页面函数，自行编排论文流程，不受固定模板限制。

== 调用模块

`config()` 返回一组页面函数（封面、摘要、目录等），这些通过 `cfg.xxx` 方式调用。但表格、公式块、代码块、定理环境等排版组件需要额外从模板中导入。

实际论文写作过程中大概率需要用到表格，这里仅以导入表格模块为例：

```typ
#import "@preview/pku-thesis-pass:0.3.1": config, booktab, as-booktab
```

未发布到官方仓库的改动需用本地相对导入，以免 `@preview` 包与本地源码不一致导致报错，上述代码要相应地改为：

```typ
#import "@preview/pku-thesis-pass:0.3.1": config, booktab, as-booktab
```

本模板提供如下模块可供导入：

- `config` — 论文配置入口，返回页面函数闭包字典（核心模块）
- `system-state` — 系统字体方案状态（类型 `state`），供字体校验表读取当前生效方案
- `font-set` — 跨平台字体方案字典（`font-set.windows` / `.macos` / `.linux`）
- `fakebold-rules` — 字体伪粗体策略字典（`fakebold-rules.windows` / `.macos` / `.linux`），控制各字型的粗体行为
- `show-cn-fakebold` — 中文伪粗体函数，为无粗体变体的字体（如楷体、仿宋）添加描边模拟加粗
- `booktab` — 学术三线表组件
- `as-booktab` — 将原生 `table` 装饰为三线表样式
- `code-preview` — 代码与渲染效果左右对照组件（主要用于本使用指南）
- `eq-block` — 带标题与编号的可引用公式块
- `code-block` — 带标题与编号的可引用代码块
- `subfigure` — 子图组件，自动按 `(a)(b)(c)` 编号
- `theorem` — 定理环境（随章编号，支持 `@label` 交叉引用）
- `definition` — 定义环境（随章编号，支持 `@label` 交叉引用）
- `lemma` — 引理环境（随章编号，支持 `@label` 交叉引用）
- `corollary` — 推论环境（随章编号，支持 `@label` 交叉引用）
- `proposition` — 命题环境（随章编号，支持 `@label` 交叉引用）
- `property` — 性质环境（随章编号，支持 `@label` 交叉引用）
- `example` — 例环境（随章编号，支持 `@label` 交叉引用）
- `remark` — 注环境（随章编号，支持 `@label` 交叉引用）
- `proof` — 证明环境（不编号，末尾带空心方框收尾符号）
- `word-count-cjk` — CJK 字数统计算子（用户通常不直接调用，使用下面的 `total-words` / `total-characters` 即可）
- `total-words` — CJK 字数统计结果（也可通过 `cfg.total-words` 访问）
- `total-characters` — 总字符数统计结果（也可通过 `cfg.total-characters` 访问）

不建议通过 `#import "@preview/pku-thesis-pass:0.3.1": *` 或者 `#import "../../format/lib.typ": *` 导入所有模块，因为这样会引入不必要的依赖，污染环境且增加编译时间。
