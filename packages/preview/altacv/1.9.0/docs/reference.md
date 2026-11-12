# altacv reference

Everything the package reads and exports. The [README](../README.md) shows how to use it.

- [Data schema](#data-schema): [top-level keys](#top-level-keys), [dates](#dates), [extensions](#extensions), [`basics`](#basics), [sections](#sections), [profile networks](#profile-networks), [PDF metadata](#pdf-metadata)
- [Preferences](#preferences) · [Theme tokens](#theme-tokens) · [Labels](#labels) · [Part labels](#part-labels)
- [Exports](#exports): [template and CV](#template-and-cv), [blocks](#blocks), [adapter](#adapter)
- [Deprecated](#deprecated)

## Data schema

The CV follows [JSON Resume](https://jsonresume.org/schema/), as a Typst dict or a `resume.json` loaded with gairm-import's `parse`. Missing or empty sections are skipped, with no orphan headings. Spec fields altacv doesn't draw (`basics.pronouns`, which JSON Resume [is removing](https://github.com/jsonresume/jsonresume.org/pull/629); a location's `address` and `postalCode`) are accepted and ignored, so a `resume.json` from elsewhere compiles unchanged.

### Top-level keys

`basics`, `objective`, `work`, `volunteer`, `education`, `skills`, `languages`, `projects`, `publications`, `certificates`, `awards`, `interests`, `references`, `custom` ([extensions](#extensions)), `meta` ([PDF metadata](#pdf-metadata)) and `$schema` (accepted, not drawn). Any other key panics, so a misspelt section (`publication`) fails rather than vanishing.

`objective` ([JSON Resume](https://jsonresume.org/schema/) 1.4.0) is a short career goal, a string or content, shown in the header under the tagline (`basics.label`), in italics.

### Dates

ISO 8601 dates (`"2024"`, `"2024-06"`, `"2024-06-15"`) are formatted per the `date-format` preference; other strings (`"Jan 2022"`) print as given. A missing or empty `endDate` reads "Present" (`labels.present`).

In Typst, a full date can also be a `datetime` (`datetime(year: 2024, month: 6, day: 15)`, or `datetime.today()`), read as its ISO string. A `datetime` always has a day, so a date known only to the month or year stays a string (`"2024-06"`).

### Extensions

altacv reads four optional fields the JSON Resume schema has no place for, from its own namespace in the schema's `custom` object. Other keys under `custom` are ignored.

```typst
(
  custom: (altacv: (focusAreas: ([Distributed systems], [Developer tooling]))),
  languages: ((language: "German", fluency: "Fluent", custom: (altacv: (rating: 3.5))),),
  skills: ((name: "Frontend", keywords: ("React",), custom: (altacv: (rating: 2.5))),),
  awards: ((title: "Best Paper", custom: (altacv: (url: "https://example.com/paper"))),),
)
```

| Field | Effect |
|---|---|
| `custom.altacv.focusAreas` (root) | An "Areas of Focus" section of prose bullets. Its section key and label are `focus-areas`. |
| `languages[].custom.altacv.rating` | An exact rating, 0 to `max-rating` in 0.5 steps; wins over `fluency`. |
| `skills[].custom.altacv.rating` | The same for a skill group; wins over `level`. |
| `awards[].custom.altacv.url` | Links the award title. |

### `basics`

| Field | Effect |
|---|---|
| `name` | Required. The name, in capitals unless `uppercase-name: false`. |
| `label` | The tagline under the name. |
| `summary` | The introduction under the header. |
| `image` | The photo: a `path(..)`, which resolves from your file, or bytes; a string resolves inside the package (deprecated: it will be an error). Non-square images are cropped from the centre. |
| `email`, `phone`, `url` | Contact bar entries. `url` shows without its scheme (`jane.dev`) and is what `qr-code: auto` encodes. |
| `location` | A string, or a dict `{address, postalCode, city, region, countryCode}`, shown as `city, region, countryCode`. |
| `profiles` | `{network, username, url}` entries in the contact bar, with the network's icon (see [Profile networks](#profile-networks)). |

### Sections

Every entry section has the same layout: the title with its date at the right edge; the organisation and short facts with the location at the right edge; then the summary, highlights and keywords. Absent fields drop their line, and the title or organisation links to the entry's `url` when set. These fields mean the same in every entry section:

| Field | Type | Meaning |
|---|---|---|
| `location` | string or dict | As in [`basics.location`](#basics). |
| `startDate` / `endDate` | string | A period, per [Dates](#dates); a single `date` is one date. |
| `summary` | string or content | A short paragraph of context. |
| `highlights` | array of content | A bulleted list of accomplishments. |
| `keywords`, `courses` | array of strings | One line at the end of the entry, joined with ` · `. Skills and interests show keywords their own way (below). |

| Section | Title | Facts line | Also reads |
|---|---|---|---|
| `work` | `position` | `name` (linked by `url`) | `location`, dates, `summary`, `highlights`, `keywords` |
| `volunteer` | `position` | `organization` (linked by `url`) | `location`, dates, `summary`, `highlights` |
| `education` | `studyType`, else `area` | `institution` (linked by `url`) | `location`, dates, `summary`, `courses`; a line above the courses with `area` (when `studyType` is the title) and `score` |
| `projects` | `name` (linked by `url`) | `entity · roles` | dates, `summary`, `highlights`, `keywords`, `type` |
| `certificates` | `name` (linked by `url`) | `issuer · credentialId` | `date`, `expiryDate` (makes the date a range), `summary` |
| `awards` | `title` (linked by `custom.altacv.url`) | `awarder` | `date`, `summary` |

An entry without its title field (`name` for projects and certificates, `title` for awards) is skipped.

**Projects** with a `type` are grouped under a heading per type, each with its icon (`project-icons`); untyped projects pool under `labels.other-projects` ("Other"). If no project has a type, the list is flat.

**Publications** render as a bibliography: the `name` (linked by `url`, else by the first DOI, arXiv or PMID identifier), then the `authors`, the source with its `releaseDate`, the identifiers and the `summary`.

| Field | Effect |
|---|---|
| `authors` | Author list. The CV owner's entry, matching `basics.name` or any of `owner-names` (ignoring case), is set apart. |
| `publisher`, `volume`, `issue`, `pages` | The citation: `ACM 12(3), 45–67`. Hyphens in `pages` become an en dash. |
| `identifiers` | Persistent IDs keyed by scheme: `DOI 10.1000/182 · arXiv 2101.00001`. `doi`, `arxiv` and `pmid` are linked; others print as given. |
| `type` | Groups publications under a heading per type, each with its icon (`publication-icons`). `article`, `book`, `patent`, `thesis` and `talk` have built-in headings (`labels.publication-types`); any other type is headed as written unless you add it there (deprecated: give it a heading in `labels.publication-types`). Untyped entries are articles. |

**Skills** are `{name, level, keywords}` groups: the name as a category tag, then the keywords as tags. A `level` of `Beginner`, `Novice`, `Intermediate`, `Advanced`, `Expert` or `Master` (any case) shows as dots, scaled to `max-rating`; any other level shows as text. `skill-level-display` forces `"rating"` (a level that doesn't map then panics) or `"text"`. Groups with no keywords are skipped.

**Languages** are `{language, fluency}`. LinkedIn's fluency terms (`Native`, `Bilingual`, `Full Professional`, `Professional Working`, `Limited Working`, `Elementary`, any case) show as dots; other strings show as text. An exact [rating extension](#extensions) wins. An entry with neither shows the language alone.

**Interests** are `{name, keywords}` lines: `Music: Trad, Jazz`. For prose bullets, use `custom.altacv.focusAreas`.

**References** show the `reference` quote under the referee's `name`, with a line of `relationship`, `organization` and `date`. `availableOnRequest: true` prints `labels.references-available-on-request` in place of the quote; if every entry sets it, the section is just that one line. Entries with neither a quote nor `availableOnRequest` are skipped.

### Profile networks

`basics.profiles[].network` is matched, ignoring case, against: `Bluesky`, `GitHub`, `GitLab`, `Link`, `LinkedIn`, `Mastodon`, `Medium`, `ORCID`, `Stackoverflow`, `Twitter` (or `X`), `Website`. `Link` is a generic fallback. Any other network panics unless you give it an icon with `profile-icons`:

```typst
#alta(cv, preferences: (profile-icons: (kaggle: "kaggle", researchgate: "researchgate")))
```

Values are FontAwesome glyph names from [fontawesome.com/search](https://fontawesome.com/search); free brand and solid glyphs work, Pro ones need the Pro fonts.

### PDF metadata

| PDF field | Source |
|---|---|
| Title | `labels.document-title` (default `"{name} — CV"`) |
| Author | `basics.name` |
| Subject | `basics.summary` |
| Keywords | Every `skills[].keywords`, de-duplicated, then `meta.canonical` and `meta.version` |
| Date | `meta.lastModified` (ISO 8601), else the compile time |

```typst
meta: (
  lastModified: "2026-06-12",               // PDF date; cv-updated-footer()
  canonical: "https://example.com/cv.json", // PDF Keywords
  version: "v1.0.0",                        // PDF Keywords; cv-updated-footer(version: true)
)
```

A `set document(..)` of your own after the show line wins. A CV written in markup has no data, so set its title and author yourself.

## Preferences

`alta(cv, preferences: (..))` and a mapping's `resume(cv, preferences: (..))` take these, each merged over its default. An unknown key or a wrong type panics, naming it. The theme isn't a preference: `theme` or `colours` passed to `alta()` panics, standalone too; use `altacv.with(theme: ..)`.

### Look

| Key | Default | Effect |
|---|---|---|
| `publication-icons` | built-ins | Icon per `publications[].type`, from the [icon set](#template-and-cv); merged over the built-ins (`article` → `newspaper`, `book` and `thesis` → `book`, `talk` → `microphone`, others `file`). |
| `project-icons` | `(:)` | Icon per `projects[].type` (e.g. `laptop-code`, `cubes`, `terminal`, `flask`); `folder` when unmapped. |
| `profile-icons` | built-ins | FontAwesome glyph per profile network; merged over the [built-ins](#profile-networks). |

### Header

| Key | Default | Effect |
|---|---|---|
| `uppercase-name` | `true` | Set `false` for scripts without case, or where uppercasing changes letters (Turkish dotless i). |
| `header-text-align` | `left` | `left`, `right` or `center`. |
| `photo-size` | `6em` | The photo's width and height. |
| `photo-shape` | `"circle"` | `"circle"`, `"rounded"` or `"square"`. |
| `photo-position` | `right` | The side of the header text the photo takes: `left`, `right`, or centred at the `top` or `bottom`. |
| `qr-code` | `none` | `auto` (encode `basics.url`; panics without one) or a URL string. |

### Layout

| Key | Default | Effect |
|---|---|---|
| `column-ratio` | `0.65` | The left column's share of the width, in `(0, 1]`; `1` for a single column, the left sections first. |
| `left-column-sections` | `("work", "volunteer", "projects", "publications")` | Sections in the left column, in order. |
| `right-column-sections` | `("focus-areas", "skills", "languages", "education", "certificates", "awards", "interests", "references")` | Sections in the right column, in order. A section in neither column isn't drawn. |

### Formatting and links

| Key | Default | Effect |
|---|---|---|
| `date-format` | `"long"` | `"long"` (`Jun 2024`), `"short"` (`06/2024`), `"iso"` (unchanged), a [`datetime.display()`](https://typst.app/docs/reference/foundations/datetime/#definitions-display) pattern such as `"[day]/[month]/[year]"`, or a function `(year, month, day) => str`. |
| `link-contact-info` | `true` | `false` to unlink the contact bar, or a dict keyed by `email`, `phone`, `location`, `url`, `profiles` (an unset channel stays linked). |
| `print-full-urls` | `false` | Unlinked profiles show their URL (`github.com/jane`) in place of the username. |
| `maps-provider` | `maps-providers.google` | The location link: `maps-providers.{google,apple,bing,duckduckgo,osm}`, a template with `{q}`, or `none`. |
| `max-rating` | `5` | Dots per rating scale. |
| `skill-level-display` | `auto` | `auto` (dots when the level maps, else text), `"rating"` (an unmapped level panics) or `"text"`. |
| `owner-names` | `()` | Other spellings of your name among publication authors, e.g. `("J. Doe",)`. |

### Standalone only

Standalone `alta()` (deprecated, see the README's [Upgrading](../README.md#upgrading)) also takes the document-level preferences. Inside the template they panic, naming the rule that replaces each.

| Key | Default | In the template |
|---|---|---|
| `font` | `auto`, the theme's | `set text(font: ..)` |
| `body-size` | `10pt` | `set text(size: ..)` |
| `paper` | `"a4"` | `set page(paper: ..)` |
| `margin` | `(x: 0.9cm, y: 1.5cm)` | `set page(margin: ..)` |
| `page-footer` | `none` | `auto`: `set page(footer: cv-footer())`. Content: `set page(footer: [..])`. |
| `last-modified-footer` | `false` | `set page(footer: cv-updated-footer())` |
| `footer-version` | `false` | `set page(footer: cv-updated-footer(version: true))` |

## Theme tokens

`altacv.with(theme: ..)` takes a theme dict: a built-in (`themes.navy`) or any of these tokens; unset tokens keep the default theme's. A wrong key or type panics with its path (`theme.type.headline.size must be a number`).

| Key | Default | Sets |
|---|---|---|
| `font` | `"Lato"` | The font family, or a fallback array. |
| `colours` | the teal theme's | The [colour roles](#colour-roles). |
| `type` | `display` 2.5 bold, `headline` 1.4 bold, `title` 1.2 semibold, `body` regular | Each role's `size` (a multiple of the text size) and `weight`: `display` the name, `headline` a section title, `title` an entry title or the tagline under the name, `body` the rest. |
| `font-weight` | `regular`, `bold` | The weights used for emphasis within a role. |
| `space` | `xx-small` 0.15, `x-small` 0.3, `small` 0.5, `medium` 0.8, `large` 1.2 | The spacing scale, in multiples of the text size. |
| `stroke-width` | `thin` 0.5, `thick` 1 | Rule and border widths, in pt. |
| `leading` | 0.55 | Line spacing, in `em`. |
| `separator` | `facts` `" · "`, `items` `", "`, `label` `": "`, `range` `" – "`, `keywords` `" · "` | Between groups of facts, between items in a group, after a label (`Music: Trad`), between two dates, and between an entry's keywords. |
| `treatment` | `preamble` italic, `link` `emph`, `owner` `strong`, `label` `strong` | How a summary, a publication title, your name among authors and an interest's name stand out: a function of the content (`emph`, `strong`, `upper`, `underline`, `it => it` for none). The italic default sets the style rather than toggling it as `emph` does, so a show rule on the summary keeps its own style. |
| `citation` | `issue` `("(", ")")`, `pages` `", "`, `source` `" "`, `page-range` `"–"` | The punctuation of `ACM 12(3), 45–67`. |

### Colour roles

| Role | Colours |
|---|---|
| `accent` | Organisation names, tags, rating dots, contact icons, publication titles, the QR code. |
| `emphasis` | Entry titles and interest group names. |
| `body` | Body text and icons. Dates, dividers and empty rating dots take lighter shades of it. |
| `heading` | Section titles. |
| `heading-rule` | The rule under each section title. |
| `subheading` | Group titles, such as a publication type. |
| `name` | The name. |
| `tagline` | The tagline under the name. |

Any `rgb(..)` value works; roles that colour text should stay dark enough to read on white.

## Labels

Every string the template prints. The defaults are [`internal/data/labels-en.toml`](../internal/data/labels-en.toml), under the document language's built-in translation, if any ([`labels-ga.toml`](../internal/data/labels-ga.toml)). `altacv.with(labels: ..)` overrides them for the document, `alta(cv, labels: ..)` for one CV. Section labels share the section's key (`focus-areas`). For a translation of your own, copy `labels-en.toml`, drop its `lang` line and its `[publication-icons]` table (both deprecated, which the template rejects), translate it and load it: `altacv.with(labels: toml("labels-de.toml"))`.

| Key | Default |
|---|---|
| `work` | `"Experience"` |
| `volunteer` | `"Volunteer"` |
| `focus-areas` | `"Areas of Focus"` |
| `skills` | `"Skills"` |
| `languages` | `"Languages"` |
| `education` | `"Education"` |
| `certificates` | `"Certifications"` |
| `publications` | `"Publications"` |
| `awards` | `"Awards"` |
| `projects` | `"Projects"` |
| `interests` | `"Interests"` |
| `references` | `"References"` |
| `references-available-on-request` | `"References available upon request."` |
| `other-projects` | `"Other"`, the group for untyped projects |
| `present` | `"Present"` |
| `date`, `location` | `"Date"`, `"Location"`: read aloud by screen readers before an entry's date and location, not printed |
| `last-modified` | `"Last updated"` |
| `page-number` | `"Page {current} / {total}"` (`{total}` optional) |
| `document-title` | `"{name} — CV"`, the PDF title |
| `months` | `("Jan", "Feb", …, "Dec")`, exactly twelve |
| `publication-types` | `(article: "Articles", book: "Books", patent: "Patents", thesis: "Theses", talk: "Talks")`, merged entry by entry; other types print as given (deprecated) |

`page-number` and `document-title` are templates, so a translation can reorder them (`"Seite {current} von {total}"`). A missing required or unknown placeholder panics.

## Part labels

Show-rule targets for [restyling](../README.md#restyling-parts). They are public API and change only in a major release; labels prefixed `alta-internal-` may change at any time, so don't target them. The kind is the rules a part takes, not the element it is: a text part takes `set text(..)`, a line part `set line(..)`, a paragraph part `set par(..)`, and a marker can be recoloured or replaced (the replacement keeps its place and alt text; rating dots also take `set circle(fill: ..)`).

| Label | Kind | Part |
|---|---|---|
| `<alta-name>` | text | The name. |
| `<alta-tagline>` | text | The tagline under the name (`basics.label`). |
| `<alta-objective>` | text | The objective, under the tagline. It is also an `<alta-summary>` part. |
| `<alta-section-title>` | text | A section's heading (Experience, Skills, …). |
| `<alta-entry-title>` | text | An entry's title: a role, qualification, project or award. |
| `<alta-group-title>` | text | A group's heading within a section: a publication type, a project type. |
| `<alta-contact>` | text | Each contact-bar entry. |
| `<alta-org>` | text | An entry's organisation: employer, institution, issuer or awarder. |
| `<alta-facts>` | text | The line under an entry's title: the organisation with its roles and details (`<alta-org>` sets the organisation's own colour). |
| `<alta-date>` | text | An entry's date or date range. |
| `<alta-location>` | text | An entry's location. |
| `<alta-summary>` | text | A summary: the CV's, the objective, or an entry's. |
| `<alta-intro>` | block | The block around the CV's summary under the header, spaced by the template (a paragraph's `spacing`, plus the theme's intro spacing as `inset`); `show <alta-intro>: set block(spacing: .., inset: ..)` respaces it. |
| `<alta-tag>` | text | A tag's text (its box is the theme's). |
| `<alta-tag-category>` | text | A category tag's text: a skill group's name. |
| `<alta-keyword>` | text | One of an entry's keywords: a work or project keyword, an education's course. |
| `<alta-keywords>` | paragraph | An entry's keyword line, a paragraph of its `<alta-keyword>` parts (not a skill or interest row). |
| `<alta-rating-label>` | text | The label beside a rating: a language's name. |
| `<alta-footer>` | text | The page footer. |
| `<alta-section-rule>` | line | The line under a section's heading. |
| `<alta-date-icon>`, `<alta-location-icon>` | marker | The icon before an entry's date or location. |
| `<alta-rating-full>`, `<alta-rating-half>`, `<alta-rating-empty>` | marker | A filled, half-filled or empty rating dot. A glyph that replaces one takes the accent, or the border colour for an empty dot. |

The line between entries is Typst's [`divider`](https://typst.app/docs/reference/model/divider/) and the bullets Typst's `list`: restyle them with `show divider` and `show list`.

A replacement rule's `it` is the part as content, whatever builds it (text, a sequence, a `context`), so use it whole (`tag(it)`, `emph(it)`), not `it.text`. To draw an entry's keywords (a project's stack, education's courses) as tags, replace each `<alta-keyword>` with a `tag()`, drop the separator between them, and space the `<alta-keywords>` line as skill rows are:

<!-- x-release-please-start-version -->
```typst
#import "@preview/altacv:1.9.0": alta, altacv, tag

#show: altacv.with(theme: (separator: (keywords: "")))
#show <alta-keyword>: it => tag(it)
#show <alta-keywords>: set par(leading: 0.8em, spacing: 0.8em)
#alta(cv)
```
<!-- x-release-please-end -->

## Exports

Every export has a doc comment, shown on hover in Tinymist and other Typst editors.

<!-- x-release-please-start-version -->
```typst
#import "@preview/altacv:1.9.0": alta, altacv, entry, tag, themes
```
<!-- x-release-please-end -->

### Template and CV

| Export | Purpose |
|---|---|
| `altacv(theme:, labels:, body)` | The template: `#show: altacv.with(theme: ..)`. Sets the theme, the text, the margins and the heading and list rules; `labels` overrides the [labels](#labels) of everything it draws. |
| `alta(cv, labels:, preferences:)` | Draws a CV from its [data](#data-schema), with [preferences](#preferences). |
| `cv-footer()` | A page footer for `set page(footer: ..)`: the name (`basics.name`; in a CV written in markup, the document's author, else its title) and the page number, on documents of more than one page, counted by Typst's page counter. |
| `cv-updated-footer(version: false, date: none)` | A page footer: `labels.last-modified` and `meta.lastModified`, with `meta.version` when `version` is `true`. `date` replaces `meta.lastModified`; a CV written in markup has no `meta`, so it needs one. |
| `themes` | The built-in themes, by name, for `altacv.with(theme: ..)`. |
| `maps-providers` | Map link templates for `maps-provider`. |
| `avatar-placeholder` | A generic silhouette (SVG bytes) for `basics.image`. |
| `icon(name, size:, shift:, fill:, alt:)` | A glyph from the icon set: `book`, `calendar`, `cubes`, `email`, `file`, `flask`, `folder`, `laptop-code`, `location`, `microphone`, `newspaper`, `phone`, `terminal` and the profile networks. |
| `adapter` | The readers for a mapping of your own ([below](#adapter)). |

### Blocks

For a CV written in markup, or a mapping of your own. Each reads the theme and labels of the template it sits in.

| Block | Purpose |
|---|---|
| `cv-header(name: auto, tagline:, objective:, contacts:, photo:, photo-position: right, photo-size: auto, photo-shape: auto, qr:, uppercase: true)` | The header: the name (the document's title by default), a tagline, an objective, the contact bar, a photo and a QR code. Its text follows the alignment around it (`#align(center, cv-header(..))`). `photo` is content, an `image(..)` loaded in your file. |
| `contact(icon, value, url: none, alt: auto)` | One contact-bar entry for `cv-header`: an icon, its text, and an optional link. |
| `entry(title:, url:, org:, org-url:, subtitle:, roles:, date:, location:, details:, summary:, keywords-lead:, keywords:, body)` | An entry under a section or group heading, after a divider when another entry precedes it there. `date` takes content, a string, or a `(start, end)` pair, a `none` end reading "Present"; `location` an array of parts, joined by the theme's item separator. The body (highlights or other prose) is optional. |
| `publication(title:, url:, authors:, owners: auto, source:, citation: (:), date:, identifiers:, body)` | A bibliography item with a required `title`: the title (linked by `url`, else the first DOI, arXiv or PMID identifier), the authors with the `owners` (the document's author by default) set apart, the source and its `citation` (`volume`, `issue`, `pages`), the date and the identifiers. The body, its summary, is optional. |
| `skill-row(name, keywords, level: none, max: auto)` | A skill group: its name as a category tag, its keywords as tags, and an optional level, a number or a rating term as dots, other text as written. |
| `rating(label, value, max: auto)` | A label with rating dots at the right edge, or a text value in their place. |
| `label-row(label, items)` | A labelled line: "Music: Trad, Jazz". |
| `tag(body, category: auto, trailing: true)` | A short text in a tinted box. `category: true` is the darker, bold one that names a skill group. |
| `divider()` | The rule between entries, in the theme's look. |
| `cv-columns(left, right, ratio: 0.65)` | Two columns with the theme's gutter, the left taking `ratio`; one column when `right` is `none` or the ratio is 1. |

`max: auto` in `rating` and `skill-row` is the `max-rating` of the last `alta()` before it, else 5.

### Adapter

The `adapter` module holds the readers `alta()` maps a CV with, for [your own mapping](../README.md#your-own-mapping). They take JSON Resume's field names (`countryCode`).

| Helper | Returns |
|---|---|
| `adapter.custom(obj, key, default: none)` | One of altacv's fields from `custom.altacv`, on the CV or an entry. |
| `adapter.entries(cv, key)` | A section's entries as `alta()` draws them, without those it skips (a project without a name, a skill group without keywords, …); `focus-areas` reads `custom.altacv.focusAreas`. |
| `adapter.format-date(value, format:, months:)` | A JSON Resume date formatted per `date-format`: `"2024-06"` reads `"Jun 2024"`. |
| `adapter.location-parts(location)` | A location's city, region and country code that are set, in that order, for you to join. |
| `adapter.basics-contacts(basics, linked:, maps-provider:, full-urls:, icons:)` | The contact bar's records from `basics`, for `cv-header(contacts: ..)`. |
| `adapter.fluency-rating(entry, max:)` | A language's rating from its `custom.altacv.rating` or its `fluency` term, else `none`. |
| `adapter.entry-type(entry)` | A project's or publication's `type`, trimmed, or `none` when it's untyped. |
| `adapter.group-by-type(items, key:, untyped:)` | `(group, items)` pairs by `type`, in the order each group first appears: a typed entry's group is `key(type)` (`lower` to ignore case), the untyped's `untyped`, which a type of that name shares. `alta()` groups projects with `untyped: labels.other-projects`, and publications with `key: lower, untyped: "article"`. |
| `adapter.labels(overrides:)` | The labels in the document's language, the template's over them and `overrides` over both. Call it in `context`. |
| `adapter.preferences(overrides:)` | Every preference, `overrides` merged over the defaults and checked. |

## Deprecated

Still accepted; removed in the next major release ([#239](https://github.com/smur89/alta-typst/issues/239)). The README's [Upgrading](../README.md#upgrading) covers standalone `alta()` and the deprecated exports.

| Deprecated | Use instead |
|---|---|
| camelCase option names (`columnRatio`, `labels.pageNumber`) | The kebab-case name (`column-ratio`, `labels.page-number`). The data stays JSON Resume's camelCase (`startDate`). |
| The section key `"focusAreas"` in a column list | `"focus-areas"`. The data stays at `custom.altacv.focusAreas`. |
| `accent` | The template's theme, or a colour role over one: `themes.teal + (colours: (..themes.teal.colours, accent: ..))`. Standalone, it colours the accent, the headings and their rules, the group titles and the name. |
| `references-available-on-request` | `references[].availableOnRequest`. |
| `imagePosition`, `imageSize` | `photo-position`, `photo-size`. |
| `imagePosition`'s strings `"left"`, `"right"`, `"center"` | The alignments `left`, `right`, and `top` (or `bottom`) for `"center"`. |
| `image-stack-order` | `photo-position: top` or `bottom`. |
| `header-text-align: "left"`, `"center"`, `"right"` | The alignments `left`, `center`, `right`. |
| `group-certificates`, `show-pronouns` | Nothing: both are ignored. |
| `labels.lang` (standalone only; it panics in the template) | `set text(lang: ..)`, which also picks the built-in labels. |
| `labels.articles` | `labels.publication-types.article`. |
| `labels.publication-icons` | The `publication-icons` preference. |
| The top-level `focusAreas`, `languages[].rating` and `awards[].url` | `custom.altacv.focusAreas`, `.rating` and `.url` ([extensions](#extensions)), which win when both are set. |
| `description` in `work`, `volunteer` and `projects` | `summary`, which wins. |
| Plural free-text publication types (`"Talks"`) | The type code (`"talk"`). |
| A string `basics.image` (it resolves inside the package, not from your file) | `path("photo.jpg")`, or bytes. In a `resume.json`, drop `image` and set the photo in Typst. |
| A publication type with no heading in `labels.publication-types`, printed as written | Its heading in `labels.publication-types`: `(poster: "Posters")`. |
