CUMCM-typst-template is a typst template for China Undergraduate Mathematical Contest in Modeling

## Usage

You can use this template in the Typst web app by clicking “Start from template” on the dashboard and searching for CUMCM-typst-template.

Alternatively, you can use the CLI to kick this project off using the command

```
typst init @preview/CUMCM-typst-template
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `cumcm` function with the following named arguments:

- title: The paper's title.
- problem_chosen: The problem your team chosen.
- team_number: Your team number.
- college_name: The college's name.
- member: The names of your team members.
- advisor: The name of the advisor.
- date: Data of CUMCM
- cover_display: Whether to display the cover.
- abstract: The content is wrapped in '[]'
- keywords: The content is wrapped in ' () ' and separated by ','

The function also accepts a single, positional argument for the body of the paper.

The template will initialize your package with a sample call to the `cumcm` function in a show rule. If you want to change an existing project to use this template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/CUMCM-typst-template:0.1.0": *
#show: thmrules

#show: cumcm.with(
  title: "全国大学生数学建模竞赛 Typst 模板",
  problem_chosen: "A",
  team_number: "1234",
  college_name: " ",
  member: (
    A: " ",
    B: " ",
    C: " ",
  ),
  advisor: " ",
  date: datetime(year: 2023, month: 9, day: 8),

  cover_display: true,

  abstract: [],
  keywords: ("Typst", "模板", "数学建模"),
)

// Your content goes below.
```

## Preview

|  Cover_1 |  Cover_2  |  Content  |
|:---:|:---:|:---:|
| ![Cover_1](https://github.com/a-kkiri/CUMCM-typst-template/blob/38309b04a9edc039def0f7a093eaa640989ccee8/figures/p1.jpg?raw=true) | ![Cover_2](https://github.com/a-kkiri/CUMCM-typst-template/blob/38309b04a9edc039def0f7a093eaa640989ccee8/figures/p2.jpg?raw=true)| ![Content](https://github.com/a-kkiri/CUMCM-typst-template/blob/38309b04a9edc039def0f7a093eaa640989ccee8/figures/p4.jpg?raw=true)|

## Caution

 > The Chinese fonts used in the document contain only about 7,000 common Chinese characters and symbols. If some characters cannot be displayed, please replace them with other fonts.