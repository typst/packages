# AI-Ethics TU Vienna
This is a Typst port of the LaTeX template for the AI Ethics course at TU Vienna.

## Usage
Look for the `ai-ethics-tuw` template in the Typst universe, or start locally with:

```sh
typst init @preview/ai-ethics-tuw
```

## Configuration

This is a sample configuration with values taken from the original template:

```typ
#import "@preview/ai-ethics-tuw:1.0.0": *


#show: ai-ethics-template.with(
  title: "This is the title of the paper",
  author: (
    name: "Author",
    number: "Matrikel number",
    email: "Email address",
    course: "Course name"
  ),
  abstract: [
    Abstract of approximately 100-200 words.
  ],
  keywords: ("Keyword1", "keyword2", "...", "keyword(n)")
)
```
