# Desk Tagger

A Typst template for generating desk name tags for students or attendants.

## What it does

This template reads a CSV file of students and produces a single file with the  desk name tags, one student per page. Each student is printed twice on the page: once normally and once rotated, so name tags can be folded and put standing on the desk.

## Files

- `template/main.typ` — Typst template that loads CSV data and renders each student name tag.
- `tempalte/students.csv` — sample student data used by the template.
- `template/assets/` — assets such as the logo image used in the name tag design.

## Input data

The template expects a CSV file with the following columns:

- `FirstName`
- `LastName`

Example:

```csv
FirstName,MiddleName,LastName
Amara,Mia,Choudhury
Javier,Daniel,Mwangi
Sofia,Ana,Petrov
Kwame,,Nakamura
Leila,Lina,Abdullah
```

Note that in this example there is an extra `MiddleName` column, the template will ignore it.

If your file is named differently, update the `students-data` variable in `template/main.typ`.

## Customize

Inside `template/main.typ`, configure:

- `students-data` — path to your CSV file.
- `logo` — path to the logo image used on each tag.

You can also change fonts, text sizes, and layout by editing the template.


## License

MIT-0
