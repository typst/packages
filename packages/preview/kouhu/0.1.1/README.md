# kouhu (口胡)

`kouhu` is a Chinese lipsum text generator for [Typst](https://typst.app). It provides a set of built-in text samples containing both Simplified and Traditional Chinese characters. You can choose from generated fake text, classic or modern Chinese literature, or specify your own text.

`kouhu` is inspired by [zhlipsum](https://ctan.org/pkg/zhlipsum) LaTeX package and [roremu](https://typst.app/universe/package/roremu) Typst package.

All [sample text](data/zhlipsum.json) is excerpted from `zhlipsum` LaTeX package (see Appendix for details).

## Usage

```typst
#import "@preview/kouhu:0.1.0": kouhu

#kouhu(indicies: range(1, 3)) // select the first 3 paragraphs from default text

#kouhu(builtin-text: "zhufu", offset: 5, length: 100) // select 100 characters from the 5th paragraph of "zhufu" text

#kouhu(custom-text: ("Foo", "Bar")) // provide your own text
```

See [manual](https://github.com/Harry-Chen/kouhu/blob/master/doc/manual.pdf) for more details.

## What does `kouhu` mean?

GitHub Copilot says:

> `kouhu` (口胡) is a Chinese term for reading aloud without understanding the meaning. It is often used in the context of learning Chinese language or reciting Chinese literature.

## Changelog

### 0.1.1

* Fix some wrong paths in `README.md`.
* Fix genearation of `indicies` when not specified by user.
* Add repetition of text until `length` is reached.

### 0.1.0

* Initial release.

## Appendix

### Generating `zhlipsum.json`

First download the `zhlipsum-text.dtx` from [CTAN](https://ctan.org/pkg/zhlipsum) or from local TeX Live (`kpsewhich zhlipsum-text.dtx`). Then run:

```bash
python3 utils/generate_zhlipsum.py /path/to/zhlipsum-text.dtx src/zhlipsum.json
```
