# hand-in

A Typst template for clean and minimalist assignments.

## Usage

You can use this template in the [official web app](https://typst.app/) by clicking "Start from template" on the dashboard and searching for `hand-in`.

Alternatively, you can use the CLI to initialise a new project using this template with the command

```sh
typst init @preview/hand-in
```

This will create a new directory containing the file `main.typ` with a sample call to the `assignment` function in a show rule.

You can also use this template by copying the following to the top of a `.typ` file:

```typ
#import "@preview/hand-in:1.0.0": assignment

// Configure the text font and language, for example, here.

// Configure the template by modifying the below.
#show: assignment.with(
  title: "Assignment 1",
  student: (
    name: "Typst Guy",
    id: 1550003495,
  ),
  subject: (
    name: "Writing with Typst",
    code: "TYP101",
  ),
)

// Start writing here!
```

## Configuration

This template provides the function `assignment` which takes the following arguments:

| Argument  | Type                     | Description                                                                                                                                                                                     |
| --------- | ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `title`   | [str]                    | The assignment's title. This argument is required.                                                                                                                                              |
| `student` | [dictionary]             | The student authoring the assignment. Two keys are expected, `name` with a value of type string and `id` with a value of any type that can be converted to a string. This argument is required. |
| `subject` | [dictionary]             | The subject the assignment is for. Two keys are expected, `name` and `code`, both of whose values are strings. This argument is required.                                                       |
| `date`    | [none] [auto] [datetime] | The assignment's creation date. This argument is optional. The default is `datetime.today()`                                                                                                    |
| `body`    | [content]                | The assignment's content.                                                                                                                                                                       |

[auto]: https://typst.app/docs/reference/foundations/auto/
[content]: https://typst.app/docs/reference/foundations/content/
[datetime]: https://typst.app/docs/reference/foundations/datetime/
[dictionary]: https://typst.app/docs/reference/foundations/dictionary/
[none]: https://typst.app/docs/reference/foundations/none/
[str]: https://typst.app/docs/reference/foundations/str/
