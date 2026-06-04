# zh-format

[![Typst Universe](https://img.shields.io/badge/Typst-Universe-239DAD.svg)](https://typst.app/universe/package/zh-format) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

zh-format is a Chinese formatting package for Typst, providing better solutions for bold, italic, and underline styles tailored for Chinese typography.

zh-format 是一个用于 Typst 的中文格式包，提供更适合中文排版的粗体、斜体和下划线处理方案。

## 用法

```typst
// 从 Typst Universe 导入 (推荐)
// #import "@preview/zh-kit:0.1.0": *

// 如果是本地开发或直接使用仓库代码
#import "../lib.typ": * // 假设 lib.typ 在上一级目录

#show: zh-format

这是*粗体*、_斜体_和#underline[下划线]的效果。

这是#u(width: 8em, offset: 0.4em)[自定义下划线]
```

### 主要功能

#### 1. 粗体 (Bold)
- 中文使用描边方式 (`stroke: 0.02857em`)
- 英文使用原生字体加粗
- 自动识别中英文并分别处理

#### 2. 斜体 (Italic)
- 中文使用 `skew(ax: -18deg)` 倾斜变换
- 英文使用原生 `style: "italic"`
- 智能处理中英文混排

#### 3. 下划线 (Underline)
- 基本下划线: `#underline[文本]`
- 自定义宽度下划线: `#u(width: 8em)[文本]`

### 完整示例

查看 [example.typ](example/example.typ) 获取详细使用示例。

## 更新日志

### 0.1.0
- 初始版本
- 实现基础的粗体、斜体、下划线功能
- 支持中英文混排智能识别
- 添加自定义宽度下划线函数 `#u()`

## 许可证

[MIT License](LICENSE)
