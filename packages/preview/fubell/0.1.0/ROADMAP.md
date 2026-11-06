# Fubell Roadmap

This roadmap is ordered by **priority first** and **difficulty second**.

## Priority Legend

- `P0`: Must-have for reliable thesis writing
- `P1`: High-value enhancements for real-world submission workflows
- `P2`: Quality and extensibility improvements
- `P3`: Release engineering and ecosystem polish

## Difficulty Legend

- `Low`: straightforward implementation
- `Medium`: moderate implementation or integration complexity
- `High`: deeper layout, tooling, or compatibility work

## P0 (Must-have) — v0.1.0

| Item | Difficulty | Status |
| --- | --- | --- |
| Universe-conventional package scaffold (`typst.toml`, `lib.typ`, `template/`) | Low | Done |
| Modular layout architecture (`src/config`, `src/cover`, `src/certification`, …) | Low | Done |
| Chinese and English cover pages | Low | Done |
| Certification page baseline (auto layout + custom content slot) | Low | Done |
| Chinese and English abstract pages with keywords | Low | Done |
| Chinese and English acknowledgement pages | Low | Done |
| TOC / List of Figures / List of Tables generation | Medium | Done |
| Main matter numbering + bibliography hook | Medium | Done |
| Example thesis starter with chapter split and BibTeX sample | Low | Done |

## P1 (Submission readiness) — v0.2.0

| Item | Difficulty | Notes |
| --- | --- | --- |
| Optional insertion of external certification PDF | Medium | Replace auto-generated page with scanned PDF |
| Appendix helpers and appendix numbering presets | Medium | `#appendix()` convenience function |
| ~~Spacing presets (`double`, `1.5`, `single`) aligned to NTU practice~~ | Low | Done in v0.1.0 — auto per `lang` |
| Better CJK/Latin font fallback diagnostics and documentation | Medium | Warn on missing fonts |
| Front-matter fine-tuning (TOC inclusion policy per section) | Medium | Toggle which lists appear |
| Spine text generation (`\makespine` equivalent) | Medium | Vertical spine for bound copies |

## P2 (Quality and extensibility) — v0.3.0

| Item | Difficulty | Notes |
| --- | --- | --- |
| Watermark and DOI toggles | Medium | Overlay NTU watermark on pages |
| Config validation with clear error messages for missing metadata | Medium | Panic with helpful messages |
| Additional bibliography/citation style presets | Medium | APA, IEEE, etc. |
| Layout regression suite (smoke compiles + visual diff strategy) | High | CI-friendly testing |
| Dual track profiles for `master` and `phd` defaults | Medium | Different default text/labels |

## P3 (Distribution and ecosystem) — v1.0.0

| Item | Difficulty | Notes |
| --- | --- | --- |
| Universe submission assets (thumbnail pipeline, metadata polish) | Medium | Ready for `@preview/fubell` |
| CI workflow for compile checks against supported Typst versions | Medium | GitHub Actions |
| Full bilingual documentation and migration guide | Medium | LaTeX → Typst migration tips |
| More real-world examples (CS, EE, humanities) | High | Discipline-specific starters |

## Milestone schedule (proposed)

- **v0.1.0:** Scaffold + MVP (P0) — current
- **v0.2.0:** Submission readiness (P1)
- **v0.3.0:** Quality and extensibility (P2)
- **v1.0.0:** Stable release and Typst Universe publish (P3)
