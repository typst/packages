# modern-sustech-thesis 

功能需求、合作开发请移步模板对应的 github 仓库：[modern-sustech-thesis](https://github.com/Duolei-Wang/modern-sustech-thesis). 

# 模板使用说明 (Usage)

## typst.app 网页版使用说明 (Use online)

使用步骤：

- 打开 typst.app 从模板新建项目（start from template）

- 论文所需字体需要手动上传到你的项目文件列表.
  
  点击左侧 Explore Files，上传字体文件，上传后的字体文件存储位置没有特殊要求，typst 拥有优秀的内核，可以完成自动搜索.

  由于格式渲染引擎的核心需要指定字体的名称，我在模板测试阶段使用了若干标准字体，这些字体可以在我的 github 仓库 [modern-sustech-thesis](https://github.com/Duolei-Wang/modern-sustech-thesis) /template/fonts 里找到.
  
  此外，可以手动更改字体配置，在正文前使用 '#set' 命令即可，由于标题、正文字体不同，此处大致语法如下：

```typst
// headings
  show heading.where(level: 1): it =>{
    set text(
      font: fonts.HeiTi,
      size: fonts.No3,
      weight: "regular",
    )
    align(center)[
      // #it
      #strong(it)
    ]
    text()[#v(0.5em)]
  }

  show heading.where(level: 2): it =>{
    set text(
      font: fonts.HeiTi,
      size: fonts.No4,
      weight: "regular"
      )
    it
    text()[#v(0.5em)]
  }

  show heading.where(level: 3): it =>{
    set text(
      font: fonts.HeiTi,
      size: fonts.No4-Small,
      weight: "regular"
      )
    it
    text()[#v(0.5em)] 
  }

  // paragraph
  set block(spacing: 1.5em)
  set par(
    justify: true,
    first-line-indent: 2em,
    leading: 1.5em)
```
  headings 设定了各个登记标题的格式，其中一级标题需要居中对齐.
  'font: fonts.HeiTi' 即为字体的关键参数，参数的值是字体的名称（字符串）. typst 将会在编译器内核、项目目录中搜索. typst 内核自带了 Source Sans（黑体）和 Source Serif（宋体）系列，但是中文论文所需的仿宋、楷体仍需自己上传.
  

# Quickstart of typst template

按照毕业设计要求，以 markdown 格式书写你的毕业论文，只需要：

- 在 configs/info 里填入个人信息.
  如有标题编译错误（比如我默认了有三行标题），可以自行按照编译器提示把相关代码注释或者修改. 大体语法和内容与基本的编程语言无差别.

- 在 content.typ 里以 typst 特定的 markdown 语法书写你的论文内容. 
  有关 typst 中 markdown 的语法变更，个人认为的主要变化罗列如下：
  - 标题栏使用 '=' 而非 '#'，'#' 在 typst 里是宏命令的开头.
  - 数学公式不需要反斜杠，数学符号可以查阅：https://typst.app/docs/reference/symbols/sym/. 值得注意的是，typst 中语法不通过叠加的方式实现，如 “不等号” 在 LaTex 中是 '\not{=}'. 而在 typst 中，使用 'eq.not' 的方式来调用 'eq'（等号）的 'not'（不等）变体实现.
  - 引用标签采用 '@label' 来实现，自定义标签通过 '<label-title>' 来实现. 对于 BibTex 格式的引用（refer.bib），与 LaTex 思路相同，第一个缩略词将会被认定为 label.
  
- 自定义格式的思路.
  如有额外的需要自定义格式的需求，可以自行学习 '#set', '#show' 命令，这可能需要一定的编程语言知识，后续我会更新部分简略教程在我的 github 仓库里：https://github.com/Duolei-Wang/lang-typst.

- 本模板的结构
  1. 内容主体. 文章主体内容书写在 content.typ 文件中，附录部分书写在 appendix.typ 文件中.
  2. 内容顺序. 文章内容顺序由 main.typ 决定，通过 typst 中 '#include' 指令实现了页面的插入. 
  3. 内容格式. 内容格式由 /sections/*.typ 控制，body.typ 控制了文章主体的格式，其余与名称一致. cover 为封面，commitment 为承诺书，outline 为目录，abstract 为摘要.

# 版本说明

版本号：0.1.1

- Fixed the fatal bug.
  修正了参数传递失败造成的封面等页面无法正常更改信息.

TODO:
- [ ] 引用格式 check.


# 特别鸣谢

南方科技大学本科毕业设计（论文）模板，论文格式参照 [南方科技大学本科生毕业设计（论文）撰写规范](https://tao.sustech.edu.cn/studentService/graduation_project.html). 如有疏漏敬请谅解，本模板为本人毕业之前自用，如有使用，稳定性请自行负责. 

- 本模板主要参考了 [iydon](https://github.com/iydon) 仓库的的 $\LaTeX$ 模板 [sustechthesis](https://github.com/iydon/sustechthesis)；结构组织参照了 [shuosc](https://github.com/shuosc) 仓库的 [SHU-Bachelor-Thesis-Typst](https://github.com/shuosc/SHU-Bachelor-Thesis-Typst) 模板；图片素材使用了 [GuTaoZi](https://github.com/GuTaoZi) 的同内容仓库里的模板.

- 感谢 [SHU-Bachelor-Thesis](https://github.com/shuosc/SHU-Bachelor-Thesis-Typst) 的结构组织让我学习到了很多，给我的页面组织提供了灵感，

- 在查找图片素材的时候，使用了 GuTaoZi 仓库 [SUSTech-thesis-typst](https://github.com/GuTaoZi/SUSTech-thesis-typst) 里的svg 素材，特此感谢. 


本模板、仓库处于个人安利 typst 的需要——在线模板需上传至 typst/packages 官方仓库才能被搜索到，如有开发和接管等需求请务必联系我：

QQ: 782564506

mail: wangdl2020@mail.sustech.edu.cn