# Changelog

## 0.2.0

- Centre list markers on the first line of each item.
- Hide the Student ID and Contribution columns of the author table when no
  author has a value for them.
- Bump every import, example, test and the starter template to 0.2.0; the
  check script now uses an empty package cache and fails on imports of any
  other version.
- Fix "cannot join label with content" for a labelled table outside a
  figure; the label stays queryable.
- Wrap long table cells at the text width, set ragged rather than justified.
  Only tables whose fixed column widths exceed the text width are scaled down.
- Accept a plain string as a `proof` body.
- Accept a plain string as `date`, as the README promised; document that
  `date: auto` prints today's date.
- Print dates without a leading zero ("1 November 2026").
- Let long code lines wrap inside the listing instead of overprinting its
  bottom rule and the text after it.
- Number figures, tables, listings, equations and theorems from the last
  numbered chapter. Unnumbered chapters no longer restart numbering or print
  a wrong prefix (such as 1.1 inside an appendix), and content before the
  first chapter is numbered 1, 2, ... instead of 0.1, 0.2, ...
- Restart custom figure kinds (such as `kind: "algo"`) in every chapter.
- Keep word spaces in the automatic short title and turn manual line breaks
  in the title into spaces.
- Number entries in a list of figures, tables or listings at the element,
  so they no longer all read "Figure 0.1".
- Keep each side of the running head and footer on one line, without
  hyphenation; overlong text ends with an ellipsis. Manual line breaks in the
  title become spaces there.
- Use `short-title` for the right-hand running head of a report, as the
  README describes (it previously showed the full title).
- Skip outline titles ("Contents", "List of Figures") when choosing the
  chapter for the running head.
- Scale a very wide logo down to its column on the cover and the assignment
  title block instead of letting it run off the page.
- Keep the report cover's blocks apart: a unit line that wraps pushes the
  title down, and when the title and the author details cannot both fit,
  the details follow the title (continuing on a second cover page if needed)
  instead of overprinting it.
- Let a long table inside a `figure` break across pages; its caption stays
  above the first part.
- Leave no extra space behind when a figure floats (`placement: top` or
  `bottom`).
- Keep a gap between a long question title and its marks; the marks sit at
  the top right.
- Stop hyphenating the unit line in the assignment title block.
- Put the end-of-proof square on the last line of a proof that ends with a
  list or enum item, and keep it clear of a closing equation's number.
- Contents: start unnumbered entries (such as References) at the margin,
  hang wrapped entries after their number, and never hyphenate entries.
- Scale headings, captions, tables, display equations, code, footnotes,
  theorem and question labels and enum labels with `font-size`. The cover,
  title block and running heads keep their sizes. At the default 11pt
  nothing changes.

## 0.1.0

- Initial assignment and report templates for Typst 0.15.
- Question statements, nested answer parts, shared theorem numbering and proofs.
- Report cover, group-author table, abstract, contents, appendices and running heads.
- Chapter-scoped figure, table, listing, equation and theorem numbering.
- Portable font selection, custom accent and optional user-supplied logo content.
- Local checks in both font modes, README sample compilation and CI.

### Review round 1

- Reformat source and fixtures to at most 100 characters per line; enforce
  that limit and fewer than 300 lines per source file in the check script.
- Build the syntax theme from a readable multi-line XML definition.
- Export `monash-fonts` for explicit use of all four preferred font stacks;
  document missing-font warnings and retain the existing `auto` defaults.
- Match the slides package's author metadata.
- Let the assignment proof paragraph flow without a forced line break.
- Refresh previews and verify all three check commands with Typst 0.15.1.

### Review round 2

- Add partial `labels` overrides for all package-owned wording and reference
  supplements; validate unknown keys and non-text values.
- Add `show-marks` and `question-box` controls in both modes, and use the
  singular mark label for numeric 1.
- Make dates and report contents opt-in when omitted; preserve the complete
  report example with an explicit contents option.
- Assert clean omission of 14 fields across 19 mode/field combinations using
  rendered text, shape positions, page counts and pinned body anchors.
- Assert custom/empty labels, references, mark visibility and horizontal and
  vertical statement insets in both modes.
- Document output choices, mark starter fields optional, and update section 3
  of the specification while retaining both source-size limits.
