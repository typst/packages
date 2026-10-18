# zebra-hust

华中科技大学课程报告与本科毕业设计的非官方 Typst 模板，提供封面、目录、页眉页脚、图表、代码块、参考文献和附录排版。

包含 `course-report` 和 `cs-thesis` 两种配置集，默认使用课程报告。

## 如何使用

需要 Typst 0.15.0 或更新版本。

发布到 Typst Universe 后，或已在本地安装此包时，可以初始化项目：

```bash
typst init @preview/zebra-hust:0.1.0 my-report
cd my-report
typst compile main.typ
```

修改时自动更新：

```bash
typst watch main.typ
```

本科毕业设计示例使用 `typst compile cs-thesis.typ` 编译。初始化后的文件都可以直接修改，示例数据和文献请替换为自己的内容。

如果直接使用 GitHub 仓库源码，在仓库根目录执行 `make`、`make watch` 或 `make examples` 即可编译默认文档、监听修改或生成两种配置集的示例 PDF。

## 如何编写

`main.typ` 顶部放基础配置，下方编写正文。默认配置无需展开，需要时修改 `report` 的参数：

```typ
#import "@preview/zebra-hust:0.1.0": report, references, appendix, img

#show: report.with(
  preset: "course-report",
  cover: (
    title: [课程实验报告],
    name: [张三],
  ),
)
```

切换配置集可将 `preset` 改为 `"cs-thesis"`，摘要等配置参考随附的 `cs-thesis.typ`。课程报告标题手动编号，毕业设计标题自动编号。

### 图片、参考文献与附录

图片和文献路径使用 `path(...)`，确保读取当前项目中的文件：

```typ
#img(path("images/go.png"), width: 20%, caption: [示例图片])

相关研究见 @zhang2020。

#references(source: path("references.bib"))

#appendix(title: [补充材料])[
  这里填写附录正文。
]
```

文献使用 BibLaTeX 格式，按引用出现顺序编号。参考文献和附录放在哪里，就排在哪里；附录自动以 A、B、C……编号。表格写法参考默认示例。

### 字体问题

默认优先使用 Times New Roman、宋体（SimSun）、黑体（SimHei）、楷体（KaiTi）和华文中宋（STZhongsong），分别用于英文、正文、标题、页眉及封面与页码。不使用额外描粗。

缺少目标字体时，英文回退到 `Libertinus Serif`，中文回退到 `Noto Serif CJK SC` 或 `Noto Sans CJK SC`；替代字体的版式可能略有不同。

发布包不附带字体。请自行合法安装所需字体并遵守其使用与 PDF 嵌入许可，也可通过 `typst compile --font-path 字体目录 main.typ` 指定字体目录；网页端缺少字体时需自行上传有相应授权的字体。

仓库中的 `fonts/` 保留了其他开源字体，不是当前默认字体。需要进一步修改样式时，可在仓库源码的 `config.typ` 中调整 `font_config` 等配置；初始化的项目只包含正文示例，样式由包提供。

### 提交到 Universe

需要 Python 3.11+、Typst、jj 和已通过 `gh auth login` 登录的 GitHub CLI。

`make check-release` 只做本地打包和编译检查；确认源代码已用 jj 提交后，执行 `make submit-pr` 自动 Fork 官方仓库、推送并创建 PR。SSH 需有推送权限，可通过 `GIT_SSH_COMMAND` 指定连接方式。

脚本读取 `typst.toml` 的包名和版本，同步发布副本中的引用版本并重新生成缩略图，不改动源文件。运行目录保留在 `build/submit-*/`；若已有同版本 PR 或远端分支，会停止而不是覆盖。后续审核修改可在其中的 `registry/` 用 jj 继续提交。首次克隆官方仓库可能较大。

### 其他问题

有问题请提 issue，当然 PR 更好，毕竟我懒。
