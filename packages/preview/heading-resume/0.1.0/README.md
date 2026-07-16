# Heading Resume

Heading Resume creates a polished editorial resume with a compact two-column
layout. It keeps content in small semantic data structures, uses fonts bundled
with Typst, and needs no images or external assets.

## Quick start

Create a ready-to-edit project:

```sh
typst init @preview/heading-resume:0.1.0
```

Or import the package into an existing document:

```typ
#import "@preview/heading-resume:0.1.0": contact, entry, entry-section, resume, skill, skill-section

#show: resume.with(
  name: [Avery Example],
  contacts: (
    contact([avery\@example.com], url: "mailto:avery@example.com"),
    contact([example.com], url: "https://example.com"),
  ),
  profile: [Short professional profile.],
  main-sections: (
    entry-section(
      [Projects],
      (
        entry(
          [Useful project],
          organisation: [Independent work],
          dates: [2025–Present],
          body: (
            [Explain the problem and your contribution.],
            [Show a concrete outcome.],
          ),
        ),
      ),
    ),
    skill-section(
      [Skills],
      (skill([Programming], [Python · Rust · SQL]),),
    ),
  ),
)
```

## Public definitions

### `resume`

Use `resume` with a show rule. Its first argument is the document body supplied
by that rule. Named arguments:

- `name`: required display name.
- `contacts`: array of values returned by `contact`.
- `profile`: optional introductory content.
- `main-sections`: sections in the wider left column.
- `aside-sections`: sections in the narrower right column.
- `full-sections`: sections below both columns.
- `accent`, `paper-fill`, `ink`, `muted`: document colors.
- `page-paper`, `page-margin`, `language`: page size, margins, and document
  language. Defaults: A4, compact resume margins, and English.
- `document-title`: title stored in document metadata. Default: `"Resume"`.
- `display-font`: font used for the name.
- `body-font`: font used for entries, dates, and skills rows.
- `label-font`: font used for contacts, the profile, and entry subtitles.
- `section-font`: optional font used for section headings. It defaults to
  `label-font`. All font roles otherwise default to portable
  `Libertinus Serif`.
- `text-size`: base size used to scale the layout. Default: `11pt`.
- `footer`: optional footer content.

### `contact`

`contact(value, url: none)` creates one item in the contact row. With `url`, the
displayed value becomes a link.

### `entry`

`entry(title, organisation: none, dates: none, subtitle: none, body: none)`
creates a project, education, or work item. An array passed as `body` renders as
a bullet list; other content renders directly.

### `entry-section`

`entry-section(title, entries, compact: false, inline-organisation: false)`
groups entries. `compact` tightens their spacing. `inline-organisation` places
the organization beside each entry title.

### `skill`

`skill(label, value)` creates one labeled skills row.

### `skill-section`

`skill-section(title, rows)` groups one or more skills rows.

## Layout tips

- Keep the initialized example to one page by shortening content before
  reducing `text-size`.
- Put the most important evidence in `main-sections`, compact facts in
  `aside-sections`, and work history in `full-sections`.
- Pass a font fallback array when using optional local fonts. Do not assume
  other readers have those fonts installed.

## License

Heading Resume is licensed under the [MIT No Attribution license](LICENSE).
