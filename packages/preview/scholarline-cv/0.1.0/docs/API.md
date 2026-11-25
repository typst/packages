# API — v0.1.0 (unreleased)

Scholarline CV has a minimal core and treats everything else as a plugin. `cv()` sets up the page and stores the theme; the header, sections, section headings, entry links, and icon table can be replaced, and every built-in component is written with the public primitives listed below.

## `cv`

```typst
#show: cv.with(
  name: "Your Name",
  subtitle: "Computer Science Researcher · Example University",
  contacts: (contact("GitHub", "https://github.com", icon: "github"),),
  lang: "en",              // "en" or "zh"
  theme: (spacing: 1.1, paper: "a4"),
  plugins: (:),
)
```

Typst warns once for every listed font family that is not installed, so the default font lists are deliberately short. All defaults are free: [Inter](https://rsms.me/inter/) (including its Inter Display cut, used for the name) and [Noto Sans CJK SC](https://github.com/notofonts/noto-cjk). In the Typst web app, Noto Sans CJK SC is built in; upload Inter's TTF files and `InterDisplay-Bold.ttf` to the project. To use system fonts instead, override them, e.g. `theme: (font: "Helvetica Neue", cjk-font: "PingFang SC")` on macOS.

`lang: "zh"` sets Chinese line spacing and punctuation and uses a full-width colon in `skill-line`. Chinese text also renders under `lang: "en"`, which is the right choice for bilingual CVs. For example, write `section("教育经历 Education")`.

## Theme

Pass only the keys you want to change; the rest come from `default-theme`. Unknown keys are an error.

| Key | Default | Meaning |
|---|---|---|
| `ink` | `rgb("#151515")` | Name, headings, body text, contact links |
| `muted` | `rgb("#666666")` | Subtitle, dates, locations, authors, roles, `[links]`, icons |
| `rule` | `rgb("#E6E6E6")` | Hairlines under the header and section labels (between sections with `margin-section`) |
| `font` | `("Inter",)` | Latin font(s) |
| `cjk-font` | `("Noto Sans CJK SC",)` | Chinese font(s); its Latin glyphs also stand in for a missing `font` |
| `display-font` | `("Inter Display",)` | Font for the name; falls back to `font` |
| `size` | `9.6pt` | Body size; all other sizes scale from it |
| `spacing` | `1.0` | Multiplier for every vertical gap |
| `paper` | `"us-letter"` | Any Typst paper name, e.g. `"a4"` |
| `margin` | `auto` | `auto` picks a default for the paper; otherwise any Typst margin value |
| `header-align` | `center` | `center` or `left` |

## Plugins

| Plugin | Default | Signature |
|---|---|---|
| `header` | `default-header` | `(name, subtitle, contacts) => content` |
| `section` | `default-section` | `(title, body) => content` — built-in alternative: `margin-section` |
| `heading` | `default-heading` | `(title) => content` — the small uppercase label and hairline used by `default-section` |
| `links` | `default-links` | `(links) => content` for entry links — built-in alternative: `underline-links` |
| `icons` | built-in table | dictionary of name → SVG string; adds icons or overrides built-in ones |

Built-in alternatives:

- `margin-section` puts small uppercase section labels in a left margin column with a hairline between sections. Headings stay real headings, so PDF bookmarks still work.
- `default-links` renders entry links as muted `paper ↗`; `underline-links` renders them as muted labels with a soft underline.

Unknown plugin names are an error. Pick a preset, or wrap a default instead of rewriting it (for example `heading: title => default-heading([§ #title])` with the default section):

```typst
#show: cv.with(
  plugins: (
    section: margin-section,
    links: underline-links,
    icons: (book: read("book.svg")),   // the SVG should use stroke="currentColor"
  ),
)
```

PDF has no hover state, so clickable text carries a static cue instead: contact links get a soft underline, and entry links get `↗` or a soft underline.

## `contact(label, url, icon: none)`

Labels, URLs, icons, and order are independent. Built-in icons: `scholar`, `github`, `web`, `email`, `linkedin`, `orcid`, `phone`, `location`, `link`. Icons from the icon table are tinted with `muted` and centred on the text line. Any other Typst content can be used as an icon as-is. Unknown icon names are an error.

## Components

All fields except the first are optional; omitted fields leave no gap.

- `section(title)[body]`
- `education(institution:, degree:, dates:, location:, details:, body:)` — `details` is a muted line such as `"GPA: 3.90/4.00 · Dean's List"`
- `experience(institution:, role:, advisor:, dates:, location:, body:)` — `role` and `advisor` share one line
- `publication(title:, authors:, venue:, links:, note:)` — `links` is an array of `(label:, url:)`
- `project(name:, role:, tech:, dates:, links:, body:)`
- `award(name:, date:)` — single-line entries share a tighter rhythm
- `skill-line(label:, items:)` — muted label column and content column

Every field accepts ordinary Typst content, including formatted author lists and inline links.

## Primitives for your own components

| Primitive | Purpose |
|---|---|
| `entry(lines, aside: (), body: none)` | Two-column entry: `lines` on the left, muted `aside` rows on the right, then `body`. `none` rows are dropped. |
| `entry-title(body)` | Semibold entry title |
| `entry-meta(body)` | Muted metadata text; `none` stays `none` |
| `dot-join(parts)` | Joins the non-`none` parts with ` · ` |
| `entry-links(links)` | Entry links styled by the `links` plugin; nothing when `links` is empty |
| `section-label(title)` | Small uppercase, letter-spaced section label |
| `cv-icon(name)` | Tinted, centred icon from the icon table |
| `cv-theme()` | The resolved theme dictionary (call inside `context`) |

A custom component looks exactly like a built-in one:

```typst
#let talk(title: "", event: none, date: none, links: ()) = entry(
  ([#entry-title(title)#entry-links(links)], entry-meta(event)),
  aside: (date,),
)
```

See `examples/custom-links.typ` for a complete example, and [PLUGINS.md](PLUGINS.md) for plugin recipes.
