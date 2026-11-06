# Grape Suite

The grape suite is a suite consisting of following templates:

*   exercises (for exams, homeworks, etc.)

*   seminar papers

*   slides (using polylux)

## Exercises

### Setup

```typ
#import "@preview/grape-suite:0.1.0": exercise
#import exercise: project, task, subtask

#show: project.with(
    title: "Lorem ipsum dolor sit",

    university: [University],
    institute: [Institute],
    seminar: [Seminar],

    abstract: lorem(100),
    with-outline: true,

    author: "John Doe",

    show-solutions: false
)
```

### Documentation

| `project`                                |                                                                                                                                                                                                                                                                                            |
| :--------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `no`                                     | optional, number, default: `none`, number of the sheet in the series                                                                                                                                                                                                                       |
| `type`                                   | optional, content, default: `[Exam]`, type of the series, eg. exam, homework, protocol, ...                                                                                                                                                                                                |
| `title`                                  | optional, content, default: `none`, title of the document: if none, then generated from no, type and suffix-title                                                                                                                                                                          |
| `suffix-title`                           | optional, content, default: `none`, used if title is none to generate the title of the document                                                                                                                                                                                            |
| `with-outline`                           | optional, bool, default: `false`, show outline after title iff true                                                                                                                                                                                                                        |
| `abstract`                               | optional, content, default: `none`, show abstract between outline and title                                                                                                                                                                                                                |
| `document-title`                         | optional, content, default: `none`, shown in the upper right corner of the page header: if none, `title` is used                                                                                                                                                                           |
| `show-hints`                             | optional, bool, default: `false`, generate hints from tasks iff true                                                                                                                                                                                                                       |
| `show-solutions`                         | optional, bool, default: `false`, generate solutions from tasks iff true                                                                                                                                                                                                                   |
| `show-namefield`                         | optional, bool, default: `false`, show namefield at the end of the left header iff true                                                                                                                                                                                                    |
| `namefield`                              | optional, content, default: `[Name:]`, content shown iff `show-namefield`                                                                                                                                                                                                                  |
| `show-timefield`                         | optional, bool, default: `false`, show timefield at the end of right header iff true                                                                                                                                                                                                       |
| `timefield`                              | optional, function, default: `(time) => [Time: #time min.]`, to generate the content shown as the timefield iff `show-timefield` is true                                                                                                                                                   |
| `max-time`                               | optional, number, default: `0`, time value used in the `timefield` function generateor                                                                                                                                                                                                     |
| `show-lines`                             | optional, bool, default: `false`, draw automatic lines for each task, if `lines` parameter of `task` is set                                                                                                                                                                                |
| `show-point-distribution-in-tasks`       | optional, bool, default: `false`, show point distribution after tasks iff true                                                                                                                                                                                                             |
| `show-point-distribution-in-solutions`   | optional, bool, default: `false`, show point distributions after solutions iff true                                                                                                                                                                                                        |
| `solutions-as-matrix`                    | optional, bool, default: `false`, show solutions as a matrix iff true, **mind that**: now the solution parameter of task expects a list of 2-tuples, where the first element of the 2-tuple is the amount of points, a number and the second element is content, how to achieve all points |
| `university`                             | optional, content, default: `none`                                                                                                                                                                                                                                                         |
| `faculty`                                | optional, content, default: `none`                                                                                                                                                                                                                                                         |
| `institute`                              | optional, content, default: `none`                                                                                                                                                                                                                                                         |
| `seminar`                                | optional, content, default: `none`                                                                                                                                                                                                                                                         |
| `semester`                               | optional, content, default: `none`                                                                                                                                                                                                                                                         |
| `docent`                                 | optional, content, default: `none`                                                                                                                                                                                                                                                         |
| `author`                                 | optional, content, default: `none`                                                                                                                                                                                                                                                         |
| `date`                                   | optional, datetime, default: `datetime.today()`                                                                                                                                                                                                                                            |
| `header`                                 | optional, content, default: `none`, overwrite page header                                                                                                                                                                                                                                  |
| `header-right`                           | optional, content, default: `none`, overwrite right header part                                                                                                                                                                                                                            |
| `header-middle`                          | optional, content, default: `none`, overwrite middle header part                                                                                                                                                                                                                           |
| `header-left`                            | optional, content, default: `none`, overwrite left header part                                                                                                                                                                                                                             |
| `footer`                                 | optional, content, default: `none`, overwrite footer part                                                                                                                                                                                                                                  |
| `footer-right`                           | optional, content, default: `none`, overwrite right footer part                                                                                                                                                                                                                            |
| `footer-middle`                          | optional, content, default: `none`, overwrite middle footer part                                                                                                                                                                                                                           |
| `footer-left`                            | optional, content, default: `none`, overwrite left footer part                                                                                                                                                                                                                             |
| `task-type`                              | optional, content, default: `[Task]`, content shown in task title box before numbering                                                                                                                                                                                                     |
| `extra-task-type`                        | optional, content, default: `[Extra task]`, for tasks where the `extra` parameter is true, content shown in title box before numbering                                                                                                                                                     |
| `box-task-title`                         | optional, content, default: `[Task]`, shown as the title of a task box used by the `slides` library                                                                                                                                                                                        |
| `box-hint-title`                         | optional, content, default: `[Hint]`, shown as the title of a tasks colored hint box                                                                                                                                                                                                       |
| `box-solution-title`                     | optional, content, default: `[Solution]`, shown as the title of a tasks colored solution box                                                                                                                                                                                               |
| `box-definition-title`                   | optional, content, default: `[Definition]`, shown as the title of a definition box used by the `slides` library                                                                                                                                                                            |
| `box-notice-title`                       | optional, content, default: `[Notice]`, shown as the title of a notice box used by the `slides` library                                                                                                                                                                                    |
| `box-example-title`                      | optional, content, default: `[Example]`, shown as the title of a example box used by the `slides` library                                                                                                                                                                                  |
| `hint-type`                              | optional, content, default: `[Hint]`,  title of a tasks hint version                                                                                                                                                                                                                       |
| `hints-title`                            | optional, content, default: `[Hints]`, title of the hints section                                                                                                                                                                                                                          |
| `solution-type`                          | optional, content, default: `[Suggested solution]`, title of a tasks solution version                                                                                                                                                                                                      |
| `solutions-title`                        | optional, content, default: `[Suggested solutions]`, title of the solutions section                                                                                                                                                                                                        |
| `solution-matrix-task-header`            | optional, content, default: `[Tasks]`, first column header of solution matrix, column contains the reasons on how to achieve the points                                                                                                                                                    |
| `solution-matrix-achieved-points-header` | optional, content, default: `[Points achieved]`, second column header of solution matrix, column contains the points the one achieved                                                                                                                                                      |
| `distribution-header-point-value`        | optional, content, default: `[Point]`, first row of point distribution, used to indicate the points needed to get a specific grade                                                                                                                                                         |
| `distribution-header-point-grade`        | optional, content, default: `[Grade]`, second row of point distribution                                                                                                                                                                                                                    |
| `message`                                | optional, function, default: `(points-sum, extrapoints-sum) => [In sum #points-sum + #extrapoints-sum P. are achievable. You achieved #box(line(stroke: purple, length: 1cm)) out of #points-sum points.]`, used to generate the message part above the point distribution                 |
| `grade-scale`                            | optional, array, default: `(([excellent], 0.9), ([very good], 0.8), ([good], 0.7), ([pass], 0.6), ([fail], 0.49))`, list of grades and percentage of points to reach that grade                                                                                                            |
| `page-margins`                           | optional, default: `none`, overwrite page margins                                                                                                                                                                                                                                          |
| `fontsize`                               | optional, default: `11pt`, overwrite font size                                                                                                                                                                                                                                             |
| `body`                                   | document content                                                                                                                                                                                                                                                                           |

