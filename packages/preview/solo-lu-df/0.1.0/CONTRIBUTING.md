Contributing to solo-lu-df

Thanks for your interest in contributing! The project follows a simple,
developer-friendly workflow. Below are recommended steps, conventions and
checks to make your contribution smooth and easy to review.

Getting started

1. Fork the repository and create a branch for your change:
   - `git checkout -b feat/short-description` or `git checkout -b fix/short-description`
2. Make changes locally and run the example build to check layout:
   - `typst compile examples/qualification-thesis/main.typ`
   - or run `typst watch` while editing.

Reporting issues

- Open issues for bugs, layout regressions, feature requests or missing
  functionality.
- Provide:
  - A short description of the problem.
  - Steps to reproduce (file paths, commands).
  - Expected vs actual behavior and screenshots/PDF snippets if helpful.
- Use labels to categorize the issue (bug, enhancement, docs, etc.) if you
  have permission; otherwise maintainers will tag.

Pull requests

- Base branch: open PRs against `main` (or other default branch).
- PR title: use a brief prefix + summary, e.g., `feat: add attachment helper`
  or `fix: correct table caption numbering`.
- Describe in the PR:
  - What you changed and why.
  - Any user-facing changes or migration steps.
  - How to test (commands to run).
- Include before/after screenshots for visual changes.

Code style & formatting

- Typst source: keep the style consistent with existing files.
- Shell examples: use fenced code blocks with `bash`.
- Keep commits small and focused; rebase/squash as needed to keep history clean.

Testing / validation

- Verify examples compile cleanly:
  - `typst compile template/main.typ`
  - `typst compile examples/qualification-thesis/main.typ`
- If you add diagrams or images, include both source (.drawio/.fig/.svg source)
  and exported assets (SVG/PDF), and update README/examples as needed.

Diagrams & assets

- If you add diagram images exported from draw.io / Figma / Inkscape:
  - Commit the source file (e.g., `.drawio`) AND the exported SVG/PDF.
  - Prefer SVG/PDF exports for vector quality; ensure fonts are embedded or
    text converted to outlines if needed for consistent rendering.
- If you add Typst-native diagrams (fletcher), keep styles consistent with
  existing helpers.

Release & versioning

- Follow semantic versioning for releases.
- Update `typst.toml` version and changelog when preparing a release.

License & copyright

- All contributions are under the project MIT-0 license.
- Don’t include third-party assets without compatible licensing. If you add
  third-party assets, note the attribution and license in your PR.

Communication

- For large features or breaking changes, open an issue first to discuss the
  design; this avoids wasted work and speeds up review.

Need help?

- Open an issue and tag it `help wanted` or `question`. Maintainers
  will respond with guidance.

Thank you for contributing -- every fix, test, example and doc update helps
make the template better for students and authors.
