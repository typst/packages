# ENSIAS Report Typst Template

A Typst template to quickly make reports for projects at ENSIAS. This template was created based on our reports that we also made for our projects.

## What does it provide?

For now, it provides a first page style that matches the common reports style used and encouraged at ENSIAS.

It also provides a style for first level headings to act as chapters.

More improvements will come soon.

## Quick start

```typ
#import "@preview/red-agora:0.2.0": project

#show: project.with(
  title: "Injecting a backdoor in the xz library and taking over NASA and SpaceX spaceship tracking servers (for education purposes only)",
  subtitle: "Second year internship report",
  authors: (
    "Amine Hadnane",
    "Mehdi Essalehi"
  ),
  school-logo: image("images/ENSIAS.svg"), // Replace with [] to remove the school logo
  company-logo: image("images/company.svg"),
  mentors: (
    "Pr. John Smith (Internal)",
    "Jane Doe (External)"
  ),
  jury: (
    "Pr. John Smith",
    "Pr. Jane Doe"
  ),
  branch: "Software Engineering",
  academic-year: "2077-2078",
  footer-text: "ENSIAS", // Text used in left side of the footer
)

// Put then your content here
```

**Additional parameters**

```typ
(
  header: [ // OPTIONAL: Text placed on top of the first page (Usually for the full school name)
    Mohammed V University
    #linebreak()
    National Higher School of Computer Science and Systems Analysis
  ],
  defense-date: "September 10th, 2025", // OPTIONAL: Needs the jury list to be displayed. The defense date to be added

  heading-numbering: "1.1", // OPTIONAL: Numbering of the document
  lang: "ar", // OPTIONAL: Supported languages: "en" (default if ommited), "ar", "fr"
  features: ("full-page-chapter-title", "header-chapter-name"), // All features are optional and not activated by default. Include the desire features.
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
