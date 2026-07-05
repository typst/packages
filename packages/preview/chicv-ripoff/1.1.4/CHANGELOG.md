# [v1.1](https://github.com/matchy233/typst-chi-cv-template/releases/tag/1.1)

## Added

- Impelement `#personal-info` function, which accepts the following inputs and generates a line of personal info with icon separated by vertical line symbols accordingly
  - `email`, `phone`, `github`,` linkedin` and `website`, with predefined styles
  - `<name of icon>: <link>`, for example: `#personal-info(x-twitter: "https://x.com/iskyzh")` will generate an icon link like the figure below:
  ![image](https://github.com/user-attachments/assets/d3698962-10b2-4b03-835d-02a11ebc79f1)
  - a dictionary with keys: link, text, icon, solid, which will generate an icon link accordingly
- Make page margin and padding around cventry blocks adjustable
- Also alllow adjusting cventry block padding individually

<!-- ## Removed -->

## Changed

- Use `typst-fontawesome` package
- Make second level heading font size larger (12pt $\to$ 14pt)

<!-- ## Migration Guide from v0.1.X -->

---

# [v1.0.0](https://github.com/matchy233/typst-chi-cv-template/releases/tag/v1.0)
Initial Release
