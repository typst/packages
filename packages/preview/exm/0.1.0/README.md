Templates and formatting for Data 8's Discussion and Tutoring Worksheets, Reference Sheet, Notes and Exams.

This library was first created for [UC Berkeley's Data 8](https://www.data8.org) in the Fall 2025 semester.


## Features
- automatic point totalling and incrementing sections (for exams or graded assignments)
- multiple choice questions (single select and multiselect, or mix of bubble types)
- answer boxes for long answer questions
- native typst indentation for subquestions
- syntax highlighting for code blocks
- custom answer blank for coding questions
- callouts for notes and information boxes
- assignment and exam template, [see below](#templates)
- togglable document modes (print, screen, answer), [see below](#exporting--accessibility)

Example PDFs can be found in the [`examples/`](./examples) directory and quick start templates in the [`quickstart/`](./quickstart) directory.


<img width="2550" height="1650" alt="1" src="https://github.com/user-attachments/assets/eaf486b0-aca0-4ef9-8c2d-f585a52ea264" />
<img width="2550" height="1650" alt="2" src="https://github.com/user-attachments/assets/a4004aef-b6ac-46a7-b7e0-a9ac734d1d09" />
<img width="2550" height="1650" alt="3" src="https://github.com/user-attachments/assets/ed166836-fd68-4638-87ec-d1cb0d692c8f" />


<hr>

# Documentation

There are three library files: `utils.typ` which defines the different question components and other niceties, `assignment.typ` which formats for assignment documents (worksheets, notes), and `exam.typ` which formats for exams.

**Quick Navigation**:

- [Question Components](#question-components)
    - [Long Answer Questions](#1-long-answer-questions)
    - [Multiple Choice Questions](#2-multiple-choice-questions)
    - [Answer Banks](#3-answer-banks)
- [Sections](#sections)
- [Info / Callouts](#info-blockcallout)
- [Other Utilities](#other-utilities)
- [Templates](#templates)
- [Exporting](#exporting--accessibility)

## Question Components

### 1. **Long answer questions**

Long answer question with an optional answer box/space.

```typst
#question(ansbox, height, ansheight, ansalign, points)[<question>][<answer>]
````

**Parameters**
- **`question`** (`content`, required): question statement
- **`answer`** (`content`, required): answer content
- **`ansbox`** (`bool`, default: `false`): draw a box underneath the question
- **`height`** (`length | auto`, default: `auto`): height of the entire question block
- **`ansheight`** (`length | auto`, default: see notes below): height of the entire question when the answer is shown
- **`ansalign`** (`alignment`, default: `horizon`): alignment of the content
- **`points`** (`float`, default: `""`): points assigned to the question

> **Examples**
> ```typst
> #question(ansbox: true, ansheight: 3cm, points: 4.0)[
>    What is $2 + 2$? Write a statement to evaluate in Python.
>    // since this is just Typst content, it can be anything (could include tables, math, images, code blocks, etc...)
> ][
>    `2 + 2  # 4`
> ]
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 11 58 17" src="https://github.com/user-attachments/assets/e226df70-660b-4ea2-aad4-cdaf18abdac0" /><br>(without answer shown)</p>
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 11 58 42" src="https://github.com/user-attachments/assets/e479fb8b-be28-406a-ab85-1ef1d0dba9be" /><br>(with answer shown)</p>
    
When the answer box is *not* shown, the default `ansheight` is auto (fits to content). When the answer box is shown, the default `ansheight` is the same as the height defined.
You may override `ansheight` to your liking if you don't want this behaviour

<br>
   
### **2. Multiple choice questions**

Multiple choice questions that support different bubble types (circle, box) with optional answer explanations.

```typst
#mcq(question, choices, answer, 
     cols, multi, color,
     ansbox, height, ansheight, ansalign, explanation, points)
````

**Parameters**
- **`question`** (`content`, required): question statement
- **`choices`** (array of `content`, required): choices
- **`answer`** (`int` or array of `int`): **index** (0-indexed) of correct answer choice OR array of correct answer choices
- **`cols`** (`int` or array of `length`, default: `1`): number of answer choice columns. defaults to `1` so options are shown vertically. For horizontal use column count equivalent to number of choices. You may also specify array of lengths, where each length corresponds to the length of that choice displayed horizontally
- **`color`** (`color`, default: `colorblue`): sets color of bubble fill in answer mode
- **`multi`** (`bool` or array of `bool`, default: `false`): display box as square (multi = `true`) or circle (multi = `false`). You may specify an array of booleans to customise each bubble
- **`explanation`** (`content`, default: `""`): an explanation of the selected answer option displayed underneath the question. Only shown when answers are shown
- **`ansbox, height, ansheight, ansalign, points`**: same as `#question` (see above)


> **Examples**
> ```typst
> #mcq([What will the following Python expression be equivalent to?
>      #align(center)[`2 + 2`]
>     ], (
>        `4`,
>         `len(np.array([1, 2, 3, 4]))`,
>        `2`,
>        `6`,
>       "None of the above"
>     ),
>     (0, 1),
>     points: 3.0,
>     multi: (true, true, true, true, false)
> )
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 12 13 59" src="https://github.com/user-attachments/assets/193c19fc-b8bd-47f2-a370-c1100f29b107" /><br>(with answer shown)</p>
> 
> ```typst
> #mcq([You can display options with different column lengths.], (
>       [Option 1], [Option 2], [Option 3], [Option 4]
>      ),
>      2,
>      points: 3.0,
>      multi: false,
>      cols: (2.5cm, 5cm, 7cm, 4cm),
> )
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 16 39 11" src="https://github.com/user-attachments/assets/b4988328-a7bf-40f5-9e73-9bbedc669c9d" /><br>(with answer shown)</p>

<br>


### **3. Answer banks**

A bank of answer choices to select from.

```typst
#ansbank(cols, choices) 
````

**Parameters**
- **`cols`** (`int`, required): number of columns to display answer choices
- **`choices`** (array of `content`, required): choices

> **Examples**
> ```typst
> #ansbank(cols: 3, choices: (
>   [$x^2$], "Any linear function", `x ** 2`,
>   "Any quadratic function", $x dot.c x dot.c x$, `pow(x, 3)`,
>   $sin(x)$, "Any quartic function", $cos(x)$
> ))
> 
> #mcq([
>     What of the following functions are even?
>   ], 
>   range(9).map(i => [*#str.from-unicode(65 + i)*]) + ("None of the above",),
>   (0,2,8),
>   points: 1.0,
>   cols: range(9).map(i => 1.53cm) + (10cm,),
>   multi: range(9).map(i => true) + (false,)
> )
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 16 51 19" src="https://github.com/user-attachments/assets/ff0e7a39-74ad-471c-99dd-dd105fcac4b9" /><br>(with answer shown)</p>



<br>

## Sections

```typst
#section(title, height, number, points, content)
```

**Parameters**
- **`title`** (`int`): number of columns to display answer choices
- **`height`** (`length`, default: `auto`): height of entire section
- **`number`** (`bool`, default: `true`): boolean to automatically count up sections (add `1.`, `2.`, ...etc in front of title)
- **`points`** (`bool`, default: `false`): boolean to count up points in section

> **Examples**
> ```typst
> #section("First Section")[
>   Content in this section does not total up points of sub questions.
> ]
> 
> #v(12pt)
> 
> #section("Second Section", points: true)[
>   Content in this second section does total up points
> 
>   + #question(points:2.0)[Subquestion][Subquestion answer]
>   
>   + #question(points:2.0)[Subquestion][Subquestion answer]
>   
>   + #question(points:2.0)[Subquestion][Subquestion answer]
> ]
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 17 06 16" src="https://github.com/user-attachments/assets/768ea846-dceb-4235-a189-6ffc0b8bb0e3" /></p>

A `#section` will automatically total up all subquestion point values wrapped in that section. You can choose to display this counter in front of the question with the `points` parameter.
If you would like each section to start on a new page, insert a `#pagebreak()` between section blocks.

For exams/worksheets that want all questions to display `points` and `number`, you can use this let statement at the top of the document. This will enable `number` and `points` for every section and you do not need to specify these parameters for each section block.
```typst
#let section = section.with(number: true, points: true)
```


## Info Block/Callout

```typst
#callout(t, content)
```

**Parameters**
- **`t`** (`str`): type of callout. Special callout types are `Definition, Formula, Method, Example`. Use empty string `""` to omit the title.

> **Example**
> ```typst
> #callout("")[
>   You may create a callout with an empty string `""` to omit the title.
>   Any non-special typed callout will be grey by default. 
> ]
> 
> Special callout types (`Definition, Formula, Method, Example`)
> 
> #callout("Definition")[
>   A definition callout
> ]
> 
> #callout("Formula")[
>   A formula callout
> ]
> 
> #callout("Method")[
>   A method callout
> ]
> 
> #callout("Example")[
>   An example callout
> ]
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 18 14 40" src="https://github.com/user-attachments/assets/8de7862e-fc3d-4ca0-b028-6bd95df5b8fe" /></p>


## Coding Blanks

Blanks for coding questions can be used in between code blocks to draw a labelled line for students to fill in.

```typst
#blank(width, placeholder, answer)
```
> **Examples**
> ```typst
> `def distance(p1, p2, row):`
> 
> `    arr = np.array(row)`
> 
> `    v1 = arr.`#blank(150pt, "[A]")
> 
> `    v2 = arr.`#blank(150pt, "[B]")
> 
> `    distances = `#blank(250pt, "[C]")
> 
> `    `#blank(200pt, "[D]")
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 18 27 07" src="https://github.com/user-attachments/assets/196b20e7-edfc-4e2d-b8be-d46698b61549" /></p>


## Other Utilities

### 1. Boxed Math

You can draw boxes (like Latex) around answers with `#boxed(...)`.

> **Example**
> ```typst
> $ y = 1/10x ==> boxed(x = 10 y) $
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 18 32 18" src="https://github.com/user-attachments/assets/c856cdd8-84ad-49a0-84b7-62aa07126ee5" /></p>


### 2. Blank page indicator
Indicator to skip a page / indicate it is blank.

> **Example**
> ```typst
> #blankpage([This page intentionally left blank
> 
>   The exam begins on the next page.
> ])
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 18 33 47" src="https://github.com/user-attachments/assets/e3820523-2355-471d-966f-3fd45a31a9fb" /></p>


### 3. Next page indicator
Indicator to see next page.

> **Example**
> ```typst
> #nextpage([See next page])
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 18 37 17" src="https://github.com/user-attachments/assets/3da15cd7-4eae-4eda-a384-16caf368a95e" /></p>


### 4. Code bubble
```typst
#bubble(content, color)
```

> **Example**
> ```typst
> The #bubble(`def`, colorred) keyword is used for creating functions in Python.
> To return a value in the function, use the #bubble(`return`, colorgreen) keyword.
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 18 43 59" src="https://github.com/user-attachments/assets/484831ff-eca5-4a1d-8e83-a8d61929929a" /></p>




### 5. Subtitle

> **Examples**
> ```typst
> #section("Section Title", number: false)[
>   Some content in the section
>   #subtitle("A smaller title")
>   More stuff
> ]
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 17 24 33" src="https://github.com/user-attachments/assets/216d561c-549c-4877-8765-ca36d563e8fa" /></p>

### 6. Colours

This library provides a few colours that can be used, and are defined as follows:

| colour          | hex       |                                                       |
| --------------- | --------- | ----------------------------------------------------- |
| `colorblue`       | `#2A40E2` | ![#2A40E2](https://readme-swatches.vercel.app/2A40E2) |
| `colorcyan`       | `#6993BF` | ![#6993BF](https://readme-swatches.vercel.app/6993BF) |
| `colorred`        | `#DD4466` | ![#DD4466](https://readme-swatches.vercel.app/DD4466) |
| `colorgreen`      | `#59B279` | ![#59B279](https://readme-swatches.vercel.app/59B279) |
| `colorgrey`       | `#808C80` | ![#808C80](https://readme-swatches.vercel.app/808C80) |
| `colorlightcyan`  | `#E8EDF4` | ![#E8EDF4](https://readme-swatches.vercel.app/E8EDF4) |
| `colorlightred`   | `#F4E8EC` | ![#F4E8EC](https://readme-swatches.vercel.app/F4E8EC) |
| `colorlightgreen` | `#E8F4EC` | ![#E8F4EC](https://readme-swatches.vercel.app/E8F4EC) |
| `colorlightgrey`  | `#F6F6F6` | ![#F6F6F6](https://readme-swatches.vercel.app/F6F6F6) |




<hr>

## Templates

This library provides two templates, one for writing assignments/worksheets, and the other for exams. You can find examples for assignment templates [here (discussion)](./examples/discussion.pdf) and [here (note)](./examples/note.pdf). You can find an example exam [here](./examples/exam.pdf). The quickstart templates for assignments and exams can be found in the [`quickstart/`](./quickstart) directory.

### Assignment

```typst
#show: doc => assignment(doc,
  courseid: "Data C8",
  coursename: "Foundations of Data Science",
  school: "UC Berkeley",
  semester: "Fall 2025",
  assignment: "Discussion 01",
  title: "Introduction"
)
```

### Exam

```typst
#show: doc => exam(doc,
  courseid: "Data C8",
  coursename: "Foundations of Data Science",
  school: "UC Berkeley",
  semester: "Fall 2025",
  instructor: "",
  examtitle: "Midterm",
  date: "7:10–9:00pm  Friday, October 17th 2025",
  length: "110 minutes",

  blanks: ("Your Name", "Your Student ID", "Your Exam Room", "the Name of Person to your Left", "the Name of Person to your Right", "Your GSI's Name (Write N/A if in Self-Service)"),
  instructions: include("instructions.typ"),
  extra: include("extra.typ"),
  sols: false
)
```

The `blanks` parameter allows you to pass in an array of strings that create blanks for students to fill out. `instructions` and `include` take in any content which are filled in inside instructions, and underneath it respectively. You may find creating separate files for `instructions` and `extra` and using `include(...)` to be more modular.




<hr>

## Exporting & Accessibility

There are three document modes to choose from, `screen`, `print`, and `sol`.

1. `screen`: does not display solutions, and code blocks are highlighted with colour
2. `print`: does not display solutions, and all code blocks are displayed as black. Accessible exports so printed code can be easily read on paper.
3. `sol`: displays solutions and code blocks in colour

These can be controlled with the Typst state variable `#docmode` and you can use `.update(mode)` to set the mode at the top of the page, which will affect all components underneath it through to end of page, or another `#docmode.update()` statement.

```typst
#docmode.update(mode)
```


> **Examples**
> ```typst
> #docmode.update("print")
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 19 04 34" src="https://github.com/user-attachments/assets/97158f65-f3fa-4e5f-8cb4-94e92a2b7fef" /></p>
> 
> ```typst
> #docmode.update("screen")
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 19 04 26" src="https://github.com/user-attachments/assets/b9c75a1c-3998-4be7-8858-a8a4af228a55" /></p>
> 
> ```typst
> #docmode.update("sol")
> ```
> <p align="center"><img width=90% alt="Screenshot 2026-01-17 at 19 03 54" src="https://github.com/user-attachments/assets/8b55ee2d-c00a-4546-b9dd-85902b2b98a2" /></p>

