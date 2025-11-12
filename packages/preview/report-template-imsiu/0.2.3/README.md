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

## Changelog

### **0.1.0 - Initial release**

- First page style.
- Level 1 headings chapter style.

### **0.1.1**

- Fixed major issue where custom school & company logos would throw an error.
- Added option to customize footer left side text (thus fixing the issue of it being hardcoded).

### **0.2.0**

- **Features**
  - Arabic language support. The template now supports Arabic, English and French.
  - New `lang` parameter to specify the language. Consequently, the `french` parameter that used to enabled French instead of English is now deprecated.
  - Added chapter name in header. This can be enabled by activating the `header-chapter-name` feature in the features parameter.
- **Fixes and enhancements**
  - Removed some parameters that were forced on the document like font. The template should not include something that can be specified from outside.

### 0.2.1

- Forked From [ensias-report-template](https://github.com/essmehdi/ensias-report-template)
- Updated Logos and Mentions to ones related to IMSIU
- Made the Table of Figures and Table of Tables Conditional

### 0.2.2

- Fixed the Lang issue
- Added Features from ilm
- Fixed the Tables Condition

### 0.2.3

- Codely Integration for Fancy Codeblocks
