# fyrst-ru-labreport

This is a template based off of the Reykjavík University [Overleaf template](https://www.overleaf.com/latex/templates/reykjavik-university-physics-lab-report-template/csfdskvychsq) with some Typst specific modifications and omissions (such as not including all the LaTeX macros that Typst has native support for).

## Usage 
```
#import "@preview/fyrst-ru-labreport:0.0.1": *
```

This template exports the `project` function which takes the following optional arguments

- `title`: The title of the project. Default:`[]`
- `course-name`: The name of the relevant course. Default:`[]`
- `course-abrev`: The abbreviation for the course. Default:`[]`
- `organization`: The name of the school. Default:`[]`
- `logo`: The logo to put at the top of the title page Default:The RU logo
- `authors`: an array of the authors, each author is a dictionary which must have a `name` key and can optionally have a `email` key and/or a `phone` key. Default:`none`
- `author-columns`: How many columns to display the authors in. Default:`auto`
- `supervisors`: An array of supervisors of the project, each supervisor is a dictionary of the same form as authros but with an additional key `title`. Default:`none`
- `supervisors-columns`: Same as `author-columns` Default:`auto`
- `bibliography`: The result of a call to the `bibliography`. Default:`none`
- `paper-size`: passed to the page function. Default:`"a4"`
- `lang`: passed to the text function. Default:`"is"`

## Example

```typst
#import "@preview/fyrst-ru-labreport:0.0.1": *

#show: project.with(
  title: [Paper Title],
  course-name: [Course Name],
  course-abrev: [COURSE],
  organization: [Reykjavík University],
  logo:image("Graphics/ru-logo.svg",width:40%),
  authors:(
    (
      name:"Jack Jones",
      email:"jackj@org.com",
    ),
    (
      name:"Jill Jones",
      email:"jillj@org.com",
      phone:"+356-123-4567"
    ),
    (
      name:"Jane Jones",
      email:"janej@org.com"
    ),
    (
      name:"Joe Jones",
      email:"joej@org.com"
    ),
    (
      name:"Juan Jones",
      email:"juanj@org.com"
    )
  ),
  author-columns:3,
  supervisors:(
    (
      name:"Big Man",
      title:"Incharge",
      email:"important@org.com",
      phone:"+001-123-4567"
    ),
    (
      name:"Less Man",
      title:"Middle",
      email:"lessm@org.com",
      phone:none
    ),
  ),
  supervisors-columns:2,
  bibliography:bibliography("bibliography.bib"),
  paper-size:"a4",
  lang:"is", 
)

// Your content here

```

## License 
This template is under a [GPL license](GPL license)
