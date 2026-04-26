# 东南大学论文模板

使用 Typst 复刻东南大学「本科毕业设计（论文）报告」模板和「研究生学位论文」模板。

请在 [`init-files`](./init-files/) 目录内查看 Demo PDF。

> [!IMPORTANT]
>
> 此模板是民间模板，学校可能不会认可本模板。
>
> 此模板内可能仍然存在诸多格式问题。
>
> 如需使用此模板，请自行承担风险。

- [东南大学论文模板](#东南大学论文模板)
  - [使用方法](#使用方法)
    - [本地使用](#本地使用)
    - [Web App](#web-app)
  - [模板内容](#模板内容)
    - [研究生学位论文模板](#研究生学位论文模板)
    - [本科毕业设计（论文）报告模板](#本科毕业设计论文报告模板)
  - [目前存在的问题](#目前存在的问题)
    - [参考文献](#参考文献)
  - [开发与协议](#开发与协议)
    - [二次开发](#二次开发)

## 使用方法

本模板需要使用 Typst 0.11.0 编译。

此模板已上传 Typst Universe ，可以使用 `typst init` 功能初始化，也可以使用 Web App 编辑。Typst Universe 上的模板可能不是最新版本。如果需要使用最新版本的模板，从本 repo 中获取。

### 本地使用

请先安装位于 `fonts` 目录内的全部字体。然后，您可以使用以下两种方式使用本模板：

- 下载/clone 本 repo 的全部文件，编辑 `init-files` 目录内的示例文件。
- 使用 `typst init @preview/cheda-seu-thesis:0.2.2` 来获取此模板与初始化文件。

随后，您可以通过编辑示例文件来生成想要的论文。两种论文格式的说明都在对应的示例文档内。

如您使用 VSCode 作为编辑器，可以尝试使用 [Tinymist](https://marketplace.visualstudio.com/items?itemName=nvarner.typst-lsp) 与 [Typst Preview](https://marketplace.visualstudio.com/items?itemName=mgt19937.typst-preview) 插件。如有本地包云同步需求，可以使用 [Typst Sync](https://marketplace.visualstudio.com/items?itemName=OrangeX4.vscode-typst-sync) 插件。更多编辑技巧，可查阅 <https://github.com/nju-lug/modern-nju-thesis#vs-code-%E6%9C%AC%E5%9C%B0%E7%BC%96%E8%BE%91%E6%8E%A8%E8%8D%90> 。

### Web App

> [!NOTE]
>
> 由于字体原因，不建议使用 Web App 编辑此模板。

请打开 <https://typst.app/universe/package/cheda-seu-thesis> 并点击 `Create project in app` ，或在 Web App 中选择 `Start from a template`，再选择 `cheda-seu-thesis`。

然后，请将 <https://github.com/csimide/SEU-Typst-Template/tree/master/fonts> 内的 **所有** 字体上传到 Typst Web App 内该项目的根目录。注意，之后每次打开此项目，浏览器都会花费很长时间从 Typst Web App 的服务器下载这一批字体，体验较差。

最后，请按照自动打开的文件的提示操作。

## 模板内容

### 研究生学位论文模板

此 Typst 模板按照[《东南大学研究生学位论文格式规定》](https://seugs.seu.edu.cn/_upload/article/files/5d/c2/abe9785f44c8b3ea4823f14bfb92/cd829a73-1b86-400d-9bce-2c4b4fdb85b7.pdf)制作，制作时参考了 [SEUThesis 模板](https://ctan.math.utah.edu/ctan/tex-archive/macros/latex/contrib/seuthesis/seuthesis.pdf)。

当前支持进度：

- 文档构件
  - [x] 封面
  - [x] 中英文扉页
  - [x] 中英文摘要
  - [x] 目录
  - [x] 术语表
  - [x] 正文
  - [x] 致谢
  - [x] 参考文献
  - [x] 附录
  - [ ] 索引
  - [ ] 作者简介
  - [ ] 后记
  - [ ] 封底
- 功能
  - [ ] 盲审
  - [x] 页码编号：正文前使用罗马数字，正文及正文后使用阿拉伯数字
  - [x] 正文、附录图表编号格式：详见研院要求
  - [x] 数学公式放置位置：离页面左侧两个汉字距离
  - [x] 数学公式编号：公式块右下
  - [x] 插入空白页：新章节总在奇数页上
  - [x] 页眉：奇数页显示章节号和章节标题，偶数页显示固定内容
  - [x] 参考文献：支持双语显示

### 本科毕业设计（论文）报告模板

此 Typst 模板基于东南大学本科毕业设计（论文）报告模板（2024 年 1 月）仿制，原模板可以在教务处网站上下载（[2019 年 9 月版](https://jwc.seu.edu.cn/2021/1108/c21686a389963/page.htm) , [2024 年 1 月版](https://jwc.seu.edu.cn/2024/0117/c21686a479303/page.htm)）。

当前支持进度：

- 文档构件
  - [x] 封面
  - [x] 中英文摘要
  - [x] 目录
  - [x] 正文
  - [x] 参考文献
  - [x] 附录
  - [x] 致谢
  - [ ] 封底
- 功能
  - [ ] 盲审
  - [x] 页码编号：正文前使用罗马数字，正文及正文后使用阿拉伯数字
  - [x] 正文、附录图表编号格式：详见本科毕设要求
  - [x] 数学公式放置位置：离页面左侧两个汉字距离
  - [x] 数学公式编号：公式块右侧中心
  - [x] 页眉：显示固定内容
  - [x] 参考文献：支持双语显示
  - [ ] 表格显示“续表”

> [!NOTE]
>
> 可以看看隔壁 <https://github.com/TideDra/seu-thesis-typst/> 项目，也正在使用 Typst 实现毕业设计（论文）报告模板，还提供了毕设翻译模板。该项目的实现细节与本模板并不相同，您可以根据自己的喜好选择。

## 目前存在的问题

- 中文首段有时会自动缩进，有时不会。如果没有自动缩进，需要使用 `#h(2em)` 手动缩进两个字符。
- 参考文献格式不完全符合要求。请见下方参考文献小节。
- 行距、边距等有待继续调整。

### 参考文献

参考文献格式不完全符合要求。Typst 自带的 GB/T 7714-2015 numeric 格式与学校要求格式相比，有以下问题：

1. 学校要求在作者数量较多时，英文使用 `et al.` 中文使用 `等` 来省略。但是，Typst 目前仅可以显示为单一语言。

   **A:** 该问题系 Typst 的 CSL 解析器不支持 CSL-M 导致的。

   <details>
   <summary> 详细原因 </summary>

   - 使用 CSL 实现这一 feature 需要用到 [CSL-M](https://citeproc-js.readthedocs.io/en/latest/csl-m/index.html#cs-layout-extension) 扩展的多 `layout` 功能，而 Typst 尚不支持 CSL-M 扩展功能。详见 https://github.com/typst/typst/issues/2793 与 https://github.com/typst/citationberg/issues/5 。
   - Typst 目前会忽视 BibTeX/CSL 中的 `language` 字段。参见 https://github.com/typst/hayagriva/pull/126 。

   因为上述原因，目前很难使用 Typst 原生方法实现根据语言自动选用 `et al.` 与 `等`。

   </details>

   OrangeX4 和我写了一个基于查找替换的 `bilingual-bibliography` 功能，试图在 Typst 支持 CSL-M 前实现中文西文使用不同的关键词。

   本模板的 Demo 文档内已使用 `bilingual-bibliography` 引用，请查看 Demo 文档以了解用法。注意，该功能仍在测试，很可能有 Bug，详见 https://github.com/csimide/SEU-Typst-Template/issues/1 。

   > 请在 https://github.com/nju-lug/modern-nju-thesis/issues/3 查看更多有关双语参考文献实现的讨论。
   >
   > 本模板曾经尝试使用 https://github.com/csimide/cslper 作为双语参考文献的实现方法。

2. 学校给出的范例中，除了纯电子资源，即使引用文献来自线上渠道，也均不加 `OL`、访问日期、DOI 与 链接。但是，Typst 内置的 GB/T 7714-2015 numeric 格式会为所有 bib 内定义了链接/DOI 的文献添加 `OL` 标记和链接/DOI 。

   **A:** 该问题系学校的标准与 GB/T 7714-2015 不完全一致导致的。

   请使用 `style: "./seu-thesis/gb-t-7714-2015-numeric-seu.csl"` ，会自动依据文献类型选择是否显示 `OL` 标记和链接/DOI。

   > 该 csl 修改自 <https://github.com/redleafnew/Chinese-STD-GB-T-7714-related-csl/blob/main/003gb-t-7714-2015-numeric-bilingual-no-url-doi.csl>
   >
   > 原文件基于 CC-BY-SA 3.0 协议共享。

3. 作者大小写（或者其他细节）与学校范例不一致。
4. 学位论文中，学校要求引用其他学位论文的文献类型应当写作 `[D]: [博士学位论文].` 格式，但模板显示为 `[D]` ，不显示子类别。
5. 学位论文中，学校给出的范例使用全角符号，如全角方括号、全角句点等。
6. 引用条目丢失 `. ` ，如 `[M]2nd ed`。

   **3~6 A:** 学校用的是 GB/T 7714-2015 的方言，曾经有学长把它叫做 GB/T 7714-SEU ，目前没找到完美匹配学校要求的 CSL（不同学院的要求也不太一样），后续会写一个符合要求的 CSL 文件。

   **2024-05-02 更新:** 现已初步实现 CSL。不得不说 Typst 的 CSL 支持成谜……目前修复情况如下：

   - 问题 3 已修复；
   - 问题 4 在学位论文的 CSL 内已修复，但 Typst 似乎不支持这一字段，因此无法显示；
   - 问题 5 不准备修复，查阅数篇已发表的学位论文，使用的也是半角符号；
   - 问题 6 似乎是 Typst 的 CSL 支持的问题，本模板附带的 CSL 文件已经做了额外处理，应该不会丢 `. ` 了。

7. 正文中连续引用，上标合并错误（例如，引用 1 2 3 4 应当显示为 [1-4] ，但是显示为 [1,4] ）。

   **A:** 临时方案是把 csl 文件里 `after-collapse-delimiter=","` 改成 `after-collapse-delimiter="-"`。本模板附带的 CSL 文件已做此修改。

   详细原因请见 https://github.com/typst/hayagriva/issues/154 。

## 开发与协议

如果您在使用过程中遇到任何问题，请提交 issue。本项目欢迎您的 PR。如果有其他模板需求也可以在 issue 中提出。

除下述特殊说明的文件外，此项目使用 MIT License 。

- `init-files/demo_image/` 路径下的文件来自东南大学教务处本科毕设模板。
- `seu-thesis/assets/` 路径下的文件是由东南大学教务处模板经二次加工得到，或从东南大学视觉设计中取得。
- `fonts` 路径下的文件是此模板用到的字体。
- `东南大学本科毕业设计（论文）参考模板 (2024年1月修订).docx` 是教务处提供的毕设论文模板。

### 二次开发

本模板欢迎二次开发。在二次开发前，建议了解本模板的主要特性与关联的文件：

- 有较为麻烦的图表、公式编号（图表编号格式不相同，甚至附录与正文中图表编号格式也不相同；图的名称在图下方，表的名称在表上方；公式不是居中对齐，公式编号位置不是右侧上下居中）。

  - `seu-thesis/utils/figure-and-ref.typ` 定义了显示图表格式、图表文内引用格式和公式引用格式的函数。
  - 上述文件依赖于 `part-state` （定义在 `seu-thesis/utils/states.typ` 内）用于判断所处的位置。
  - 部分计数器置零的工作是在 `heading` 中完成的，即 `seu-thesis/utils/show-heading.typ`
  - 如有条件或没有如此麻烦的需求，建议使用 `i-figure` 包。

- （仅研究生学位论文）奇数页偶数页页眉不同，且有页眉中显示章节名称的需求。

  - 该功能位于 `seu-thesis/parts/main-body-degree-fn.typ` ，并且强依赖在 `heading` （`seu-thesis/utils/show-heading.typ`）中完成的工作。
  - 该功能以来 `seu-thesis/utils/states.typ` 内定义的多个 `state`。

- 支持双语显示参考文献（自动使用 `et al.` 和 `等`）
  - 该功能来自 `bilingual-bibliography`，关联的文件是 `seu-thesis/utils/bilingual-bibliography.typ`。
  - 有关 `bilingual-bibliography` 的更多信息，请查看 https://github.com/nju-lug/modern-nju-thesis/issues/3

> [!NOTE]
>
> 本模板内造的轮子比较多，而且我的代码质量一般，请酌情取用。
