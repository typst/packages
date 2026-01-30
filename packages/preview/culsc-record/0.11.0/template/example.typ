#import "@preview/culsc-record:0.11.0": *
//#import "/lib.typ": *

#show: culsc-record.with(
  // 文本字体集：可选 "windows", "macos", "web"
  text-fontset: "windows",
  // 也可以自定义配置：
  /*
  text-fontset: (
    sans: ("Arial", "SimHei"), // 黑体
    serif: "SimSun",           // 宋体
    en: "Times New Roman"      // 西文
  ),
  */

  // 数学字体集：可选 "recommend", "windows", "macos", "web"
  // 使用 "recommend" 效果最佳，但需要自行安装额外字体
  math-fontset: "recommend",
  // 也可以自定义配置：
  /*
  math-fontset: (
    main: ("TeX Gyre Termes Math"), // 主字体
    text: ("TeX Gyre Termes"), // 文本字体
    blackboard: ("TeX Gyre Termes Math", "New Computer Modern Math"), // 板粗体（空心体）
    calligraphic: ("New Computer Modern Math"), // 花体
    integral: ("TeX Gyre Termes Math")), // 积分号字体
  */
  
  session: "十一",
  serial: "01",          // 序号
  start-year: "2026",    // 开始年
  start-month: "01",     // 开始月
  start-day: "21",       // 开始日
  start-time: "08:00",   // 开始时间
  end-year: "2026",      // 结束年
  end-month: "01",       // 结束月
  end-day: "30",         // 结束日
  end-time: "12:30"      // 结束时间
)

// 设置代码字体
// #show raw: set text(font: ("New Computer Modern Mono", "Noto Sans CJK SC"))

// 开始撰写实际内容

// noindent 用于创建一个不缩进的内容块
#noindent[
*注意：*

1、“序号”是实验记录的顺序，1、2、3等，不是团队编号。

2、所有上传材料中请勿出现团队编号、任何学校名称和姓名。

3、避免出现明确的实验材料采样和保存地点，比如xx菌种保存在xx学校菌种库，xx材料从xx学校采集获得。

4、避免出现过多的实验过程照片，比如穿着xx学校实验服的学生，贴有xx学校固定资产的实验仪器，有xx学校抬头的实验记录纸。

5、避免出现团队成员合照、正面照片、指导老师照片。

6、参考文献中的姓名学校没有关系。

7、实验记录内容没有格式要求。

（撰写实验记录时请删除这段话）
]

= 实验目的

本次实验旨在探究......

= 实验材料

- 试剂：......
- 仪器：......

= 实验步骤

+ 取样......
+ 离心......

= 实验结果

== 本模板只提供了基本的布局排版、国标格式数学公式及国标格式参考文献的支持

=== 布局排版与 MS Word 的对应关系<layout>

下述宋体、黑体均指代中易系列下的效果。

文档网格：只指定行网格，每页 46 行。

一级标题：四号加粗宋体、段前 0.5 行、段后 0 行。

其他级标题：小四号加粗宋体、无段前段后距离、1.25 倍行距。 

正文：小四号宋体、无段前段后距离、1.25 倍行距。

题注：五号宋体，段后 1.75 磅、1.2 倍行距。

=== 公式的书写与引用

公式一般有编号，如@eq:example：

$
cal(F){f(x)} = hat(f)(omega) = 1/sqrt(2pi) integral_(-infinity)^(+infinity) f(x) e^(-i omega x) dif x, quad omega in bb(R).
$<eq:example>

如果不需要编号，可以使用 ```typ #notag()``` 函数包围，如下式：

#notag(
  $
  nabla times bold(E) = -(partial bold(B)) / (partial t), quad nabla dot bold(B) = 0, quad bold(E), bold(B) in bb(R)^3,
  $
)

#noindent[
这类公式不能添加标签，故不能被引用，否则会报错。
]

=== 参考文献采用 GB/T 7714—2015 格式规范，通过 `.bib` 文件管理文献源

像这样引用文献@美国妇产科医师学会2010，也可以引用多个@praetzellis2011@汪昂1881、@钱学森2001@中国职工教育研究会1985@雷光春2012、@praetzellis2011@雷光春2012。

由于 Typst 的原生文献工具 Hayagriva 尚不完善，因此有部分文献类型需要手动处理，主要是标准[S]、报纸[N]及汇编[G]，还有一些罕用的情况，如连续出版物[J]（常见的期刊文献本质上是连续出版物的析出文献）。

