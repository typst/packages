# T4 - Tsinghua Thesis Typst Template: 清华大学研究生学位论文Typst模板（非官方）
An unofficial Typst template for Tsinghua University (THU) graduate thesis.

本项目是清华大学研究生学位论文Typst模板，旨在规定论文各部分内容格式与样式，详细介绍模板的使用和制作方法，帮助研究生进行学位论文写作，降低编辑论文格式的不规范性和额外工作量。请注意，这是一个非官方、非专业的模板，请在使用前充分确认该模板符合院系要求，并咨询院系负责老师。由于作者是生医药专业学生，该模板优先满足本专业的需求，其他功能随缘更新，敬请理解。

除常见自动排版功能外，本模板的特色功能包括通过`#tupian()`函数便捷地添加图片、图注，并防止跨页；以及通过`#biaoge()`函数便捷地添加三线表并在跨页时自动生成续表题。

如果有进阶的排版需求，请了解基于LaTeX的ThuThesis模板，这是一个非常成熟的模板，全面支持最新的本科、研究生、博士后论文/报告格式，获研究生院官方推荐。

本项目受PKUTHSS-Typst和ThuThesis启发，并在PKUTHSS-Typst的基础上修改而来，格式大量参考了ThuWordThesis模板。项目使用了以下Typst包：`tablem`、`cuti`、`a2c-nums`。感谢开发者们的贡献。

## 使用方法

### A: from Typst Universe to Web APP
- 使用[本模板](https://typst.app/universe/package/uo-tsinghua-thesis)创建项目
- 前往`设置与其他.typ`配置字体

只有大版本更新会同步Typst Universe，如果想要获取最新版，或需要修改模板格式，请前往GitHub/GitCode


### B: from GitHub/GitCode to Web APP
- 在GitHub上下载[Release](https://github.com/dl-li/uo-Tsinghua-Thesis-Typst-Template/releases)的Source Code
- 前往 Typst Web App 的 Dashboard 界面
- 创建新项目 + Empty document 或 Project - New Project
- 打开Web APP上的项目文件目录，拖拽上传`template`、`lib.typ`
- 静待所有文件上传完成
- 前往`设置.typ`末尾配置字体
- 点开template目录下`正文.typ`旁的眼睛图标，即可看到预览

[国内GitCode镜像](https://gitcode.com/dl-li/uo-Tsinghua-Thesis-Typst-Template)

### C: from GitHub/GitCode to Local Enviroment
- 面向有开发基础的用户，不再赘述


## 关于字体
本项目提供一系列开源字体，但是Windows版本的字体仍然是最佳选择，建议替换。字体设置参见`template- 设置与其他.typ - settings - 字体`

## 博资考模板
本项目包含生医药博资考书面报告模板(英文，非官方)，但不在Typst Universe提供，请前往GitHub/GitCode仓库获取。本模板可能不常维护。

![thumbnail](/thumbnail.png)