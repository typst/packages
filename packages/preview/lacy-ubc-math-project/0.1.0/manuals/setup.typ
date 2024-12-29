== Setup
In ```typc setup()```, we define the project details, including the project name, number, flavor, group name, and authors. The displayed title will look like
#align(center)[
  `project` `number`, `flavor`
]
for example,
#align(center)[
  GROUP PROJECT 1, FLAVOUR A
]

Then it is the authors. Since this is a "group project" template, `group` indicates the group name, which will be displayed between the title and the authors.

Finally, `authors`. Each author should be a dictionary with `name` and `id`. The `name` should be a dictionary with `first` and `last`. The `id` should be the student number. Such a dictionary can be created with function ```typc author()```. So, it will look like
```typc
// You are Jane Doe with student number 12345678
author("Jane", "Doe", 12345678),
```
More authors, you ask? Just add more ```typc author()```, separated by commas.

Title and authors made in ```typc setup()``` are converted to PDF metadata, which can be seen in the PDF document properties.

