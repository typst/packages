# shiyin-reader · 诗音读本

A data-driven Chinese poetry reader for Typst. It provides A4/A5/A6 page profiles, one- or two-column layouts, a large-print two-poems-per-page layout, pinyin ruby annotations, short notes under each poem, chapter covers, a table of contents, and optional appendix pages for poet biographies, famous lines, an author index, and endnotes for disputed readings.

The package contains the layout engine and a small public-domain example. It does **not** bundle a poetry corpus, curriculum, school logo, or other institution-specific data. You provide the content as a Typst dictionary or a JSON file.

## Quick start

Create a project from the template:

```bash
typst init @preview/shiyin-reader:0.2.0 my-poetry-book
cd my-poetry-book
typst compile main.typ
```

Or import the package directly:

```typst
#import "@preview/shiyin-reader:0.2.0": poem-book
#let book = json("book.json")
#show: poem-book.with(book: book)
```

## Data model

### Book dictionary

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| `metadata` | dictionary | yes | Title and edition information. |
| `format` | dictionary | yes | Page size, columns, type sizes, and leading. |
| `notes` | dictionary | yes | Note mode. Currently `mode: "short"`. |
| `fonts` | dictionary | yes | Body and title font fallback lists. |
| `chapters` | array | yes | Chapters, each containing poems. |
| `branding` | dictionary | no | Optional school or organization branding. |
| `features` | dictionary | no | Optional appendix pages; all default to `false`. |
| `front_matter` | dictionary | no | Preface text. Required when `features.front_matter` is `true`. |
| `appendix` | dictionary | no | Data for the optional appendix pages. |

### `metadata`

| Key | Type | Description |
| --- | --- | --- |
| `title` | string | Book title (required). |
| `volume` | string | Volume or grade label. |
| `edition` | string | Edition year or label. |
| `version` | string | Optional version label shown after the edition on the cover, e.g. `v0.3`. |
| `author` | string | Document author. Defaults to the book title. |
| `cover_mode` | `"general"` or `"personal"` | `personal` adds name and class fields to the cover. |
| `student_name`, `class_name` | string | Values used in personal mode. |
| `review_mode` | boolean | Show a review label on the title page. |
| `review_label` | string | Review label text. Defaults to `审核稿`. |

### `format`

| Key | Type | Description |
| --- | --- | --- |
| `paper` | `"a4"`, `"a5"`, `"a6"` | Page size. |
| `columns` | `1` or `2` | Column count. |
| `gutter_pt` | number | Column gutter in points. |
| `body_size` | number | Body text size in points. |
| `leading` | number | Paragraph leading multiplier. |
| `note_size` | number | Note text size in points. |
| `note_leading` | number | Note paragraph leading multiplier. |
| `poems_per_page` | number | Poems per page. `1` is the normal flow; `2` stacks two equal panels per page. |
| `panel_gap` | number | Gap between the two panels in points when `poems_per_page` is `2`. |
| `compact_fit` | boolean | Tighten note and heading spacing before giving up on a two-up pair. Body size never shrinks. |
| `poem_title_size`, `author_size`, `poem_gap` | number | Title, author, and inter-poem spacing in points. |
| `pinyin_body_size`, `pinyin_note_size`, `pinyin_size`, `pinyin_leading` | number | Pinyin-mode body, note, ruby, and leading overrides. |
| `pinyin_title_size`, `pinyin_title_pinyin_size`, `pinyin_author_size`, `pinyin_author_pinyin_size` | number | Pinyin-mode title and author overrides. |
| `margin_left_pt`, `margin_right_pt`, `margin_top_pt`, `margin_bottom_pt` | number | Pin reading margins independently of the theme. |
| `aux_scale` | number | Scale factor for appendix pages. |
| `title_size`, `title_pinyin_size`, `author_size`, `author_pinyin_size`, `pinyin_size` | number | Legacy pinyin overrides kept for compatibility. |

### `notes`

```typst
notes: (mode: "short")
```

`"short"` renders numbered notes under each poem. Other values render no notes; footnote rendering is not implemented yet.

### `branding`

All fields are optional. The cover and back cover hide empty branding blocks automatically.

| Key | Type | Description |
| --- | --- | --- |
| `school_name` | string | School or organization name. |
| `school_name_en` | string | Secondary name, usually English. |
| `slogan` | string | Cover and back-cover slogan. |
| `motto` | string | Vertical motto on the back cover. |
| `cover_lines` | array of strings or string | Lines shown in the middle of the cover in general mode. |
| `logo` | string or image | Logo image. Typst callers can pass `image("logo.svg")`, which resolves in their project. JSON callers pass a path string, resolved from the package file; use an absolute path or the `asset-root` prefix. |
| `end_motto` | string | Ending-page motto. Defaults to `诗心常在　书香长伴`. |

### `features`

| Key | Default | Description |
| --- | --- | --- |
| `front_matter` | `false` | Render the preface page. |
| `famous_lines` | `false` | Render the famous-lines appendix. |
| `poet_bio` | `false` | Render the poet biographies appendix. |
| `author_index` | `false` | Render the author index. |
| `reading_notes` | `false` | Render the endnote appendix for disputed or easily misread characters. |
| `end_page` | `false` | Render the closing page. |
| `back_cover` | `false` | Render the back cover. |

### `front_matter`

```typst
front_matter: (
  title: "卷首语",
  preface: "Plain-text preface.",
  paragraphs: (
    "First paragraph.",
    "Second paragraph.",
  ),
)
```

