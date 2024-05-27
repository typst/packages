# ttt-exam


`ttt-exam` is a *template* to create exams and belongs to the [typst-teacher-tools-collection](https://github.com/jomaway/typst-teacher-templates).

## Usage 

Run this command inside your terminal to init a new exam. 

```sh
typst init @preview/ttt-exam my-exam
```

This will scaffold the following folder structure.

```ascii
my-exam/
├─ meta.toml
├─ exam.typ
├─ eval.typ
├─ justfile
└─ logo.jpg
```

Replace the `logo.jpg` with your schools, university, ... logo or remove it. Then edit the `meta.toml`.
Edit the `exam.typ` and replace the questions with your own. If you like you can also remove the `meta.toml` file and specify the values directly inside `exam.typ`

If you have installed [just](https://just.systems) you can use it to build a *student* and *teacher* version of your exam by running `just build`.

Here you can see an example with both versions. On the left the student version and on the right the teachers version.

![Thumbnail with both versions](https://github.com/jomaway/typst-teacher-templates/blob/main/ttt-exam/thumbnail.png)

The `eval.typ` is a template for generating grade lists. You need to add your students to `meta.toml` and add the total amount of points.

## Features

You can pass the following arguments to `exam`

```typ
#let exam(
  // metadata 
  logo: none, // none | image
  title: "exam", // the title of the exam
  subtitle: none, // is shown below the title
  date: none,     // date of the exam, preferred type of datetime.
  class: "",      
  subject: "" ,
  authors: "",  // string | array
  // config
  solution: auto,  // if solutions are displayed can also be specified with `--input solution=true` on the cli.
   cover: true, // true | false
   header: auto, // true | false | auto
   eval-table: false,  // true | false
   appendix: none, // content | none
)
```