| `task`             |                                                                                                                  |
| :----------------- | :--------------------------------------------------------------------------------------------------------------- |
| `lines`            | optional, default: `0`, number of lines to draw if `show-lines` in exercise's `project` is set to `true`         |
| `points`           | optional, default: `0`, number of points achievable                                                              |
| `extra`            | optional, default: `false`, determines if the task is obligatory (`false`) or additional (`true`)                |
| `numbering-format` | optional, default: `none`,                                                                                       |
| `title`            | title of the task                                                                                                |
| `instruction`      | instruction of the task, highlighted                                                                             |
| `..args`           | 1: task body; 2: task solution, not highlighted (see `solution-as-matrix` of exercise's `project`), 3: task hint |

| `subtask`     |                                                                                                                                |
| :------------ | :----------------------------------------------------------------------------------------------------------------------------- |
| `points`      | optional, default: `0`, points achievable, adds to a tasks point                                                               |
| `tight`       | optional, default: `false`, enum style                                                                                         |
| `markers`     | optional, default: `("1.", "a)")`, numbering format for each level, fallback is `i.`                                           |
| `show-points` | optional, default: `true`, show points next to subtask's body iff `true`                                                       |
| `counter`     | optional, default: `none`, change number styled by the numbering format; if `none`, each level has an incrementel auto counter |
| `content`     | subtask body                                                                                                                   |

***Subtasks are to be use inside of the task's body and inside of a subtask's body.***

## Seminar paper

### Setup

```typ
#import "@preview/grape-suite:0.1.0": seminar-paper

#show: seminar-paper.project.with(
    title: "Die Intensionalität von dass-Sätzen",
    subtitle: "Intensionale Kontexte in philosophischen Argumenten",

    university: [Universität Musterstadt],
    faculty: [Exemplarische Fakultät],
    institute: [Institut für Philosophie],
    docent: [Dr. phil. Berta Beispielprüferin],
    seminar: [Beispielseminar],

    submit-to: [Eingereicht bei],
    submit-by: [Eingereicht durch],

    semester: german-dates.semester(datetime.today()),

    author: "Max Muster",
    email: "max.muster@uni-musterstadt.uni",
    address: [
        12345 Musterstadt \
        Musterstraße 67
    ]
)
```

### Documentation

| `project`                              |                                                                          |
| :------------------------------------- | :----------------------------------------------------------------------- |
| `title`                                | optional, default: `none`, title used on the title page                  |
| `subtitle`                             | optional, default: `none`, subtitle used on title page                   |
| `submit-to`                            | optional, default: `"Submitted to"`, title for the assignees's section   |
| `submit-by`                            | optional, default: `"Submitted by"`, title for the assigned's section    |
| `university`                           | optional, default: `"UNIVERSITY"`                                        |
| `faculty`                              | optional, default: `"FACULTY"`                                           |
| `institute`                            | optional, default: `"INSTITUTE"`                                         |
| `seminar`                              | optional, default: `"SEMINAR"`                                           |
| `semester`                             | optional, default: `"SEMESTER"`                                          |
| `docent`                               | optional, default: `"DOCENT"`                                            |
| `author`                               | optional, default: `"AUTHOR"`                                            |
| `email`                                | optional, default: `"EMAIL"`                                             |
| `address`                              | optional, default: `"ADDRESS"`                                           |
| `title-page-part`                      | optional, default: `none`, overwrite date, assignee and assigned section |
| `title-page-part-submit-date`          | optional, default: `none`, overwrite date section                        |
| `title-page-part-submit-to`            | optional, default: `none`, overwrite assignee section                    |
| `title-page-part-submit-by`            | optional, default: `none`, overwrite assigned section                    |
| `date`                                 | optional, default: `datetime.today()`                                    |
| `date-format`                          | optional, default: `(date) => date.display("[day].[month].[year]")`      |
| `header`                               | optional, content, default: `none`, overwrite page header                |
| `header-right`                         | optional, content, default: `none`, overwrite right header part          |
| `header-middle`                        | optional, content, default: `none`, overwrite middle header part         |
| `header-left`                          | optional, content, default: `none`, overwrite left header part           |
| `footer`                               | optional, content, default: `none`, overwrite footer part                |
| `footer-right`                         | optional, content, default: `none`, overwrite right footer part          |
| `footer-middle`                        | optional, content, default: `none`, overwrite middle footer part         |
| `footer-left`                          | optional, content, default: `none`, overwrite left footer part           |
| `show-declaration-of-independent-work` | optional, default: `true`, show German declaration of independent work   |
| `page-margins`                         | optional, default: `none`, overwrite page margins                        |
| `fontsize`                             | optional, default: `11pt`, overwrite fontsize                            |
| `body`                                 | document content                                                         |

## Slides

### Setup

```typ
#import "@preview/grape-suite:0.1.0": slides
#import slides: *

#show: slides.with(
    no: 1,
    series: [Logik-Tutorium],
    title: [Organisatorisches und Einführung in die Logik],

    author: "Tristan Pieper",
    email: link("mailto:tristan.pieper@uni-rostock.de"),
)
```

### Documentation

| `slides`               |                                                                                            |
| :--------------------- | :----------------------------------------------------------------------------------------- |
| `no`                   | optional, default: `0`, number in the series                                               |
| `series`               | optional, default: `none`, name of the series                                              |
| `title`                | optional, default: `none`, title of the presentation                                       |
| `topics`               | optional, default: `()`, topics of the presentation                                        |
| `author`               | optional, default: `none`, author                                                          |
| `email`                | optional, default: `none`, author's email                                                  |
| `show-semester`        | optional, default: `true`, show name of the semester (e.g. "SoSe 24")                      |
| `show-outline`         | optional, default: `true`, show outline on the second slide                                |
| `box-task-title`       | optional, content, default: `[Task]`, shown as the title of a slide's task box             |
| `box-hint-title`       | optional, content, default: `[Hint]`, shown as the title of a slide's tasks colored        |
| `box-solution-title`   | optional, content, default: `[Solution]`, shown as the title of a slide's tasks colored    |
| `box-definition-title` | optional, content, default: `[Definition]`, shown as the title of a slide's definition box |
| `box-notice-title`     | optional, content, default: `[Notice]`, shown as the title of a slide's notice box         |
| `box-example-title`    | optional, content, default: `[Example]`, shown as the title of a slide's example box       |
| `date`                 | default: `datetime.today()`                                                                |
| `body`                 | document content                                                                           |

*   `slide`, `pause`, `only`, `uncover`: imported from polylux

