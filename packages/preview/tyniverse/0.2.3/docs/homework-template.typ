#import "@preview/tyniverse:0.2.3": homework, template

#show raw.where(block: true): block.with(
  width: 100%,
  fill: luma(93%),
  inset: 5pt,
  spacing: 0.7em,
  breakable: false,
  radius: 0.35em,
)
#set raw(lang: "typc")

#set page(height: auto)
#show: template.with(title: "Homework Template Examples", author-infos: "Fr4nk1in")

`homework.template` is built upon the basic `template` and is designed for homework. It sacrifices some flexibility for a more specialized and convenient interface. For more information about the basic `template`, please refer to its examples.

```typc
let template(
  lang: "en",
  use-patch: true,
  course: "Course Name",
  number: 1,
  transform-title: auto,
  student-infos: ((name: "Student Name", id: "Student ID"),),
  team-name: none,
  body,
) = content
```

- `lang`: `str`, language identifier used in `set text(lang: lang)`
- `use-patch`: `bool` | `(list?: bool, enum?: bool)` \
  whether to use the patch for list and/or enum, default enabled when ignored
- `course`: `str`, course name
- `number`: `int`, homework number
- `transform-title`: `auto` | `(course: str, number: int) => str`:
  title transformation function, default to `auto`, which generates the
  title as `"{course}{hw-literal} {number}"` where `hw-literal` is
  " Homework" in English and "作业" in Chinese
- `student-infos`: `array[(name: str, id: str)]`, list of student names and ids
- `team-name`: `str` | `none`: team name. \
  When set to a string, the team name will be displayed in the header. This is useful when there are multiple students, since the header only handles the case that there is only one student.

In the following, each page is an example of the template with different configurations.

#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: ((name: "Student", id: "1234567890"),),
)

```typ
#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: ((name: "Student", id: "1234567890"),),
)
```


#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: ((name: "Student", id: "1234567890"),),
  team-name: "Team Name",
)

```typ
#import "preview/tyniverse:0.2.3": homework

#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: ((name: "Student", id: "1234567890"),),
  team-name: "Team Name",
)
```


#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: (
    (name: "Student 1", id: "1234567890"),
    (name: "Student 2", id: "2345678901"),
  ),
)

```typ
#import "preview/tyniverse:0.2.3": homework

#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: (
    (name: "Student 1", id: "1234567890"),
    (name: "Student 2", id: "2345678901"),
  ),
)
```


#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: (
    (name: "Student 1", id: "1234567890"),
    (name: "Student 2", id: "2345678901"),
  ),
  team-name: "Team Name",
)

```typ
#import "preview/tyniverse:0.2.3": homework

#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: (
    (name: "Student 1", id: "1234567890"),
    (name: "Student 2", id: "2345678901"),
  ),
  team-name: "Team Name",
)
```


#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: ((name: "Student", id: "1234567890"),),
  transform-title: (course, number) => "Homework " + str(number) + " for " + course,
)

```typ
#show: homework.template.with(
  course: "Math",
  number: 1,
  student-infos: ((name: "Student", id: "1234567890"),),
  transform-title: (course, number) => "Homework " + str(number) + " for " + course,
)
```
