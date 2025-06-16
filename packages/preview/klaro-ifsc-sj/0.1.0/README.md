# klaro-ifsc-sj

A report Typst template for [IFSC-SJ](https://sj.ifsc.edu.br/). 

## Usage

You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `klaro-ifsc-sj`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/klaro-ifsc-sj
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `report` function with the following named arguments:

- `title`: The reoirt's title as string. This is displayed at the center of the cover page.
- `subtitle`: The report's subtitle as string. This is displayed below the title at the cover page.
- `authors`: The array of authors as strings. Each author is displayed on a separate line at the cover page.
- `date`:  The date of the last revision of the report. This is displayed at the bottom of the cover page.