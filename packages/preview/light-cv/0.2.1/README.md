# CV Template in Typst

This is my CV template written in Typst. You can find a two example CVs in this repository as PDFs:

- [English CV](https://github.com/AnsgarLichter/light-cv/blob/main/cv-en.pdf)

## Setup

To use the CV you have to install the font awesome fonts for the icons to work. Please refer to the instructions of the font awesome package itself. You can find these on:
    - [Typst Universe](https://typst.app/universe/package/fontawesome)
    - [GitHub](https://github.com/duskmoon314/typst-fontawesome).

## Functions

1. `header`: Creates a page header including your name, current job title or any other sub title, socials and profile picture
    - `full-name`: your full name
    - `job-title`: your current job title rendered below your name
    - `socials`: array containing all socials. Every social must have the following properties: `icon`, `link` and `text`
    - `profile-picture`: path to your profile picture

2. `section`: Creates a new section, e. g. `Professional Experience` or `Education`
    - `title`: section's title

3. `entry`: Adds an entry / item to the current section
    - `title`: the entry's title, e. g. your job title
    - `company-or-university`: the name of the institution which you were at, e. g. company or university
    - `date`: start and end date of this entry, e. g. 2020 - 2022
    - `location`: describes where you worked, e. g. London, UK
    - `logo`: path to the logo of this entry
    - ``description`: description what you have done - normally supplied as a list

## Customization

In the folder `settings` you will a file `styles.typ` which includes all used styles. You can customize them as you want to.

## Multi Language Support

If you want to add a new language, copy the `cv-en.typ` and rename it. Afterwards you can adapt the text correspondingly. Maybe I will introduce i18n in the future.

## Inspiration

A big thanks to [brilliant-CV](https://github.com/mintyfrankie/brilliant-CV) as this project was an inspiration for my CV and for the scripting.

## Questions & Issues

If you have questions, please create a [discussion](https://github.com/AnsgarLichter/light-cv/discussions).
If you have an issue, please create an [issue](https://github.com/AnsgarLichter/light-cv/issues).
