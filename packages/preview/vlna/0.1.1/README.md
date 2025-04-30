# `vlna` package for Typst

In the context of Czech typography and typesetting, the term "vlna" (literally "wave") refers to a non-breaking space. It is typically represented by the tilde symbol (`~`) in typesetting systems like Typst or LaTeX.

## Usage

In the main file, insert the following code:

```c
#import "@preview/vlna:0.1.1":*
#show: apply-vlna
```

## Changelog

### [0.1.1] – April 30, 2025

#### Changed
- Refined implementation of Feature #1: non-breaking spaces after short words (less than two lowercase letters) now specifically target sequences using the regex `(\<\p{Lowercase}{1,2}\>)+ `, replacing the broader rule from version 0.1.0.

#### Added
- **Experimental/Partial:** Added a list of common Czech and English titles, ranks, and abbreviations (`titles_list`).
- **Experimental/Partial:** Basic regex pattern (`titles_pattern`) derived from `titles_list` for Feature #9 (titles/abbreviations preceding names).  
  _Note:_ The current implementation `#show regex(...): box` uses `box` instead of `~`, as there is no better workaround yet.

---

### [0.1.0] – March 3, 2025

#### Added
- Initial implementation of Feature #1: automatic insertion of non-breaking spaces (`~`) after short (less than 3 characters) prepositions and conjunctions (`k`, `s`, `v`, `z`, `o`, `u`, `a`, `i`, etc.) followed by a space.

---

## Implementation Status as of Version 0.1.1

- [x] **1. One-/two-letter words:** Implemented (`apply-vlna`, regex `short-words`).  
- [ ] **2. Digit groups:** Not implemented.  
- [ ] **3. Number + symbol/sign:** Not implemented.  
- [ ] **4. Number + abbreviation/unit:** Not implemented.  
- [ ] **5. Number + counted item:** Not implemented.  
- [ ] **6. Dates:** Not implemented.  
- [ ] **7. Ratios/scales:** Not implemented.  
- [ ] **8. Phone numbers, etc.:** Not implemented.  
- [x] **9. Abbreviations/Titles + Name/Word:** Implemented (can be expanded).

---

## Important Implementation Notes

This project aims to provide similiar functionality of `luavlna` developed by Mr. Michal Hoftich. The goal is to create a package that automates Czech typographic rules as specified by the Institute of the Czech Language.  
Link: https://prirucka.ujc.cas.cz/?id=880
