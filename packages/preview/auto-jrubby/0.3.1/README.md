# auto-jrubby

**auto-jrubby** is a Typst package that provides automatic Japanese morphological analysis and furigana (ruby) insertion.

It leverages a Rust-based WASM plugin to tokenize text using [Lindera](https://github.com/lindera/lindera) (a morphological analysis library) and uses the [rubby](https://typst.app/universe/package/rubby) package to render the furigana.

## Features

- **Automatic Furigana Generation:** Automatically determines readings for Kanji based on context and renders them as ruby text.
- **Smart Okurigana Alignment:** Intelligent handling of mixed Kanji/Hiragana words (e.g., `食べる` is rendered with ruby `た` over `食`, leaving `べる` untouched).
- **Morphological Analysis Table:** Visualize the text structure (Part of Speech, Detailed POS, Readings, Base forms) via a formatted data table.
- **Customizable Styling:** Supports custom ruby sizing and positioning via the `rubby` package backend.
- **High Performance:** Powered by a Rust WASM plugin using **Lindera** for fast and accurate tokenization.

## Usage

### Basic Furigana

To automatically add readings to Japanese text:
```typst
#import "@preview/auto-jrubby:0.3.1": *
#set text(font: "Hiragino Sans", lang: "ja")

#let sample = "東京スカイツリーの最寄り駅はとうきょうスカイツリー駅です"
#show-ruby(sample)
```

![sample](./images/sample.png)

### Morphological Analysis Table

To debug or display the linguistic structure of the text:
```typst
#import "@preview/auto-jrubby:0.3.1": *
#set text(font: "Hiragino Sans", lang: "ja")

#let sample = "東京スカイツリーの最寄り駅はとうきょうスカイツリー駅です"
#show-analysis-table(sample)
```

![table](./images/table.png)

## API Reference

### `show-ruby`

Renders the input text with automatic furigana.

```typc
#let show-ruby(
  input-text,
  size: 0.5em,
  leading: 1.5em,
  ruby-func: auto,
  user-dict: none,
  dict: "ipadic"
)
```

**Parameters:**

- `input-text` (string): The Japanese text to analyze and render.
- `size` (length): The font size of the ruby text. Defaults to `0.5em`.
- `leading` (length): The vertical space between lines to accommodate ruby text. Defaults to `1.5em`.
- `ruby-func` (function | auto): A custom ruby function from the `rubby` package.
  - If `auto`, it uses the default configuration (`get-ruby(size: size)`).
  - If provided, it allows advanced customization of ruby positioning (e.g., specific `pos` or `alignment`).
- `user-dict` (string | array | none): Optional user dictionary for custom tokenization.
  - If `string`: A CSV-formatted string with custom dictionary entries.
  - If `array`: An array of arrays, where each inner array represents a CSV row.
  - If `none`: No user dictionary is used.
- `dict` (string): The dictionary to use for tokenization. Must be one of:
  - `"ipadic"` (default): Standard Japanese dictionary
  - `"unidic"`: Alternative dictionary with different grammatical analysis

### `show-analysis-table`

Renders a table displaying the morphological breakdown of the text.

```typc
#let show-analysis-table(
  input-text,
  user-dict: none,
  dict: "ipadic"
)
````

**Parameters:**

  - `input-text` (string): The text to analyze.
  - `user-dict` (string | array | none): Optional user dictionary for custom tokenization.
  - `dict` (string): The dictionary to use. Must be one of: `"ipadic"` (default) or `"unidic"`.

**Table Columns:**

The columns displayed depend on the selected `dict`.

**If `dict: "ipadic"` (10 columns):**

1.  **Surface Form (表層形):** The word as it appears in the text.
2.  **Part of Speech (品詞):** Grammatical category (Noun, Verb, etc.).
3.  **POS Subcategory 1 (品詞細分類1)**
4.  **POS Subcategory 2 (品詞細分類2)**
5.  **POS Subcategory 3 (品詞細分類3)**
6.  **Conjugation Form (活用形)**
7.  **Conjugation Type (活用型)**
8.  **Base Form (原形):** The dictionary form of the word.
9.  **Reading (読み):** Katakana reading.
10. **Pronunciation (発音)**

**If `dict: "unidic"` (18 columns):**

1.  **Surface Form (表層形)**
2.  **POS Major (品詞大分類)**
3.  **POS Medium (品詞中分類)**
4.  **POS Minor (品詞小分類)**
5.  **POS Fine (品詞細分類)**
6.  **Conjugation Type (活用型)**
7.  **Conjugation Form (活用形)**
8.  **Lexeme Reading (語彙素読み)**
9.  **Lexeme (語彙素)**
10. **Orthographic Surface (書字形出現形)**
11. **Phonological Surface (発音形出現形)**
12. **Orthographic Base (書字形基本形)**
13. **Phonological Base (発音形基本形)**
14. **Word Type (語種)**
15. **Initial Mutation Type (語頭変化型)**
16. **Initial Mutation Form (語頭変化形)**
17. **Final Mutation Type (語末変化型)**
18. **Final Mutation Form (語末変化形)**

### `tokenize`

Low-level function that returns the raw JSON data from the WASM plugin. Useful if you want to process the analysis data manually.

```typc
#let tokenize(
  input-text,
  user-dict: none,
  dict: "ipadic"
)
```

**Parameters:**

  - `input-text` (string): The text to tokenize.
  - `user-dict` (string | array | none): Optional user dictionary for custom tokenization.
  - `dict` (string): The dictionary to use. Must be one of: `"ipadic"` or `"unidic"`.

**Returns:** An array of dictionaries containing:

  - `surface` (string): The surface form of the token.
  - `details` (array of strings): The raw detailed information for the token. The content and length depend on the dictionary used (e.g., POS, conjugation, reading, etc.).
  - `ruby_segments` (array of dictionaries): A pre-calculated list of segments for furigana, where each item has `text` and `ruby` fields.

## User Dictionary Format

The user dictionary allows you to define custom word segmentation and readings. It uses a simple CSV format with three columns:

```csv
<surface>,<part_of_speech>,<reading>
```

- `surface`: The word as it appears in text
- `part_of_speech`: Custom part-of-speech label (e.g., "カスタム名詞")
- `reading`: Katakana reading for the word

**Usage Examples:**

**Method 1: Inline string**

```typst
#let user-dict-str = "東京スカイツリー,カスタム名詞,トウキョウスカイツリー
東武スカイツリーライン,カスタム名詞,トウブスカイツリーライン
とうきょうスカイツリー駅,カスタム名詞,トウキョウスカイツリーエキ"

