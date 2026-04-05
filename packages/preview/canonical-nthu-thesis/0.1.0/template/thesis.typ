#import "@preview/canonical-nthu-thesis:0.1.0": setup-thesis

#let (
    doc, cover-pages, preface, outline-pages, body,
) = setup-thesis(
    info: (
	degree: "master",
	title-zh: [一個標題有點長的 \ 有趣的研究],
	title-en: [An Interesting Research \ With a Somewhat Long Title],
	department-zh: "某學系",
	department-en: "Mysterious Department",
	id: "012345678",
	author-zh: "張三",
	author-en: "San Chang",
	supervisor-zh: "李四 教授",
	supervisor-en: "Prof. Si Lee",
	year-zh: "一一三",
	month-zh: "七",
	date-en: "July 2024",
    ),
    style: (
	margin: (top: 1.75in, left: 2in, right: 1in, bottom: 2in),
    ),
)

#cover-pages()


////////////////////////////////////////////////////////////////////////////////////////////////
// The preface, which contains the abstract, the acknowledgements, and the table(s) of contents.
// 前言部分，包含摘要、誌謝、大綱及圖表目錄。
#show: preface

= 摘要
此論文模板使用Typst @madje2022programmable\標記語言排版。請參閱隨附的README文件以及位於https://typst.app/docs/的文檔了解如何使用Typst。

// Fake abstract text.  Delete it and fill in your actual abstract.
本文深入探討一個未指定領域的主題，深入研究一個模糊的概念及其複雜性。研究方法採用了難以理解的方式進行，所呈現的發現幾乎沒有清晰度或實質性的貢獻。這項工作的意義同樣模糊不清，讓讀者留下更多疑問而非答案。

關鍵詞：未指定領域、模糊概念、難以理解的方法、不清的發現、模糊的意義

#pagebreak()


= Abstract
This template for master theses / doctoral dissertations uses Typst @madje2022programmable.  Refer to the README file and the upstream documentations at https://typst.app/docs/ to know more about Typst.

// Fake generic text.  Delete it and fill in your actual abstract.
#lorem(150)
#pagebreak()


= 誌謝
// Fake acknowledgements text.  Delete it and fill in your actual acknowledgements.
在完成這篇論文的過程中，我得到了許多人的幫助和支持。首先，我要感謝我的指導老師李四，是他悉心的指導和鼓勵，才讓我得以順利完成這篇論文。其次，我要感謝我的父母和家人，是他們無私的愛和支持，給了我堅持下去的力量。此外，還要感謝我的同學和朋友們，是他們在學習和生活上對我的幫助，讓我受益匪淺。

最後，我要感謝所有曾經幫助過我的人。正是有了大家的幫助，我才得以取得今天的成績。
#pagebreak()


#outline-pages


///////////////////
// The main matter.
// 本文部分。
#show: body

= Introduction
#figure(
    square(size: 100pt, fill: gradient.linear(..color.map.rainbow)),
    caption: [A figure to populate the image list],
    placement: bottom,
)
#lorem(300)


= Background
== Important background
#lorem(100)
== Previous works
#lorem(100)


= Methods
== An excellent method
#figure(
    table(
        columns: 4,
        table.header([], [Apples], [Bananas], [Cherries]),
        [Alice], [1.0], [2.0], [3.0],
        [Bob], [1.5], [1.0], [0.5],
        [Eve], [3.5], [7.5], [1.2],
    ),
    caption: [A dummy table to populate the table index page],
    placement: bottom,
)
#lorem(100)
== Another method
#lorem(100)


= Experiments
== Setup
#lorem(100)
== The results
#lorem(100)


= Conclusion
#lorem(200)


#bibliography("citations.bib", style: "ieee")
