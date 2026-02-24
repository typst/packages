# modern-innopolis-thesis

Typst template for thesis at Innopolis University.

## Getting Started

1. Import this template from [lib.typ](./lib.typ) (if working offline) or from Typst Universe.

    ```typst
    #import "@preview/modern-innopolis-thesis:0.1.0": *
    ```

1. Start with a title page (optional)

    ```typst
    #title-page(
        program-code: "09.04.01",
        program-ru: "Информатика и вычислительная техника",
        program-en: "Computer Science",
        work-ru: "МАГИСТЕРСКАЯ ДИССЕРТАЦИЯ",
        work-en: "MASTER GRADUATE THESIS",
        specialty-ru: "Анализ данных и искусственный интеллект",
        specialty-en: "Data Analysis and Artificial Intelligence",
        topic-ru: "Применение существующих бизнес-моделей к продуктам, созданным на платформе Telegram",
        topic-en: "Application of existing business models to product on Telegram platform",
        author-ru: "Иванов Иван Иванович",
        author-en: "Ivanov Ivan Ivanovich",
        supervisor-ru: "Иванов Иван Иванович",
        supervisor-en: "Ivanov Ivan Ivanovich",
        consultants: "Иванов Иван Иванович / Ivanov Ivan Ivanovich",
        year: "2025"
    )
    ```

1. Show the main document (recommended [external font](https://www.fonts.uprock.ru/fonts/tempora-lgc-uni))

    ```typst
    #show: thesis.with(
        abstract: lorem(100),
        font-family: "Liberation Serif",
        font-size: 14pt,
        chap-title-size: 30pt,
        h1-size: 35pt,
        h2-size: 20pt,
        h3-size: 17pt,
    )
    ```

1. Write chapters using the regular Typst syntax

    ```typst
    = Introduction <intro>
    #lorem(100)
    
    == Section
    ...
    
    === Subsection
    ...

    = Methodology <method>
    ...

    = Implementation <impl>
    ...
    
    = Evaluation and Discussion <eval>
    ...
    
    = Conclusion <concl>
    ...

    ```

1. Finalize with appendices (optional) and bibliography (read from a BibTex file).

    ```typst
    #bibliography(
        title: "Bibliography cited",
        "refs.bib"
    )
    
    #show: appendix
    
    = Extra Stuff
    
    #lorem(100)
    
    = Even More Extra Stuff
    
    #lorem(100)
    ```

## Additional features

1. Method for working with captions with different representations in outlines/page headers.

    ```typst
    #flex-title([Real figure/table/section title], [Alternative title to appear in page headers and outlines])
    ```

1. Simple formatted blocks for some math-related elements.

    ```typst
    #theorem[ #lorem(100), ] <thm>
    
    #proof[ I'm a (very short) proof. ]
    
    #lemma[ I'm a lemma. ]
    
    #corollary[ I include a reference to #link(<thm>)[Theorem 1] ]
    
    #proposition[ I'm a proposition. ]
    
    #remark[ I'm a remark. ]
    
    #definition[ I'm a definition. ]
    
    #example[ I'm an example. ]
    ```
