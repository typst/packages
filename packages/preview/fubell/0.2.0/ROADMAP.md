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

| Item | Difficulty | Status |
| --- | --- | --- |
| Optional insertion of external certification PDF | Medium | Done in v0.2.0 — `certification-pdf` option |
| Appendix helpers and appendix numbering presets | Medium | Done in v0.2.0 — `#show: appendix` |
| Spacing presets (`double`, `1.5`, `single`) aligned to NTU practice | Low | Done in v0.2.0 — auto per `lang` |
| Better CJK/Latin font fallback diagnostics and documentation | Medium | Done in v0.2.0 — font profiles + CLI diagnostics guide |
| Watermark and DOI toggles | Medium | Done in v0.2.0 |
| Front-matter fine-tuning (TOC inclusion policy per section) | Medium | Open → v0.3.0 |
| Spine text generation (`\makespine` equivalent) | Medium | Open → v0.3.0 |

## P2 (Quality and extensibility) — v0.3.0

| Item | Difficulty | Notes |
| --- | --- | --- |
| Per-chapter figure/table/equation numbering | Medium | `圖 1.1` / `表 1.1` / `(1.1)`; currently numbered globally |
| Skip empty 圖目錄 / 表目錄 pages | Low | A thesis with no figures still gets a blank list page |
| Config validation with clear error messages for missing metadata | Medium | Panic with helpful messages |
| Additional bibliography/citation style presets | Medium | APA, IEEE, etc. |
| Layout regression suite (smoke compiles + visual diff strategy) | High | CI-friendly testing |
| Dual track profiles for `master` and `phd` defaults | Medium | Different default text/labels |

## P3 (Distribution and ecosystem) — v1.0.0

| Item | Difficulty | Notes |
| --- | --- | --- |
| Universe submission assets (thumbnail pipeline, metadata polish) | Medium | Done in v0.2.0 — `scripts/stage-release.sh` |
| CI workflow for compile checks against supported Typst versions | Medium | GitHub Actions |
| Expand the example thesis (figures, tables, equations, cross-references) | Low | Current example exercises none of these |
| Full bilingual documentation and migration guide | Medium | LaTeX → Typst migration tips |
| More real-world examples (CS, EE, humanities) | High | Discipline-specific starters |

## Milestone schedule (proposed)

- **v0.1.0:** Scaffold + MVP (P0) — released
- **v0.2.0:** Submission readiness (P1) — current
- **v0.3.0:** Quality and extensibility (P2)
- **v1.0.0:** Stable release and Typst Universe publish (P3)
