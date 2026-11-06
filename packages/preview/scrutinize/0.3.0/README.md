# Scrutinize

Scrutinize is a library for building exams, tests, etc. with Typst.
It has three general areas of focus:

- It helps with grading information: record the points that can be reached for each question and make them available for creating grading keys.
- It provides a selection of question writing utilities, such as multiple choice or true/false questions.
- It supports the creation of sample solutions by allowing to switch between the normal and "pre-filled" exam.

Right now, providing a styled template is not part of this package's scope.
Also, visual customization of the provided question templates is currently nonexistent.

See the [manual](docs/manual.pdf) for details.

## Example

<table>
<tr>
  <td>
    <a href="gallery/gk-ek-austria.typ">
      <img src="thumbnail.png">
    </a>
  </td>
  <td>
    <a href="gallery/gk-ek-austria.typ">
      <img src="thumbnail-solved.png">
    </a>
  </td>
</tr>
</table>

This example can be found in the [gallery](gallery/). Here are some excerpts from it:

```typ
#import "@preview/scrutinize:0.3.0" as scrutinize: grading, task, solution, task-kinds
#import task-kinds: free-form, gap, choice
#import task: t

// ... document setup ...

#context {
  let ts = task.all(level: 2)
  let total = grading.total-points(ts)

  let grades = grading.grades(
    [F],
    0.6 * total,
    [D],
    0.7 * total,
    [C],
    0.8 * total,
    [B],
    0.9 * total,
    [A],
  )

  // ... show the grading key ...
}

// ...

= Basic competencies -- theoretical part B

#lorem(40)

== Writing
#t(category: "b", points: 4)
#lorem(30)

#free-form.lines(stretch: 180%, lorem(20))

== Multiple Choice
#t(category: "b", points: 2)
#lorem(30)

#{
  set align(center)
  choice.multiple((
    (lorem(3), true),
    (lorem(5), true),
    (lorem(4), false),
  ))
}
```
