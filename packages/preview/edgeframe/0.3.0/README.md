# edgeframe

Edgeframe is a Typst package designed for rapid document scaffolding: handling headers, footers, margins, watermarks, and typography rules, all in a single, flexible function.

It's particularly powerful for creating papers, reports, or drafts where you need dynamic headers (different on first/last/odd/even pages) without spending time writing or copying the logic yourself.

## Quick Start

The core of Edgeframe is the `ef-document` function, intended to be used with a show rule at the top of your file.

```typ
#import "@preview/edgeframe:0.3.0": *

// Apply defaults and start writing
#show: ef-document.with(..ef-defaults)

= My Title
Start writing your content here...
```

This example is, of course, very simple but it can be configured with a lot more.

View some [example documents](https://github.com/neuralpain/edgeframe/blob/main/0.3.0/examples) available on the Github repository:

  - [academic.typ](https://raw.githubusercontent.com/neuralpain/edgeframe/refs/heads/main/0.3.0/examples/academic.typ)
  - [basic.typ](https://raw.githubusercontent.com/neuralpain/edgeframe/refs/heads/main/0.3.0/examples/basic.typ)
  - [business.typ](https://raw.githubusercontent.com/neuralpain/edgeframe/refs/heads/main/0.3.0/examples/business.typ)
  - [professional.typ](https://raw.githubusercontent.com/neuralpain/edgeframe/refs/heads/main/0.3.0/examples/professional.typ)
  - [works.bib](https://raw.githubusercontent.com/neuralpain/edgeframe/refs/heads/main/0.3.0/examples/works.bib) (Get the bibliography data)

---

## Configuration

### 1\. Paper and Layout

Basic settings for the physical page and margin dimensions.

| Parameter      | Type       | Default         | Description                                                                                                                   |
| :------------- | :--------- | :-------------- | :---------------------------------------------------------------------------------------------------------------------------- |
| `paper`        | string     | `"us-letter"`   | The paper size (e.g., "a4", "us-letter").                                                                                     |
| `margin`       | dictionary | `margin.normal` | The page margins. You can use the provided `margin` utility (e.g., `margin.wide`) or a standard dictionary `(top: 1cm, ...)`. |
| `hf-flex`      | boolean    | `true`          | Controls flexbox layout behavior for headers/footers.                                                                         |
| `hf-text-size` | length     | `none`          | Overrides the text size specifically for headers and footers.                                                                 |

### 2\. Headers and Footers

Edgeframe uses a robust system for headers and footers. You can pass a simple string/content, or a **dictionary** for granular control over specific pages.

**The Content Array:**
When defining content for a header or footer, you can provide a single item (centered) or an array of three items: `([Left], [Center], [Right])`.

#### Header & Footer Configuration (`header: (...)`, `footer: (...)`)

| Key          | Type           | Description                                                              |
| :----------- | :------------- | :----------------------------------------------------------------------- |
| `content`    | content, array | The default content. Can be `[Center]` or `([Left], [Center], [Right])`. |
| `first-page` | content, array | Content specific to the first page.                                      |
| `last-page`  | content, array | Content specific to the last page.                                       |
| `odd-page`   | content, array | Content specific to odd pages (useful for double-sided printing).        |
| `even-page`  | content, array | Content specific to even pages.                                          |
| `alignment`  | alignment      | Default alignment (e.g., `center`).                                      |

**Example:**

```typ
#show: ef-document.with(
  ..ef-defaults,
  header: (
    content: ([Left], [Center], [Right]),
    first-page: ([First], [], [Page]),
  ),
  footer: (
    content: [Copyright 2025],
    even-page: [Even Page Footer],
  )
)
```

### 3\. Page Numbering

Manage automatic page counting and its position.

| Parameter               | Type      | Default  | Description                                               |
| :---------------------- | :-------- | :------- | :-------------------------------------------------------- |
| `page-count`            | boolean   | `false`  | If true, adds page numbers to the footer.                 |
| `page-count-first-page` | boolean   | `true`   | Whether to show the number on the first page.             |
| `page-count-position`   | alignment | `center` | Where to place the number (`left`, `center`, or `right`). |

*Note: Enabling `page-count` will automatically replace the corresponding slot in your footer `content` array with the page counter.*

### 4\. Watermarks and Overlays

Add drafts stamps, confidentiality warnings, or decorative overlays.

| Parameter            | Type    | Default        | Description                                               |
| :------------------- | :------ | :------------- | :-------------------------------------------------------- |
| `draft`              | boolean | `false`        | Shortcut. If true, adds a "DRAFT" watermark.              |
| `confidential`       | boolean | `false`        | Shortcut. If true, adds a large "CONFIDENTIAL" watermark. |
| `watermark`          | content | `""`           | Custom text or content for the background.                |
| `watermark-color`    | color   | `luma(0, 20%)` | Color and transparency of the watermark.                  |
| `watermark-rotation` | angle   | `-45deg`       | Rotation angle.                                           |
| `overlay`            | content | `none`         | Content placed in the foreground (top of page).           |

### 5\. Typography (Paragraphs & Lists)

Edgeframe wraps standard Typst styling for paragraphs and lists so you can configure them in one place.

#### Paragraphs (`paragraph: (...)`)

| Key                 | Type    | Default  | Description                                    |
| :------------------ | :------ | :------- | :--------------------------------------------- |
| `justify`           | boolean | `false`  | Justify text.                                  |
| `leading`           | length  | `0.75em` | Spacing between lines.                         |
| `spacing`           | length  | `1em`    | Spacing between paragraphs.                    |
| `first-line-indent` | length  | `0em`    | Indentation for the first line of a paragraph. |

#### Lists (`bullet-list` and `number-list`)

Both list types accept dictionaries with the following keys: `indent`, `body-indent`, `spacing`, and `tight`.

**`bullet-list` specific:**

  * `marker` (an array of symbols, e.g., `([•], [‣], [–])`).
  * `numbering` (e.g., `"1."`), `start`, `full`, and `reversed`.

---

## Advanced Usage

### Creating Custom Defaults

These are the current defaults for edgeframe:

```typ
// Biased defaults for documents
#let ef-defaults = (
  paper: "a4",
  margin: margin.a4,
  paragraph: (
    justify: false,
    leading: 0.8em,
    spacing: 1.5em,
    first-line-indent: 0em,
  ),
)
```

If you frequently use a specific setup you can create a dictionary and pass it as an argument sink to `ef-document`.

```typ
#import "@preview/edgeframe:0.3.0": *

#let my-notebook-style = (
  paper: "a5",
  margin: margin.wide,
  page-count: true,
  paragraph: (
    justify: true,
    first-line-indent: 2em
  )
)

#show: ef-document.with(
  ..my-notebook-style,
  watermark: "PERSONAL" // You can still edit specific keys
)
```

If you've created a default setup by standard international convention, you can submit it to the project on Github via [Github Issues](https://github.com/neuralpain/edgeframe/issues/new). It can be added to Edgeframe for use in a future release.

### Complex Header Example

This example demonstrates a document with specific requirements: a different header on the first page, specific headers for the last page, and page numbers on the right.

```typ
#show: ef-document.with(
  ..ef-defaults,
  paper: "us-letter",
  page-count: true,
  page-count-position: right,
  header: (
    content: ([Project Alpha], [], [2025]),
    first-page: strong[EXECUTIVE SUMMARY],
    last-page: (none, [End of Document], none)
  ),
  footer: (
    // Page count takes the 'right' slot, we define the left slot here
    content: ([Confidential], [], []),
  )
)
```

---

## Utilities

The package exports a `margin` utility object containing common presets based on Microsoft Word layout settings:

  * `normal`
  * `narrow`
  * `moderate`
  * `wide`
  * `a4`
  * `a5`

**Line breaks and page breaks:**

There are a couple extra tools that can be used for niche solutions:

  * `xlinebreak(n)`: allows an `n` amount of `linebreaks()` with a single function.
  * `xpagebreak(n)`: allows an `n` amount of `pagebreaks()` with a single function.

These are useful when you want to don't want a single function making your project look messy in repetition (like I said, niche). They can be used normally and it's easy to switch between this and the regular functlion by using the `x` prefix.
