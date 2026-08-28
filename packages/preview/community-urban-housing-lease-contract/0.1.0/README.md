# 城镇房屋租赁合同 Typst 模板

适用于城镇房屋租赁合同的 Typst 模板

[中文](./README.md) [English](./README_en.md)

## 关于本项目

[Typst](https://typst.app/) 是使用 Rust 语言开发的全新文档排版系统，您可以通过编写遵循 Typst 语法规则的文本文档、执行编译命令，来可生成目标格式的 PDF 文档。Typst 有望以 Markdown 级别的简洁语法和编译速度实现 LaTeX 级别的排版能力。

本模板是一套简单易用的城镇房屋租赁合同 Typst 模板，可生成标准化的房屋租赁合同文档。

## 使用

### 本地编辑

- 安装 Typst

如果您使用 Scoop 包管理器，直接使用如下命令安装：

```sh
scoop install typst
```

- 克隆项目

```sh
git clone <repository-url>
cd urban-housing-lease-contract
```

- 编辑合同内容

修改 `template/main.typ` 文件中的配置参数，包括房屋信息、租赁条款、甲乙双方信息等。

- 编译生成 PDF

```sh
typst compile template/main.typ
```

## 模板结构

- `src/lib.typ` - 核心库函数
- `src/style.typ` - 样式配置
- `template/main.typ` - 合同模板示例

## 主要功能

- 完整的房屋租赁合同格式
- 房屋信息管理（位置、面积、户型、装修等）
- 租赁条款配置（租金、押金、租期、费用承担等）
- 甲乙双方信息管理
- 房屋交割清单附件
- 单选框、复选框等交互元素

## 已知问题

- 合同中的空格和下划线位置可能需要根据实际情况调整
- 部分格式细节可能需要根据当地房管部门要求进行修改
