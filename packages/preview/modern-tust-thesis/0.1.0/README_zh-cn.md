# 天津科技大学本科毕业设计（论文） Typst 模板

[[English](README.md)]

本模板面向天津科技大学本科毕业设计/论文写作，基于 [modern-sjtu-thesis](https://github.com/tzhtaylor/modern-sjtu-thesis) 修改与适配，结构与排版已按校内规范调整。

---

## 使用

### Web App

使用 [Typst Web App](https://typst.app/) 直接在浏览器中从模板创建新项目：

1. 打开 https://typst.app/
2. 点击 “Start from template” 并搜索 “modern-tust-thesis”
3. 从模板创建新项目
4. 在网页编辑器中编辑并预览

**注意：** Web App 环境可能不包含本模板所需的全部字体。可能会出现字体回退提示，但编译仍可正常完成。若需最佳排版效果，请使用下列本地方法或手动上传字体。

### VS Code + Tinymist（推荐）

面向本地编辑的推荐流程，使用 Typst Universe 模板库版本：

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，提供语法高亮、错误检查和 PDF 预览。
2. 按下 `Ctrl + Shift + P`（Windows）/ `Command + Shift + P`（macOS）打开命令面板，输入 **Typst: Show available Typst templates (gallery) for picking up a template**，打开 Tinymist 的 Template Gallery。
3. 在模板库中找到 **modern-tust-thesis**，点击 ❤ 收藏，再点击 + 创建项目。
4. 用 VS Code 打开生成的目录，打开 `thesis.typ` 文件，按下 `Ctrl + K V`（Windows）/ `Command + K V`（macOS）或点击右上角按钮进行实时编辑和预览。

### 使用 Typst CLI

如果你更倾向于使用命令行：

1. 确保已安装 [Typst](https://github.com/typst/typst)
2. 从模板初始化项目：
	```
	typst init @preview/modern-tust-thesis:0.1.0
	```
3. 用你喜欢的编辑器编辑生成的文件
4. 编译：
	```
	typst compile thesis.typ
	```

---

## 模板入口与配置

以下内容主要适用于直接使用本仓库进行自定义或二次开发：

- 入口文件： [template/thesis.typ](template/thesis.typ)
- 全局信息通过 `info` 配置；`work-type` 用于选择“毕业设计/毕业论文”。

---

## 功能概览

- 中文封面、英文封面、声明页、任务书、摘要、目录、正文、参考文献、致谢、附录
- 插图、表格、算法、定理环境与示例
- 公式与编号、字数统计

---

## 字体说明

模板包含跨平台字体回退列表。若本机缺少某些字体，Typst 会给出警告但不影响编译。你可以按需在 [utils/style.typ](utils/style.typ) 中精简字体列表。

---

## 致谢

本模板基于 modern-sjtu-thesis 修改与适配，并参考部分第三方开源模板的组织方式。详细许可证信息见 [third_party/](third_party/)。

---

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