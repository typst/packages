# HTLium

A template for protocolls for higher Technical Colleges for Information Technology.

> *Note: This template is in german*

## Typst

In ``examples/main.typ`` is a example file on how to use my template.

Here the documentation for typst in general: <https://typst.app/docs/>

### Compiler Download

<https://typst.app/open-source/>

## Usage

### Local Package

Copy all files and folders to `~\AppData\Local\typst\packages\{namespace}\{package}\{version}`.
For Example: `~\AppData\Local\typst\packages\local\htlium\1.1.1\`.
Then use it in your file like this:

```typst
#import "@local/htlium:1.1.1": template

#show: body => template(body)
```

The following parameter can be set:

1. `author` string: full fame
2. `class-long` string: center header
3. `logo` image: typst image()
4. `school-year` string: e.g.: 2025/26
5. `title` string: protocol title
6. `subtitle` string: subtitle
7. `task-title` string: task title
8. `task-content` string: task description
9. `class` string: school class
10. `date` string: date of your protocol
11. `subject` string: school subject
12. `school` string: your school name
13. `department` string: your school debartment
14. `teachers` list(string): list of teachers
15. `do-lof` bool: if you want a list of figures
16. `do-lot` bool: if you want a list of tables
17. `do-bib` bool: if you want a bibliography
18. `bib-src` string(path): path to bibliography file
19. `fancy-design` bool: if you want fancy color design

There are standard values for everything, but please change so it fits your document.
