para-lipics - CHANGELOG (YYYY-MM-DD format)

Pending changes (not published): N/A

- 2025-09-22: v0.1.3
    - para-lipics project:
        - updated README and typst.toml
        - moved thumbnail and fixed template entrypoint (for passing bot checks during Typst package PR)
        - edited authors
    - compliance with official LIPIcs template: 
        - fixed spacing of event title in footer boxes
        - changed theorem handling with ctheorems
        - used fallback for Sans font, removed NCU Mono font requirement
        - fixed yellow triangle for theorems
        - fixed unspecified metadata
        - added smallcaps font
        - fixed bold text not working
        - fixed layout of lists/enums
        - fixed bug with headings without numbering (e.g. bibliography)
        - added LIPIcs-like bibliography look
        - fixed line-numbering for theorem and proof environments (because they are figures)
    - other:
        - updated sample article (changed the template version, added bibliography, minor changes)

- 2025-07-07: v0.1.2
    - para-lipics project:
        - created typst.toml
        - updated README (esp., wrote basic doc)
    - compliance with official LIPIcs template: 
        - added author email, website, and ORCID
        - implemented anonymous and hide-lipics flags
        - added related-version
        - fixed bullet mark height
    - other:
        - renamed template function
        - simplified affiliations, author-running, funding, ccs-desc, and supplement
        - renamed test-doc.typ to sample-article.typ
        - updated sample-article.typ for comparison with official dummy document
        - removed bibliography from template

- 2025-07-04: v0.1.1
    - para-lipics project:
        - added this changelog
        - added TODO.md
        - filled README
        - created para-lipics logo + added files files
        - updated license
    - compliance with official LIPIcs template:
        - made document title bold
        - fixed line numbers on first page + their size
        - fixed metadata elements color and made them bold
        - changed sans font for CMU Sans
        - added editor-only arguments
        - infer DOI from metadata
        - abstract: "Abstract" bold and fixed horizontal rule color and height
        - fixed footnote's horizontal rule color
        - added SVG logo files
        - first page footer: integrated LIPIcs logo, fixed event/copyright/publisher info
        - fixed short event title color in footer 
    - other:
        - added DOI link
        - changed parts of the testing document to make it closer to the official LIPIcs dummy document (easier for comparison)

- 2025-05-23: v0.1.0
    - initial version by Nicolas M