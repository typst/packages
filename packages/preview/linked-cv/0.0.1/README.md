# linked-cv

A beautiful CV template that emulates the LinkedIn UI.

## Installation

Simply import the `linked-cv` package and install it using the Typst package manager.

```typ
#import "@preview/linked-cv:0.0.1": *
```

## Usage

Generate started CV by using the `linked-cv` template.

```typ
#show: linked-cv.with(
  firstname: "Your",
  lastname: "Name",
  email: "hello@example.com",
  mobile: "01234 567890",
  github: "your-github-username",
  linkedin: "your-linkedin-username",
)
```

For a fuller example, see the [example/cv.typ](example/cv.typ) file.
