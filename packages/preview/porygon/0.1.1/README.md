# porygon

This package uses fontawesome, you should install the font first.

## Usage

```typ
#import "@preview/porygon:0.1.1": show-cv

#let path_json = sys.inputs.at("CV_JSON", default: "cv_data.json")
#let data = json(path_json)
#show-cv(data)
```

## Compilation

```sh
typst compile cv.typ --input CV_LANG=en CV_en.pdf
typst compile cv.typ --input CV_LANG=fr CV_fr.pdf
```

## Typst package

```sh
# compile template
typst compile template/porygon_template.typ

# export thumbnail as png
typst compile -f png --pages 1 --ppi 250 template/porygon_template.typ screenshots/porygon_template.png
oxipng screenshots/porygon_template.png

```

## Lisence

- [MIT](./LICENSE)
