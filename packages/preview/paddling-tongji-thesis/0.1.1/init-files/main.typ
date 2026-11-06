#import "@preview/paddling-tongji-thesis:0.1.1": *

#set pagebreak(weak: true)

#show: thesis.with(
  school: "某某学院", major: "某某专业", id: "1999999", student: "某某某", teacher: "某某某", title: "论文模板", subtitle: [基于多种场景的Typst简要教程], title-english: "Thesis Template", subtitle-english: "with Various Scenes", date: datetime(
    year: datetime.today().year(), month: datetime.today().month(), day: datetime.today().day(),
  ), abstract: [
    摘要通常是一篇文章、论文、报告或其他文本的简短概括。它的目的是帮助读者了解文本的主要内容和结论，以便决定是否需要继续阅读原文。摘要通常包含文本的主题、目的、方法、结果和结论等方面的信息，并尽可能简洁明了地呈现。好的摘要应该能够概括文本的重点，同时避免使用不必要的细节和专业术语，以便广大读者能够轻松理解。

    此外，摘要通常也是学术界和研究人员评估一篇文献的重要依据之一。在文献检索和筛选过程中，人们通常会根据摘要来决定是否进一步查看完整的文献。因此，撰写一个清晰、准确、简洁的摘要对于文献的传播和影响力至关重要。在撰写摘要时，作者应该遵循文献的格式要求和撰写规范，同时结合文本的内容和目的，将摘要撰写得准确、简洁、易懂，以提高文献的传播和影响力。

    关键词1，关键词2，关键词3通常是与文章内容相关的几个词语，用于帮助读者更好地了解文章主题和内容。关键词的选择应该与文章的主题和研究领域密切相关，通常应该选择具有代表性、权威性、独特性和可搜索性的词语。
  ], keywords: ("关键词1", "关键词2", "关键词3"), abstract-english: [
    An abstract is usually a short summary of an article, essay, report, or other
    text. Its purpose is to help the reader understand the main content and
    conclusions of the text so that he or she can decide whether he or she needs to
    continue reading the original text. The abstract usually contains information
    about the topic, purpose, methods, results, and conclusions of the text and is
    presented as concisely and clearly as possible. A good abstract should be able
    to summarize the main points of the text while avoiding unnecessary details and
    jargon so that it can be easily understood by a wide audience.

    In addition, abstracts are often one of the most important bases on which
    academics and researchers evaluate a piece of literature. During the literature
    search and selection process, people often base their decision to look further
    into the complete literature on the abstract. Therefore, writing a clear,
    accurate, and concise abstract is crucial to the dissemination and impact of the
    literature. When writing an abstract, authors should follow the formatting
    requirements and writing specifications of the literature, as well as combine
    the content and purpose of the text to write an accurate, concise, and
    easy-to-understand abstract in order to improve the dissemination and impact of
    the literature.

    Keyword 1, Keyword 2, and Keyword 3 are usually a few words related to the
    content of the article and are used to help readers better understand the topic
    and content of the article. The choice of keywords should be closely related to
    the topic and research area of the article, and words that are representative,
    authoritative, unique, and searchable should usually be chosen.
  ], keywords-english: ("Keyword 1", "Keyword 2", "Keyword 3"),
)

#include "sections/01_intro.typ"
#pagebreak()

#include "sections/02_math.typ"
#pagebreak()

#include "sections/03_reference.typ"
#pagebreak()

#include "sections/04_figure.typ"
#pagebreak()

#include "sections/05_conclusion.typ"
#pagebreak()

#bibliography("bib/note.bib", full: false, style: "gb-7714-2015-numeric")
#pagebreak()

#include "sections/acknowledgments.typ"
