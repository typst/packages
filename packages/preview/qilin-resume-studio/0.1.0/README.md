# qilin-resume-studio

Data-driven resume and CV layouts with multiple built-in themes.

## Use as a package

```typst
#import "@preview/qilin-resume-studio:0.1.0": resume

#let data = yaml("data.yml")
#show: resume.with(data: data)
```

## Use as a template

```bash
typst init @preview/qilin-resume-studio:0.1.0
```

This creates a starter project with:

- `main.typ`
- `data.yml`
- `img/`

Edit `data.yml` to change resume content.
