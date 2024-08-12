# Caidan

Caidan (菜单 in Chinese, /cài dān/, meaning food menu) is a clean and minimal food menu template.

See the [example.pdf] file to see how it looks. Additionally, [cu1ch3n/menu] serves as a practical example project utilizing this template.

## Usage

Ensure that [WebOMints GD], [LXGW WenKai], and [Ysabeau Infant] fonts are installed first. The required fonts are provided in [fonts].

To use this template with typst.app, you may upload the required fonts manually (**Note**: [LXGW WenKai] may be too large to upload onto typst.app).

## Configuration

This template includes the `caidan` function, which comes with several configurable named arguments:

| Argument | Default Value | Type | Description |
| --- | --- | --- | --- |
| `title` | `none` | [content] | The title for your menu |
| `cover_image` | `none` | [content] | The image on the menu's cover page |
| `update_date` | `none` | [datetime] | This date will be displayed on the cover page in both Chinese and English |
| `page_height` | `595.28pt` | [length] | Page height of your menu |
| `page_width` | `841.89pt` | [length] | Page width of your menu |
| `num_columns` | `3` | [int] | The number of columns per page |

The function also accepts a single, positional argument for the body.

## Example

```typ
#import "@preview/caidan:0.1.0": *

#show: caidan.with(
  title: [#en_text(22pt, fill: nord0)[Chen's Private Cuisine]],
  cover_image: image("cover.png"),
  update_date: datetime.today(),
  num_columns: 3,
)

#cuisine[鲁菜][Shandong Cuisine]
- #item[葱烧海参][Braised Sea Cucumber w/ Scallions]
- #item[葱爆牛肉][Scallion Beef Stir-Fry]
- #item[醋溜白菜][Napa Cabbage Stir-Fry w/ Vinegar]

#cuisine[川菜][Sichuan Cuisine]
- #item[宫保鸡丁][Gong Bao Chicken]
- #item[回锅肉][Twice-cooked pork]
- #item[麻婆豆腐][Mapo Tofu]
```
[example.pdf]: https://github.com/cu1ch3n/caidan/blob/main/example.pdf
[cu1ch3n/menu]: https://github.com/cu1ch3n/menu
[fonts]: https://github.com/cu1ch3n/caidan/tree/main/fonts
[content]: https://typst.app/docs/reference/foundations/content/
[datetime]: https://typst.app/docs/reference/foundations/datetime/
[length]: https://typst.app/docs/reference/layout/length/
[int]: https://typst.app/docs/reference/foundations/int/
[WebOMints GD]: http://www.galapagosdesign.com/original/webomints.htm
[LXGW WenKai]: https://github.com/lxgw/LxgwWenKai
[Ysabeau Infant]: https://fonts.google.com/specimen/Ysabeau+Infant
