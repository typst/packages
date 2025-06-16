# T4 - Tsinghua Thesis Typst Template: 清华大学研究生学位论文Typst模板（非官方）
An unofficial Typst template for Tsinghua University (THU) graduate thesis.

本项目是清华大学研究生学位论文Typst模板，旨在规定论文各部分内容格式与样式，详细介绍模板的使用和制作方法，帮助研究生进行学位论文写作，降低编辑论文格式的不规范性和额外工作量。请注意，这是一个非官方、非专业的模板，请在使用前充分确认该模板符合院系要求，并咨询院系负责老师。由于作者是生医药专业学生，该模板优先满足本专业的需求，其他功能随缘更新，敬请理解。

除常见自动排版功能外，本模板的特色功能包括通过`#tupian()`函数便捷地添加图片、图注，并防止跨页；以及通过`#biaoge()`函数便捷地添加三线表并在跨页时自动生成续表题。

如果有进阶的排版需求，请了解基于LaTeX的ThuThesis模板，这是一个非常成熟的模板，全面支持最新的本科、研究生、博士后论文/报告格式，获研究生院官方推荐。

本项目受PKUTHSS-Typst和ThuThesis启发，并在PKUTHSS-Typst的基础上修改而来，格式大量参考了ThuWordThesis模板。项目使用了以下Typst包：`tablem`、`cuti`、`a2c-nums`。感谢开发者们的贡献。

## 使用方法

### A: from Typst Universe to Web APP
- 使用本模板创建项目
- 前往本项目的GitHub页面，下载fonts目录中的所有字体，并上传到项目目录任意位置

### B: from GitHub to Web APP
- 在GitHub上下载本项目的所有文件
- 前往 Typst Web App 的 Dashboard 界面
- 创建新项目 + Empty document 或 Project - New Project
- 打开项目目录（左上角 Files），在本地多选本项目目录下除PDF外的所有文件，一起拖入 Web App 的目录中。注意不要直接上传整个项目的大文件夹。
- 静待所有文件上传完成，尤其是字体文件。
- 点开template目录下`正文-教程.typ`旁的眼睛图标，即可看到预览。

### C: from GitHub to Local Enviroment
- 面向有开发基础的用户，不再赘述。


## 关于字体

为避免违反用户协议，已在v0.2.0版本中将英文字体替换为Web App自带字体（同时附带字体文件），中文字体替换为开源字体文件。这些平替字体基本可用，但是仍然建议在最后导出时替换为Windows版本的字体。字体设置参见`template- 设置.typ - 字体`