![GitHub Repo stars](https://img.shields.io/github/stars/fine-seat/hm-typst-template?color=fb5454)
![GitHub Release](https://img.shields.io/github/v/release/fine-seat/hm-typst-template?color=fb5454)


# scribbling-hm

Unofficial thesis template for Munich University of Applied Sciences (Hochschule München).

ℹ️ Currently supports FK07 and FK21 (MUC.DAI) theses.

## Getting started

Initialize the project via the Typst CLI:

```bash
typst init @preview/scribbling-hm
```

Or search for ``scribbling-hm`` in the Typst web app under "Start from template".

After initialization, open ``main.typ``, fill in the properties below, and start writing.

### Properties

| Property | Description |
|----------|-------------|
| `title` | The title of your thesis |
| `title-translation` | English translation of the title |
| `language` | Document language (`"de"` or `"en"`, default: `"de"`) |
| `study-name` | Abbreviation of your course of study (default: `study-name.IFB`) |
| `author` | Your full name |
| `gender` | Your gender (`"m"`, `"w"`, `"d"`, or `none`) |
| `student-id` | Your student ID number |
| `birth-date` | Your date of birth (optional) |
| `study-group` | Your study group |
| `semester` | Current semester |
| `supervisors` | Array of supervisor names or single supervisor name |
| `examiner-gender` | Gender of examiner (`"m"`, `"w"`, `"d"`, or `none`) |
| `submission-date` | Date of thesis submission |
| `abstract` | Your thesis abstract |
| `abstract-translation` | Translation of abstract (shown based on `language` setting) |
| `appendix` | Optional appendix content with separate numbering (A, A.1, ...) |
| `blocking` | Enable blocking notice (default: `false`) |
| `enable-header` | Show page headers (default: `true`) |
| `draft` | Enable draft mode (default: `true`) |
| `bib` | Bibliography file reference |
| `abbreviations-list` | Abbreviations for the glossary |
| `variables-list` | Pre-defined variables |
| `print` | Enable print view (default: `false`) |

### Draft mode

If you set ``draft`` to true, your thesis will have written "ENTWURF" all over the place. This will help you to keep track of whether you're finished or not.

Additionally, if you're in draft mode, you can use these helpers:

```typst
#todo[Something to do]
#done()
```

### Variables

The `variables-list` is helpful if you want to pre-define frequently-used phrases, including their formatting. You can use them just like the abbreviations.

IMPORTANT:\
Your keys must be unique across all files (``abbreviations.typ`` and ``variables.typ``)

### Print view

To get a print view, set `print` to true. This adds empty pages, optimizing binding and two sided printing.

### Study name

The `study-name` property controls how your thesis is labeled. Based on the selected value, the following information is derived automatically:

- **Thesis type**: Bachelor's or Master's thesis
- **Academic degree**: "Bachelor of Science" or "Master of Science"
- **Faculty**: The faculty name
- **Study program name**: The full study program name

Abbreviations from: https://hm.edu/studium_1/im_studium/mein_studium/recht/stg_abkuerzungen.de.html
