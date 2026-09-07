# resume-ofa

Resume One For All: a compact, configurable CV layout for Typst.

`resume-ofa` is the reusable layout package. Keep personal names, contact details, work history, portfolio content, and generated PDFs in your own project.

## Quick start

Create a new project from the published template:

```bash
typst init @preview/resume-ofa:0.1.0
cd resume-ofa
typst compile main.typ
```

To use the layout in an existing document, import the pinned package version and apply the `resume` function as a show rule:

```typst
#import "@preview/resume-ofa:0.1.0": *

#show: resume.with(
  author: "Your Name",
  email: "you@example.com",
  github: "github.com/your-handle",
  linkedin: "linkedin.com/in/your-handle",
  accent-color: "#315A7D",
)

== Experience

#work(
  title: "Your Role",
  company: "Your Company",
  dates: dates-helper(start-date: "2023", end-date: "Present"),
  location: "City, Country",
)
- Describe an outcome, contribution, or measurable result.
```

Use exact package versions in source files. Update the import deliberately when a new package version is released.

## Configuration

`resume` accepts these layout and metadata parameters:

| Parameter | Purpose |
| --- | --- |
| `author` | Name shown as the level-one heading and used as document metadata. |
| `author-position` | Alignment of the name heading. |
| `personal-info-position` | Alignment of the contact row. |
| `pronouns`, `location`, `email`, `phone` | Optional contact values. |
| `github`, `linkedin`, `personal-site` | Optional URLs. Supply them without `https://`. |
| `orcid` | Optional ORCID identifier without the `https://orcid.org/` prefix. |
| `accent-color` | Hex color string applied to headings and links. |
| `font` | Text font family; defaults to `New Computer Modern`. |
| `paper` | Page format such as `us-letter` or `a4`. |
| `author-font-size` | Name heading size. |
| `font-size` | Document body size. |
| `lang` | Document language. |
| `marginxy` | Dictionary with `x` and `y` page margins. |
| `body` | The document content passed by `#show: resume.with(...)`. |

The template disables ligatures to improve text extraction by applicant-tracking systems and uses a compact, single-column layout.

## Helpers

The package exports these helpers:

- `dates-helper(start-date:, end-date:)` formats a date range with an em dash.
- `edu(...)` formats an education entry. Set `consistent: true` to place dates in the upper-right position.
- `work(...)` formats a work entry. Set `one-liner: true` for a compact row.
- `project(...)` formats a project entry with optional role, organization, URL, and dates.
- `certificates(...)` formats a certificate entry with optional URL, date, and credential ID.
- `extracurriculars(...)` formats an activity and date row.
- `skills(category:, items:)` formats a skill category.
- `language(...)` formats a language, proficiency, certificate, score, and date.
- `generic-two-by-two(...)` and `generic-one-by-two(...)` provide unstyled two-column building blocks.

URLs passed to `project`, `certificates`, or `language` are also expected without the `https://` prefix because the current API adds it.

## Local development

The repository uses `lib.typ` as its package entrypoint. Before publication, test the package using a local package path:

```bash
PACKAGE_PATH="$(mktemp -d)"
mkdir -p "$PACKAGE_PATH/preview/resume-ofa"
ln -s "$PWD" "$PACKAGE_PATH/preview/resume-ofa/0.1.0"

TYPST_PACKAGE_PATH="$PACKAGE_PATH" typst compile examples/resume.typ /tmp/resume-ofa-example.pdf
TYPST_PACKAGE_PATH="$PACKAGE_PATH" typst init @preview/resume-ofa:0.1.0 /tmp/resume-ofa-init
TYPST_PACKAGE_PATH="$PACKAGE_PATH" typst compile /tmp/resume-ofa-init/main.typ /tmp/resume-ofa-template.pdf
```

The generated template must compile without editing. The current package depends on [`scienceicons:0.1.0`](https://typst.app/universe/package/scienceicons/), which is distributed separately under the MIT License.

## Publish to Typst Universe

The canonical source repository is [aldrick-t/typst-resume-ofa](https://github.com/aldrick-t/typst-resume-ofa). Typst Universe stores immutable package copies under `packages/preview/{name}/{version}`.

After committing and pushing this repository, fork `typst/packages` and submit the package files with a sparse checkout:

```bash
git clone --depth 1 --no-checkout --filter="tree:0" git@github.com:YOUR_GITHUB_USERNAME/packages
cd packages
git sparse-checkout init
git sparse-checkout set packages/preview/resume-ofa
git remote add upstream git@github.com:typst/packages
git config remote.upstream.partialclonefilter tree:0
git checkout main

mkdir -p packages/preview/resume-ofa/0.1.0
cp /path/to/typst-resume-ofa/typst.toml packages/preview/resume-ofa/0.1.0/
cp /path/to/typst-resume-ofa/lib.typ packages/preview/resume-ofa/0.1.0/
cp /path/to/typst-resume-ofa/README.md packages/preview/resume-ofa/0.1.0/
cp /path/to/typst-resume-ofa/LICENSE packages/preview/resume-ofa/0.1.0/
cp /path/to/typst-resume-ofa/thumbnail.png packages/preview/resume-ofa/0.1.0/
cp -R /path/to/typst-resume-ofa/template packages/preview/resume-ofa/0.1.0/

git add packages/preview/resume-ofa/0.1.0
git commit -m "Add resume-ofa 0.1.0"
git push origin main
```

Do not copy the source repository's `.git` directory and do not use a Git submodule. Open a pull request from the fork to `typst/packages`, wait for CI, and address maintainer feedback. After the pull request is merged, Typst makes the package available through the `@preview` namespace.

## License

The layout code in this repository is licensed under the MIT License. See [`LICENSE`](LICENSE). The `scienceicons` dependency remains separately licensed by its authors.
