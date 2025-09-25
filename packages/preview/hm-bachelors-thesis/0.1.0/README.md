# HM Typst template

Unofficial computer science Bachelor's thesis template for Munich University of Applied Sciences (Hochschule München).

## Installation
You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for ``hm-bachelors-thesis``.

Alternatively, you can use the CLI to initialize this project using the command:

```bash
typst init @preview/hm-bachelors-thesis
```

## Usage
1. Open the ``main.typ`` file.
2. Customize the properties.
3. Write the content at the bottom of the file.
4. Compile.

### Properties

| Property | Description |
|----------|-------------|
| `title` | The title of your thesis |
| `title-translation` | English translation of the title |
| `author` | Your full name |
| `gender` | Your gender |
| `student-id` | Your student ID number |
| `birth-date` | Your date of birth (optional) |
| `study-group` | Your study group |
| `semester` | Current semester |
| `supervisors` | Array of supervisor names or single supervisor name |
| `supervisor-gender` | Gender of supervisor |
| `submission-date` | Date of thesis submission |
| `abstract-two-langs` | Enable bilingual abstract (default: true) |
| `abstract` | Your thesis abstract |
| `abstract-translation` | English translation of abstract (if bilingual set to true) |
| `blocking` | Enable blocking notice (default: false) |
| `enable-header` | Show page headers (default: true) |
| `draft` | Enable draft mode (default: true) |
| `bib` | Bibliography file reference |

### Draft mode

If you set ``draft`` to true, your thesis will have written "ENTWURF" all over the place. This will help you to keep track of whether you're finished or not.

Additionally, if you're in draft mode, you can set todo texts in your document.

```typst
#todo[Something to do]
```