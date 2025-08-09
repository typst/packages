# HSRM Internship Report

Template for internship reports in the DCSM department at RheinMain University of Applied Sciences (HSRM) as part of the Computer Science degree program.
This template provides a standardized layout and makes it easy to clearly mark text sections by author.

## Features

- Preconfigured layout based on internship reports in the DCSM department at HSRM conventions (page margins, line spacing etc.).
- Multiple authors with clear, color-coded marking inside the text via the `#author(...)` function.
- Optional author legend shown in the table of contents.
- Title page with university and company logos, plus supervisor details.
- Customizable fonts for headings and body text.

## Usage

1. Configure `data.typ`
   - Title and subtitle
   - Authors (name, short code, student ID, email, color)
   - Logos (file paths and sizes)
   - Supervisors at the university and the company
   - Fonts (`heading-font`, `text-font`)
   - Line spacing (`line-spacing`) and whether to show an author legend in the outline (`legend-on-outline`)

2. Mark author-specific content
   ```typst
   #author("RZ")[This section was written by the author with short code RZ.]
   ```
   Use the `short` code defined for each author in `data.typ`.

### Notes on fonts

The Typst app does not bundle “Times New Roman” or “Arial” by default. You can:
- Add the font files (`.ttf`, `.ttc`, `.otf`, `.otc`) to your project and reference them, or
- Use the Typst CLI to make fonts available system-wide and then reference them in your document.

## Files

- `main.typ` – The main document that imports the template and your data, and demonstrates author marking.
- `data.typ` – Project- and person-specific configuration (title, authors, logos, supervisors, fonts, etc.).
- `template.typ` – Package entry that defines and exports the document layout and utilities.
- Placeholder logos – Generic logos for university and company.

## License

This package is licensed under the MIT License (see `LICENSE`).  
The included placeholder logos are generic and can be replaced freely.

**Disclaimer**: I do not guarantee the correctness, completeness, or up-to-dateness of the contents in regards to HSRM's formal requirements. Use at your own discretion.
