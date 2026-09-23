
# Northwest University Academic Year Paper Template

西北大学学年论文 Typst 模板。本模板基于 Typst 开发，旨在为西北大学学子提供一个初步的、符合规范的学年论文排版环境。

> ⚠️ **声明**：本模板为个人自发维护的第三方开源项目，**非西北大学官方发布**。使用前请务必与学院要求的最终格式进行核对。

## 快速上手

### 1. 导入模板
在你的 `.typ` 文件顶部，通过预览包（`@preview`）的方式引入本模板：

```typst
#import "@preview/nwu-academic-year-paper:0.1.0": template

#show: template.with(
  meta-title: [基于 Typst 的西北大学学年论文排版系统设计],
  meta-stu-name: [张三],
  meta-stu-number: "2026000001",
  meta-tch-name: [李四 教授],
  meta-department: [计算机科学与技术学院],
  meta-major: [软件工程],
  meta-grade: "2026级",
  
  // 摘要内容
  meta-zh-abstract: [这里是中文摘要内容...],
  meta-zh-keywords: ([Typst], [西北大学], [学年论文]),
  
  meta-en-abstract: [Here is the English abstract...],
  meta-en-keywords: ([Typst], [NWU], [Academic Year Paper]),
)

// === 正文从这里开始 ===
= 引言
这是你的第一章引言内容。

== 研究背景
这是二级标题。
```

### 2. 编译渲染
在终端中运行以下命令即可编译为 PDF，推荐配合 VS Code 的 Tinymist 插件使用实时预览：

```Bash
typst compile example.typ
```

将 `example.typ` 替换为你的 `.typ` 文件路径

## 核心参数说明

本模板提供丰富的自定义参数，均带有默认值，可根据需求在 `template.with()` 中覆盖：

### 文档控制组件

| 参数名 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `doc-show-cover` | `bool` | `true` | 是否渲染论文封面页 |
| `doc-show-zh-abstract` | `bool` | `true` | 是否渲染中文摘要页 |
| `doc-show-en-abstract` | `bool` | `true` | 是否渲染英文摘要页 |
| `doc-show-outline` | `bool` | `false` | 是否生成大目录 |

### 文档元数据（Meta）

| 参数名 | 类型 | 说明 |
| --- | --- | --- |
| `meta-title` | `content` | 论文题目 |
| `meta-stu-name` | `content` | 学生姓名 |
| `meta-stu-number` | `content/string` | 学号 |
| `meta-tch-name` | `content` | 指导老师姓名及职称 |
| `meta-department` | `content` | 学院名称 |
| `meta-major` | `content` | 专业名称 |
| `meta-grade` | `content/string` | 年级（如：`[2026级]`） |
| `meta-zh-keywords` | `array` | 中文关键词元组，如 `([键1], [键2])` |
| `meta-en-keywords` | `array` | 英文关键词元组 |
| `meta-bib-path` | `string/none` | 参考文献 `.bib` 文件的路径 |

> 💡 **提示**：如果需要调整具体字号或字体族（如修改 `font-serif` 或标题字号），可参考源码 `template.typ` 中的字体细粒度映射参数。

## 默认字体族

本模板采用如下默认字体设置：

| 用途 | 字体优先级序列 | 适用场景 |
| --- | --- | --- |
| **正文 (衬线)** | `"Times New Roman"`, `"Source Han Serif"`, `"SimSun"`, `"STSong"` | 正文、摘要、参考文献、页眉页脚 |
| **标题 (无衬线)** | `"Arial"`, `"Source Han Sans"`, `"Microsoft YaHei"`, `"SimHei"` | 封面、各级标题、表格标题 |

> 💡 **提示**：模板不自带字体文件，直接调用系统内置字体，若需完整功能请先安装字体，或传入参数以使用其他字体。

## 目录结构

```text
.
├── assets/               # 校徽 LOGO 等静态资源
├── src/                  # 模板核心源码
│   ├── renderer/         # 各页面排版渲染器 (封面、摘要、目录等)
│   ├── show-rules/       # 原子化拦截规则 (标题、公式、图表等)
│   ├── pipeline.typ      # 主排版流水线核心逻辑
│   ├── renderer.typ      # 渲染器统一入口
│   └── show-rules.typ    # 规则集统一入口
├── template/
│   ├── paper.typ         # 开箱即用的骨架
│   └── ref.bib           # 预设参考文献数据库
├── lib.typ               # 暴露的顶层接口
├── typst.toml            
├── LICENSE               
└── README.md                 
```

## 本地开发与贡献

如果你对本模板有任何改进建议或样式修复，欢迎提出 Issue 或直接提交 Pull Request：
1. 克隆本仓库到本地。
2. 参照各操作系统下 Typst 的本地包管理规范，将其放置于对应的 packages 路径下进行本地测试。
3. 修改 renderer/ 或 show-rules/ 下的具体页面逻辑或调整 pipeline.typ 样式流。

## 开源协议

本模板基于 **MIT** 协议开源。
> ⚠️ **声明**：本模板中所包含的西北大学校徽等视觉素材，其版权与商标权均归属于**西北大学**。模板中素材仅供西北大学师生个人在学术论文排版中合理使用，**请勿用于商业用途**。
