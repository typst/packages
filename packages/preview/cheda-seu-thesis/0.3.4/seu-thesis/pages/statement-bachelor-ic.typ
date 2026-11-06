#import "../utils/fonts.typ": 字体, 字号

#page(
  paper: "a4",
  margin: (
    top: 2cm + 0.5cm,
    bottom: 2cm + 0.5cm,
    left: 2cm + 0.25cm,
    right: 2cm + 0.25cm,
  ),
  {
    v(80pt - 0.4cm)
    set align(left)
    set text(font: 字体.宋体, size: 字号.小四, lang: "zh", region: "cn")
    set par(leading: 11.3pt, justify: true, first-line-indent: 0pt)
    set line(stroke: 0.6pt)
    align(
      center,
      text(
        font: 字体.黑体,
        size: 字号.小二,
      )[东南大学毕业（设计）论文独创性声明],
    )
    v(24pt)
    h(2em)
    [本人声明所呈交的毕业（设计）论文是我个人在导师指导下进行的研究工作及取得的研究成果。尽我所知，除了文中特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写过的研究成果，也不包含为获得东南大学或其它教育机构的学位或证书而使用过的材料。与我一同工作的同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示了谢意。]
    v(18pt)
    grid(
      columns: 11,
      h(48pt),
      [论文作者签名：],
      line(length: 8em, start: (6pt, 10pt)),
      h(18pt),
      [日期：],
      line(length: 3.5em, start: (6pt, 10pt)),
      [年],
      line(length: 2.5em, start: (2pt, 10pt)),
      [月],
      line(length: 2.5em, start: (2pt, 10pt)),
      [日],
    )

    v(140pt)

    align(
      center,
      text(
        font: 字体.黑体,
        size: 字号.小二,
      )[东南大学毕业（设计）论文使用授权声明],
    )
    v(13pt)
    h(2em)
    [东南大学有权保留本人所送交毕业（设计）论文的复印件和电子文档，可以采用影印、缩印或其他复制手段保存论文。本人电子文档的内容和纸质论文的内容相一致。除在保密期内的保密论文外，允许论文被查阅和借阅，可以公布（包括刊登）论文的全部或部分内容。论文的公布（包括刊登）授权东南大学教务处办理。]
    v(16pt)
    grid(
      columns: (24pt, 200pt, 22pt, 1fr),
      row-gutter: 10pt,
      rows: 2,
      [],
      grid(
        columns: 2,
        [论文作者签名：],
        line(length: 115pt, start: (6pt, 10pt)),
      ),
      [],
      grid(
        columns: 2,
        [导师签名：],
        line(length: 140pt, start: (6pt, 10pt)),
      ),
      [],
      grid(
        columns: 7,
        [日期：],
        line(length: 3.5em, start: (6pt, 10pt)),
        [年],
        line(length: 2.9em, start: (2pt, 10pt)),
        [月],
        line(length: 2.9em, start: (2pt, 10pt)),
        [日],
      ),
      [],
      grid(
        columns: 7,
        [日期：],
        line(length: 2.5em, start: (6pt, 10pt)),
        [年],
        line(length: 2.9em, start: (2pt, 10pt)),
        [月],
        line(length: 2.9em, start: (2pt, 10pt)),
        [日],
      ),
    )
  },
)