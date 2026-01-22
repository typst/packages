# SDU-Touying-Simpl

一个为山东大学设计的、基于 [Touying](https://github.com/touying-typst/touying) 的 Typst 演示文稿模板。

A  [Touying](https://github.com/touying-typst/touying)-based Typst presentation template designed for Shandong University (SDU).

![演示效果](./example/figures/main.png)

## 目录

- [简介](#简介)
- [特性](#特性)
- [安装](#安装)
- [快速开始](#快速开始)
- [字体支持](#字体支持)
- [许可证](#许可证)
- [致谢](#致谢)

## 简介

`sdu-touying-simpl` 是一个基于 [Typst](https://typst.app/) 和 [Touying](https://github.com/touying-typst/touying) 的演示文稿模板，专为山东大学师生设计。本项目旨在提供一个简单易用、美观大方的学术演示模板，同时保持与山东大学视觉形象的一致性。

通过多个月的开发，终于是做出了一款自己还算比较满意的，效果不错的模板供大家使用。

## 特性

- **现代化排版系统**：基于 Typst 构建，提供快速的编译速度和清晰的语法。
- **完整的幻灯片功能**：
  - 支持渐进式显示（`#pause`、`#uncover`、`#only` 等）；
  - 灵活的幻灯片布局系统；
  - 演讲者备注支持；
  - 讲义模式。
- **山大特色设计**：
  - 内置山东大学校徽和视觉元素；
  - 采用山大标准红色（`#880000`）作为主题色；
  - 优化的中文字体支持。
- **丰富的幻灯片类型**：
  - 标题页（`title-slide`）；
  - 大纲页（`outline-slide`）；
  - 标准内容页；
  - 自定义页脚样式。
- **主题定制**：
  - 支持多种主题样式（`full` 和 `normal`）；
  - 可自定义页眉页脚；
  - 灵活的布局配置。

## 安装

### 方法一：通过 Typst Universe 安装

```bash
typst init @preview/sdu-touying-simpl:1.0.1
```

### 方法二：通过 [Typst.app](https://typst.app/universe/package/sdu-touying-simpl) 在线使用

## 快速开始

创建一个新的 Typst 文件（例如 `main.typ`），并添加以下内容：

```typst
#import "@preview/sdu-touying-simpl:1.0.1": *

#show: sdu-theme.with(
  title: "演示文稿标题",
  author: "您的姓名",
  subtitle: "副标题",
  institution: "山东大学",
  date: datetime.today(),
)

#title-slide()

#outline-slide("目录")

= 主题一

== 页面一

= 主题二

== 页面二

== 页面三
```


## 字体支持

本项目支持中文字体，您可以从以下位置获取字体文件：

1. 项目 [GitHub 仓库](https://github.com/Dregen-Yor/sdu-touying-simpl/tree/main/fonts) 的 `fonts` 目录；
2. 将字体文件放置在您的项目目录中；
3. 在文档中通过 `#set text(font: "字体名称")` 设置字体。

## 许可证

本项目采用 GPL-3.0 许可证。详见 [LICENSE](LICENSE) 文件。

本仓库为模板渲染可能包含山东大学相关标识（如“山东大学/SDU/山大”等文字、校徽，以及可能的校庆/院系标识等）。

根据学校公开制度文件，校名校誉（含校徽等）属于学校无形资产，学校对依法注册的相关文字与校徽等图标享有注册商标专用权等权益，并对使用进行管理。 因此：

- 许可范围： 本仓库的开源许可证仅覆盖模板代码与仓库原创内容，不包含对山东大学名称/校徽/相关标识的任何授权。

- 禁止擅改： 标识应完整、准确、规范使用，不得擅自改动，不得以任何方式损害学校形象、声誉与利益。

- 可能需要授权： 不得用于与山东大学无关事项；未经授权不得用于商业或潜在商业目的；校外单位及个人未经许可不得使用。

- 非官方声明： 本项目与山东大学无隶属关系，不代表学校官方立场或背书。

This repository may include Shandong University (SDU) visual identifiers (e.g., “Shandong University / SDU / 山大” text marks, the SDU crest, and possibly anniversary/college marks) for template rendering.

SDU treats its name, crest, and related identifiers as intangible assets and (where registered) trademarks, and manages their use accordingly. Therefore:

- License scope: The repository’s open-source license applies to the template code and original content only. It does not grant any rights to SDU’s names, crests, or other SDU identifiers.

- No modification: Use SDU identifiers completely, accurately, and consistently; do not alter them or use them in ways that may harm SDU’s image/reputation.

- Authorization may be required: Do not use SDU identifiers for unrelated activities; do not use them for commercial (or potentially commercial) purposes without authorization; external entities/individuals should not use SDU identifiers without permission.

- No endorsement: This project is not affiliated with, endorsed by, or sponsored by SDU.

## 致谢

- 感谢 [Typst 官方文档]("https://typst.app/docs") 

- 感谢 [Typst 中文教程]("https://github.com/typst-doc-cn/tutorial")

- 感谢 **Typst 非官方中文交流群** 793548390

- 感谢 [OrangeX4 的 Typst 讲座]("https://github.com/OrangeX4/typst-talk")（几乎占了介绍内容的全部）

- 感谢 [**Touying 官方文档**]("https://touying-typ.github.io/")

- 感谢 [**中科大touying-pres-ustc模板**]("https://github.com/Quaternijkon/touying-pres-ustc")

- 感谢 [**touying-brandred-uobristol**]("https://github.com/HPDell/touying-brandred-uobristol")

- 感谢 [Touying](https://github.com/touying-typst/touying) 项目提供的强大基础；

- 感谢 [PolyU Beamer Slides](https://www.overleaf.com/latex/templates/polyu-beamer-slides/pyhhgmgmvzhg) 提供的设计灵感；

- 感谢 [OrangeX4 的 Typst 讲座]("https://github.com/OrangeX4/typst-talk") 这个讲座内容非常好，几乎占据了示例文件的全部；

- 感谢所有为本项目提供反馈和建议的用户。

