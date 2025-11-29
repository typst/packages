# 伽库噚文字模板

一个专为中文设计的Typst文档模板，提供高度自定义的排版样式，适用于学术论文、报告、书籍等多种文档类型。

## 使用方法

通过以下命令使用此模板：

```bash
typst init @preview/gakusyun-doc:1.0.0
```

然后在Typst中打开生成的项目即可开始编写文档。

## 功能特点

- **高度可定制**：支持自定义字体、页面布局、样式等
- **自动目录生成**：可选择性生成文档目录
- **双语排版优化**：专门优化了中英文混排的显示效果
- **响应式布局**：支持单栏或双栏布局
- **超链接支持**：美观的超链接样式
- **代码高亮**：内置代码块和行内代码样式

## 快速开始

### 基本使用

模板已经预配置了常用的设置，您可以直接开始编写内容：

### 自定义配置

您可以修改以下参数来自定义模板：

```
#show: docu.with(
  title: "文档标题",
  author: ("作者1", "作者2"),
  cjk-font: "Source Han Serif",        // 中文字体
  emph-cjk-font: "FandolKai",          // 中文强调字体
  latin-font: "New Computer Modern",   // 西文字体
  mono-font: "Maple Mono NF",          // 等宽字体
  default-size: "小四",                  // 默认字号
  paper: "a4",                         // 纸张大小
  column: 2,                           // 栏数
  show-index: true,                    // 显示目录
  title-page: false,                   // 独立标题页
)
```

## 参数说明

### 字体设置

- `cjk-font`: 中文字体名称
- `emph-cjk-font`: 中文强调字体（斜体等）
- `latin-font`: 西文字体名称
- `mono-font`: 等宽字体名称
- `default-size`: 默认字号，支持中文字号（小四、五号等）

### 页面设置

- `paper`: 纸张大小（a4、a5、letter等）
- `column`: 正文栏数（1或2）
- `margin`: 页面边距

### 文档结构

- `title-page`: 是否创建独立标题页
- `blank-page`: 标题页后是否添加空白页
- `show-index`: 是否显示目录
- `index-page`: 目录是否在新页面开始
- `column-of-index`: 目录栏数

## 语言支持

### 中文排版

模板会自动处理中文排版，包括：
- 首行缩进
- 中英文间距调整
- 中文标点符号

### 英文排版

对于英文内容，建议使用 `#en()` 函数：

```
#en("This is English text with proper formatting.")
```

这样可以确保英文内容的正确排版。

## 高级功能

### 超链接

```
#link("https://example.com")[链接文本]
```

超链接会以斜体加下划线的样式显示。

### 代码显示

使用反引号显示 `inline code`，或者使用代码块：

```
// 这是一个代码块示例
let example = "Hello, Typst"
```

### 多级标题

模板支持多级标题：

```
= 一级标题
== 二级标题
=== 三级标题
```

## 依赖项

本模板依赖以下Typst包：

- `@preview/pointless-size:0.1.2` - 中文字号支持
- `@preview/zebraw:0.6.1` - 排版增强功能

## 字体要求

为了获得最佳效果，建议安装以下字体：

- **思源宋体** (Source Han Serif) - 中文正文
- **FandolKai** - 中文强调
- **New Computer Modern** - 西文正文
- **Maple Mono NF** - 等宽字体

您可以根据喜好替换为其他字体。

## 示例效果

![示例图片](thumbnail.png)

## 许可证

本项目采用 [MIT](LICENSE) 许可证。

## 贡献

欢迎提交问题报告和功能建议。如果您想贡献代码，请：

1. Fork 本项目
2. 创建功能分支
3. 提交更改
4. 创建 Pull Request

## 更新日志

### v1.0.0
- 初始版本发布
- 支持中英文混排
- 基本文档模板功能