# modern-sustech-thesis
南方科技大学的学士、硕士、博士学位论文模版。

A thesis template for the Southern University of Science and Technology.
You probably read Simplified Chinese if you are using this.
The code still documents itself in English.

## 用法
建议在 [Typst Web App](https://typst.app) 里按此模版创建项目（Start from template），或用 Typst CLI 创建模版项目（`typst init @preview/modern-sustech-thesis:0.2.0`）之后按需删掉不用的学士（bachelor）或硕博（master、chapters）文件即可。推荐在本地编辑器中配合 Tinymist 语言服务编写文档，体验比网页版好。

模版自身即教程。更多教程见[官方文档](<https://typst.app/docs/>)和[中文社区导航](<https://typst.dev/guide/>)。

模版内容也见于[本仓库](template/)。

本模版特意不包含学术写作很可能要用到的包，比如
- `physica`（更多符号）
- `lilaq`（简明绘图）
- `zero`（数字与单位）

请自行选用最新或合适的版本。

### 字体
使用本模版前，请安装下列免费字体：
- 思源宋体（Source Han Serif）
- 思源黑体（Source Han Sans）
- 楷体（KaiTi）
- Times New Roman
- Arial
- XITS Math（不是 STIX）

这些字体必须是*静态*的，因为 Typst v0.14 还不支持可变字体。选择思源字体时尤其要注意。

若用 Typst Web App，则须将字体文件上传到项目中任意位置。

## 示例
```typ
#import "@preview/modern-sustech-thesis:0.2.0": *

#let (
  figures,
  cover,
  title-page,
  abstract,
  // ...
) = setup(
  degree: "master",
  title: (
    zh: [狂人日记],
    en: [Diary of a Madman],
  ),
  subtitle: (
    zh: [救救孩子],
    en: [Save the Children],
  ),
  keywords: (
    zh: ("仁义道德", "吃人", "白话文"),
    en: ("Benevolence and Morality", "Cannibalism", "Baihua"),
  ),
  // ...
)

#show: generic-style
#cover
#title-page()
#title-page(lang: "en")
#reviewers-n-committee

// ...
```

## 免责声明
本模版未经校方认证，不一定被认可；使用后果自负。

0.2.0版成包时，各模版基于当时（2026-01-01）最新标准制作。

其中，学士学位论文模版基于[本科毕业设计论文规范][bachelor.standard]和[样例][bachelor.template]及[中][bachelor.cover.zh]、[英][bachelor.cover.en]封面，[中][bachelor.declaration.zh]、[英][bachelor.declaration.en]承诺书编写。这些文件当时可见于[教学工作部–学生事务–毕业论文][bachelor.website]网页。

## 引用
- `src/`
    - `assets/`
      - [`zh.sustech-logo.svg`](src/assets/zh.sustech-logo.svg)
      - [`en.sustech-logo.svg`](src/assets/en.sustech-logo.svg)

      均来自[中][bachelor.cover.zh]、[英][bachelor.cover.en]封面模版。

  - 部分 [`component.typ`](src/component.typ)
  - 部分[`style.typ`](src/style.typ)
  - [`gb-t-7714-2015-author-date.hayagriva-0.9.1.csl`](src/gb-t-7714-2015-author-date.hayagriva-0.9.1.csl)
  - [`gb-t-7714-2015-numeric.cite.csl`](src/gb-t-7714-2015-numeric.cite.csl)
  - [`gb-t-7714-2015-numeric.hayagriva-0.9.1.csl`](src/gb-t-7714-2015-numeric.hayagriva-0.9.1.csl)

  引用已在首次出现时标明。

鉴于被引作品属于公共领域，无证书可循，或未达 MIT 证书要求的“substantial portions”，不做更多引用说明。

## 证书
本项目采用 MIT 证书，详见[`LICENSE.txt`](LICENSE.txt)。

## 致谢
感谢原作者 [Duolei Wang](<https://github.com/Duolei-Wang>) 提供的初始代码。


## 支持
在使用模板的过程中有什么困难的，可以联系QQ 1524632440 寻求支持。


<!-- Links -->

[bachelor.website]: <https://tao.sustech.edu.cn/xueshengfuwu/biyelunwen>

[bachelor.standard]: <https://tao.sustech.edu.cn/uploads/%E5%8D%97%E6%96%B9%E7%A7%91%E6%8A%80%E5%A4%A7%E5%AD%A6%E6%9C%AC%E7%A7%91%E7%94%9F%E6%AF%95%E4%B8%9A%E8%AE%BE%E8%AE%A1%E8%AE%BA%E6%96%87%E6%92%B0%E5%86%99%E8%A7%84%E8%8C%83(2410%E4%BF%AE%E6%94%B9)_1730186554.docx>

[bachelor.template]: <https://tao.sustech.edu.cn/uploads/%E5%8D%97%E6%96%B9%E7%A7%91%E6%8A%80%E5%A4%A7%E5%AD%A6%E6%9C%AC%E7%A7%91%E7%94%9F%E6%AF%95%E4%B8%9A%E8%AE%BE%E8%AE%A1%E8%AE%BA%E6%96%87%E4%B8%AD%E8%8B%B1%E6%96%87%E6%A0%B7%E4%BE%8B--%E8%AF%95%E8%A1%8C(2511%E4%BF%AE%E6%94%B9)_1763109203.docx>

[bachelor.cover.zh]: <https://tao.sustech.edu.cn/uploads/%E5%8D%97%E6%96%B9%E7%A7%91%E6%8A%80%E5%A4%A7%E5%AD%A6%E6%9C%AC%E7%A7%91%E7%94%9F%E6%AF%95%E4%B8%9A%E8%AE%BE%E8%AE%A1%E8%AE%BA%E6%96%87%E4%B8%AD%E6%96%87%E5%B0%81%E9%9D%A22025%E5%B9%B45%E6%9C%88%E6%9B%B4%E6%96%B0_1748312935.docx>

[bachelor.cover.en]: <https://tao.sustech.edu.cn/uploads/%E5%8D%97%E6%96%B9%E7%A7%91%E6%8A%80%E5%A4%A7%E5%AD%A6%E6%9C%AC%E7%A7%91%E7%94%9F%E6%AF%95%E4%B8%9A%E8%AE%BE%E8%AE%A1%E8%AE%BA%E6%96%87%E8%8B%B1%E6%96%87%E5%B0%81%E9%9D%A2-2017%E5%B9%B4%E6%9B%B4%E6%96%B0%E7%89%88_1665655302.docx>

[bachelor.declaration.zh]: <https://tao.sustech.edu.cn/uploads/%E8%AF%9A%E4%BF%A1%E6%89%BF%E8%AF%BA%E4%B9%A6%E4%B8%AD%E6%96%87%E7%89%88_1748312973.docx>

[bachelor.declaration.en]: <https://tao.sustech.edu.cn/uploads/CommitmentofHonesty%E8%AF%9A%E4%BF%A1%E6%89%BF%E8%AF%BA%E4%B9%A6%E8%8B%B1%E6%96%87%E7%89%88_1665655320.pdf>

