# Ape for Typst

  

Tired of documents that look like they were formatted by a troop of baboons? Try Ape for Typst!

  

This Typst package provides a comprehensive set of tools for structuring and styling academic course documents across various disciplines. It simplifies the process of creating good looking and consistent layouts, allowing students to focus on content creation.

  

**Key Features:**

  

*  **Flexible Title Numbering:** Offers a variety of numbering styles for headings and subheadings

*  **Table of Contents Customization:** Provides enhanced outline

*  **Front Page Design:** Offers a pre-designed front page templates

*  **Easy Integration:** Simple to integrate into your Typst documents with clear and concise functions and components.

*  **Helpful function:** function to highlight information (in boxes), write a comment, etc.

  

**Benefits:**

  

*  **Consistent Formatting:** Ensures a uniform and professional look across all course materials.

*  **Time Saving:** Reduces the effort required to manually format titles, tables of contents, and front pages.

*  **Improved Readability:** Well-structured documents with clear numbering and formatting enhance the reader's experience.

  

**Functionalities:**


* Starting a new document
```typst
#import "@preview/ape:0.1.0": *

#show: doc.with(
  lang: "en",

  title: "Title",
  authors: ("Author1", "Author2"),
  style: "numbered",

  title-page: true,
  outline: true,
  smallcaps: true,
)
```

* Available style
  - Numbered
  - Plain
  - Colored




_will be completed later_ 