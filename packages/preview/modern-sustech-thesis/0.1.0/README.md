# sustech-bachelor-thesis

版本说明：v0.1.0.

TODO:
- [ ] 引用格式 check.

南方科技大学本科毕业设计（论文）模板，论文格式参照 [南方科技大学本科生毕业设计（论文）撰写规范](https://tao.sustech.edu.cn/studentService/graduation_project.html). 如有疏漏敬请谅解，本模板为本人毕业之前自用，如有使用，稳定性请自行负责. 

本模板参考了 [iydon](https://github.com/iydon) 仓库的的 $\LaTeX$ 模板 [sustechthesis](https://github.com/iydon/sustechthesis)；结构组织参照了 [shuosc](https://github.com/shuosc) 仓库的 [SHU-Bachelor-Thesis-Typst](https://github.com/shuosc/SHU-Bachelor-Thesis-Typst) 模板；图片素材使用了 [GuTaoZi](https://github.com/GuTaoZi) 的同内容仓库里的模板.

本模板、仓库处于个人安利 typst 的需要——在线模板需上传至 typst 官方仓库才能被搜索到，如有开发和接管等需求请务必联系我：

QQ: 782564506
mail: wangdl2020@mail.sustech.edu.cn

## Quickstart

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


## 有关字体的补充说明

为了 typst/packages 审核方便，我将字体文件上传到了个人版本的仓库里：https://github.com/Duolei-Wang/sustech-thesis-typs. 如有字体使用的需求，请将其中 fonts 文件夹下载后移动到当前根目录下使用.

经个人查阅，论文等要求的“宋体”等字体要求均是一个模糊的概念. 

实际上，Windows 系统的宋体指中易宋体等，macOS 采用了华文宋体等. 为了避免不必要的纠纷，建议字体采用完全开源的字体，如：思源宋体、思源黑体、方正宋体、方正黑体、方正楷体、仿宋GB2312 等. 如担心字体审核问题，建议统一采用 GB2312 系列（缺点是部分生僻字缺失）. 本模板中使用的字体均为开源字体.

论文字体的选择在 font.typ 里进行了设置，可以修改 SongTi, HeiTi 等自变量的值来决定采用哪一个字体，这些自变量的值应当是字体的标准名称. 

如果想查阅当前编译环境内的可选字体，可以通过以下两种方式：

```typst
#set text(
  font: ...
)
```

然后将光标悬停在 'font: ' 后，编译器会自动列出当前可用字体. 

或者采用命令行指令 'typst fonts' 来查看可选字体.

# 特别鸣谢

- 绘制封面页的时候，参考了 LaTex 版本的 [sustechthesis](https://github.com/iydon/sustechthesis)，特此感谢. 

- 感谢 [SHU-Bachelor-Thesis](https://github.com/shuosc/SHU-Bachelor-Thesis-Typst) 的结构组织让我学习到了很多，给我的页面组织提供了灵感，

- 在查找图片素材的时候，发现了 GuTaoZi 的 [SUSTech-thesis-typst](https://github.com/GuTaoZi/SUSTech-thesis-typst)，发现了自己是闭门造车的事实. 故标注本人的模板为自用版本，此外，校徽等素材使用了咕桃的 svg 素材，特此感谢. 