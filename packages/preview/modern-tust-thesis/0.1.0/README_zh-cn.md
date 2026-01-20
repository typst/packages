# 天津科技大学本科毕业设计（论文） Typst 模板

[English](README.md)

本模板面向天津科技大学本科毕业设计/论文写作，基于 [modern-sjtu-thesis](https://github.com/tzhtaylor/modern-sjtu-thesis) 修改与适配，结构与排版已按校内规范调整。

## 使用

### VS Code 本地编辑（推荐）

1. 安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，用于语法高亮、错误检查和 PDF 预览。
2. 打开本仓库，编辑模板入口 [template/thesis.typ](template/thesis.typ)。
3. 使用 `Ctrl + K V`(Windows) / `Command + K V`(macOS) 进行实时预览。

### 编译

在仓库根目录执行：

- `typst compile template/thesis.typ`

## 模板入口与配置

- 入口文件： [template/thesis.typ](template/thesis.typ)
- 全局信息通过 `info` 配置；`work-type` 用于选择“毕业设计/毕业论文”。

## 功能概览

- 中文封面、英文封面、声明页、任务书、摘要、目录、正文、参考文献、致谢、附录
- 插图、表格、算法、定理环境与示例
- 公式与编号、字数统计

## 字体说明

模板包含跨平台字体回退列表。若本机缺少某些字体，Typst 会给出警告但不影响编译。你可以按需在 [utils/style.typ](utils/style.typ) 中精简字体列表。

## 致谢

本模板基于 modern-sjtu-thesis 修改与适配，并参考部分第三方开源模板的组织方式。详细许可证信息见 [third_party/](third_party/)。

## 许可证（License）

本项目采用 MIT 许可证进行授权。

项目中可能包含依据其他开源许可证发布的第三方组件，相关许可信息请参见
third_party/ 目录中的说明。

## 学校标志（Logo）

本模板包含天津科技大学校徽，仅用于学位论文排版等学术用途的展示。

天津科技大学校徽不属于本项目所采用的 MIT 许可证授权范围。
校徽的使用仅限于非商业的教学与学术用途，例如用于撰写和提交
天津科技大学的毕业设计（论文）或相关学术报告。

使用本模板的用户需自行确认其对校徽的使用符合学校的相关管理规定
及适用的法律法规。