详细的处理方法参考示例 `ref-01.bib` 文件中的注释即可，已尽可能地考虑对 Zotero 和 #LaTeX 宏包 biblatex-gb7714-2015 的兼容性，迁移过去后可以比较快速地修改为正确的格式。

此外，基于 citegeist 的国标格式参考文献包 gb7714-bilingual 正在蓬勃发展，如果未来发展成熟，本模板会及时切换到更完善的方案，Typst 未来可期！

= 实验总结

建议在项目中建立多个文件夹分别管理各个实验，例如将第一个实验的文件放在 `\01\` 目录下，实验文件命名为 `experiment-01.typ`，文献源命名为 `ref-01.bib`。

```
project/
├── 01/
│   ├── experiment-01.typ
│   └── ref-01.bib
├── 02/
│   ├── experiment-02.typ
│   └── ref-02.bib
├── 03/
│   ├── experiment-03.typ
│   └── ref-03.bib
⋮
└── 0n/
    ├── experiment-0n.typ
    └── ref-0n.bib
```

测试是否跟 MS Word 中按照@layout 设置后的效果相同，即每页可容纳 34 行正文文本。

#pagebreak() // 强制换页

#noindent[
  #for i in range(1, 35) [
    第#i 行\
  ]
]

#pagebreak() // 强制换页

= 实验反思

本模板预设了数个平台的字体配置，具体如下所示：

// 导入 markdown-like 风格的三线表
#import "@preview/tablem:0.3.0": three-line-table

#figure(
  caption: [culsc-record 模板中预设字体集的具体设置],
  {
    set text(size: 10pt)
    three-line-table[
    |平台   |宋体    |黑体    |西文字体       |数学主字体|数学文本字体|
    |Windows|中易宋体|中易黑体|Times New Roman|Cambria Math|对应的西文字体 + 宋体|
    |macOS  |华文宋体|华文黑体|Times New Roman|STIX Two Math|^|
    |Web App|思源宋体|思源黑体|TeX Gyre Termes|TeX Gyre Termes Math|^|
    |`"recommend"`|--|--|--|XITS Math|Windows 下的配置|
    ]
  }
)

Web App 和 `"recommend"` 下的数学字体有回退机制，具体如下代码所示：

#grid(
  columns: (1fr, 1fr),
  [
    #text(size: 8pt)[
      ```typst
        recommend: (
            main: (
              "XITS Math",
              "TeX Gyre Termes Math",
              "STIX Two Math",
              "New Computer Modern Math",
            ),
            text: (
              "Times New Roman",
              "SimSun"
            ),
            blackboard: (
              "TeX Gyre Termes Math",
              "New Computer Modern Math",
              "XITS Math",
              "STIX Two Math",
            ),
            calligraphic: (
              "XITS Math",
              "New Computer Modern Math",
              "TeX Gyre Termes Math",
              "STIX Two Math",
            ),
            integral: (
              "Euler Math",
              "TeX Gyre Termes Math",
              "XITS Math",
              "STIX Two Math",
              "New Computer Modern Math",
            ),
          ),
      ```
    ]
  ],
  [
    #text(size: 9.5pt)[
      ```typst
          web: (
            main: (
              "TeX Gyre Termes Math",
              "STIX Two Math",
              "New Computer Modern Math",
            ),
            text: (
              "TeX Gyre Termes",
              "Noto Serif CJK SC"
            ),
            blackboard: (
              "TeX Gyre Termes Math",
              "New Computer Modern Math",
              "STIX Two Math",
            ),
            calligraphic: (
              "New Computer Modern Math",
              "TeX Gyre Termes Math",
              "STIX Two Math",
            ),
            integral: (
              "TeX Gyre Termes Math",
              "STIX Two Math",
              "New Computer Modern Math",
            ),
          ),
      ```
    ]
  ]
)

如欲使用 `"recommend"` 数学字体集，请自行安装这些字体#footnote[模板所预设的数学字体都是免费且开源的。]。
// 打印参考文献
#show: columns.with(2) // 像这样可以修改后续内容为两列布局，如果文献特别多的话可以这样处理，显得美观许多
#text(size: zh(5))[ // 像这样修改参考文献的字号，例如 `5` 代表五号`，-5` 代表小五号
  #print-bib(
    bibliography: bibliography.with("ref-example.bib"), // 添加文献源
    full: true, // 打印全部文献，注释掉或者设为 `false` 则只打印引用过的文献
    gbpunctwidth: "full", // 中文文献使用全角标点，可选 `half`
    uppercase-english-names: true, // 西文人名是否全大写
    bib-number-gutter: 1em, // 编号与条目的间距
    bib-number-align: "right", // 编号对齐行为，可选 `"left"`
  )
]