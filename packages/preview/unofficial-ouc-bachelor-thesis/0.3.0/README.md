# （非官方）中国海洋大学本科毕业论文 Typst 模板

<a href="https://typst.app/universe/package/unofficial-ouc-bachelor-thesis"> <img src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Funofficial-ouc-bachelor-thesis&amp;query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&amp;logo=typst&amp;label=Universe&amp;color=%2339cccc" alt="Typst Universe package version badge" /></a>
<a href="https://github.com/hongjr03/ouc-bachelor-thesis"> <img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fhongjr03%2Fouc-bachelor-thesis%2Frefs%2Fheads%2Fmaster%2Ftypst.toml&amp;query=package.version&amp;logo=GitHub&amp;label=GitHub" alt="GitHub repository version badge" /></a>

This package is an unofficial Typst template for Ocean University of China (OUC) bachelor theses.

基于 [Typst](https://typst.app/) 编写的中国海洋大学本科毕业论文模板。根据[中国海洋大学本科毕业论文（设计）撰写规范及附表（2026）](https://jwc.ouc.edu.cn/_upload/article/files/5a/2d/739028b94008954fabb295e513d8/1d6f220a-7701-49c4-8084-16a8f20fb41a.doc) 的要求制作。

## 效果预览

以下是本模板渲染后的论文效果展示。所有预览图片可通过 `examples` 文件夹查看。

<p align="center">
  <img src="examples/1.png" width="24%" alt="第1页" />
  <img src="examples/2.png" width="24%" alt="第2页" />
  <img src="examples/3.png" width="24%" alt="第3页" />
  <img src="examples/4.png" width="24%" alt="第4页" />
</p>

<p align="center">
  <img src="examples/5.png" width="24%" alt="第5页" />
  <img src="examples/6.png" width="24%" alt="第6页" />
  <img src="examples/7.png" width="24%" alt="第7页" />
  <img src="examples/8.png" width="24%" alt="第8页" />
</p>

<p align="center">
  <img src="examples/9.png" width="24%" alt="第9页" />
  <img src="examples/10.png" width="24%" alt="第10页" />
  <img src="examples/11.png" width="24%" alt="第11页" />
  <img src="examples/12.png" width="24%" alt="第12页" />
</p>

<p align="center">
  <img src="examples/13.png" width="24%" alt="第13页" />
  <img src="examples/14.png" width="24%" alt="第14页" />
  <img src="examples/15.png" width="24%" alt="第15页" />
  <img src="examples/16.png" width="24%" alt="第16页" />
</p>

<p align="center">
  <img src="examples/17.png" width="24%" alt="第17页" />
</p>



## 快速开始

> **重要：** 非 Windows 用户在编译前请先安装[中文字体包](https://github.com/hongjr03/assets/releases/download/cn-thesis-fonts-2.1-f0dde462e435/cn-thesis-fonts-2.1-f0dde462e435.zip)。

> **提示：** 如需在 typst.app 上使用，请下载[中文字体包](https://github.com/hongjr03/assets/releases/download/cn-thesis-fonts-2.1-f0dde462e435/cn-thesis-fonts-2.1-f0dde462e435.zip)，解压后直接上传到论文对应 typst.app 文件夹。

可以通过 Typst 命令行快速初始化论文项目：

<!-- README_INIT_CMD:BEGIN -->
```bash
typst init @preview/unofficial-ouc-bachelor-thesis:0.3.0
```
<!-- README_INIT_CMD:END -->

初始化的项目会包含 `main.typ` 示例文件。此时你需要通过 `project.with` 注入论文的基础信息：

<!-- README_MAIN_TYP:BEGIN -->
```typst
#import "@preview/unofficial-ouc-bachelor-thesis:0.3.0": project

#show: project.with(
  title: (
    zh: ("城市空气质量时空分布特征", "及其影响因素分析"),
    en: "The Practice of Dance Based on Singing, Dancing, Rapping and Basketball",
  ),
  author: (name: "蔡徐坤", id: "123456789"),
  advisor: ("唱跳导师", "篮球导师"),
  college: "信息科学与工程学院",
  department: "计算机科学与技术2017级",
  abstract: (
    zh: [
      关于这个事，我简单说两句，你明白就行，总而言之这个事呢，现在就是这个情况，具体的呢，大家也都看得到，也得出来说那么几句，可能你听的不是很明白，但是意思就是那么个意思，不知道的你也不用去猜，这种事情见得多了，我只想说懂得都懂，不懂的我也不多解释，毕竟自己知道就好，细细品吧。
    ],
    en: [
      #lorem(100)
    ],
  ),
  keywords: (
    zh: ("关于这个事", "我简单说两句", "你明白就行"),
    en: ("lorem ipsum", "dolor sit amet", "consectetur adipiscing elit"),
  ),
  bibliography: read("references.bib"),
  acknowledgments: [
    在论文的最后我想向所有帮助支持过我的亲人、朋友、老师致以崇高的敬意和真诚的感谢，感谢你们在我的学习和科研中给予的生活和工作的支持。

    这段时光中，我要特别感谢指导老师在选题、研究方法和论文写作上的悉心指导；感谢同学和朋友在我碰到问题时给予帮助；最后特别感谢我的父母，感谢你们对我学习生涯的支持与鼓励。
  ],
  // 可选：如果不需要请注释掉下面这行
  appendix: include "chapters/03-appendix.typ",
  config: (
    fonts: (
      宋体: "SimSun",
      黑体: "SimHei",
      楷体: "KaiTi",
      仿宋: "FangSong",
      西文: "Times New Roman",
      等宽: ("Consolas", "Courier New", "Liberation Mono", "Noto Sans Mono CJK SC", "Noto Sans Mono", "SimSun"),
    ),
    numbering: (
      (figure.where(kind: raw), figure, "1-1"),
      (figure.where(kind: "algorithm"), figure, "1-1"),
    ),
  ),
)

= 绪论

#include "chapters/01-basic-syntax.typ"

= 使用指南

#include "chapters/02-user-guide.typ"
```
<!-- README_MAIN_TYP:END -->

## 交流群

![OUC thesis template user group QR code](assets/qrcode_1777349536775.jpg)

## 许可证

本项目使用 [MIT License](LICENSE) 开源许可证。
