# academicv

<p align="center">
 <a href="LICENSE">
   <img alt="Apache-2 License" src="https://img.shields.io/badge/license-Apache%202-brightgreen"/>
 </a>
 <a href="https://github.com/roaldarbol/academicv/releases">
   <img alt="Release" src="https://img.shields.io/github/v/release/roaldarbol/academicv"/>
 </a>
</p>

*academicv* is a clean, flexible curriculum vitae (CV) template using Typst and YAML.

## Key Features

- **Highly Customizable**: Easily modify fonts, spacing, colors, and layout through YAML settings
- **Multiple Section Layouts**: Choose from header, prose, timeline, and numbered list layouts - or add your own!
- **Flexible Element System**: Configure primary, secondary, and tertiary elements for each section
- **No Code Modification Required**: Create and customize your CV entirely through YAML configuration
- **Comprehensive Typography Control**: Set different styles for headings, body text, and content elements
- **Toggle Sections**: Easily show/hide sections with a simple parameter

The *academicv* template is designed to be flexible and simple, only requiring editing of the YAML data.

The template as well as the documentation is based on the [*imprecv*](https://github.com/jskherman/imprecv) template - huge thanks goes to [jskherman](https://go.jskherman.com/) for their work. There are some notable differences: (1) a YAML-only approach and (2) the flexible use of elements, which allows users to create their own section types.

## Demo

<table cellspacing="0" style="border-collapse: collapse !important; border-spacing: 0 !important;">
<tr>
 <td>
  <img src="https://github.com/roaldarbol/academicv/raw/main/assets/thumbnail_1.png" alt="Sample CV Page 1">
 </td>
 <td>
  <img src="https://github.com/roaldarbol/academicv/raw/main/assets/thumbnail_2.png" alt="Sample CV Page 2">
 </td>
</tr>
</table>

## Usage

*academicv* is intended to be used by importing the template's [package entrypoint](cv.typ) from a "content" file (see [`template.typ`](template/template.typ) as an example).
In this content file, all data for compiling the CV is loaded from the YAML file (see [`template.yml`](template/template.yml) as an example).

Inside the YAML file you can modify several style (settings) variables and specify the sections you would like to include in your CV.

### With the [Typst CLI](https://github.com/typst/typst)

The recommended usage with the Typst CLI is by running the command `typst init @preview/academicv:1.0.0` in your project directory.
This will create a new Typst project with the `academicv` template and the necessary files to get started.
You can then run `typst compile template.typ` to compile your file to PDF.

### With [typst.app](https://typst.app)

From the Dashboard, select "Start from template", search and choose the `academicv` template.
From there, decide on a name for your project and click "Create".
You can now edit the template files and preview the result on the right.

You can also click the `Create project in app` button in [Typst Universe](https://typst.app/universe/package/academicv) to create a new project with the `academicv` template.

## Contributing
If you would like to contribute to this project, I appreciate bug reports as issues, and am happy to review pull requests, especially for new layout types or settings you would like to be able to configure.