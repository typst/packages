# hanqing (汗青)

A Typst **manual/handbook template** with full Chinese typography support. Inspired by the layout patterns of [chef-cookbook](https://github.com/Paulmue0/chef-cookbook), redesigned for creating structured manuals, handbooks, and regulatory documents in Chinese.

📄 **[View example PDF →](https://codeberg.org/songwupei/hanqing/raw/tag/v0.1.1/examples/example.pdf)**

![Cover preview](https://codeberg.org/songwupei/hanqing/raw/tag/v0.1.1/thumbnail.png)

Key features:
- **CJK font stack**: Zhuque Fangsong, LXGW WenKai, Sarasa Mono SC — optimized for Chinese documents
- **Custom cover page**: `cover-line-1`, `cover-line-2` for subtitle lines, `cover-image` for background, `back-notice` for confidentiality notices
- **Flexible TOC**: `numbly` (numbered with Chinese numerals) and `simple` (clean dot-leader) styles
- **Customizable headings**: `chapter-header`, `menu-header`, `items-header`, `content-header`, `notes-header`
- **Version stamp**: `version` parameter for back-page date display
- **`lang: "cn"`** for proper Chinese punctuation and line breaking

## Usage

```bash
typst init @preview/hanqing
```

## Configuration

### `manual`

```typ
#import "@preview/hanqing:0.1.1": manual, entry

#show: manual.with(
  title: "My Manual",
  subtitle: none,             // Subtitle below title on cover
  author: "Your Name",
  date: datetime.today(),
  paper: "a4",
  accent-color: rgb("#D9534F"),
  cover-image: none,           // Path to cover background image
  cover-line-1: none,          // Top-left subtitle line 1
  cover-line-2: none,          // Top-left subtitle line 2
  back-notice: none,           // Confidentiality notice on last page
  version: "年月日",           // "年月日" = auto YYYY年MM月DD日, or literal string
  menu-header: "目录",         // TOC heading
  chapter-header: "章节",      // Chapter heading prefix
  toc-type: "simple",          // "simple" or "numbly" (numbered)
)
```

### `entry`

```typ
#entry(
  "Entry Title",
  description: [Short description.],
  badge: "Department Name",
  image: image("path/to/diagram.jpg"),
  items-header: "要点",       // Sidebar items heading
  items: (
    (amount: "要点一", name: "具体内容描述"),
    (amount: "要点二", name: "具体内容描述"),
    "Simple text item",
  ),
  content-header: "详细说明", // Content column heading
  content: [
    1. First point...
    2. Second point...
  ],
  notes-header: "备注",       // Notes heading
  notes: "Additional notes or tips.",
)
```

## About the Name

Hanqing (汗青) literally means "sweat of green" — the ancient Chinese process of preparing bamboo slips for writing. The term came to signify formal historical records and authoritative documentation, immortalized by the Song dynasty poet Wen Tianxiang's famous line: "人生自古谁无死，留取丹心照汗青" ("Leave a loyal heart to shine upon the bamboo annals").

The name was chosen to evoke the tradition of careful, lasting documentation — fitting for a template designed to produce structured, authoritative manuals.

## License

MIT — Original layout inspired by chef-cookbook (Copyright (c) 2025 PaulMue0), modifications and redesign Copyright (c) 2025 songwupei.
