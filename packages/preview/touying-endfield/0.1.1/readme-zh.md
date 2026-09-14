# Touying Endfield 主题

受鹰角网络旗下游戏《明日方舟：终末地》美术风格启发，为 [Touying](https://github.com/touying-typ/touying) 制作的演示文稿主题。

[English](README.md) | 中文

## 预览

<table>
  <tr>
    <td><img src="https://github.com/leostudiooo/typst-touying-theme-endfield/blob/v0.1.1/img/zh/page-1.png?raw=true" alt="标题页"></td>
    <td><img src="https://github.com/leostudiooo/typst-touying-theme-endfield/blob/v0.1.1/img/zh/page-2.png?raw=true" alt="目录页"></td>
    <td><img src="https://github.com/leostudiooo/typst-touying-theme-endfield/blob/v0.1.1/img/zh/page-3.png?raw=true" alt="章节标题页"></td>
  </tr>
  <tr>
    <td><img src="https://github.com/leostudiooo/typst-touying-theme-endfield/blob/v0.1.1/img/zh/page-4.png?raw=true" alt="含公式的内容页"></td>
    <td><img src="https://github.com/leostudiooo/typst-touying-theme-endfield/blob/v0.1.1/img/zh/page-7.png?raw=true" alt="含列表与编号的内容页"></td>
    <td><img src="https://github.com/leostudiooo/typst-touying-theme-endfield/blob/v0.1.1/img/zh/page-8.png?raw=true" alt="聚焦页"></td>
    <td></td>
  </tr>
</table>

## 功能特性

- 简洁现代的设计，注重可读性
- 灵感来源于终末地工业的视觉风格
- 支持三种导航模式：侧边栏、缩略幻灯片或无导航
- 可配置 CJK 与拉丁字体
- 聚焦幻灯片，用于突出关键内容
- 可自定义配色方案

## 安装

在 Typst 文档中导入主题：

```typst
#import "@preview/touying-endfield:0.1.1": *
```

或使用模板创建新项目：

```bash
typst init @preview/touying-endfield:0.1.1 my-presentation
cd my-presentation
typst compile main.typ
```

## 使用方法

```typst
#import "@preview/touying:0.6.3": *
#import "@preview/touying-endfield:0.1.1": *

#show: endfield-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  navigation: "none", // "sidebar"、"mini-slides" 或 "none"
  config-info(
    title: [演示文稿标题],
    subtitle: [演示文稿副标题],
    author: [作者姓名],
    date: [2026-01-01],
    institution: [机构名称],
  ),
)

#title-slide()

#outline-slide()

= 第一章

== 幻灯片 1

在此输入内容。

#focus-slide[
  重要信息！
]
```

## 配置

### 导航模式

- `"none"`（默认）：无导航的简洁幻灯片
- `"sidebar"`：左侧显示章节大纲的侧边栏
- `"mini-slides"`：顶部显示缩略幻灯片的导航栏

### 字体配置

使用 `config-fonts()` 自定义字体：

```typst
#show: endfield-theme.with(
  config-fonts(
    cjk-font-family: ("思源黑体",),
    latin-font-family: ("Helvetica",),
    lang: "zh",
    region: "cn",
  ),
)
```

## 示例

请参阅 `examples/` 目录，其中包含中英文完整示例。

## 字体

本主题最适合搭配以下字体使用：
- **HarmonyOS Sans**（默认，适合 CJK）
- **Gilroy**（可用于聚焦幻灯片以突出强调；商业字体）

## 已知问题

1. HarmonyOS Sans 字体家族的字体伸缩元数据不规范，Typst 会将字重 "light" 解析为该字体的压缩变体，斜体样式也会受到影响。目前粗体渲染正常。由于压缩变体同样具有 `stretch: 1000` 的元数据，无法通过 `#text(stretch: 100%)` 修复此问题。建议使用 `Source Sans` 或 `思源黑体` 作为替代方案，或卸载压缩系列字体，或尝试社区解决方案 https://github.com/typst/typst/issues/2917 ，也可等待 Typst 官方修复（https://github.com/typst/typst/issues/2098 ，截至 2026 年 2 月仍未关闭）。当然，你也可以乐观地将其视为该字体家族的特色。
2. 侧边栏导航不支持自适应布局（即不会根据幻灯片数量自动调整大纲深度或文字大小，可能发生*内容溢出* https://github.com/touying-typ/touying/issues/118 ）。缩略幻灯片模式也存在类似问题，但可通过 `mini-slides: (height: 3em)` 自定义参数来调整。这是由于 touying 内置的 `custom-progressive-outline` 和 `mini-slides` 组件的限制。未来或许可以实现更高级的组件来修复此问题，欢迎提出建议或提交 PR！如果不想麻烦，直接使用 `navigation: "none"` 即可。
3. 标题幻灯片的装饰条也存在类似问题。目前可通过在 `config-store` 中设置更大的 `title-height` 来修复标题换行时的显示问题，但这并非理想方案。同样欢迎提出有用的建议或提交 PR！

## 贡献

欢迎贡献！请在 [GitHub](https://github.com/leostudiooo/typst-touying-theme-endfield) 上提交 Issue 或 Pull Request。

## 许可证

MIT 许可证——详见 [LICENSE](LICENSE.md)。

## 免责声明

《明日方舟：终末地》是鹰角网络（中国大陆以外地区为 Gryphline）旗下的视频游戏。本主题与鹰角网络没有任何关联。所有商标均归其各自所有者所有。
