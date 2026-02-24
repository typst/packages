# 山东大学本科毕业论文（设计）typst模板

<p align="center", >
  <a href="https://typst.app/universe/package/typsium"><img src="https://img.shields.io/badge/version-0.2.0-3230E3?style=for-the-badge" alt="Typst Package"></a>
  <a href="https://github.com/Typsium/typsium/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-red?style=for-the-badge" alt="MIT License"></a>
</p>

> 山东大学本科毕业论文（设计）typst模板，带来超越word与tex的体验，助你轻松编辑，简洁书写。
> 本项目借鉴了[modern-nju-thesis](https://typst.app/universe/package/modern-nju-thesis)，在此表示感谢。
> 如果这帮到了你，阁下不妨点击⭐️作为给予我的我的奖励

- Typst 非官方中文交流群:793548390
- **如遇到任何问题或需求，请联系GG:** _`groovewjh@foxmail.com`_，或提交[issue](https://github.com/GrooveWJH/unofficial-sdu-thesis/issues)

## 优势

- **易于Tex**
- **无需浪费过多心思于格式，专注编辑**
- **引用符合gb-7714-2015格式，自动排序，轻松引用**
- **图表编号自动排序，简单管理**

## 开发预览

![cover](https://img.z4a.net/images/2025/03/19/cover.png)

### 快速预览

请参考[此项目库](https://github.com/GrooveWJH/unofficial-sdu-thesis)

- [thesis.pdf](https://github.com/GrooveWJH/unofficial-sdu-thesis/blob/main/template/thesis.pdf)
- [thesis.typ](https://github.com/GrooveWJH/unofficial-sdu-thesis/blob/main/template/thesis.typ)

实际上，理想的情况下，你几乎只需要修改 `thesis.typ`文件即可完成你的工作。

## 使用

### 初次使用typst

请浏览[typst官网](https://typst.app/docs/) 与 [typst文档](https://typst.app/docs/)(或[非官方简中版本](https://typst-doc-cn.github.io/docs/)) ，以掌握初步的typst语法知识。

### 推荐编辑方式

#### [Visual Studio Code](https://visualstudio.microsoft.com/) + [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)

#### [Typst app](https://typst.app/) -> Start from a template

### 本地安装

**由于从代码完成到typst universe发布中间需要间隔大约24h，因此为了时刻获得最新版本，请参照以下方法完成本地安装**

```shell
git clone https://github.com/GrooveWJH/unofficial-sdu-thesis.git
cd ./unofficial-sdu-thesis

# linux / macOS
sudo bash ./local_install.sh

# windows
.\local_install.sh
```

此后，即可将 `@preview/unofficial-sdu-thesis`替换为 `@local/unofficial-sdu-thesis`。

自行查阅

## 简洁示例

> 此示例未包含正文之后的部分及图表应用，具体仍请参考[thesis.typ](https://github.com/GrooveWJH/unofficial-sdu-thesis/blob/main/template/thesis.typ)

```typst
#import "@preview/unofficial-sdu-thesis:0.2.0": documentclass, algox, tablex, fonts, fontsize
// 如果是本地安装，则使用
// #import "@local/unofficial-sdu-thesis:0.2.0": documentclass, algox, tablex, fonts, fontsize
#let (
  info,
  doc,
  cover,
  declare,
  appendix,
  outline,
  mainmatter,
  conclusion,
  abstract,
  bib,
  acknowledgement,
  under-cover,
) = documentclass(
  info: (
    title: "XXXX毕业论文",
    name: "渐入佳境Groove",
    id: "20XX008XXXXX",
    school: "XXXX学院",
    major: "人工智能",
    grade: "20XX级",
    mentor: "XXX",
    time: "20XX年X月XX日",
  ),
)

#show: doc
#cover()
#abstract(
  body: [
    摘要
  ],
  keywords: ("关键词1", "关键词2"),
  body-en: [
    dissertation
  ],
  keywords-en: ("dissertation", "dissertation format"),
)
#outline()

#set heading(numbering: "1.1")
#counter(page).update(1)
#show: mainmatter

= 绪#h(2em)论

== 二级标题
山東大學本科畢業論文（設計）Typst模板。

=== 三级标题
本文...

=== 三级标题
许多年后奥雷里亚诺·布恩迪亚上校站在行刑队面前，准会想起父亲带他去见识冰块的那个遥远的下午。

Many years later, as he faced the firing squad, Colonel Aureliano Buendía was to remember that distant afternoon when his father took him to discover ice.
= 本科毕业论文写作规范

== 二级标题
本组织...

=== 三级标题
本文将...
```

## 特性 / 路线图

- 模板
  - [X] 本科生模板
  - [X] 封面
  - [X] 中文摘要
  - [X] 英文摘要
  - [X] 目录页
  - [X] 致谢
  - [X] 引用
- 编号
  - [X] 正文-关联章节图表编号
  - [X] 附录-无关联图表编号 (开发中)
- 全局配置
  - [X] 类似 LaTeX 中的 documentclass 的全局信息配置
  - [ ] 盲审模式，将个人信息替换成小黑条，并且隐藏致谢页面，论文提交阶段使用
  - [ ] 双面模式，会加入空白页，便于打印
  - [X] 自定义字体配置，可以配置「宋体」、「黑体」与「楷体」等字体对应的具体字体, 参见 `styles/fonts.typ`
  - [X] 数学字体配置：模板不提供配置，用户可以自己使用 #show math.equation: set text(font: "Fira Math")
  - [ ] 自定义图表旋转

## 更新日志

| 版本  | 描述                                                                                                                    |
| ----- | ----------------------------------------------------------------------------------------------------------------------- |
| 0.1.0 | 完成基本模板，留存小部分未完善或未修复的问题。                                                                          |
| 0.2.0 | 完善附录页图表序号，修复示例与删除部分多余无用代码，修复公式序号问题，修复表格行间距与块间距问题，加入local本地安装脚本 |
