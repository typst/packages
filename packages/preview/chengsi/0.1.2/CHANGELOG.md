# Changelog

## 0.1.2

- Add an `appendix` environment: appendices use their own A, B, C numbering
  controlled by `appendix-numbering`, label their chapter 附录 / APPENDIX, and
  leave the numbering of chapters that follow untouched.
- Give image and table figures one shared caption layout: a centered figure with
  an accent-coloured label and small muted caption text below it, configured
  through `figure-caption-size` and `figure-caption-color`. References to them
  read 图 / Figure 1 and 表 / Table 1 in bilingual documents, and a figure is
  never split from its caption across pages.
- Extend the bundled template with an appendix on figures and captions, a sample
  plot in `template/assets/`, and documentation for the new options.
- Inline code now uses the body font size instead of `0.85em`, so code spans no
  longer look smaller than the surrounding text. The new `code-inline-size`
  option (default `1em`) adjusts it per project.

## 0.1.1

- Give examples an independent counter with configurable `example-numbering`;
  other theorem-like environments continue to share `theorem-numbering`.
- Add configurable paragraph spacing, spacing before and after section headings,
  and font sizes for chapter labels and chapter, section, and subsection titles.
- Increase default paragraph and section heading spacing and chapter label size,
  and update the bundled template configuration with roomier spacing and larger titles.
- Add code block language labels for Mathematica and Wolfram Language.

## 0.1.0

Initial release of Chengsi (澄思).

- Chinese, English, and bilingual mathematics environments.
- Covers, outlines, chapter epigraphs, cross-references, and bibliographies.
- Teal, indigo, and sepia palettes with matching syntax highlighting.
- Complete example with analysis, linear algebra, and numerical experiments.
