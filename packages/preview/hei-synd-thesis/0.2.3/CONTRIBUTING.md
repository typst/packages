# Contributing to hei-synd-thesis

Thanks for your interest in improving the **HEI Typst Thesis Template**! ❤️
We welcome all contributions — from typo fixes to feature suggestions and style refinements.

If you like the project but can’t contribute code right now, you can still help:

- ⭐️ Star the repository
- Share it with colleagues and students
- Mention it in your own Typst projects

---

## Table of Contents

- [Issues](#issues)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)
- [Contributing Code or Documentation](#contributing-code-or-documentation)
- [Creating a New Release](#creating-a-new-release)
- [Style Guide](#style-guide)
- [Legal](#legal)

---

## Issues

Before opening a new issue, please:

1. Check the [README](https://github.com/hei-templates/hei-synd-thesis/blob/main/README.md) and example files.
2. Search [existing issues](https://github.com/hei-templates/hei-synd-thesis/issues).
3. If none fit, open a new [issue](https://github.com/hei-templates/hei-synd-thesis/issues/new) with:
   - A clear description of your question or problem
   - Steps to reproduce (if relevant)
   - Typst version and OS info

---

## Reporting Bugs

When reporting a bug:

- Make sure you’re using the **latest version** of the template.
- Verify that the problem persists with a fresh document.
- Include:
  - Reproduction steps
  - Expected vs. actual output
  - Typst version and OS

> ❗ **Security-related issues** must **not** be reported publicly.
> Please email **<silvan.zahno@hevs.ch>** directly.

---

## Suggesting Enhancements

Have an idea to improve the template?
Please open an [issue](https://github.com/hei-templates/hei-synd-thesis/issues/new) and include:

- A short description of the feature
- Why it’s useful (especially for students or supervisors)
- Optional example syntax or visual reference

Enhancements should keep the template simple, elegant, and aligned with the HEI thesis format.

---

## Contributing Code or Documentation

1. **Fork** the repository and create a feature branch.
2. Make your changes:
   - Keep commits small and focused.
   - Follow existing Typst and Markdown formatting conventions.
3. **Test** that your version compiles correctly with Typst.
4. **Submit a Pull Request (PR)** to the `main` branch.
   - Include a short description of the change.
   - Link related issues (e.g., `Closes #42`).

---

## Creating a New Release

Releases are semi-automated via GitHub Actions.
A release is triggered when a **pull request is merged into `main`** and all **release checks** pass.

### ✅ Release Checklist

To pass the CI checks, **update the version number consistently** in these files:

| File           | Purpose                                                          |
| -------------- | ---------------------------------------------------------------- |
| `typst.toml`   | Official Typst package version                                   |
| `README.md`    | Example usage snippet with latest version                        |
| `justfile`     | Update `project_tag` (for `git-cliff` and Typst release tooling) |
| `metadata.typ` | Internal version used for imports                                |

### 🚀 Release Process

1. Create a PR from your feature or release branch into `main`.
2. Ensure all version references match and CI passes.
3. Once merged, the GitHub Action will:
   - Build and verify the Typst package
   - Generate changelog and release notes

> The **official Typst package submission** to
> [typst/packages](https://github.com/typst/packages)
> is **done manually** after the CI release is complete.

---

## Style Guide

- **Commit messages:**
  Use [Conventional Commits](https://www.conventionalcommits.org/) where possible:
  - feat: add abstract section option
  - fix: correct title spacing on cover page
  - docs: clarify usage for bachelor theses

- **Code style:**
- Typst code should remain readable and well-commented.
- Prefer descriptive variable names.
- Keep template logic minimal — readability over cleverness.

## Legal

By contributing, you confirm that:

- You wrote the content yourself or have the rights to contribute it.
- Your contribution can be distributed under the same license as the project.
