# 一份简单的华东师范大学论文模板

项目地址：[JackyLee3362/simple-ecnu-thesis](https://github.com/JackyLee3362/simple-ecnu-thesis)

![alt text](https://assets-1302294329.cos.ap-shanghai.myqcloud.com/2025/md/202503291647410.png)

## 🔍️ 项目介绍

本项目基于 [华东师范大学本科 / 研究生学位论文 Typst 模板](https://github.com/jtchen2k/modern-ecnu-thesis)，
进行了以下的 **重构与优化**：

- 💄 开箱即用，重新设计了界面，更加美观
- ⚡️ 使用中文变量，易于理解，对无编程经验的小白非常友好
- 🗃️ 重构了项目结构，可读性更好
- 💡 扩展性好，易于深度定制

本项目非常适合**边写论文边学习** Typst 语法，
并且可以定制自己的样式。

## 🙈 快速开始

### 本地项目

```sh
git clone https://github.com/JackyLee3362/simple-ecnu-thesis
code simple-typst-thesis-template
```

在 `vscode` 中搜索插件 `Tinymist Typst`

![Tinymist Typst](https://assets-1302294329.cos.ap-shanghai.myqcloud.com/2025/md/202503291647595.png)，


安装并下载后，
在 `vscode` 中打开 `main.typ`，
并点击 `预览`，
如下所示

![alt text](https://assets-1302294329.cos.ap-shanghai.myqcloud.com/2025/md/202503291647340.png)

## 🔧 如何配置？

本地：在项目中选择 `template/用户配置.typ` 文件，
在线：选择 `用户配置.typ` 文件

## 🧐 关于字体

本项目的字体在 `package/font.typ` 中定义，
建议下载以下字体

- 新罗马字体：`Times New Roman`，用于所有英文字体
- 华文宋体: `Songti SC`，用于标题
- 方正宋体: `FZShuSong-Z01S`，用于正文
- 方正楷体`FZKai-Z03S`，用于中文斜体
- 方正黑体: `FZHei-B01S`，用于中文加粗
- JetBrains Mono: `JetBrains Mono`，用于代码块

## 🗃️ 项目结构

```sh
├───assets   ... README 文件文件
├───package  ... 项目样式、库等的定义
├───public   ... 缩略图片存放
├───style    ... 子样式文件
├───template ... 模板
├───test     ... 测试文件
└─── lib.typ ... 模板入口文件
```

## 为什么会有该项目？

Typst 作为一款排版工具，
网上的中文教程依然较少，
对于即将毕业的学生来说，
很难花费大量的时间和精力研究其中的语法，
即使存在相关论文模板，
也很难进行自定义的定制。

## FAQ

## 感谢

- [The Raindrop-Blue Book (Typst 中文教程)](https://typst-doc-cn.github.io/tutorial/)
- [Typst 中文社区导航](https://typst-doc-cn.github.io/guide/)
- [nju-lug/modern-nju-thesis: 南京大学学位论文 Typst 模板 modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis)
- [jtchen2k/modern-ecnu-thesis: 华东师范大学本科 / 研究生学位论文 Typst 模板 modern-ecnu-thesis](https://github.com/jtchen2k/modern-ecnu-thesis)
- Typst qq 中文讨论群
