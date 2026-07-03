# Grape Suite

The grape suite is a suite consisting of following templates:

- exercises (for exams, homework, etc.)

  - essays and minutess

- seminar papers

- slides (using polylux)

## Exercises

Use the `exercise` module to create exercise sheets or exams (or hand in your homework):

<table>
    <tr>
        <td>
            <a href="examples/homework01.typ">
                <img alt="screenshot of a document that represents an exercise sheet with multiple tasks" src="img/homework01-1.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/homework01.typ">
                <img alt="screenshot of a document that represents an exercise sheet with tasks and a highlighted hint for a specific subtask" src="img/homework01-1-hints.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/homework01.typ">
                <img alt="screenshot of a document that represents an exercise sheet with tasks and solutions for two tasks" src="img/homework01-1-solutions.png" width="250px">
            </a>
        </td>
    </tr>
    <tr>
        <td>Tasks</td>
        <td>Hints</td>
        <td>Solutions</td>
    </tr>
</table>

The `exercise` module also supports exams with a titlepage, point distributions and grading rubric:

<table>
    <tr>
        <td>
            <a href="examples/exam03.typ">
                <img alt="screenshot of a document that represents the title page of an exam sheet" src="img/exam03-1.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/exam03.typ">
                <img alt="screenshot of a document that represents an exercise sheet with lines for students to write on" src="img/exam03-2.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/exam03.typ">
                <img alt="screenshot of a document that represents an exercise sheet with a table of criteria that allow transparent grading" src="img/exam03-5.png" width="250px">
            </a>
        </td>
    </tr>
    <tr>
        <td>Title page</td>
        <td>Tasks</td>
        <td>Grading Rubric</td>
    </tr>
</table>

