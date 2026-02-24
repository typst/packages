# zh-kit

[![Typst Package Version](https://img.shields.io/badge/typst%20package-v0.1.0-blue)](https://github.com/ctypst/zh-kit)
[![License: LGPL-2.1](https://img.shields.io/badge/License-LGPL--2.1-blue.svg)](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)

zh-kit 是一个基础的 Typst 中文支持库，旨在为使用 Typst 进行中文写作的用户提供便捷的字体配置和常用的中文排版功能，帮助用户轻松上手，专注于内容创作。

您可以**基于**本项目开发自己的中文排版模板，也可以使用其它由 CTypst 小组提供的模板。

## ✨ 功能特性

*   **便捷的字体配置**: 通过 `setup-base-fonts` 函数，一键设置常用的中英文衬线、无衬线、等宽字体及段落格式。
*   **中文数字转换**: 支持将阿拉伯数字转换为中文大小写数字 (例如 `zhnumber-lower(123)` 输出 "一百二十三")。
*   **智能拼音显示**: 能够将带声调数字的拼音字符串 (例如 `pinyin("ni3 hao3")`) 渲染为标准的拼音格式 (nǐ hǎo)。
*   **中文占位文本**: 提供 `zhlorem()` 函数，方便生成中文随机文本，用于排版测试。

> [!note]
>
> `zh-kit` 是通用的，它不会破坏您的版式设置，而仅仅是提供一些中文排版支持。
>
> `zh-kit` 中提供的中文排版功能通常优于您手动配置的，我们更推荐您使用本库。

## 🚀 快速开始

### 1. 安装字体 (推荐)

为了获得最佳的显示效果，建议您在您的操作系统上安装以下字体。`zh-kit` 会优先使用列表中靠前的字体。

*   **中文衬线 (Serif):** 思源宋体 CN, LXGW WenKai SC (霞鹜文楷 SC), Songti SC, SimSun
*   **中文无衬线 (Sans-serif):** 思源黑体 CN, Inter, PingFang SC, SimHei
*   **中文等宽 (Mono):** 霞鹜文楷 Mono, JetBrains Mono, Source Code Pro, Noto Sans Mono CJK SC, Menlo, Consolas
*   **拉丁文衬线 (Serif):** Times New Roman, Georgia
*   **拉丁文无衬线 (Sans-serif):** Times New Roman, Georgia
*   **拉丁文等宽 (Mono):** JetBrains Mono, Consolas, Menlo

*您也可以根据自己的喜好在 `setup-base-fonts` 函数中自定义字体列表。您可以在 Typst 的官方文档或社区中找到更多关于字体安装和配置的信息。*

### 2. 在项目中使用

在您的 Typst 项目的入口文件 (通常是 `.typ` 文件) 的开头，通过以下方式导入 `zh-kit` 并应用基础设置：

```typ
// 从 Typst Universe 导入 (推荐方式，当包发布后)
// #import "@preview/zh-kit:0.1.0": * 
// 请将 0.1.0 替换为最新的版本号。您可以在项目的 GitHub 仓库或 Typst Universe 上查找最新版本。

// 如果是本地开发或直接使用仓库代码
#import "../lib.typ": * // 假设 lib.typ 在上一级目录

#show: doc => setup-base-fonts(doc)

// --- 从这里开始您的文档内容 ---

= 我的第一个中文 Typst 文档

欢迎使用 zh-kit！

这是一个段落，使用了默认的字体设置和首行缩进。
#zhlorem(30)
```

## 📖 使用示例

### 字体配置

默认情况下，`setup-base-fonts` 会应用推荐的字体设置。您也可以自定义字体列表和首行缩进：

```typ
#show: doc => setup-base-fonts(
  doc,
  cjk-serif-family: ("霞鹜文楷 SC", "宋体"), // 优先使用霞鹜文楷 SC
  first-line-indent: 2em, // 设置首行缩进为2个字符宽度
)

= 自定义字体和缩进

这个文档将使用自定义的字体和首行缩进设置。
```

### 中文数字

`zh-kit` 提供了将阿拉伯数字转换为中文数字的功能。

```typ
// 小写中文数字
#zhnumber-lower(0)     // 零
#zhnumber-lower(10)    // 十
#zhnumber-lower(25)    // 二十五
#zhnumber-lower(123)   // 一百二十三
#zhnumber-lower(10086) // 一万零八十六

// 大写中文数字 (通常用于金额等正式场合)
#zhnumber-upper(0)     // 零
#zhnumber-upper(10)    // 拾
#zhnumber-upper(25)    // 贰拾伍
#zhnumber-upper(123)   // 壹佰贰拾叁
#zhnumber-upper(10086) // 壹万零捌拾陆
```
*(注: `zhnumber-upper` 的具体实现请参考 [`zhnumber.typ`](zhnumber.typ) 文件)*

### 拼音

使用 `pinyin` 函数可以方便地显示带声调的拼音。

```typ
#pinyin("ni3 hao3, shi4 jie4!") // 你好，世界！
#pinyin("Typst de zhong1 wen2 pai2 ban3 fei1 chang2 ku4!") // Typst 的中文排版非常酷！
```

### 中文随机文本

在设计和排版阶段，可以使用 `zhlorem` 生成中文占位文本。

```typ
== 示例文本

#zhlorem(50) // 生成约 50 个字符的中文随机文本

=== 更长的示例文本

#zhlorem(150)
```

## 🛠️ 主要 API

以下是 `zh-kit` 提供的主要函数：

*   `setup-base-fonts(doc, cjk-serif-family: tuple, cjk-sans-family: tuple, cjk-mono-family: tuple, latin-serif-family: tuple, latin-sans-family: tuple, latin-mono-family: tuple, first-line-indent: length)`
    *   **描述:** 初始化文档的字体和基础排版设置。
    *   **参数:**
        *   `doc`: 必需，传递文档内容。
        *   `...family`: 可选，各类字体族列表，默认为推荐字体。
        *   `first-line-indent`: 可选，段落首行缩进量，默认为 `1.5em`。
    *   **返回:** 应用了样式设置的文档内容。

*   `zhnumber-lower(number)`
    *   **描述:** 将非负整数转换为小写中文数字字符串。
    *   **参数:** `number` (integer) - 要转换的数字。
    *   **返回:** (string) 小写中文数字。

*   `zhnumber-upper(number)`
    *   **描述:** 将非负整数转换为大写中文数字字符串。
    *   **参数:** `number` (integer) - 要转换的数字。
    *   **返回:** (string) 大写中文数字。

*   `pinyin(pinyin-string)`
    *   **描述:** 将包含数字声调的拼音字符串渲染为带声调符号的拼音。
    *   **参数:** `pinyin-string` (string) - 例如 `"ni3 hao3"`。
    *   **返回:** 渲染后的拼音文本。

*   `zhlorem(count)`
    *   **描述:** 生成指定数量（近似）的中文随机文本。
    *   **参数:** `count` (integer) - 希望生成的字符数量。
    *   **返回:** 中文随机文本字符串。

## 🤝 贡献指南

我们欢迎各种形式的贡献，包括但不限于：

*   报告 Bug (Issues)
*   提交功能请求 (Issues)
*   改进文档 (Pull Requests)
*   提交代码 (Pull Requests)

在您开始贡献之前，请花点时间阅读我们的 [贡献指南](CONTRIBUTING.md)。

## 📜 许可证

本项目采用 [LGPL-2.1](LICENSE) 许可证。这意味着：

*   **您可以自由地：**
    *   **使用 (Use):** 在您的任何 Typst 项目（无论是开源还是闭源）中使用 `zh-kit`。
    *   **分发 (Distribute):** 分发 `zh-kit` 的原始版本。
    *   **修改 (Modify):** 修改 `zh-kit` 的源代码。

*   **在以下条件下：**
    *   **共享修改 (Share Alike for Modifications to the Library):** 如果您修改了 `zh-kit` 的源代码，并且您选择分发这个修改后的版本，那么这个修改后的版本也必须在 LGPL-2.1 许可下提供。
    *   **声明和版权 (Notice and Copyright):** 您必须保留原始的版权声明和许可证文本。

*   **请注意：**
    *   **链接不“传染” (No "Viral" Effect on Your Project):** 仅仅在您的 Typst 文档或项目中通过 `#import` 使用 `zh-kit`，并**不会**强制要求您的整个文档或项目也必须采用 LGPL-2.1 许可证。您可以为您的作品选择任何您希望的许可证。