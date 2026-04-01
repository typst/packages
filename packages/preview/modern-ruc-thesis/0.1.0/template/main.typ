#import "@preview/modern-ruc-thesis:0.1.0": project


#show: project.with(
  title: "对毕业论文模板的研究",
  subtitle: "以Typst模板为例",
  author: "张三",
  school: "信息学院",
  major: "计算机科学与技术",
  grade: "2022级",
  student-id: "2022000000",
  advisor: "李四",
  score: "90分",
  date: "2026年3月10日",
  encoding: "RUC-BK-050101-2021000000",
  abstract-zh: [
    这里是中文摘要。在对论文进行总结的基础上，用简单、明确、易懂、精辟的语言对全文内容加以概括，提取论文的主要信息。

    摘要通常包含研究背景、目的、方法、结果和结论。
  ],
  keywords-zh: ("关键词1", "关键词2", "关键词3"),
  abstract-en: [
    This is abstract. Use simple, clear, understandable, incisive language to summarize the full text content, extract the main information of the paper.

    The abstract usually contains the research background, purpose, methods, results, and conclusions.
  ],
  keywords-en: ("Keyword1", "Keyword2", "Keyword3"),
  acknowledgement: include "acknowledgement.typ",
  appendix: include "appendix.typ",
  bibliography: bibliography("refs.bib"),
)

#include "chapters/chapter1.typ"
#include "chapters/chapter2.typ"
