# NTUST Thesis Typst Template

臺灣科技大學論文模板。Thesis template for National Taiwan University of Science and Technology.

## Usage

Create a new project using this template:

```shell
typst init @preview/ntust-thesis-unofficial:1.0.0 my-thesis
```

Move into the project directory:

```shell
cd my-thesis
```

Download [NTUST logo](https://www.secretariat.ntust.edu.tw/p/406-1063-85380,r1785.php?Lang=zh-tw) or run the following command to download it directly into the project:

```shell
curl -L -o logo.png "https://www.secretariat.ntust.edu.tw/app/index.php?Action=downloadfile&file=WVhSMFlXTm9Mekl3TDNCMFlWOHpPRE13TkY4M09UTXhPVFUzWHpNMU16YzJMbkJ1Wnc9PQ==&fname=LOGGYSOKRKDCOOYXEDLKIG24FC30TWLK50FGXSMKGG25WWRKDCMKYSTWSSOKCDFCNOWWUT0520FGNK24KOOKQL00
```

Change the logo and fonts in `main.typ` if needed.

```typ
#show: ntust-thesis.with(
  // ...
  // logo: image("logo.png"), // 放入校徽圖片
  // fonts: ("Times New Roman", "DFKai-SB"), // 使用 Window 自帶的字體
  // ...
)
```

And then compile:

```shell
typst compile main.typ
```

### Fonts

Default fonts used in this template:

- [Liberation Serif](https://github.com/liberationfonts/liberation-fonts/releases)
- [教育部標準楷書 (TW-MOE-Std-Kai)](https://language.moe.gov.tw/001/Upload/Files/site_content/M0001/edukai-5.0.zip)

### Logo

There are no clear terms regarding the distribution of the logo, so it's not included in the repository. You can download it from [NTUST official website](https://www.secretariat.ntust.edu.tw/p/406-1063-85380,r1785.php).

## Preview

[main.pdf](https://github.com/8LWXpg/ntust-thesis-unofficial-typst/blob/v1.0.0/build/main.pdf)

## Official NTUST Thesis Format

- [論文上傳步驟說明](https://etheses.lib.ntust.edu.tw/zh-hant/help/aboutedit/)
- [國立臺灣科技大學學位論文撰寫、編排規則及注意事項（112.03.07）](https://etheses.lib.ntust.edu.tw/media/download/ed6370c8-7c81-11ee-b999-0242ac1f0806.pdf)

## Notice

Placeholder text and structure adapted from

- [hadziq/ntust-thesis](https://github.com/hadziq/ntust-thesis)
- [hsiangjenli/ntust-thesis-latex](https://github.com/hsiangjenli/ntust-thesis-latex)

Both licensed under Apache 2.0.