`paragraphs` is what gets rendered. `preface` is optional metadata kept for convenience.

### `appendix`

```typst
appendix: (
  famous_lines: (
    (quote: "春眠不觉晓，处处闻啼鸟。", source: "孟浩然《春晓》"),
  ),
  poet_heading: "【诗人简介】",
  poets: (
    (group: "唐", name: "孟浩然", years: "689—740", bio: "唐代诗人，襄阳人。"),
  ),
  author_index: (
    (
      initial: "M",
      name: "孟浩然",
      dynasty: "唐",
      poems: ((title: "春晓", poem_id: "chunxiao"),),
    ),
  ),
  reading_notes: (
    heading: "【后注】",
    subtitle: "多音字与异读备查",
    intro: "正文按教材或通行读法标注；下列异读供教师和家长备查。",
    groups: (
      (
        heading: "一、多音字示例",
        items: (
          (
            poem: "《春晓》",
            word: "不觉晓",
            reading: "bù jué xiǎo",
            alternative: "bù jiào xiǎo",
            note: "“觉”在这里是“觉察、发觉”，读 jué。",
          ),
        ),
      ),
    ),
  ),
)
```

Every poem referenced from `author_index` must have a matching `poem_id` in the chapter data so its page reference can be resolved.

`reading_notes` groups contain `heading` and `items`; each item has `poem`, `word`, `reading`, an optional `alternative`, and a `note`. The page is rendered when `features.reading_notes` is `true`.

### `chapters` and `poems`

```typst
chapters: (
  (
    name: "第一编 春晓",
    subname: "五言绝句",
    bg_color: "#E65100",
    poems: (
      (
        number: 1,
        poem_id: "chunxiao",
        title: "春晓",
        author: "（唐）孟浩然",
        lines: ("春眠不觉晓，处处闻啼鸟。", "夜来风雨声，花落知多少。"),
        notes: (
          (headword: "晓", text: "天刚亮的时候。"),
          (headword: "闻", text: "听见。"),
        ),
      ),
    ),
  ),
)
```

- `poem_id` is optional, but it is required for pinyin annotations and author-index page references.
- `notes` is required; use `()` when a poem has no notes.
- `topic` and `subtopic` are optional grouping headings within a chapter.

### Pinyin annotations

Pinyin data is passed separately:

```typst
#let pinyin = json("pinyin.json")
#show: poem-book.with(
  book: book,
  pinyin: pinyin,
  pinyin-mode: true,
)
```

`pinyin-mode` forces a single column and larger type. The JSON shape is:

```json
{
  "version": 1,
  "poem_count": 1,
  "poems": {
    "jingyesi": {
      "title": [["静", "jìng"], ["夜", "yè"], ["思", "sī"]],
      "author": [["李", "lǐ"], ["白", "bái"]],
      "lines": [
        [["床", "chuáng"], ["前", "qián"], ["明", "míng"], ["月", "yuè"]],
        [["疑", "yí"], ["是", "shì"], ["地", "dì"], ["上", "shàng"], ["霜", "shuāng"]]
      ]
    }
  }
}
```

Each `title`, `author`, and line is an array of `[hanzi, pinyin]` pairs. The key under `poems` must match the poem's `poem_id`.

## `poem-book` parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `book` | required | Book dictionary. |
| `format` | `none` | Override `book.format`. |
| `notes` | `none` | Override `book.notes`. |
| `fonts` | `none` | Override `book.fonts`. |
| `features` | `(:)` | Override `book.features`. |
| `cover-mode` | `none` | Override `metadata.cover_mode`. |
| `asset-root` | `""` | Prefix for `branding.logo`. |
| `pinyin` | `none` | Pinyin dictionary. |
| `pinyin-mode` | `false` | Enable ruby annotations and single-column layout. |
| `design` | `"school"` | Reading-page structure. `"school"` keeps the original layout; `"kami"` is accepted as a compatibility alias. |
| `palette` | `none` | Colour palette applied over the structure: `"school"` (default) or `"kami"` (warm paper and ink blue). |

## Page profiles

| Paper | Margins (left/right/top/bottom) | Status |
| --- | --- | --- |
| A4 | 22/20/21/20 mm | Production target. |
| A5 | 20/17/19/18 mm | Supported; visual acceptance is still in progress. |
| A5 (Kami) | 20/20/26/18 mm | Kami reading layer: top-heavy margins, two columns. |
| A6 | 18/14/16/15 mm | Supported; visual acceptance is still in progress. |

## Fonts

The template uses `Noto Serif CJK SC` for body text and `STKaiti` or `KaiTi` for titles, with `Noto Serif CJK SC` as the final fallback. Install a CJK font before compiling. On Debian/Ubuntu, install `fonts-noto-cjk`; on macOS and Windows, the system KaiTi/STKaiti fonts can be used. If a font is unavailable, Typst falls back to another installed font and emits a warning.

The `kami` design uses `LXGW WenKai` for both body and titles, so the reading pages keep a single serif family. Install `LXGW WenKai` before compiling Kami editions.

## Template contents

The template ships with four public-domain poems (春晓, 静夜思, 登鹳雀楼, 咏鹅) and neutral example data. Replace the `chapters`, `appendix`, and `front_matter` entries with your own content. No real school name, logo, or curriculum is included.

## License

MIT. See [LICENSE](LICENSE).
