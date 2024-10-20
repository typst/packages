# APA7 (-ish) Template for Typst

[Typst](https://typst.app/) Template that (mostly) complies with APA7 Style (Work in Progress).

The template does not follow all recommendations by the APA Manual, especially when the suggestions break with typographic conventions (such as double line spacing :vomiting_face:). Instead, the goal of this template is that it generates you a high-quality manuscript that has all the important components of the APA7 format, but is aesthetically pleasing.

# Work in Progress

The following works already quite well:

- consistent and simple typesetting
- correct display of author information / author note
- citations and references
- Page headers and footers (show short title in header)
- Option to anonymize the paper

This is still not finished:

- Tables: seeking to implement 3-part-tables (caption, content, and table notes)
- figures
- complete pandoc integration (template for pandoc to replace Latex-based workflows)
- automatic calculation of page margins (like memoir-class for Latex)

# Basic Usage

The easiest way to get started is to edit the example file, which has sensible default values. Most fields in the configuration are optional and will safely be ignored (not rendered) when you set them to `none`.

## Authors

The `authors` setting expects an array of dictionaries with the following fields:

```typst
(
  name: "First Name Last Name", // Name of author as it should appear on the paper title page
  affiliation: "University, Department", // affiliation of author as it should appear on the title page
  orcid: "0000-0000-0000-0000", // optional for author note
  corresponding: true, // optional to mark an author as corresponding author
  email: "email@upenn.edu", // optional email address, required if author is corresponding
  postal: "Longer string", // optional postal address for corresponding author
)
```

## Anonymization

Sometimes you need to submit a paper without any author information. In such cases you can set `anonymous` to `false`.
