#import "@preview/touying:0.6.3": *
#import "touying-endfield:0.1.1": *

#import "@preview/numbly:0.1.0": numbly
#import "@preview/zh-kit:0.1.0"
#import "@preview/sicons:16.0.0": *

// 脚注设置
#show footnote.entry: set text(size: 0.8em)

// 主题主体设置
#show: endfield-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  navigation: "mini-slides", // sidebar, mini-slides, none。如果你有很多小标题和子标题，建议选择 mini-slides 或 none。默认为 none。
  mini-slides: (
    height: 2.5em,            // 缩略幻灯片栏高度
    inline: true,             // 显示模式：false = 换行显示，true = 标题行内
    spacing: .2em,            // 幻灯片指示器之间的间距
    current-slide-sym: $triangle.small.b.filled$,  // 当前幻灯片符号（可选）
    other-slides-sym: $triangle.small.t.stroked$,  // 其他幻灯片符号（可选）
  ),
  config-store(
    title-height: 4.5em,
  ),
  config-info(
    title: [塔卫二超域跨维动力学及其现象学影响],
    subtitle: [研究综述],
    author: [
      #grid(
        columns: (auto, auto),
        align: center,
        gutter: 0.5em,
        [
          管理员#footnote(numbering: "*")[同等贡献]<eq-contrib> #counter(footnote).update(0) #footnote[塔卫二同步轨道，O.M.V. 帝江号，终末地工业]<endfield> #h(1em)
          佩丽卡 @eq-contrib @endfield #h(1em)
          秦茳尺 @eq-contrib @endfield #footnote[塔卫二，四号谷地，联盟工团（四号谷地基地）]<uwst> #h(1em)
          安德鲁 @eq-contrib @endfield @uwst #h(1em)
          伊冯 @eq-contrib @endfield @uwst
        ],
        [
          庄方宜 @eq-contrib #footnote[塔卫二，武陵科技发展区，宏山科学院]
        ],

        [`{endmin,perlica,jqin,andrew,yvonne}`\ `@endfield.co.ii.talos`], [`fzhuang@has.ac.ii.talos`],
      )
    ],
    date: [2026-01-22],
    institution: text("ENDFIELD", font: "Gilroy", weight: "bold") + text(" INDUSTRIES", font: "Gilroy", size: 0.8em),
  ),
  config-page(fill: luma(231)), // 使用侧边栏导航和/或打印时，建议使用纯色而非渐变色

  // 你可以设置 CJK 和拉丁文字的默认字体，并指定语言和区域以获得正确的字形和本地化。默认主字体为 `Harmony OS Sans`，你可以通过此设置完全覆盖它。不建议使用 `Arial`，因为它捆绑的 `Arial Unicode Sans MS` CJK 字体很难看；建议使用 `Helvetica` 或 `Source Sans` 以获得更好的显示效果。对于 CJK 字体，`Source Han Sans` 是一个不错的免费选项。
  config-fonts(
    cjk-font-family: ("HarmonyOS Sans SC", "Source Han Sans", "Noto Sans CJK"),
    latin-font-family: ("HarmonyOS Sans", "Source Sans 3", "Noto Sans"),
    lang: "zh",
    region: "cn",
  ),
)

// 标题编号设置
#set heading(numbering: numbly("{1}.", default: "1.1"))

// 公式编号设置
#set math.equation(numbering: "(1)")

#title-slide()

#outline-slide()

= 基础现象学

== 维度拓扑学

超域处于深度 1 的复合维度态，与实域（深度 0）在地下、大气层及轨道空间存在重叠。@depth-equation 反映了裂隙边界距离与局部深度读数的相关关系。

$ D(x) = tanh(lambda x) $ <depth-equation>

式中 $D$ 为深度场，取值区间 $[-1, 1]$：$D = 0$ 为现实空间（正常状态），$D = -1$ 为源石内化宇宙，$D = 1$ 为超域；$x$ 为距裂隙边界的距离。当深度读数在 $0.5$ 附近时侵蚀最为活跃，对应 Higgs 型标量场偏离真空期望值较远的超域-现实重叠区。

