# 合肥工业大学课程现代设计报告模板

A modern report template for HFUT (unofficial)

这是合肥工业大学的现代课程设计报告模板（非官方）

## 使用方法

开始使用模板时，请先完整阅读 `template/guide.typ`及其预览，了解如何从模板开始编写自己的报告

### 在线编辑

[Typst Web App](https://typst.app/) 提供在线编辑和编译功能，适合不想在本地安装软件的用户

只需在 Web App 的 [Templates](https://typst.app/universe/search/?kind=templates) 中搜索「modern-hfut-report」，点击「Create project in app」即可在线创建模板

### 本地编辑

推荐使用 [VSCode](https://code.visualstudio.com/download) + [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件进行本地编辑

#### 方法一：使用 typst init（推荐）

```bash
typst init @preview/modern-hfut-report:0.1.0
cd modern-hfut-report
```

#### 方法二：在 VSCode 中创建

按下「Ctrl + Shift + P」打开命令面板，输入「Typst: Show Available Typst Templates」，从列表中选择 modern-hfut-report，点击「+」号创建项目

最后用 VSCode 打开生成的目录，打开 `template/report.typ` 文件，等待插件激活后点击顶部预览按钮进行预览

### 本地开发

如果你想要开发本模板，请从 [GitHub 仓库](https://github.com/KercyDing/modern-hfut-report) 克隆代码到本地，将 `template/report.typ` 首行的导入路径更换为 `"../lib.typ"`

## 致谢
- [modern-xmu-thesis](https://typst.app/universe/package/modern-xmu-thesis) by HPCesia，本模板借鉴了该模板的部分思路
- [i-figured](https://typst.app/universe/package/i-figured) by RubixDev，使用起来确实很方便，功能也很强大
- [zh-format](https://typst.app/universe/package/zh-format) by me，自己为了这碗醋才包的这顿饺子（bushi

## 环境要求

- Typst 版本：0.13.1+
- 首次使用需联网下载依赖库

## 许可证

[MIT License](LICENSE)
