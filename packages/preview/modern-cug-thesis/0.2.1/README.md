# 基于 Typst 的中国地质大学（武汉）学位论文模板

**cug-thesis-thesis** 适用于中国地质大学（武汉）学位论文模板，具有便捷、简单、实时渲染等特性。欢迎各位同学、校友们前来 [Issues](https://github.com/Rsweater/cug-thesis-typst/issues) 交流学习~

![预览](https://cdn.jsdelivr.net/gh/Rsweater/images/img/preview.gif)

## 为什么考虑 Typst 实现学位论文模板？

1. 首要是为了学习。看到 Typst 惊人的成长速度，确实有点小激动。Typst 似乎继承了 Markdown、Tex、Wiki 各自的优点于自身。
2. 本人写文档相对来说较为粗心，使用 Word 模板会忍不住的反复去检查格式是否符合要求。又听说 Latex 写毕业论文可能后面编译一次需要几十秒~~ 虽然这个自己只是听说，但是 LaTex 在线编辑的方式 Overleaf 达到一定的编译时间收费这个是真的，就我小论文都勉强够用。自己使用开源的 Overleaf 搭建的平台功能上总是缺点什么，奈何自己又不懂~ 自己搭建的本地的 Tex 环境随解决了编译时间付费问题。但是涉及到的宏包、环境，前段时间打开突然不能用了，捣鼓半天不知是何原因~ 直至重新装了2024年的 LaTex 环境才重新运行自己的学位论文。
3. 惊喜的发现 Typst 编译速度真的非常快~ 经过一段时间的了解，发现基本满足制作学位论文的需求，于是乎~就有了这个cug-thesis-typst。

## 参考规范

- 本科生论文模板参考：[学士学位论文写作规范（2018版）-中国地质大学本科生院](https://bksy.cug.edu.cn/info/1489/1851.htm)
- 研究生论文模板参考：[研究生学位论文写作规范（2015版）-中国地质大学地理与信息工程学院](https://xgxy.cug.edu.cn/info/1073/3509.htm)（对研究生院相关通知附件进行了整理）

## 模板认可度问题

**值得提醒的是**毕竟是民间实现模板，有不被学院认可的可能性~

目前已知情况，计算机学院、地信学院对于学位论文要求不是太苛刻。去年计算机学院师兄使用了 Github 的 Latex 模板 [Timozer/CUGThesis: 中国地质大学（武汉）研究生学位论文 TeX 模板](https://github.com/Timozer/CUGThesis) 完成学位论文。

而且哈~ 咱们的研究生学位论文写作规范（2015版）似乎要求似乎不是特别苛刻。请自行斟酌~

> 小声~ 研究生学位论文写作规范（2015版）似乎还有一处前后矛盾的要求，斯~

## 使用方法

### Typst 在线编辑

本模板已上传 [Typst Universe](https://typst.app/universe)，您可以使用 Typst 的官方 Web App 进行编辑。只需要在 [Typst Web App](https://typst.app/) 中的 `Start from template` 里选择 `modern-cug-thesis`，即可从模板创建项目。

或者，直接点击注册 [typst.app.universe.modern-cug-thesis](https://typst.app/app?template=modern-cug-thesis&version=0.2.1)，并开始编写你的论文~

### 如果你经常使用 VS Code，也比较推荐使用这个~

**使用步骤**：安装 typst (命令行工具) → VS Code 插件(实时预览、智能提醒)，随后就可以准备开始项目了(打开项目文件、撰写论文内容)

1. **安装 typst ：**

   - **macOS:** `brew install typst`
   - **Windows:** `winget install --id Typst.Typst -l "D:\bw_ch\toolkits\typst"`
2. **安装插件**：在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)
3. **准备项目文件**：

   - **方法一：Clone Repo**: 使用命令 `git clone https://github.com/Rsweater/cug-thesis-typst.git` 将整个项目克隆到本地，寻找 `template/thesis.typ`。
   - **方法二：使用 Typst Packages**：按下 `Ctrl + Shift + P` 打开命令界面，输入 `Typst: Show available Typst templates (gallery) for picking up a template` 打开 Tinymist 提供的 Template Gallery，然后从里面找到 `cug-thesis`，点击 `❤` 按钮进行收藏，以及点击 `+` 号，就可以创建对应的论文模板了，会出现 `ref.bib` 以及 `thesis.typ`。
4. 打开开始编写论文内容~

## Q&A

### 使用这个模板需要了解些什么？

需要掌握一些 Markdown Like 标记用来编写文档，了解文章大致结构即可【见 `template\thesis.typ` 中介绍】。

**参考资料：**

- 官网Tutorial：[Writing in Typst – Typst Documentation](https://typst.app/docs/tutorial/writing-in-typst/)、[Tutorial中文翻译](https://typst-doc-cn.github.io/docs/tutorial/writing-in-typst/)
- Typst 语法官网文档：[Syntax – Typst Documentation](https://typst.app/docs/reference/syntax/)、[语法中文翻译](https://typst-doc-cn.github.io/docs/reference/syntax/)
- 中文社区小蓝书：[The Raindrop-Blue Book (Typst中文教程)](https://typst-doc-cn.github.io/tutorial/basic/writing-markup.html)

### 我不会代码、不会 LaTeX 可以使用吗？从接触到使用需要多久？

可以的。因为文档样式该模板已经提供，Typst 有标记模式（语法糖），使用起来就类似于 Markdown，完全不需要较多的代码功底。

如果有 Markdown 基础，基本上可以直接上手~ 如果没有，跳回第一个问题，查看相关说明。

### Typst 是个啥玩意？相较于 LaTeX 有啥优势？

**提供两篇**写的很用心的**文章：**

- [探索 Typst，一种类似于 LaTeX 的新排版系统](https://mp.weixin.qq.com/s/58IYHA3pROuh4iDHB4o1Vw)（译文）、[原文](https://blog.jreyesr.com/posts/typst/)
- [Typst 中文用户使用体验 - OrangeX4大佬](https://zhuanlan.zhihu.com/p/669097092)

### 在线模式字体显示异常，怎么办？

你需要上传 <https://github.com/Rsweater/cug-thesis-typst/tree/main/fonts/Windows-SysFonts> 里面所有字体，将 `fonts/Windows-SysFonts` 文件夹上传至模板创建的项目根目录即可。

### 为什么提醒类似 `unknown font family: songti sc` 的 Warning ?

如果你的设备是 Windows ，会遇见所有的 `sc` 结尾的字体找不到的提醒，因为这个是 Mac OS 系统字体，可以忽略。模板为了适应不同的平台，模板默认设置了多种字体。但是只要不是两种系统的字体均报 Warning，就不会影响渲染效果。如果不想看报错，可以去 [Rsweater/cug-thesis-typst/tree/main/fonts](https://github.com/Rsweater/cug-thesis-typst/tree/main/fonts) 安装所有字体。

## 致谢

- 感谢 [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis)、[better-thesis](https://github.com/sysu/better-thesis)、[HIT-Thesis-Typst](https://github.com/hitszosa/universal-hit-thesis) 为本模板提供了项目实现思路。
- 感谢 [Timozer/CUGThesis: 中国地质大学（武汉）研究生学位论文 TeX 模板](https://github.com/Timozer/CUGThesis) 提供了页面布局依据。
- 感谢 [Typst 非官方中文交流群](https://jq.qq.com/?_wv=1027&k=m58va1kd) 的大佬的答疑解惑，感谢 [tzhTaylor](https://github.com/tzhTaylor) 大佬交流 CJK 第一段首行缩进的解决方案。

## License

This project is licensed under the MIT License.
