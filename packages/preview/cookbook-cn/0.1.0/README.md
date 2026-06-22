# cookbook-cn

A Typst cookbook template with **full Chinese typography support**, forked from [chef-cookbook](https://github.com/Paulmue0/chef-cookbook) by PaulMue0.

Key enhancements over the original:
- **CJK font stack**: Zhuque Fangsong, LXGW WenKai, Sarasa Mono SC — optimized for Chinese documents
- **Custom cover page**: `cover-line-1`, `cover-line-2` for subtitle lines, `back-notice` for confidentiality notices
- **Flexible TOC**: `numbly` (numbered with Chinese numerals) and `simple` (clean dot-leader) styles
- **Customizable headings**: `chapter-header`, `menu-header`, `ingredients-header`, `instructions-header`, `worknote-header`
- **Version stamp**: `version` parameter for back-page date display
- **`lang: "cn"`** for proper Chinese punctuation and line breaking

## Usage

```bash
typst init @preview/cookbook-cn
```

## Configuration

### `cookbook`

```typ
#import "@preview/cookbook-cn:0.1.0": *

#show: cookbook.with(
  title: "My Recipes",
  subtitle: none,
  author: "Your Name",
  date: datetime.today(),
  paper: "a4",
  accent-color: rgb("#D9534F"),
  cover-image: none,
  cover-line-1: none,        // Cover subtitle line 1
  cover-line-2: none,        // Cover subtitle line 2
  back-notice: none,         // Confidentiality notice text at back of document
  version: "年月日",       // Back-page version date
  menu-header: "目录",
  chapter-header: "章节",
  toc-type: "simple",      // "simple" or "numbly" (numbered)
  ingredients-header: "材料",
  instructions-header: "步骤",
  worknote-header: "备注",
)
```

### `recipe`

```typ
#recipe(
  "Recipe Name",
  description: [Short description.],
  servings: "4 servings",
  prep-time: "20m",
  cook-time: "40m",
  ingredients: (
    (amount: "200g", name: "Flour"),
    (amount: "2", name: "Eggs"),
    "Salt",
    "Pepper",
  ),
  instructions: [
    1. First step...
    2. Second step...
  ],
  notes: "Optional chef's notes.",
  image: image("path/to/dish.jpg"),
  ingredients-header: "材料",
  instructions-header: "步骤",
  worknote-header: "备注",
)
```

## License

MIT — Original work Copyright (c) 2025 PaulMue0, modifications Copyright (c) 2025 songwupei.
