# exzellenz-tum-thesis
This is a Typst template for a thesis at TU Munich. I made it for my thesis in the School CIT, but I think it can be adapted to other schools as well.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `exzellenz-tum-thesis`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/exzellenz-tum-thesis
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `exzellenz-tum-thesis` function with the following named arguments:

- `degree`: String
- `program`: String
- `school`: String
- `supervisor`: String
- `advisor`: Array of Strings
- `author`: String
- `startDate`: String
- `titleEn`: String
- `titleDe`: String
- `abstractEn`: Content block
- `abstractDe`: Content block
- `acknowledgements`: Content block
- `submissionDate`: String
- `showTitleInHeader`: Boolean
- `draft`: Boolean

The template will initialize your package with a sample call to the `exzellenz-tum-thesis` function.