#show-ruby("東京スカイツリーの最寄り駅はとうきょうスカイツリー駅です", user-dict: user-dict-str)
```

**Method 2: Array of arrays**

```typst
#let user-dict-array = (
  ("東京スカイツリー", "カスタム名詞", "トウキョウスカイツリー"),
  ("東武スカイツリーライン", "カスタム名詞", "トウブスカイツリーライン"),
  ("とうきょうスカイツリー駅", "カスタム名詞", "トウキョウスカイツリーエキ")
)

#show-ruby("東京スカイツリーの最寄り駅はとうきょうスカイツリー駅です", user-dict: user-dict-array)
```

**Method 3: Load from CSV file**

```bash
$ cat user_dict.csv
東京スカイツリー,カスタム名詞,トウキョウスカイツリー
東武スカイツリーライン,カスタム名詞,トウブスカイツリーライン
とうきょうスカイツリー駅,カスタム名詞,トウキョウスカイツリーエキ
```

```typst
#let user-dict-from-file = csv("user_dict.csv")

#show-ruby("東京スカイツリーの最寄り駅はとうきょうスカイツリー駅です", user-dict: user-dict-from-file)
```

## Under the Hood

This package uses **Lindera** (a Rust port of Kuromoji) with two available dictionary options:

- **IPADIC**: Standard Japanese morphological dictionary
- **UniDic**: Alternative dictionary with different part-of-speech classifications

The processing workflow:

1. The text is passed from Typst to the Rust WASM plugin.
2. Lindera tokenizes the text using the specified dictionary and retrieves readings.
3. A custom algorithm aligns the readings with the surface form to separate okurigana (kana endings of verbs/adjectives) from the kanji stems.
4. The structured data is returned to Typst and rendered using the `rubby` package for furigana display.

## License

This project is distributed under the AGPL-3.0-or-later License. See [LICENSE](https://www.google.com/search?q=LICENSE) for details.