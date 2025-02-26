# g-exam 

This template provides a way to generate exams. You can create questions and sub-questions, header with information about the academic center, score box, subject, exam, header with student information, clarifications, solutions, watermark with information about the exam model and teacher.

#### Features 

- Scoreboard.
- Scoring by questions and subquestions.
- Student information, on the first page or on all odd pages.
- Question and subcuestion.
- Show solutions and clarifications
- List of clarifications.
- Teacher's Watermark
- Exam Model Watermark
- Draft mode

## Usage 

For information, see the [online docucumentation](https://matheschool.github.io/typst-g-exam/). 

To use this package, simply add the following code to your document:

#### A sample exam

<img src="./gallery/exam-table-content.png" alt="Exam - Table of content" style="width:500px;"/>

#### Source:

```typ
#import "@preview/g-exam:0.4.1": *

#show: exam.with(
  school: (
    name: "Sunrise Secondary School",
    logo: read("./logo.png", encoding: none),
  ),
  exam-info: (
    academic-period: "Academic year 2023/2024",
    academic-level: "1st Secondary Education",
    academic-subject: "Mathematics",
    number: "2nd Assessment 1st Exam",
    content: "Radicals and fractions",
    model: "Model A"
  ),
  
  show-student-data: "first-page",
  show-grade-table: true,
  clarifications: "Answer the questions in the spaces provided. If you run out of room for an answer, continue on the back of the page."
)
#question(points:2.5)[Is it true that $x^n + y^n = z^n$ if $(x,y,z)$ and $n$ are positive integers?. Explain.] 
#v(1fr)

#question(points:2.5)[Prove that the real part of all non-trivial zeros of the function $zeta(z) "is" 1/2$].
#v(1fr)

#question(points:2)[Compute $ integral_0^infinity (sin(x))/x $ ]
#v(1fr)
```

## Changelog

### v0.4.1
- Fix student data.
- Fix Indenting subquestion.

### v0.4.0
- Change g-exam for exam.
- Change g-question and g-subquestion for question and subquestion.
- Change point parameter to points in question and subquestion.
- Change question-points-position paramet to question-points-position.
- Include online documentation.
- Use paper by default.
- Indenting subquestion.
- Include support for dutch language.
- Corrections in English texts. 
- Draft label.

### v0.3.2

- Change show-studen-data to show-student-data parameter.
- Change languaje to language parameter.

### v0.3.1

- Corrections in French.

### v0.3.0

- Include parameter question-text-parameters.
- Show solution.
- Expand documentation.
- Possibility of estrablecer question-point-position to none.
- Bug fix show watermark.

### v0.2.0

- Control the size of the logo image.
- Convert to template
- Allow true and false values in show-student-data.
- Show clarifications.
- Widen margin points.
- Show solution.

### v0.1.1

- Fix loading image.

### v0.1.0

- Initial version submitted to typst/packages.