== 生物危害

=== 活性侵蚀病原学

直接接触超域物质将导致生命活动*不可逆*地终止#footnote[《环带公约》第 934 条严禁活体置换实验。]。

反之，自超域逸出的物质会在实域引发活性侵蚀，构成严重的污染风险。

= 工程应用

== 源石调制

培育源石矿藏可降低局部深度读数，有效稳定维度屏障并抑制裂隙扩张。但重叠区域内源石技艺设备的运行干扰问题仍待解决。

- 一些要点
  - 一些子要点
- 其他要点

+ 一些枚举要点
+ 其他枚举要点

#focus-slide[
  #text(size: 2em)[警告]\
  检测到活性侵蚀\
  #text(weight: "light")[请与未记录的裂隙结构保持安全距离]
]

== 实验方法

#block(fill: luma(250), inset: 1em, radius: 0.5em)[这里演示 `#pause` 和 `#meanwhile` 的 #pause 用法。]

#pause

深度读数接近 0.3 时，人员须立即穿戴防护外骨骼；超过 0.5 后侵蚀风险急剧上升。

#meanwhile

与此同时，#pause 能量提取作业#pause 需配置冗余遏制阵列以防级联失效。

#show: appendix

= 附录

== 附录

#block(fill: luma(250), inset: 1em, radius: 0.5em)[请注意当前页码。]

主要参考资料包括塔卫二研究联合会档案及环带公约安全文档。

== 注意事项

Typst 与 Touying 的新手可参考：
- #link("https://typst.app/docs")（Typst 官方文档）
- #link("https://touying-typ.github.io/")（Touying 官方文档）

推荐使用 Visual Studio Code 搭配 Typst 扩展，实现编辑与实时预览。

为获得最佳显示效果，建议安装 `Harmony OS Sans` 与 `Gilroy`。默认主字体为 `Harmony OS Sans`，焦点幻灯片的"警告"文本可以使用 `Gilroy` 字体以突出强调（CJK 直接用 HarmonyOS Sans 就好）。*请注意 `Gilroy` 为商业字体*，非个人使用需购买许可证。

== 已知问题

1. HarmonyOS Sans 字体系列的拉伸元数据未标准化，typst 会将 "light" 字重渲染为压缩变体 #text(weight: "light", "like this")，_italic_ 样式亦受影响。CJK 文本则无此问题。*粗体*目前渲染正常。由于 Condensed 变体的 `stretch` 元数据同样为 `1000`，无法通过 `#text(stretch: 100%)` 修复。可改用 `Source Sans` 或 `Source Han Sans`，或卸载 Condensed 字重系列，亦可关注社区方案 #footnote[#link("https://github.com/typst/typst/issues/2917")]及官方后续修复 #footnote[#link("https://github.com/typst/typst/issues/2098")，截至 2026 年 2 月仍处开放状态。]，抑或权当这是该字体系列的特色。

2. 侧边栏导航无法自适应（不会随幻灯片数量调整大纲深度或文本大小，左侧将出现溢出）。mini-slides 同理，可通过 `mini-slides: (height: 3em)` 等参数自行调整。此为 touying 内置 `custom-progressive-outline` 与 `mini-slides` 组件的固有限制，未来或可重写高级版本以解决。欢迎建议与 PR！\ 如果不想折腾，直接用 `navigation: "none"` 即可。

#pagebreak()
3. 此外，标题幻灯片的装饰条存在类似的无法自适应问题。目前可在 `config-store` 中增大 `title-height` 以应对标题换行，但非理想方案。同样欢迎建议与 PR！

== 免责声明

《明日方舟：终末地》由#link("https://hypergryph.com", "鹰角网络")（境外为 #link("https://gryphline.com/", "Gryphline")）开发。本主题与鹰角网络及其关联方无任何关联。所有商标归各自权利人所有。

#heading(depth: 2, outlined: false)[感谢！]
欢迎在 #link("https://github.com/leostudiooo/typst-touying-theme-endfield", [#box(sicon(slug: "github")) `leostudiooo/typst-touying-theme-endfield`]) 提交 Issues 和 PR。