For written minutes and essays see [subtypes module](#subtypes).

### Setup

```typ
#import "@preview/grape-suite:4.0.0": exercise
#import exercise: project, task, subtask

#show: project.with(
    title: "Lorem ipsum dolor sit",

    university: [University],
    institute: [Institute],
    seminar: [Seminar],

    abstract: lorem(100),
    show-outline: true,

    author: "John Doe",

    show-solutions: false
)
```

### Documentation

| `project`                               |                                                                                                                                                                                                                                                                                    |
| :-------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `no`                                    | optional, number, default: `none`, number of the sheet in the series                                                                                                                                                                                                               |
| `type`                                  | optional, content, default: `[Exam]`, type of the series, eg. exam, homework, ...                                                                                                                                                                                                  |
| `title`                                 | optional, content, default: `none`, title of the document: if none, then generated from no, type and suffix-title                                                                                                                                                                  |
| `suffix-title`                          | optional, content, default: `none`, used if title is none to generate the title of the document                                                                                                                                                                                    |
| `show-outline`                          | optional, bool, default: `false`, show outline after title iff true                                                                                                                                                                                                                |
| `abstract`                              | optional, content, default: `none`, show abstract between outline and title                                                                                                                                                                                                        |
| `document-title`                        | optional, content, default: `none`, shown in the upper right corner of the page header: if none, `title` is used                                                                                                                                                                   |
| `show-namefield`                        | optional, bool, default: `false`, show namefield at the end of the left header iff true                                                                                                                                                                                            |
| `namefield`                             | optional, content/array, default: `[Name:]`, content shown iff `show-namefield`; can take an array of strings/content iff `show-titlepage` is true that will be shown on the titlepage                                                                                             |
| `show-timefield`                        | optional, bool, default: `false`, show timefield at the end of right header iff true                                                                                                                                                                                               |
| `timefield`                             | optional, function, default: `(time) => [Time: #time min.]`, to generate the content shown as the timefield iff `show-timefield` is true                                                                                                                                           |
| `max-time`                              | optional, number, default: `0`, time value used in the `timefield` function generator                                                                                                                                                                                              |
| `show-titlepage`                        | optional, bool, default: `false`, generate a title page for the exercise                                                                                                                                                                                                           |
| `show-lines`                            | optional, bool, default: `false`, draw automatic lines for each task, if `lines` parameter of `task` is set                                                                                                                                                                        |
| `show-solutions`                        | optional, bool, default: `false`, will not display solutions iff false                                                                                                                                                                                                             |
| `show-hints`                            | optional, bool, default: `false`, will not display hints iff false                                                                                                                                                                                                                 |
| `show-point-distribution`               | optional, bool, default: `false`, show point distribution after tasks iff true                                                                                                                                                                                                     |
| `show-points-table`                     | optional, bool, default: `false`, show a table of all tasks and their points at the end of the document                                                                                                                                                                            |
| `show-grading-rubric`                   | optional, bool, default: `false`, show solutions as a grading rubric iff true - description of point distribution in each task can be provided through `rubric`                                                                                                                    |
| `university`                            | optional, content, default: `none`                                                                                                                                                                                                                                                 |
| `faculty`                               | optional, content, default: `none`                                                                                                                                                                                                                                                 |
| `institute`                             | optional, content, default: `none`                                                                                                                                                                                                                                                 |
| `seminar`                               | optional, content, default: `none`                                                                                                                                                                                                                                                 |
| `semester`                              | optional, content, default: `none`                                                                                                                                                                                                                                                 |
| `instructor`                            | optional, content, default: `none`                                                                                                                                                                                                                                                 |
| `author`                                | optional, content, default: `none`                                                                                                                                                                                                                                                 |
| `date`                                  | optional, datetime or content, default: `datetime.today()`                                                                                                                                                                                                                         |
| `date-format`                           | optional, function, default: `(date) => if type(date) == type(datetime.today()) { date.display("[day].[month].[year]") } else { date }`                                                                                                                                            |
| `header-gutter`                         | optional, length, default: `20%`, overwrite header gutter                                                                                                                                                                                                                          |
| `header`                                | optional, content, default: `none`, overwrite page header                                                                                                                                                                                                                          |
| `header-right`                          | optional, content, default: `none`, overwrite right header part                                                                                                                                                                                                                    |
| `header-middle`                         | optional, content, default: `none`, overwrite middle header part                                                                                                                                                                                                                   |
| `header-left`                           | optional, content, default: `none`, overwrite left header part                                                                                                                                                                                                                     |
| `show-header-line`                      | optional, bool, default: `true`, show `colors-primary` line in header                                                                                                                                                                                                              |
| `footer`                                | optional, content, default: `none`, overwrite footer part                                                                                                                                                                                                                          |
| `footer-right`                          | optional, content, default: `none`, overwrite right footer part                                                                                                                                                                                                                    |
| `footer-middle`                         | optional, content, default: `none`, overwrite middle footer part                                                                                                                                                                                                                   |
| `footer-left`                           | optional, content, default: `none`, overwrite left footer part                                                                                                                                                                                                                     |
| `show-footer-line`                      | optional, bool, default: `true`, show `colors-primary` line in footer                                                                                                                                                                                                              |
| `task-type`                             | optional, content, default: `[Task]`, content shown in task title box before numbering                                                                                                                                                                                             |
| `extra-task-type`                       | optional, content, default: `[Extra task]`, for tasks where the `extra` parameter is true, content shown in title box before numbering                                                                                                                                             |
| `box-task-title`                        | optional, content, default: `[Task]`, shown as the title of a task box used by the `slides` library                                                                                                                                                                                |
| `box-hint-title`                        | optional, content, default: `[Hint]`, shown as the title of a tasks colored hint box                                                                                                                                                                                               |
| `box-solution-title`                    | optional, content, default: `[Solution]`, shown as the title of a tasks colored solution box                                                                                                                                                                                       |
| `box-definition-title`                  | optional, content, default: `[Definition]`, shown as the title of a definition box used by the `slides` library                                                                                                                                                                    |
| `box-notice-title`                      | optional, content, default: `[Notice]`, shown as the title of a notice box used by the `slides` library                                                                                                                                                                            |
| `box-example-title`                     | optional, content, default: `[Example]`, shown as the title of a example box used by the `slides` library                                                                                                                                                                          |
| `hint-type`                             | optional, content, default: `[Hint]`, title of a tasks hint version                                                                                                                                                                                                                |
| `hints-title`                           | optional, content, default: `[Hints]`, title of the hints section                                                                                                                                                                                                                  |
| `solution-type`                         | optional, content, default: `[Suggested solution]`, title of a tasks solution version                                                                                                                                                                                              |
| `solutions-title`                       | optional, content, default: `[Suggested solutions]`, title of the solutions section                                                                                                                                                                                                |
| `grading-rubric-task-header`            | optional, content, default: `[Tasks]`, first column header of the grading rubric, column contains the reasons on how to achieve the points                                                                                                                                         |
| `grading-rubric-achieved-points-header` | optional, content, default: `[Points achieved]`, second column header the grading rubric, column contains the points the one achieved                                                                                                                                              |
| `show-grading-rubric-comment-field`     | optional, bool, default: `false`, show comment field in the grading rubric                                                                                                                                                                                                         |
| `grading-rubric-comment-field-value`    | optional, content, default: `[*Note:* #v(0.5cm)]`, value of the grading rubric comment fields                                                                                                                                                                                      |
| `distribution-header-point-value`       | optional, content, default: `[Point]`, first row of point distribution, used to indicate the points needed to get a specific grade                                                                                                                                                 |
| `distribution-header-point-grade`       | optional, content, default: `[Grade]`, second row of point distribution                                                                                                                                                                                                            |
| `points-table-header-task`              | optional, content, default: `[Task]`, first row of point distribution                                                                                                                                                                                                              |
| `points-table-header-points`            | optional, content, default: `[Points]`, second row of point distribution                                                                                                                                                                                                           |
| `points-table-header-achieved`          | optional, content, default: `[Achieved]`, third row of point distribution                                                                                                                                                                                                          |
| `message`                               | optional, function, default: `(points-sum, extrapoints-sum) => [In sum #points-sum + #extrapoints-sum P. are achievable. You achieved #box(line(stroke: colors-primary, length: 1cm)) out of #points-sum points.]`, used to generate the message part above the point distribution |
| `grade-scale`                           | optional, array, default: `(([excellent], 0.9), ([very good], 0.8), ([good], 0.7), ([pass], 0.6), ([fail], 0.49))`, list of grades and percentage of points to reach that grade                                                                                                    |
| `page-margins`                          | optional, margins, default: `none`, overwrite page margins                                                                                                                                                                                                                         |
| `text-font`                             | optional, content, default: `("Atkinson Hyperlegible Next", "Atkinson Hyperlegible", "Libertinus Serif")`, overwrite font family for text content                                                                                                                                  |
| `math-font`                             | optional, content, default: `("STIX Two Math", "New Computer Modern Math")`, overwrite font family for math equations                                                                                                                                                              |
| `fontsize`                              | optional, size, default: `11pt`, overwrite font size                                                                                                                                                                                                                               |
| `show-todolist`                         | optional, bool, default: `true`, show list of usages of the `todo` function after the outline                                                                                                                                                                                      |
| `format-links`                          | optional, bool, default: `true`, links are underlined and in primary color iff true                                                                                                                                                                                                |
| `colors-primary`                        | optional, color, default: `purple`, primary color of the document                                                                                                                                                                                                                  |
| `colors-accent`                         | optional, color, default: `blue`, accent color of the document                                                                                                                                                                                                                     |
| `colors-highlight`                      | optional, color, default: `magenta`, highlight color of the document                                                                                                                                                                                                               |
| `colors-warning`                        | optional, color, default: `yellow`, warning color of the document                                                                                                                                                                                                                  |
| `colors-warning-dark`                   | optional, color, default: `brown`, dark version of the warning color of the document                                                                                                                                                                                               |
| `body`                                  | content, document content                                                                                                                                                                                                                                                          |

`task` creates a task element in an exercise project.

| `task`               |                                                                                                                                                                                                         |
| :------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `lines`              | optional, number, default: `0`, number of lines to draw if `show-lines` in exercise's `project` is set to `true`                                                                                        |
| `points`             | optional, number, default: `0`, number of points achievable                                                                                                                                             |
| `extra`              | optional, bool, default: `false`, determines if the task is obligatory (`false`) or additional (`true`)                                                                                                 |
| `numbering-format`   | optional, function, default: `none`,                                                                                                                                                                    |
| `instruction-format` | optional, function, default: `emph`,                                                                                                                                                                    |
| `title-format`       | optional, function, default: `none`,                                                                                                                                                                    |
| `rubric`             | optional, list of tuples, default: `none`, first element has to be the number of points, second the description of what the points are for. sum of points here must be equal to the sum of task points. |
| `title`              | content, title of the task                                                                                                                                                                              |
| `instruction`        | content, instruction of the task, highlighted                                                                                                                                                           |
| `..args`             | 1: content, body of the task                                                                                                                                                                            |

`solution` and `hint` create elements that can be toggled via `exercise`'s `show-solutions` and `show-hints` arguments.

| `solution` |                               |
| :--------- | :---------------------------- |
| `body`     | content, body of the solution |

| `hint` |                           |
| :----- | :------------------------ |
| `hint` | content, body of the hint |

`subtask` creates a part of a task. Its points are added to the parent task. **_Subtasks are to be use inside of the task's body or inside of another subtask's body._**

| `subtask`     |                                                                                                                                         |
| :------------ | :-------------------------------------------------------------------------------------------------------------------------------------- |
| `points`      | optional, number, default: `0`, points achievable, adds to a tasks point                                                                |
| `tight`       | optional, bool, default: `false`, enum style                                                                                            |
| `markers`     | optional, array, default: `("1.", "a)")`, numbering format for each level, fallback is `i.`                                             |
| `show-points` | optional, bool, default: `true`, show points next to subtask's body iff `true`                                                          |
| `counter`     | optional, counter, default: `none`, change number styled by the numbering format; if `none`, each level has an incremental auto counter |
| `content`     | content, subtask body                                                                                                                   |

## Seminar paper

<table>
    <tr>
        <td>
            <a href="examples/seminar-paper01.typ">
                <img alt="screenshot of a document that represents the title page of a paper or essay" src="img/seminar-paper01-1.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/seminar-paper01.typ">
                <img alt="screenshot of a document which shows the outline of a paper or essay" src="img/seminar-paper01-2.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/seminar-paper01.typ">
                <img alt="screenshot of a document that shows formatted text the package can produce" src="img/seminar-paper01-3.png" width="250px">
            </a>
        </td>
    </tr>
    <tr>
        <td>Title page</td>
        <td>Outline</td>
        <td>Body</td>
    </tr>
</table>

_Note:_ The template generates a German statement of authorship as the last page by default. This behavior can be deactivated by using `show-declaration-of-independent-work`.

### Setup

```typ
#import "@preview/grape-suite:4.0.0": seminar-paper

#show: seminar-paper.project.with(
    title: "Die Intensionalität von dass-Sätzen",
    subtitle: "Intensionale Kontexte in philosophischen Argumenten",

    university: [Universität Musterstadt],
    faculty: [Exemplarische Fakultät],
    institute: [Institut für Philosophie],
    instructor: [Dr. phil. Berta Beispielprüferin],
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

| `project`                              |                                                                                                                                                   |
| :------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| `title`                                | optional, content, default: `none`, title used on the title page                                                                                  |
| `subtitle`                             | optional, content, default: `none`, subtitle used on title page                                                                                   |
| `submit-to`                            | optional, content, default: `"Submitted to"`, title for the assignees's section                                                                   |
| `submit-by`                            | optional, content, default: `"Submitted by"`, title for the assigned's section                                                                    |
| `university`                           | optional, content, default: `"UNIVERSITY"`                                                                                                        |
| `faculty`                              | optional, content, default: `"FACULTY"`                                                                                                           |
| `institute`                            | optional, content, default: `"INSTITUTE"`                                                                                                         |
| `seminar`                              | optional, content, default: `"SEMINAR"`                                                                                                           |
| `semester`                             | optional, content, default: `"SEMESTER"`                                                                                                          |
| `instructor`                           | optional, content, default: `"ISNTRUCTOR"`                                                                                                        |
| `author`                               | optional, content, default: `"AUTHOR"`                                                                                                            |
| `student-number`                       | optional, content, default: `none`                                                                                                                |
| `email`                                | optional, content, default: `"EMAIL"`                                                                                                             |
| `address`                              | optional, content, default: `"ADDRESS"`                                                                                                           |
| `title-page-part`                      | optional, content, default: `none`, overwrite date, assignee and assigned section                                                                 |
| `title-page-part-submit-date`          | optional, content, default: `none`, overwrite date section                                                                                        |
| `title-page-part-submit-to`            | optional, content, default: `none`, overwrite assignee section                                                                                    |
| `title-page-part-submit-by`            | optional, content, default: `none`, overwrite assigned section                                                                                    |
| `date`                                 | optional, datetime or content, default: `datetime.today()`                                                                                        |
| `date-format`                          | optional, function, default: `(date) => if type(date) == type(datetime.today()) { date.display("[day].[month].[year]") } else { date }`           |
| `header`                               | optional, content, default: `none`, overwrite page header                                                                                         |
| `header-right`                         | optional, content, default: `none`, overwrite right header part                                                                                   |
| `header-middle`                        | optional, content, default: `none`, overwrite middle header part                                                                                  |
| `header-left`                          | optional, content, default: `none`, overwrite left header part                                                                                    |
| `show-header-line`                     | optional, bool, default: `true`, show `colors-primary` line in header                                                                             |
| `footer`                               | optional, content, default: `none`, overwrite footer part                                                                                         |
| `footer-right`                         | optional, content, default: `none`, overwrite right footer part                                                                                   |
| `footer-middle`                        | optional, content, default: `none`, overwrite middle footer part                                                                                  |
| `footer-left`                          | optional, content, default: `none`, overwrite left footer part                                                                                    |
| `show-footer-line`                     | optional, bool, default: `true`, show `colors-primary` line in footer                                                                             |
| `show-outline`                         | optional, bool, default: `true`, show outline                                                                                                     |
| `show-declaration-of-independent-work` | optional, bool, default: `true`, show German declaration of independent work                                                                      |
| `page-margins`                         | optional, margins, default: `none`, overwrite page margins                                                                                        |
| `text-font`                            | optional, content, default: `("Atkinson Hyperlegible Next", "Atkinson Hyperlegible", "Libertinus Serif")`, overwrite font family for text content |
| `math-font`                            | optional, content, default: `("STIX Two Math", "New Computer Modern Math")`, overwrite font family for math equations                             |
| `fontsize`                             | optional, size, default: `11pt`, overwrite fontsize                                                                                               |
| `show-todolist`                        | optional, bool, default: `true`, show list of usages of the `todo` function after the outline                                                     |
| `box-task-title`                       | optional, content, default: `[Task]`, shown as the title of a slide's task box                                                                    |
| `box-hint-title`                       | optional, content, default: `[Hint]`, shown as the title of a slide's tasks colored                                                               |
| `box-solution-title`                   | optional, content, default: `[Solution]`, shown as the title of a slide's tasks colored                                                           |
| `box-definition-title`                 | optional, content, default: `[Definition]`, shown as the title of a slide's definition box                                                        |
| `box-notice-title`                     | optional, content, default: `[Notice]`, shown as the title of a slide's notice box                                                                |
| `box-example-title`                    | optional, content, default: `[Example]`, shown as the title of a slide's example box                                                              |
| `format-links`                         | optional, bool, default: `true`, links are underlined and in primary color iff true                                                               |
| `colors-primary`                       | optional, color, default: `purple`, primary color of the document                                                                                 |
| `colors-accent`                        | optional, color, default: `blue`, accent color of the document                                                                                    |
| `colors-highlight`                     | optional, color, default: `magenta`, highlight color of the document                                                                              |
| `colors-warning`                       | optional, color, default: `yellow`, warning color of the document                                                                                 |
| `colors-warning-dark`                  | optional, color, default: `brown`, dark version of the warning color of the document                                                              |
| `body`                                 | content, document content                                                                                                                         |

| `sidenote` |                                                                                                         |
| :--------- | :------------------------------------------------------------------------------------------------------ |
| `body`     | sidenote content, which is a block with 3cm width and will be displayed in the right margin of the page |

## Slides

<table>
    <tr>
        <td>
            <a href="examples/slides01.typ">
                <img alt="screenshot of a document that represents the title slide of a series of presentation slides" src="img/slides01-01.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/slides01.typ">
                <img alt="screenshot of the second slide which shows the outline of the presentation" src="img/slides01-02.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/slides01.typ">
                <img alt="screenshot of a content slide with a heading" src="img/slides01-03.png" width="250px">
            </a>
        </td>
    </tr>
    <tr>
        <td>
            <a href="examples/slides01.typ">
                <img alt="screenshot of a content slide with a task box" src="img/slides01-04.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/slides01.typ">
                <img alt="screenshot of a content slide with an example box" src="img/slides01-12.png" width="250px">
            </a>
        </td>
    </tr>
</table>

### Setup

```typ
#import "@preview/grape-suite:4.0.0": slides
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

| `slides`               |                                                                                                                                                                  |
| :--------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `no`                   | optional, number, default: `0`, number in the series                                                                                                             |
| `series`               | optional, content, default: `none`, name of the series                                                                                                           |
| `title`                | optional, content, default: `none`, title of the presentation                                                                                                    |
| `topics`               | optional, array, default: `()`, topics of the presentation                                                                                                       |
| `author`               | optional, content, default: `none`, author                                                                                                                       |
| `email`                | optional, content, default: `none`, author's email                                                                                                               |
| `head-replacement`     | optional, content, default: `none`, replace head on title slide with given content                                                                               |
| `title-replacement`    | optional, content, default: `none`, replace title below head on title slide with given content                                                                   |
| `footer`               | optional, content, default: `none`, replace footer on slides with given content                                                                                  |
| `page-numbering`       | optional, function, default: `(n, total) => {...}`, function that creates the page numbering (where `n` is the current, `total` is the last page)                |
| `show-semester`        | optional, bool, default: `true`, show name of the semester (e.g. "SoSe 24")                                                                                      |
| `show-date`            | optional, bool, default: `true`, show date in german format                                                                                                      |
| `show-outline`         | optional, bool, default: `true`, show outline on the second slide                                                                                                |
| `outline-depth`        | optional, number, default: `1`, maximum heading depth shown in the outline                                                                                       |
| `heading-numbering`    | optional, none/str/function (see [here](https://typst.app/docs/reference/model/heading/#parameters-numbering)), default: `none`, how to number headings          |
| `box-task-title`       | optional, content, default: `[Task]`, shown as the title of a slide's task box                                                                                   |
| `box-hint-title`       | optional, content, default: `[Hint]`, shown as the title of a slide's tasks colored                                                                              |
| `box-solution-title`   | optional, content, default: `[Solution]`, shown as the title of a slide's tasks colored                                                                          |
| `box-definition-title` | optional, content, default: `[Definition]`, shown as the title of a slide's definition box                                                                       |
| `box-notice-title`     | optional, content, default: `[Notice]`, shown as the title of a slide's notice box                                                                               |
| `box-example-title`    | optional, content, default: `[Example]`, shown as the title of a slide's example box                                                                             |
| `date`                 | optional, datetime or content, default: `datetime.today()`                                                                                                       |
| `date-format`          | optional, function, default: `(date) => if type(date) == type(datetime.today()) [#weekday(date.weekday()), #date.display("[day].[month].[year]")] else { date }` |
| `show-todolist`        | optional, bool, default: `true`, show list of usages of the `todo` function after the outline                                                                    |
| `show-title-slide`     | optional, bool, default: `true`, show title slide                                                                                                                |
| `show-author`          | optional, bool, default: `true`, show author name on title slide                                                                                                 |
| `show-footer`          | optional, bool, default: `true`, show footer on slides                                                                                                           |
| `show-page-numbers`    | optional, bool, default: `true`, show page numbering                                                                                                             |
| `outline-title-text`   | optional, content, default: `"Outline"`, title for the outline                                                                                                   |
| `text-font`            | optional, content, default: `("Atkinson Hyperlegible Next", "Atkinson Hyperlegible", "Libertinus Serif")`, overwrite font family for text content                |
| `math-font`            | optional, content, default: `("STIX Two Math", "New Computer Modern Math")`, overwrite font family for math equations                                            |
| `colors-primary`       | optional, color, default: `purple`, primary color of the document                                                                                                |
| `colors-accent`        | optional, color, default: `blue`, accent color of the document                                                                                                   |
| `colors-highlight`     | optional, color, default: `magenta`, highlight color of the document                                                                                             |
| `colors-warning`       | optional, color, default: `yellow`, warning color of the document                                                                                                |
| `colors-warning-dark`  | optional, color, default: `brown`, dark version of the warning color of the document                                                                             |
| `body`                 | content, document content                                                                                                                                        |

| `focus-slide` |                           |
| :------------ | :------------------------ |
| `body`        | content, document content |

- `slide`, `later`, `only`, `uncover`: imported from polylux

## Subtypes

The `subtypes` module contains templates for essays and minutes based on the `exercise` module.

<table>
    <tr>
        <td>
            <a href="examples/essay01.typ">
                <img alt="screenshot of document that represents the first page of an essay" src="img/essay01-1.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/essay01.typ">
                <img alt="screenshot that shows the second page of the essay" src="img/essay01-2.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/essay01.typ">
                <img alt="screenshot that shows the third page of the essay" src="img/essay01-3.png" width="250px">
            </a>
        </td>
    </tr>
    <tr>
        <td>
            <a href="examples/minutes01.typ">
                <img alt="screenshot of a document that represents the minutes of a meeting" src="img/minutes01-1.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/minutes01.typ">
                <img alt="screenshot of the second page of the minutes" src="img/minutes01-2.png" width="250px">
            </a>
        </td>
        <td>
            <a href="examples/minutes01.typ">
                <img alt="screenshot of the third page of the minutes" src="img/minutes01-3.png" width="250px">
            </a>
        </td>
    </tr>
</table>

### Setup

Essay:

```typ
#import "@preview/grape-suite:4.0.0": subtype

#show: subtype.essay.with(
    title: "Lorem ipsum dolor sit",
    university: [University],
    institute: [Institute],
    seminar: [Seminar],
    semester: [Semester],
    instructor: [Instructor],
    author: [Author],
    date: [1#super[st] January 1970],
)
```

Minutes:

```typ
#import "@preview/grape-suite:4.0.0": subtype

#show: subtype.minutes.with(
    title: "Some session's title",
    university: [University],
    institute: [Institute],
    seminar: [Seminar],
    semester: [Semester],
    instructor: [Instructor],
    author: [Author],
    date: [1#super[st] January 1970],
)
```

### Documentation

The base layout of these functions is provided by `exercise.project`.

| `essay`      |                                                   |
| :----------- | :------------------------------------------------ |
| `title`      | optional, content, default: `[#todo[Title]]`      |
| `university` | optional, content, default: `[#todo[University]]` |
| `institute`  | optional, content, default: `[#todo[Institute]]`  |
| `seminar`    | optional, content, default: `[#todo[Seminar]]`    |
| `semester`   | optional, content, default: `[#todo[Semester]]`   |
| `instructor` | optional, content, default: `[#todo[Instructor]]` |
| `author`     | optional, content, default: `[#todo[Author]]`     |
| `date`       | optional, content, default: `[#todo[Date]]`       |
| `body`       | content, document content                         |

| `minutes`    |                                                   |
| :----------- | :------------------------------------------------ |
| `title`      | optional, content, default: `[#todo[Title]]`      |
| `university` | optional, content, default: `[#todo[University]]` |
| `institute`  | optional, content, default: `[#todo[Institute]]`  |
| `seminar`    | optional, content, default: `[#todo[Seminar]]`    |
| `semester`   | optional, content, default: `[#todo[Semester]]`   |
| `instructor` | optional, content, default: `[#todo[Instructor]]` |
| `author`     | optional, content, default: `[#todo[Author]]`     |
| `date`       | optional, content, default: `[#todo[Date]]`       |
| `body`       | content, document content                         |

## Color Customization

All templates support customizable colors to match your institution's branding or personal preferences. You can override the default colors by passing color parameters to any template's setup function.

### Available Color Parameters

- `colors-primary`: Main color for headings, links, and separator lines (default: purple)
- `colors-accent`: Color for task boxes and backgrounds (default: blue)
- `colors-highlight`: Color for definitions, notices, and todos (default: magenta)
- `colors-warning`: Color for hints and examples (default: yellow)
- `colors-warning-dark`: Darker variant for warning text (default: brown)

### Color Usage Map

| Color             | Used For                                           |
| ----------------- | -------------------------------------------------- |
| `primary`         | Headings, links, header/footer lines, focus slides |
| `primary-light`   | Heading numbers, subtitle text                     |
| `accent`          | Task/solution boxes (border)                       |
| `accent-light`    | Task backgrounds, point distribution tables        |
| `accent-lighter`  | Task/solution box backgrounds                      |
| `highlight`       | Definition/notice boxes, todo markers              |
| `highlight-light` | Definition/notice backgrounds, todo highlights     |
| `warning`         | Hint/example boxes (border)                        |
| `warning-light`   | Hint/example backgrounds                           |
| `warning-dark`    | Hint/example title text                            |

### Examples

#### Exercise with Custom Colors

```typ
#import "@preview/grape-suite:4.0.0": exercise
#import exercise: project, task

#show: project.with(
  type: [Exam],
  title: [Mathematics Exam],

  // Custom institutional colors
  colors-primary: rgb("#003366"),    // Dark blue
  colors-accent: rgb("#0066cc"),     // Medium blue
  colors-highlight: rgb("#cc0000"),  // Red
  colors-warning: rgb("#ff9900"),    // Orange
  colors-warning-dark: rgb("#cc6600"),
)

= Problem Set
#task(points: 10, title: [Derivatives])[
  Calculate the derivative of $f(x) = x^2 + 3x + 2$.
]
```

#### Seminar Paper with Custom Colors

```typ
#import "@preview/grape-suite:4.0.0": seminar-paper
#import seminar-paper: project

#show: project.with(
  title: [Research on Color Theory],
  author: [Student Name],

  colors-primary: rgb("#2c3e50"),
  colors-accent: rgb("#3498db"),
  colors-highlight: rgb("#e74c3c"),
)
```

#### Slides with Custom Colors

```typ
#import "@preview/grape-suite:4.0.0": slides
#import slides: *

#show: slides.with(
  series: [Lecture],
  no: 1,
  title: [Introduction],

  colors-primary: rgb("#8b0000"),    // Dark red
  colors-accent: rgb("#4169e1"),     // Royal blue
)
```

### Using Default Colors

If you don't specify color parameters, the templates use the default grape-suite color scheme.

## Todos

The following functions can be imported from `slides`, `exercise` and `seminar-paper`:

- `todo(content, ...)` - create a highlighted inline todo-note
- `list-todos()` - create list of all todo-usages with page of usage and content
- `hide-todos()` - hides all usages of `todo()` in the document

## Elements

The following functions can be imported from `slides`, `exercise` and `seminar-paper`: `definition`

## Citation

This package offers an optional citation style made for internal use. If you're obliged to use the style, configure it like this:

```typ
#import "@preview/grape-suite:4.0.0": citation
#import citation: *

#show: grape-suite-citation

...
```

This configures the new bibliography style. All citations are now fully printed like in bibliography, instead of `@entry` and `cite(<entry>)` use one of the following functions:

- `ct(key, ..a)`: in a footnote, call `ct-full(key, ..a)`.
- `cf(key, ..a)`: in a footnote, call `cf-full(key, ..a)`.
- `ct-full(key, ..a)`: writes full citation, where the first optional positional parameter of `a` is the supplement of the citation, the last positional parameter is a prefix.
- `cf-full(key, ..a)`: calls `ct-full` with a prefix that adds (depending on language) "Vgl." (German) or "Cf." (not German) to citations.

For direct quotes use `ct(key)`, for indirect quotes use `cf(key)`.

# Changelog

With version 3.0.0, the versioning of grape-suite is based on [Semantic Versioning](https://semver.org/) extended for template purposes. Taken into account (next to API compatibility) are the visual results compared to the last version. Thus the major version of the package increases if either the changes of the API are incompatible (so a Typst document from a previous package version might not compile with the new package version) or if visual equivalence to the last version cannot be guaranteed.

## 4.0.0

Fixes:

- the `colors` module does not set `orange`, `red` and `green` to `none`

New:

- supports color themes via the `colors-*` parameters in `exercise`, `seminar-paper` and `slides`
- `slides` now supports the arguments `outline-depth` and `heading-numbering`
- `tasks` now has the arguments `instruction-format`, `title-format` and `rubric`
- `exercise` can generate a per-task point table via `show-points-per-task-table`, translation via:
  - `point-table-header-task`
  - `point-table-header-points`
  - `point-table-header-achieved`
- `exericse`: added argument `show-titlepage`, adjusted `namefield` for this purpose
- `elements`, `tasks` and `todo` can be imported the package for internals
- translated all examples into English

Changes:

- **(breaking)** `task`s and their solutions are now decoupled: the `task` syntax is different, hints and solutions are not generated separately but in place, this affects `show-point-distribution-in-tasks` and `show-point-distribution-in-solutions`, which are renamed to `show-point-distribution`
- **(breaking)** points for grading rubric is now provided by `task`'s `rubric` argument
- **(breaking)** internal functions are now guarded and can't be imported from templates
- **(breaking)** some function and attribute names were translated wrong into English, the following has been changed:
  - solution matrix → graduation rubric, which affects: `exercise.show-solution-matrix`, `exercise.show-solution-matrix-comment-field`, `exercise.solution-matrix-comment-field-value`, `exercise.solution-matrix-task-header` and `exercise.solution-matrix-achieved-points-header`
  - protocol → minutes, which affects: `subtypes.minutes`
  - docent → instructor, which affects: `exercise.project.docent`, `subtypes.procotol.docent` (now `subtypes.minutes`) and `seminar-paper.project.docent`

## 3.1.0

Fixes:

- metadata querying in `todo` and `exercise` (todos and subtasks)
- Readme versioning clarification

New:

- `citation` can be importet from package

## 3.0.0

Fixes:

- `sidenote` in `seminar-paper`

New:

- `subtypes`:
  - `subtypes.essay`
  - `subtypes.minutes`
- `show-header-line` and `show-footer-line` in `exercise.project` and `seminar-paper.project`
- styling for Typst-native `quote` in favor of `blockquote`

Changes:

- `seminar-paper`: adjust `par.leading` to comply with internal requierments (in addition: `par.spacing` and `par.first-line-indent` for aesthetical purposes)
- `blockquote` now just creates a `quote` element with attribution
- `date` (in `seminar-paper`, `exercise` and `slides`) now accepts `content` too
- `big-heading` moved from `tasks` module to `elements` module
- layout of subtasks in `exercise` and `tasks` modules

## 2.0.0

Fixes:

- typos in Readme file

New:

- `math-font` and `text-font` options in `slides`, `exercise.project` and `seminar-paper.project`
- `date-format` in `slides`

**Breaking Changes:**

- updated polylux to 0.4.0: replacing `#pause` in favor of `#show: later`

## 1.0.1

Fixes:

- titles of solutions and hints
- generation of semester name in `german-dates.typ`

New:

- `focus-slide` in `slides`
- `header-gutter` option in `exercise.typ`

## 1.0.0

New:

- `todo`, `list-todos`, `hide-todos` in `todo.typ`, importable from `slides`, `exercise.project` and `seminar-paper.project`
- `show-todolist` attribute in above templates
- `ignore-points` attribute in `task` and `subtask` of exercises, so that their points won't be shown in the grading rubric or point distribution
- comment field and a standard-value for grading rubric via `show-grading-rubric-comment-field` and `grading-rubric-comment-field-value` options in `exercise.project`
- optional parameter `type` in `slides.task`
- new parameters in `slides.slides`:
  - `head-replacement`
  - `title-replacement`
  - `footer`
  - `page-numbering`
  - `show-title-slide`
  - `show-author` (on title slide)
  - `show-date`
  - `show-footer`
  - `show-page-numbers`
- optional parameter `show-outline` in `seminar-paper.project`

Changes:

- `dates.typ` becomes `german-dates.typ`

Fixes:

- remove forced German from the slides template
- long headings are now properly aligned
- subtask counter now resets for each part of task

**Breaking Changes:**

- `dates` becomes `german-dates`
- changed all `with-outline` to `show-outline`
