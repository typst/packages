# ifsc-sj-articled

A article Typst template for [IFSC-SJ](https://sj.ifsc.edu.br/). 

## Usage

You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `ifsc-sj-articled`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/ifsc-sj-articled
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `article` function with the following named arguments:

- `title`: The article's title as string. This is displayed at the center of the cover page.
- `subtitle`: The article's subtitle as string. This is displayed below the title at the cover page.
- `authors`: The array of authors as strings. Each author is displayed on a separate line at the cover page.
- `date`:  The date of the last revision of the article. This is displayed at the bottom of the cover page.