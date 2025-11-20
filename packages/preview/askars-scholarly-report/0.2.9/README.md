# IMAMU CCIS Report Typst Template

A Typst template to quickly make reports for projects at Imam Mohammed ibn Saud Islamic University (IMAMU), College of Computer and Information Sciences (CCIS).
This repository is a fork of the ENSIAS Report Typst Template and was adapted to match the styles and requirements used at IMAMU CCIS.

## What does it provide?

For now, it provides a first page style that matches the common report style used and encouraged at IMAMU CCIS.

It also provides a style for first level headings to act as chapters.

More improvements will come soon.

## Additional parameters

```typ
(
  header: [ // OPTIONAL: Text placed on top of the first page (Usually for the full school name)
    Imam Mohammed ibn Saud Islamic University
    #linebreak()
    College of Computer and Information Sciences (CCIS)
  ],
  defense-date: "September 10th, 2025", // OPTIONAL: Needs the jury list to be displayed. The defense date to be added

  heading-numbering: "1.1", // OPTIONAL: Numbering of the document
  lang: "ar", // OPTIONAL: Supported languages: "en" (default if ommited), "ar", "fr"
  features: ("full-page-chapter-title", "header-chapter-name","fancy-codeblocks"), // All features are optional and not activated by default. Include the desire features.
  accent-color: rgb("#ff4136") // OPTIONAL: Change the default accent color of the document
)
```

## Contributing

Contributions are welcome! Please read the contribution guidelines in `CONTRIBUTING.md` for how to propose changes, keep the manifest compliant with Typst Universe, and update the changelog.
