
[The compiled demo thesis.pdf](./template/thesis.pdf)

# jku-thesis
This is a Typst template for a thesis at JKU.

## Usage
You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `not-JKU-thesis`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/jku-thesis
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `jku-thesis` function with the following named arguments:

- `thesis-type`: String
- `degree`: String
- `program`: String
- `supervisor`: String
- `advisor`: Array of Strings
- `department`: String
- `author`: String
- `date`: datetime
- `place-of-submission`: string
- `title`: String
- `abstract-en`: Content block
- `abstract-de`: optional: Content block or none
- `acknowledgements`: optional: Content block or none
- `show-title-in-header`: Boolean
- `draft`: Boolean

The template will initialize your package with a sample call to the `jku-thesis` function.

The dummy thesis, including the sources, was created by generative AI and is simply meant as a placeholder. The content, citations, and data presented are not based on actual research or verified information. They are intended for illustrative purposes only and should not be considered accurate, reliable, or suitable for any academic, professional, or research use. Any resemblance to real persons, living or dead, or actual research, is purely coincidental. Users are advised to replace all placeholder content with genuine, verified data and references before using this material in any formal or academic context. 


