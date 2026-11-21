# Exp Cover Letter

A one-page cover letter in the same type as
[exp-resume](https://github.com/tahzeer/exp-resume-template). The sender
block is one line per field. The body is the letter, not a second resume.

Keep real letters outside this repository. The only letter in git is the
John Doe starter.

## Sample

![example cover letter](./example-letter.png)

## What to write

Three paragraphs, one page.

1. Name the role and one reason you want that employer. Put a referral in
   the first sentence if you have one.
2. Tell one or two results as stories. The resume already lists them. Do
   not paste the bullets.
3. Ask for a conversation and thank the reader.

That shape is what the University of Michigan career center and the Harvard
Extension School resume guide both describe. Use the same name, contacts,
and accent as the resume.

## Quick start

```sh
typst init @preview/exp-cover-letter:0.1.0
```

```typst
#import "@preview/exp-cover-letter:0.1.0": *

#show: letter.with(
  font: "New Computer Modern",
  font-size: 12pt,
  paper: "us-letter",
  gap: 20pt,
  date: "October 26, 2026",
  closing: "Sincerely,",
)

#sender(
  author: "John Doe",
  email: "john.doe@example.com",
)

#recipient(
  recipient-name: "Ada Lovelace",
  recipient-title: "Hiring Manager",
  company: "Example Corporation",
)

First paragraph.

Second paragraph.

Third paragraph.
```

`letter.with` is the page, the date, the closing, and the gap. `#sender` is
the name and contact lines. `#recipient` is the company and the greeting.
Contact fields use the same names as `resume.with`. An empty string drops
that line. The greeting uses `recipient-name` when it is set, and
`recipient-title` otherwise. The [manual](docs/manual.pdf) lists every
parameter.

## Local development

```sh
just install-preview
typst compile template/main.typ /tmp/exp-cover-letter-example.pdf
```

```sh
just ci
```

`just package out` builds a release candidate. `docs/manual.pdf` is
gitignored and rebuilt by the release workflow.

## Versioning

Versions follow [Semantic Versioning 2.0.0](https://semver.org/). Tags use a
`v` prefix and must match `typst.toml`. `./scripts/bump.sh` updates pins and
the changelog. Do not edit a version that has already been released.

## Publishing

A matching tag runs the release workflow. It pushes
`packages/preview/exp-cover-letter/<version>` to `tahzeer/typst-packages`.
The repository needs a `REGISTRY_TOKEN` secret that can push to that fork.
The fork stays public so the Typst Universe pull request can be opened.
