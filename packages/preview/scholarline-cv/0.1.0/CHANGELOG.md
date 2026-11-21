# Changelog

## 0.1.0 — Initial release

- Minimal, customizable academic CV template for Typst with a monochrome editorial design: Inter typography, grayscale palette (`#151515` / `#666666` / `#E6E6E6`), hairline section rules, and an asymmetric content / date grid
- Everything is a plugin: replaceable `header`, `section`, `heading`, and `links` plugins, an extensible icon table, and public primitives (`entry`, `entry-title`, `entry-meta`, `entry-links`, `dot-join`, `section-label`, `cv-icon`, `cv-theme`) that the built-in components also use
- Swiss-style default: small uppercase section labels over hairlines, a label-column skills grid, tabular figures for dates, and `label ↗` entry links
- Typographic rhythm: single-line entries share a tight gap, descriptions get extra air above them, list items sit further apart than wrapped lines, and the name uses Inter Display
- Built-in plugin presets: `margin-section` (labels in a left margin column) and `underline-links`
- `theme:` dictionary for colours, fonts, size, spacing, paper, margin, and header alignment
- Centred header with icon-led, softly underlined contact links
- Redrawn Lucide-style icon set (including GitHub and ORCID), tinted by the theme and centred on the text line
- Chinese and bilingual support via `lang: "zh"`; short default font lists (Inter + Noto Sans CJK SC) so compiles stay free of missing-font warnings
- Components for education (with `details`), experience (role · advisor), publications (with `venue`), projects, awards, and skills
- Inter (OFL-1.1) bundled in the repository's `fonts/` folder for the web app and `--font-path`; excluded from the package
- Compile-based tests and a CI workflow that installs fonts and uploads PDF previews and a plugin gallery
- Plugin guide in English and Chinese (`docs/PLUGINS.md`) with rendered images of every built-in plugin combination
- Anonymous English, Chinese, and plugin examples
