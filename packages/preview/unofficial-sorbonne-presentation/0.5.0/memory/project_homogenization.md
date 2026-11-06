---
name: Config keys homogenization
description: Ongoing work to harmonize config parameters across sorbonne, iplesp, and aphp themes
type: project
---

Ongoing homogenization of config keys across the 3 presentation themes (sorbonne, iplesp, aphp) based on CONFIG_KEYS_AUDIT.md. Working step by step, one suggestion at a time, with user approval before each code change.

**Suggested order (from audit):**
1. `title-bg-light` / `title-bg-dark` in APHP — add to conf, use in aphp-title-slide (replacing hardcoded `white`)
2. `footer-func` in sorbonne and iplesp — expose as parameter (conditional dict key, only include when non-none)
3. `cite-box-bottom-dy` in sorbonne and iplesp — low priority, core.typ already has default 0.3em
4. `transition-part-layout` / `transition-section-layout` in APHP — skip (APHP uses render-transition-func override, keys would have no effect)
5. `margin-top` in sorbonne — verify/expose as template parameter

**Status:** Presenting suggestion #1 to user, awaiting approval.

**Why:** API coherence between themes. Each change must be user-approved before implementation, then tested via `bash compile.sh`, then committed.

**How to apply:** When resuming this session, check project_homogenization.md to know which step is next. Always ask user approval before making code changes.
