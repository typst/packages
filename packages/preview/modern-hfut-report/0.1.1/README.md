# 合肥工业大学课程现代设计报告模板

[![Typst Universe](https://img.shields.io/badge/Typst-Universe-239DAD.svg)](https://typst.app/universe/package/modern-hfut-report)

这是合肥工业大学的现代课程设计报告模板（非官方）

## 前4页示例
<p align="center">
  <img width=48% alt="模板示例：封面" src="https://github.com/user-attachments/assets/a290b98b-8e4a-4e47-b202-a771f7470a4f" /><img width=48% alt="模板示例：摘要" src="https://github.com/user-attachments/assets/be5c6933-717d-4dda-99b5-824f4ea20a5b" />
  <br /><img width=48% alt="模板示例：目录" src="https://github.com/user-attachments/assets/894e582c-118c-48e1-bad9-7eec4162bf58" /><img width=48% alt="模板示例：正文" src="https://github.com/user-attachments/assets/21d6ffc9-30d8-4607-b348-5217cf6525b6" />
</p>

## Typst 中文教程

[![下载最新版本](https://custom-icon-badges.demolab.com/badge/-Download-blue?style=for-the-badge&logo=download&logoColor=white "下载最新版本")](https://nightly.link/typst-doc-cn/tutorial/workflows/build/main/ebook.zip) **(latest 版本)**

## 使用方法

开始使用模板时，请先完整阅读 `template/guide.typ`及其预览，了解如何从模板开始编写自己的报告

### 本地编辑（✔️）

> 官网中文字体不全，在线编辑体验不佳，推荐本地编辑。

推荐使用 [VSCode](https://code.visualstudio.com/download) + [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件进行本地编辑

#### 方法一：使用 typst init（推荐）

```bash
typst init @preview/modern-hfut-report:0.1.1
cd modern-hfut-report
```

#### 方法二：在 VSCode 中创建

按下「Ctrl + Shift + P」打开命令面板，输入「Typst: Show Available Typst Templates」，从列表中选择 modern-hfut-report，点击「+」号创建项目

最后用 VSCode 打开生成的目录，打开 `template/report.typ` 文件，等待插件激活后点击顶部预览按钮进行预览

### 本地开发

如果你想要开发本模板，请从 [GitHub 仓库](https://github.com/KercyDing/modern-hfut-report) 克隆代码到本地，将 `template/report.typ` 首行的导入路径更换为 `"../lib.typ"`

## 贡献与反馈

本模板托管在 GitHub：[https://github.com/KercyDing/modern-hfut-report](https://github.com/KercyDing/modern-hfut-report)

- **报告问题**：遇到 bug 或排版异常，欢迎到 [Issues](https://github.com/KercyDing/modern-hfut-report/issues) 反馈，最好附上最小复现的 `.typ` 片段和编译日志
- **提出建议**：对参数命名、默认样式或文档表述有更好的想法，可以开 Issue 一起讨论
- **提交代码**：Fork 本仓库，从 `main` 拉出功能分支，改完后提交 Pull Request；若涉及样式变更，请同时在 `template/guide.typ` 中更新对应说明
- **分享模板**：如果这个模板帮到了你，欢迎分享给同学，或点个 Star

模板以「开箱即用、贴近学校格式要求」为目标，因此对默认样式的改动会比较谨慎，望理解。

## 致谢
- [modern-xmu-thesis](https://typst.app/universe/package/modern-xmu-thesis) by HPCesia，本模板借鉴了该模板的部分思路
- [zh-format](https://typst.app/universe/package/zh-format) by me，自己为了这碗醋才包的这顿饺子（bushi

同时感谢 Typst 开发团队、Typst 中文社区，以及所有第三方依赖库作者。

## 环境要求

- Typst 版本：0.13.1+
- 首次使用需联网下载依赖库

## 许可证

[MIT License](LICENSE)
